require "elasticsearch/extensions/test/cluster"

module EsSpecHelper
  def es_mock_bad_gateway
    allow_any_instance_of(Elasticsearch::Transport::Client)
      .to receive(:perform_request)
      .and_raise(Elasticsearch::Transport::Transport::Errors::BadGateway, "oops, can't find ES service")
  end

  def es_mock_connection_failed
    allow_any_instance_of(Elasticsearch::Transport::Client)
      .to receive(:perform_request)
      .and_raise(Faraday::ConnectionFailed, "oops, connection failed")
  end

  def start_es_server
    # circleci has locally installed version of elasticsearch so alter PATH to find
    ENV["PATH"] = "./elasticsearch/bin:#{ENV['PATH']}"

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
    debug { "Rebuilding index for #{klass}..." }
    search = klass.__elasticsearch__
    create search, name: klass.index_name
    import search
    refresh search
  end

  def create(search, name: nil)
    debug { "  Creating index..." }
    search.create_index!(
      # Req'd by https://github.com/elastic/elasticsearch-rails/issues/571
      force: search.index_exists?(index: name),
      index: name
    )
  end

  def import(search)
    debug { "  Importing data..." }
    search.import(return: "errors", batch_size: 200) do |resp|
      # show errors immediately (rather than buffering them)
      errors    = resp["items"].select { |k, _v| k.values.first["error"] }
      completed = resp["items"].size
      debug { "Finished #{completed} items" }
      STDERR.flush
      STDOUT.flush
      if !errors.empty? && ENV["ES_DEBUG"]
        STDOUT.puts "ERRORS in #{$PROCESS_ID}:"
        STDOUT.puts errors.pretty_inspect
      end
    end
  end

  def refresh(search)
    debug { "  Refreshing index..." }
    search.refresh_index!
  end

  # h/t https://devmynd.com/blog/2014-2-dealing-with-failing-elasticserach-tests/
  def es_execute_with_retries(retries = 3)
    begin
      retries -= 1
      yield
    rescue SearchUnavailable => error
      if retries > 0
        sleep 0.5
        retry
      else
        puts "retries: #{retries}"
        raise error
      end
    end
  end

  def debug
    if ENV["ES_DEBUG"]
      puts yield
    end
  end
end

RSpec.configure do |config|
  include EsSpecHelper

  config.before :suite do
    start_es_server unless es_server_running?
    create_es_index(Proposal)
  end

  config.after :suite do
    stop_es_server
  end
end
