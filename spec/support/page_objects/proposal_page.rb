class ApproverSection < SitePrism::Section
  element :name, "span.approver"
  element :role, "span.approver-role"
  element :timestamp, "span.timestamp"
end

class StatusSection < SitePrism::Section
  sections :approvers, ApproverSection, ".approval-details .approval-row"
  sections :actionable, ApproverSection, ".step-row.actionable"
end

class DescriptionSection < SitePrism::Section
  element :submitted, "p.submitted strong span"
  element :submitted_redesign, ".c2n_submitted"
end

class ProposalPage < SitePrism::Page
  set_url "/proposals/{proposal_id}"
  set_url_matcher /\/proposals\/(\d+)?/

  section :status, StatusSection, "#status-container-detail"
  section :description, DescriptionSection, ".c2_description"
  section :description_redesign, DescriptionSection, ".c2n_description"
end
