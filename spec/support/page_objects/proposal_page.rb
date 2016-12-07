class ApproverSection < SitePrism::Section
  element :name, "span.step-user-name"
  element :role, "span.step-user-role"
  element :timestamp, "span.step-user-status"
end

class StatusSection < SitePrism::Section
  sections :approvers, ApproverSection, ".step-row"
  sections :actionable, ApproverSection, ".step-row.step-status-actionable"
end

class DescriptionSection < SitePrism::Section
  element :submitted, "p.submitted strong span"
  element :submitted_redesign, ".c2n_submitted"
end

class ProposalPage < SitePrism::Page
  set_url "/proposals/{proposal_id}"
  set_url_matcher /\/proposals\/(\d+)?/

  section :status, StatusSection, "#steps-card"
  section :description, DescriptionSection, ".c2_description"
  section :description_redesign, DescriptionSection, ".c2n_description"
end
