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
    output_if_debug_true { "Creating Index for class #{klass}" }
    klass.__elasticsearch__.create_index!(force: true, index: klass.index_name)
    klass.__elasticsearch__.refresh_index!
    klass.__elasticsearch__.import(return: "errors", batch_size: 200) do |resp|
      # show errors immediately (rather than buffering them)
      errors += resp["items"].select { |k, v| k.values.first["error"] }
      completed += resp["items"].size
      output_if_debug_true { "Finished #{completed} items" }
      STDERR.flush
      STDOUT.flush
      if errors.size > 0 && ENV["ES_DEBUG"]
        STDOUT.puts "ERRORS in #{$$}:"
        STDOUT.puts errors.pretty_inspect
      end
    end

    output_if_debug_true { "Refreshing index for class #{klass}" }
    klass.__elasticsearch__.refresh_index!
  end

  # h/t https://devmynd.com/blog/2014-2-dealing-with-failing-elasticserach-tests/
  def es_execute_with_retries(retries = 3, &block)
    begin
      retries -= 1
      response = block.call
    rescue Elasticsearch::Transport::Transport::Error => error
      if retries > 0 && error.message.match(/all shards failed/)
        retry
      else
        raise error
      end
    end
  end

  def output_if_debug_true
    if ENV["ES_DEBUG"]
      puts yield
    end
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
