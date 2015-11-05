module ClientDataHelper
  def client_data_partial(client_name, path, args = {})
    client_name ||= "default"
    partial_path = "#{client_name}/#{path}"
    default_partial_path = "default/#{path}"

    if lookup_context.template_exists?(partial_path, [], true)
      args[:partial] = partial_path
      render(args)
    elsif lookup_context.template_exists?(default_partial_path, [], true)
      args[:partial] = default_partial_path
      render(args)
    end
  end

  def modify_client_data_button(proposal)
    client_data = proposal.client_data

    if client_data && client_data.editable?
      url = polymorphic_path(client_data, action: :edit)
      link_to "Modify Request", url, class: "form-button modify"
    else
      ""
    end
  end
end
