module Query
  module Proposal
    class FieldedSearch
      attr_reader :field_pairs

      def initialize(field_pairs)
        @field_pairs = field_pairs
      end

      def present?
        return false unless field_pairs
        to_s.present?
      end

      def value_for(key)
        if field_pairs && field_pairs.key?(key)
          field_pairs[key]
        end
      end

      def to_s
        clauses = []
        if field_pairs
          field_pairs.each do |k, v|
            next if v.empty?
            next if v == "*"
            clauses << clause_to_s(k, v)
          end
        end
        clauses.join(" ")
      end

      private

      def clause_to_s(key, value)
        if value.match(/^\w/)
          "#{key}:(#{value})"
        else
          "#{key}:#{value}"
        end
      end
    end
  end
end
