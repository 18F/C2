class SummaryController < ApplicationController
  before_action :authorize

  def index
    if current_user.gateway_admin?
      client_namespaces = Proposal.client_slugs.map(&:titleize)
    else
      client_namespaces = [current_user.client_slug.titleize]
    end

    @summaries = client_namespaces.map do |cn|
      ClientSummarizer.new(
        client_namespace: cn,
        fiscal_year: params[:fiscal_year]
      ).run
    end
  end

  private

  def authorize
    if !adminish_role? || (!client_slug? && !current_user.gateway_admin?)
      render "authorization_error", status: 403
    end
  end

  def adminish_role?
    current_user.admin? || current_user.client_admin? || current_user.gateway_admin?
  end

  def client_slug?
    current_user.client_slug.present?
  end
end
