class ProposalUpdateRecorder
  include ValueHelper

  def initialize(client_data, user)
    @client_data = client_data
    @user = user
  end

  def run
    comment_texts = changed_attributes.map do |key, _value|
      update_comment_format(key)
    end

    if comment_texts.any?
      create_comment(comment_texts)
    end
  end

  private

  attr_accessor :client_data, :user

  def changed_attributes
    @changed_attributes ||= client_data.changed_attributes.except(:updated_at)
  end

  def update_comment_format(key)
    if key =~ /id/
      "#{bullet}*#{association_name(key)}* was changed " + former_association_value(key) + "to #{new_association_value(key)}"
    else
      "#{bullet}*#{property_name(key)}* was changed " + from(key) + "to #{new_value(key)}"
    end
  end

  def bullet
    if changed_attributes.length > 1
      "- "
    else
      ""
    end
  end

  def property_name(key)
    client_data.class.human_attribute_name(key)
  end

  def association_name(key)
    if key == "ncr_organization_id"
      "Org code"
    elsif key == "approving_official_id"
      "Approving official"
    end
  end

  def former_association_value(key)
    if key == "ncr_organization_id"
      former_ncr_organization(key) || ""
    elsif key == "approving_official_id"
      former_approving_official(key) || ""
    end
  end

  def former_ncr_organization(key)
    former_id = former_id(key)
    if former_id.present? && Ncr::Organization.find(former_id)
      "from #{Ncr::Organization.find(former_id).code_and_name} "
    end
  end

  def former_approving_official(key)
    former_id = former_id(key)
    if former_id.present? && User.find(former_id)
      "from #{User.find(former_id).email_address} "
    end
  end

  def former_id(key)
    former_value(key)
  end

  def new_association_value(key)
    if key == "approving_official_id"
      client_data.approving_official.email_address
    elsif key == "ncr_organization_id"
      client_data.ncr_organization.try(:code_and_name) || "*empty*"
    end
  end

  def from(key)
    value = former_value(key)

    if value.present?
      "from #{value} "
    else
      ""
    end
  end

  def new_value(key)
    value = property_to_s(client_data[key])

    if value.empty?
      "*empty*"
    else
      value
    end
  end

  def create_comment(comment_texts)
    if client_data.approved?
      comment_texts << "_Modified post-approval_"
    end

    proposal.comments.create(
      comment_text: comment_texts.join("\n"),
      update_comment: true,
      user: user
    )
  end

  def proposal
    client_data.proposal
  end

  def former_value(key)
    property_to_s(client_data.send(key + "_was"))
  end
end
