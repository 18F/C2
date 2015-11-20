module Ncr
  class Organization
    WHSC_CODE = "P1122021"
    OOL_CODES = [
      "P1171001",
      "P1172001",
      "P1173001"
    ]

    attr_reader :code, :name

    def initialize(code:, name:)
      @code = code
      @name = name
    end

    def to_s
      "#{code} #{name}"
    end

    def ool?
      OOL_CODES.include?(code)
    end

    def whsc?
      code == WHSC_CODE
    end

    def self.all
      Ncr::OrganizationCollection.new.all
    end

    def self.find(code)
      Ncr::OrganizationCollection.new.finder[code]
    end
  end
end
