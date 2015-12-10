module Searchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model

    after_commit on: [:create] do
      delay.reindex
    end

    after_commit on: [:update] do
      #STDERR.puts("UPDATE proposal called from #{caller.join("\n")}")
      delay.reindex
    end

    after_commit on: [:destroy] do
      delay.remove_from_index
    end

    def reindex
      __elasticsearch__.index_document
    end

    def remove_from_index
      __elasticsearch__.destroy_document
    end
  end
end
