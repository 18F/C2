require 'elasticsearch/extensions/test/cluster'

module EsSpecHelper
  def start_es_server
    # circleci has locally installed version of elasticsearch so alter PATH to find
    ENV["PATH"] = "./elasticsearch/bin:#{ENV["PATH"]}"

    es_test_cluster_opts = {
      nodes: 1,
      path_logs: "tmp/es-logs"
    }

    unless es_server_running?
      Elasticsearch::Extensions::Test::Cluster.start(es_test_cluster_opts)
    end
  end

  def stop_es_server
    if es_server_running?
      Elasticsearch::Extensions::Test::Cluster.stop
    end
  end

  def es_server_running?
    Elasticsearch::Extensions::Test::Cluster.running?
  end

  def create_es_index(klass)
    errors = []
    completed = 0
    #puts "Creating Index for class #{klass}"
    klass.__elasticsearch__.create_index! force: true, index: klass.index_name
    klass.__elasticsearch__.refresh_index!
    klass.__elasticsearch__.import(return: "errors", batch_size: 200) do |resp|
      # show errors immediately (rather than buffering them)
      errors += resp["items"].select { |k, v| k.values.first["error"] }
      completed += resp["items"].size
      #puts "Finished #{completed} items"
      STDERR.flush
      STDOUT.flush
      if ENV["ES_DEBUG"].to_i > 0 && errors.size > 0
        STDOUT.puts "ERRORS in #{$$}:"
        STDOUT.puts errors.pretty_inspect
      end
    end
    puts "Refreshing index for class #{klass}"
    klass.__elasticsearch__.refresh_index!
  end

end

RSpec.configure do |config|
  include EsSpecHelper
  config.before :each, elasticsearch: true do
    start_es_server unless es_server_running?
    create_es_index(Proposal)
  end
  config.after :suite do
    stop_es_server
  end
end
