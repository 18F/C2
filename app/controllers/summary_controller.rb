class SummaryController < ApplicationController
  def authz_check
    unless current_user.admin? or current_user.client_admin?
      fail "Must be admin to view summary"
    end
    unless current_user.client_slug.present?
      fail "Must have client_slug set to view summary"
    end
  end

  def index
    client_namespace = current_user.client_slug.titleize
    @client_summarizer = ClientSummarizer.new(
      client_namespace: client_namespace, 
      fiscal_year: params[:fiscal_year]
    )
    @summary = @client_summarizer.run
  end
end
