module Searchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model

    after_commit on: [:create] do
      unless Rails.env.test?
        #STDERR.puts("CREATE proposal called from #{caller.join("\n")}")
        delay.reindex
      end
    end

    after_commit on: [:update] do
      unless Rails.env.test?
        #STDERR.puts("UPDATE proposal called from #{caller.join("\n")}")
        delay.reindex
      end
    end

    after_commit on: [:destroy] do
      unless Rails.env.test?
        #STDERR.puts("DESTROY proposal called from #{caller.join("\n")}")
        delay.remove_from_index
      end
    end

    def reindex
      __elasticsearch__.index_document
    end

    def remove_from_index
      __elasticsearch__.destroy_document
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
