module Query
  module Proposal
    class FieldedSearch
      attr_reader :field_pairs

      def initialize(field_pairs)
        @field_pairs = field_pairs
      end

      def present?
        field_pairs && field_pairs.any?
      end

      def value_for(key)
        if field_pairs && field_pairs.has_key?(key)
          field_pairs[key]
        end
      end

      def to_s
        clauses = []
        if field_pairs
          field_pairs.each do |k, v|
            next if v.empty?
            next if v == "*"
            clauses << "#{k}:(#{v})"
          end
        end
        clauses.join(" ")
      end
    end
  end
end
