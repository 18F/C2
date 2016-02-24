class DispatchFinder
  def self.run(proposal)
    if proposal.client_slug == "ncr"
      NcrDispatcher.new(proposal)
    else
      Dispatcher.new(proposal)
    end
  end
end
