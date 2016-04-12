module ClientHelper
  def client_specific_partial(user, partial_path)
    partial = "#{user.client_slug}/#{partial_path}"
    if lookup_context.template_exists?(partial, [], true)
      partial
    else
      "shared/#{partial_path}"
    end
  end

  def modify_client_button(proposal, link_text = "Modify Request", link_class = "form-button modify", disabled = false)
    client_data = proposal.client_data

    if client_data && client_data.editable? && !proposal.canceled?
      url = polymorphic_path(client_data, action: :edit)
      link_to link_text, url, class: link_class, disabled: disabled
    else
      ""
    end
  end
end
