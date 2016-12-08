module ApplicationHelper
  def controller_name
    params[:controller].gsub(/\W/, "-")
  end

  def display_return_to_proposal
    controller.is_a?(ProposalsController) && params[:action] == "history"
  end

  def display_return_to_proposals
    controller.is_a?(ClientDataController) ||
      (controller.is_a?(ProposalsController) && params[:action] != "index")
  end

  def auth_url(provider:)
    {
      cg: "/auth/cg"
    }.fetch(provider)
  end

  def display_profile_warning?
    !current_page?(profile_path) && current_user && current_user.requires_profile_attention?
  end

  def display_search_ui?
    current_user && current_user.client_model && !client_disabled?
  end

  def blank_field_default(field)
    field.blank? ? "--" : field
  end

  def current_proposal_status?(type)
    " active " if !@proposal.nil? && @proposal.status == type
  end

  def new_request_page?
    if (controller.is_a?(Ncr::WorkOrdersController) || controller.is_a?(Gsa18f::ProcurementsController)) && params[:action] == "new"
      "active"
    end
  end

  def new_report_page?
    if controller.is_a?(ReportsController) || controller.is_a?(Ncr::DashboardController) || controller.is_a?(Gsa18f::DashboardController)
      "active"
    end
  end

  def proposal_count(type)
    return 0 if @current_user.nil?

    listing = ProposalListingQuery.new(@current_user, params)
    get_proposal_count(type, listing)
  end

  def get_proposal_count(type, listing)
    case type
    when "pending"
      listing.pending_review.query.count
    when "completed"
      listing.completed.query.count
    when "canceled"
      listing.canceled.query.count
    else
      ""
    end
  end

  def list_view_conditions
    !@current_user.nil? && @current_user.should_see_beta?("BETA_FEATURE_LIST_VIEW")
  end

  def detail_view_conditions
    !@current_user.nil? && @current_user.should_see_beta?("BETA_FEATURE_DETAIL_VIEW")
  end
end
