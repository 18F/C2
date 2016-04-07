module Searchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model

    after_commit on: [:create] do
      if Rails.env.test?
        self.class.reindexed << self.id
      else
        delay.reindex
      end
    end

    after_commit on: [:update] do
      if Rails.env.test?
        self.class.reindexed << self.id
      else
        delay.reindex
      end
    end

    after_commit on: [:destroy] do
      if Rails.env.test?
        self.class.track_reindex(self, false)
      else
        delay.remove_from_index
      end
    end

    def reindex
      __elasticsearch__.index_document
    end

    def remove_from_index
      __elasticsearch__.destroy_document
    end

    def self.reindexed
      @@reindexed ||= []
    end

    def self.removed_from_index
      @@removed_from_index ||= []
    end

    def self.clear_index_tracking
      @@reindexed = []
      @@removed_from_index = []
    end

    def self.rebuild_index
      stager = index_stager
      indexer(stager).run
      stager.alias_stage_to_tmp_index && stager.promote
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

    private

    def self.index_stager
      Elasticsearch::Rails::HA::IndexStager.new(self.to_s)
    end

    def self.indexer(stager)
      Elasticsearch::Rails::HA::ParallelIndexer.new(
        klass: self.to_s,
        idx_name: stager.tmp_index_name,
        nprocs: ENV.fetch("NPROCS", 1),
        batch_size: ENV.fetch("BATCH", 100),
        force: true,
        verbose: false
      )
    end
  end
end
