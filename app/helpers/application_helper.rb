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

end
