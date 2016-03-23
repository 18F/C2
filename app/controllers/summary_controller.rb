class SummaryController < ApplicationController
  before_action :authorize

  def index
    client_namespaces = if current_user.gateway_admin?
                          Proposal.client_slugs
                        else
                          [current_user.client_slug]
                        end
                        .map(&:titleize)

    @summaries = client_namespaces.map do |cn|
      get_client_summary(cn, params[:fiscal_year])
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

  def get_client_summary(client_namespace, fiscal_year)
    ClientSummarizer.new(
      client_namespace: client_namespace,
      fiscal_year: fiscal_year
    ).run
  end
end
