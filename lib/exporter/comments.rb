module Exporter
  class Comments < Exporter::Base
    def headers
      Comment.attributes
    end

    def comments
      self.proposal.comments
    end

    def sorted_comments
      self.comments.order('updated_at ASC')
    end

    def rows
      self.sorted_comments.map do |comment|
        comment.to_a
      end
    end
  end
end
