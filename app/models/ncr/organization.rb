module Ncr
  class Organization < ActiveRecord::Base
    WHSC_CODE = "P1122021"
    OOL_CODES = [
      "P1171001",
      "P1172001",
      "P1173001",
    ]

    has_many :ncr_work_orders, class_name: Ncr::WorkOrder, foreign_key: "ncr_organization_id"

    validates :code, presence: true, uniqueness: true
    validates :name, presence: true

    def code_and_name
      "#{code} #{name}"
    end

    def ool?
      OOL_CODES.include?(code)
    end

    def whsc?
      code == WHSC_CODE
    end
  end
end
