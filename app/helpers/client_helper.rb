module ClientHelper
  def client_specific_partial(user, partial_path)
    partial = "#{user.client_slug}/#{partial_path}"
    if lookup_context.template_exists?(partial, [], true)
      partial
    else
      "shared/#{partial_path}"
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
