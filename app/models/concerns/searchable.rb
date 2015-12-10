module Searchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model

    # TODO delayed_job hooks
    after_commit on: [:create] do

    end

    after_commit on: [:update] do

    end

    after_commit on: [:destroy] do

    end

    after_commit on: [:touch] do

    end

    def reindex
      __elasticsearch__.index_document
    end

  end
end
