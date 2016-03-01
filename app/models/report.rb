class Report < ActiveRecord::Base
  belongs_to :user

  visitable # Used to track user visit associated with processed report

  def client_query
    ProposalFieldedSearchQuery.new(JSON.parse(query)[user.client_model_slug])
  end

  def text_query
    JSON.parse(query)["text"]
  end

  def humanized_query
    JSON.parse(query)["humanized"]
  end

  def query_string
    if text_query.present? && client_query.present?
      "(#{text_query}) AND (#{client_query})"
    elsif client_query.present?
      "#{client_query}"
    else
      text_query
    end
  end

  def url
    allowed_params = ["text", user.client_model_slug, "from", "size"]
    params = JSON.parse(query).slice(*allowed_params)
    params[:report] = id
    "#{Rails.application.routes.url_helpers.query_proposals_path}?#{params.to_query}"
  end

  def self.sql_for_user(user)
    <<-SQL.gsub(/^ {6}/, "")
      SELECT * FROM reports
      WHERE user_id=#{user.id}
        OR (
          shared=true AND user_id IN (
            SELECT id FROM users WHERE client_slug='#{user.client_slug}'
          )
        )
    SQL
  end

  def self.for_user(user)
    sql = sql_for_user(user)
    self.find_by_sql(sql)
  end
end
