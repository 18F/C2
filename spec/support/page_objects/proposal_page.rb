class ApproverSection < SitePrism::Section
  element :approver_name, "span.approver"
  element :approver_role, "span.approver_role"
  element :timestamp, "span.timestamp"
end

class StatusSection < SitePrism::Section
  sections :approvers, ApproverSection, ".approval_details .approval-row"
end

class ProposalPage < SitePrism::Page
  set_url "/proposals/{proposal_id}"
  set_url_matcher /\/proposals\/(\d+)?/

  section :status, StatusSection, "#status-container-detail"
end
