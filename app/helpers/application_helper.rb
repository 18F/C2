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

  def auth_path
    "/auth/myusa"
  end

  def display_profile_warning?
    !current_page?(profile_path) && current_user && current_user.requires_profile_attention?
  end

  def display_search_ui?
    current_user && current_user.client_model && !client_disabled?
  end

  def blank_field_default(field)
    if field.blank?
      field = "--".to_s
    end
    field
  end

  def current_proposal_status?(type)
    if @proposal&.status == type
      " active "
    end
  end

  def proposal_count(type)
    if @current_user.nil?
      return 0
    end
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

  def show_beta_layout?
    show_beta_list_view? || show_beta_new_request?
  end

  private

  def show_beta_list_view?
    user_condition = @current_user&.should_see_beta?("BETA_FEATURE_LIST_VIEW")
    action_condition = (params[:action] == "index" || params[:action] == "show")
    controller_condition = (controller_name == "proposals")
    controller_condition && action_condition && user_condition
  end

  def show_beta_new_request?
    controller_name == "ncr-work_orders" &&
      params.fetch(:action) == "new" &&
      @current_user&.should_see_beta?("BETA_NEW_REQUEST")
  end
end
