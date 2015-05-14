module Search
  def self.find_proposals(query)
    # modified from http://blog.lostpropertyhq.com/postgres-full-text-search-is-good-enough/#ranking
    query = <<-SQL
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
      -- TODO sanitize
      WHERE p_search.document @@ plainto_tsquery('english', '#{query}')
      ORDER BY ts_rank(p_search.document, plainto_tsquery('english', '#{query}')) DESC
    SQL

    # feels a bit janky
    Proposal.where("id IN (#{query})")
  end
end
