require "csv"

module Ncr
  # Make sure all table names use "ncr_XXX"
  def self.table_name_prefix
    "ncr_"
  end

  EXPENSE_TYPES = %w(BA60 BA61 BA80)
  BUILDING_NUMBERS = YAML.load_file("#{Rails.root}/config/data/ncr/building_numbers.yml")

  class WorkOrder < ActiveRecord::Base
    # must define before include PurchaseCardMixin
    def self.purchase_amount_column_name
      :amount
    end

    include ClientDataMixin
    include PurchaseCardMixin

    # This is a hack to be able to attribute changes to the correct user. This attribute needs to be set explicitly, then the update comment will use them as the "commenter". Defaults to the requester.
    attr_accessor :modifier

    belongs_to :ncr_organization, class_name: Ncr::Organization
    belongs_to :approving_official, class_name: User

    validates :approving_official, presence: true
    validate :frozen_approving_official_not_changed
    validates :amount, presence: true
    validates :cl_number, format: {
      with: /\ACL\d{7}\z/,
      message: "must start with 'CL', followed by seven numbers"
    }, allow_blank: true
    validates :expense_type, inclusion: { in: EXPENSE_TYPES }, presence: true
    validates :function_code, format: {
      with: /\APG[A-Z0-9]{3}\z/,
      message: "must start with 'PG', followed by three letters or numbers"
    }, allow_blank: true
    validates :project_title, presence: true
    validates :vendor, presence: true
    validates :building_number, presence: true, if: :not_ba60?
    validates :rwa_number, presence: true, if: :ba80?
    validates :rwa_number, format: {
      with: /\A[a-zA-Z][0-9]{7}\z/,
      message: "must be one letter followed by 7 numbers"
    }, allow_blank: true
    validates :soc_code, format: {
      with: /\A[A-Z0-9]{3}\z/,
      message: "must be three letters or numbers"
    }, allow_blank: true

    def self.all_system_approvers
      [
        Ncr::Mailboxes.ba61_tier1_budget_team,
        Ncr::Mailboxes.ba61_tier1_budget,
        Ncr::Mailboxes.ba61_tier2_budget,
        Ncr::Mailboxes.ba80_budget,
        Ncr::Mailboxes.ool_ba80_budget,
      ]
    end

    def fields_for_display
      Ncr::WorkOrderFields.new(self).display
    end

    def approver_email_frozen?
      approval = individual_steps.first
      approval && !approval.actionable?
    end

    def requires_approval?
      !emergency
    end

    def for_whsc_organization?
      ncr_organization.try(:whsc?)
    end

    def for_ool_organization?
      ncr_organization.try(:ool?)
    end

    def ba_6x_tier1_team?
      expense_type.match(/^BA6[01]$/) && ncr_organization.try(:ba_6x_tier1_team?)
    end

    def organization_code_and_name
      ncr_organization.try(:code_and_name)
    end

    def setup_approvals_and_observers
      manager = ApprovalManager.new(self)
      manager.setup_approvals_and_observers
    end

    def current_approver
      if pending?
        currently_awaiting_step_users.first
      elsif approving_official
        approving_official
      elsif emergency and approvers.empty?
        nil
      else
        User.for_email(system_approver_emails.first)
      end
    end

    def final_approver
      if !emergency and approvers.any?
        approvers.last
      end
    end

    def budget_approvals
      individual_steps.offset(1)
    end

    def budget_approvers
      budget_approvals.map(&:completed_by)
    end

    def editable?
      true
    end

    def ba80?
      expense_type == "BA80"
    end

    def ba61?
      expense_type == "BA61"
    end

    def not_ba60?
      expense_type != "BA60"
    end

    def total_price
      amount || 0.0
    end

    # may be replaced with paper-trail or similar at some point
    def version
      updated_at.to_i
    end

    def building_id
      regex = /\A(\w{8}) .*\z/
      if building_number && regex.match(building_number)
        regex.match(building_number)[1]
      else
        building_number
      end
    end

    def name
      project_title
    end

    def public_identifier
      "FY" + fiscal_year.to_s.rjust(2, "0") + "-#{proposal.id}"
    end

    def fiscal_year
      year = created_at.nil? ? Time.zone.now.year : created_at.year
      month = created_at.nil? ? Time.zone.now.month : created_at.month
      if month >= 10
        year += 1
      end
      year % 100   # convert to two-digit
    end

    def restart_budget_approvals
      budget_approvals.each(&:restart!)
      proposal.reset_status
      proposal.root_step.initialize!
    end

    def self.expense_type_options
      EXPENSE_TYPES.map { |expense_type| [expense_type, expense_type] }
    end

    private

    def frozen_approving_official_not_changed
      if persisted? && approving_official_id_changed? && approver_email_frozen?
        errors.add(:approving_official, "Approving official cannot be changed")
      end
    end
  end
end
