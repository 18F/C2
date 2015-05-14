module Search
  def self.find_proposals(query)
    # modified from http://blog.lostpropertyhq.com/postgres-full-text-search-is-good-enough/#ranking
    query = <<-SQL
      SELECT pid
      FROM (
        SELECT
          proposals.id as pid,
          setweight(to_tsvector(to_char(proposals.id, '999')), 'A')
        AS document
        FROM proposals
        GROUP BY proposals.id
      ) p_search
      -- TODO sanitize
      WHERE p_search.document @@ to_tsquery('#{query}')
      ORDER BY ts_rank(p_search.document, to_tsquery('#{query}')) DESC
    SQL

    # feels a bit janky
    Proposal.where("id IN (#{query})")
  end
end
