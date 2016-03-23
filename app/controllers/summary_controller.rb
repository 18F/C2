class SummaryController < ApplicationController
  before_action :authorize

  def index
    @summaries = titleized_client_namespaces.map do |cn|
      get_client_summary(cn, params[:fiscal_year])
    end
  end

  private

  def authorize
    if !current_user.any_admin? || (needs_client_slug? && !client_slug?)
      render "authorization_error", status: 403
    end
  end

  def needs_client_slug?
    current_user.client_admin?
  end

  def client_slug?
    current_user.client_slug.present?
  end

  def titleized_client_namespaces
    namespaces = if current_user.client_admin?
                   [current_user.client_slug]
                 else
                   Proposal.client_slugs
                 end
    namespaces.map(&:titleize)
  end

  def get_client_summary(client_namespace, fiscal_year)
    ClientSummarizer.new(
      client_namespace: client_namespace,
      fiscal_year: fiscal_year
    ).run
  end
end
