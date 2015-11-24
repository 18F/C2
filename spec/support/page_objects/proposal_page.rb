class ApproverSection < SitePrism::Section
  element :name, "span.approver"
  element :role, "span.approver-role"
  element :timestamp, "span.timestamp"
end

class StatusSection < SitePrism::Section
  sections :approvers, ApproverSection, ".approval-details .approval-row"
end

class ProposalPage < SitePrism::Page
  set_url "/proposals/{proposal_id}"
  set_url_matcher /\/proposals\/(\d+)?/

  section :status, StatusSection, "#status-container-detail"
end
