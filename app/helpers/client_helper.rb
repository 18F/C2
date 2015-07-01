# Contains functions which make client selection/branching easier
module ClientHelper
  def client_partial(client_name, path, args={})
    client_name ||= "default"
    to_check = client_name + "/" + path
    default_check = "default/" + path
    if lookup_context.template_exists?(to_check, [], true)
      args[:partial] = to_check
      render(args)
    elsif lookup_context.template_exists?(default_check, [], true)
      args[:partial] = default_check
      render(args)
    else
      ""
    end
  end

  def modify_client_button(proposal)
    client_data = proposal.client_data_legacy
    if client_data
      # TODO find a better way to check if there's a corresponding edit path
      begin
        url = polymorphic_path(client_data, action: :edit)
      rescue NoMethodError
        ''
      else
        link_to "Modify Request", url, class: 'form-button modify'
      end
    else
      ''
    end
  end
end
