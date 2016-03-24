class SummaryController < ApplicationController
  before_action :block_non_admins
  before_action :block_client_admins_without_client_slugs

  def index
    @summaries = titleized_client_namespaces.map do |cn|
      get_client_summary(cn, params[:fiscal_year])
    end
  end

  private

  def block_non_admins
    unless current_user.any_admin?
      render "authorization_error", status: 403
    end
  end

  def block_client_admins_without_client_slugs
    if current_user.client_admin? && !client_slug?
      render "authorization_error", status: 403
    end
  end

  def client_slug?
    current_user.client_slug.present?
  end

  def titleized_client_namespaces
    namespaces = if !(current_user.gateway_admin? || current_user.admin?)
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
