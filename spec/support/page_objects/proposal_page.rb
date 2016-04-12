class ProposalApproverSection < SitePrism::Section
  element :name, "span.step-user-name"
  element :role, "span.step-user-role"
  element :timestamp, "span.step-timestamp"
end

class ProposalApprovalsSection < SitePrism::Section
  sections :approvers, ProposalApproverSection, ".step-row"
  sections :actionable, ProposalApproverSection, ".step-row.step-status-actionable"
end

class ProposalDescriptionSection < SitePrism::Section
  element :submitted, "p.submitted strong span"
end

class ProposalPage < SitePrism::Page
  set_url "/proposals/{proposal_id}"
  set_url_matcher /\/proposals\/(\d+)?/

  element :edit_button, "a.request-detail-edit-button"
  element :cancel_button, "a.cancel-request-button"
  element :success_alert, ".alert-success"

  section :status, ProposalApprovalsSection, "#steps-card"
  section :description, ProposalDescriptionSection, ".c2_description"
end
