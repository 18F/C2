class Report < ActiveRecord::Base
  belongs_to :user

  def client_query
    ::Query::Proposal::FieldedSearch.new(JSON.parse(query)[user.client_model_slug])
  end

  def text_query
    JSON.parse(query)["text"]
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

end
