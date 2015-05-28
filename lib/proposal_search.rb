# Query logic modified from
#
#   http://blog.lostpropertyhq.com/postgres-full-text-search-is-good-enough/#ranking
#
# Note that all search computation is done at runtime, so may need to use one or more VIEWs or INDEXes down the road to make it more performant. Query object based on
#
#   http://blog.codeclimate.com/blog/2012/10/17/7-ways-to-decompose-fat-activerecord-models/
#
class ProposalSearch
  attr_reader :relation

  def initialize(proposals=Proposal.all)
    @relation = proposals
  end

  # @todo: this should be a select rather than a join
  def joined
    join = <<-SQL
      INNER JOIN (
        -- TODO handle associations and their properties in a more automated way
        SELECT
          proposals.id AS pid,
          (
            -- need to set empty string as a default for values that can be null, either within the column or by the association not being present
            setweight(to_tsvector(proposals.id::text), 'A') ||
            ---
            -- it's possible to look at all values of a field, but for now, just mimic master
            --    e.g. select string_agg(value, ' ') from json_each_text('{"a":"foo","b":"bar","c":"baz"}'::json)
            setweight(to_tsvector(coalesce(proposals.client_fields->>'project_title', '')), 'B') ||
            setweight(to_tsvector(coalesce(proposals.client_fields->>'description', '')), 'C') ||
            setweight(to_tsvector(coalesce(proposals.client_fields->>'vendor', '')), 'C') ||
            ---
            setweight(to_tsvector(coalesce(proposals.client_fields->>'product_name_and_description', '')), 'B') ||
            setweight(to_tsvector(coalesce(proposals.client_fields->>'justification', '')), 'C') ||
            setweight(to_tsvector(coalesce(proposals.client_fields->>'additional_info', '')), 'C')
          ) AS document
        FROM proposals
      ) p_search
      ON proposals.id = p_search.pid
    SQL

    self.relation.joins(join)
  end

  def with_rank(query)
    sanitized_query = ActiveRecord::Base::sanitize(query)
    rank = <<-SQL
      ts_rank(p_search.document, plainto_tsquery(#{sanitized_query})) AS rank
    SQL

    self.joined.select('*', rank)
  end

  def filtered(query)
    self.with_rank(query).where('p_search.document @@ plainto_tsquery(?)', query)
  end

  def ordered(query)
    self.filtered(query).order('rank DESC')
  end

  def execute(query)
    self.ordered(query)
  end
end
