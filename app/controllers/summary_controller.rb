class SummaryController < ApplicationController
  before_action :authorize
  before_action :check_disabled_client

  def index
    client_namespace = current_user.client_slug.titleize
    @client_summarizer = ClientSummarizer.new(
      client_namespace: client_namespace,
      fiscal_year: params[:fiscal_year]
    )
    @summary = @client_summarizer.run
  end

  private

  def authorize
    if !adminish_role? || !client_slug?
      render "authorization_error", status: 403
    end
  end

  def adminish_role?
    current_user.admin? || current_user.client_admin?
  end

  def client_slug?
    current_user.client_slug.present?
  end
end
