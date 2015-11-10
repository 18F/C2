# Contains functions which make client selection/branching easier
module ClientHelper
  def client_partial(client_slug, path, args={})
    client_slug ||= "default"
    to_check = client_slug + "/" + path
    default_check = "default/" + path

    if lookup_context.template_exists?(to_check, [], true)
      args[:partial] = to_check
      render(args)
    elsif lookup_context.template_exists?(default_check, [], true)
      args[:partial] = default_check
      render(args)
    end
  end

  def modify_client_button(proposal)
    client_data = proposal.client_data

    if client_data && client_data.editable?
      url = polymorphic_path(client_data, action: :edit)
      link_to "Modify Request", url, class: 'form-button modify'
    else
      ""
    end
  end
end
