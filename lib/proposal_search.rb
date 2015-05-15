# http://blog.codeclimate.com/blog/2012/10/17/7-ways-to-decompose-fat-activerecord-models/
class ProposalSearch
  attr_reader :relation

  def initialize(proposals=Proposal.all)
    @relation = proposals
  end

  def execute(query)
    # Modified from
    #
    #   http://blog.lostpropertyhq.com/postgres-full-text-search-is-good-enough/#ranking
    #
    # Note that all search computation is done at runtime, so may need to use one or more VIEWs or INDEXes down the road to make it more performant.

    # TODO sanitize query

    join = <<-SQL
      INNER JOIN (
        -- TODO handle other use case models
        -- TODO handle associations and their properties in a more automated way
        SELECT
          proposals.id AS pid,
          (
            setweight(to_tsvector(to_char(proposals.id, '999')), 'A') ||
            setweight(to_tsvector(coalesce(ncr_work_orders.project_title, '')), 'B')
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

    filter = <<-SQL
      p_search.document @@ plainto_tsquery('#{query}')
    SQL

    ordering = <<-SQL
      ts_rank(p_search.document, plainto_tsquery('#{query}')) DESC
    SQL

    self.relation.joins(join).where(filter).order(ordering)
  end
end
