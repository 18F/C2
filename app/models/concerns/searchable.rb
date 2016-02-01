module Searchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model

    after_commit on: [:create] do
      unless Rails.env.test?
        delay.reindex
      end
    end

    after_commit on: [:update] do
      unless Rails.env.test?
        delay.reindex
      end
    end

    after_commit on: [:destroy] do
      unless Rails.env.test?
        delay.remove_from_index
      end
    end

    def reindex
      __elasticsearch__.index_document
    end

    def remove_from_index
      __elasticsearch__.destroy_document
    end

    def self.rebuild_index
      __elasticsearch__.create_index! force: true
      __elasticsearch__.import
      __elasticsearch__.refresh_index!
    end

    # ransack/meta_search (for activeadmin) and elasticsearch both try and inject a class search() method,
    # so we declare our own and Try To Do the Right Thing
    def self.search(*args, &block)
      if args.first.is_a?(Elasticsearch::DSL::Search) || args.first.is_a?(String)
        return self.__elasticsearch__.search(*args, &block)
      else
        return ransack(*args, &block)
      end
    end
  end
end
