module Query
  module Proposal
    class FieldedSearch
      attr_reader :field_pairs

      def initialize(field_pairs)
        @field_pairs = field_pairs
      end

      def to_s
        if @field_pairs
          @field_pairs.reject { |k, v| v.empty? }.map { |k, v| "#{k}:(#{v})" }.join(" ")
        else
          ""
        end
      end
    end
  end
end
