module Search
  def self.find_proposals(query)
    # Modified from
    #
    #   http://blog.lostpropertyhq.com/postgres-full-text-search-is-good-enough/#ranking
    #
    # Note that all search computation is done at runtime, so may need to use one or more VIEWs or INDEXes down the road to make it more performant.
    result_set = <<-SQL
      SELECT pid
      FROM (
        -- TODO handle other use case models
        -- TODO handle associations and their properties in a more automated way
        SELECT
          proposals.id AS pid,
          (
            setweight(to_tsvector(to_char(proposals.id, '999')), 'A') ||
            setweight(to_tsvector(coalesce(ncr_work_orders.project_title, '')), 'B')
          ) AS document
        FROM proposals
        LEFT OUTER JOIN ncr_work_orders ON
          ncr_work_orders.id = proposals.client_data_id AND
          proposals.client_data_type = 'Ncr::WorkOrder'
        GROUP BY proposals.id, ncr_work_orders.id
      ) p_search
      WHERE p_search.document @@ plainto_tsquery(:query)
      ORDER BY ts_rank(p_search.document, plainto_tsquery(:query)) DESC
    SQL

    # feels a bit janky
    Proposal.where("id IN (#{result_set})", query: query)
  end
end
