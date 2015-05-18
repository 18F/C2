# Query logic modified from
#
#   http://blog.lostpropertyhq.com/postgres-full-text-search-is-good-enough/#ranking
#
# Note that all search computation is done at runtime, so may need to use one or more VIEWs or INDEXes down the road to make it more performant. Query object based on
#
#   http://blog.codeclimate.com/blog/2012/10/17/7-ways-to-decompose-fat-activerecord-models/
#
# TODO sanitize query
class ProposalSearch
  attr_reader :relation

  def initialize(proposals=Proposal.all)
    @relation = proposals
  end

  def joined
    join = <<-SQL
      INNER JOIN (
        -- TODO handle other use case models
        -- TODO handle associations and their properties in a more automated way
        SELECT
          proposals.id AS pid,
          (
            setweight(to_tsvector(proposals.id::text), 'A') ||
            -- need to set empty string as a default for values that can be null, either within the column or by the association not being present
            setweight(to_tsvector(coalesce(ncr_work_orders.project_title, '')), 'B') ||
            setweight(to_tsvector(coalesce(ncr_work_orders.description, '')), 'C') ||
            setweight(to_tsvector(coalesce(ncr_work_orders.vendor, '')), 'C')
            -- TODO handle additional properties
          ) AS document
        FROM proposals
        LEFT OUTER JOIN ncr_work_orders ON
          ncr_work_orders.id = proposals.client_data_id AND
          proposals.client_data_type = 'Ncr::WorkOrder'
        GROUP BY proposals.id, ncr_work_orders.id
      ) p_search
      ON proposals.id = p_search.pid
    SQL

    self.relation.joins(join)
  end

  def filtered(query)
    filter = <<-SQL
      p_search.document @@ plainto_tsquery('#{query}')
    SQL

    self.joined.where(filter)
  end

  def ordered(query)
    ordering = <<-SQL
      ts_rank(p_search.document, plainto_tsquery('#{query}')) DESC
    SQL

    self.filtered(query).order(ordering)
  end

  def execute(query)
    self.ordered(query)
  end
end
