module ProposalSpecHelper
  def linear_approval_statuses(proposal)
    proposal.individual_steps.pluck(:status)
  end

  def fully_complete(proposal, completer = nil)
    proposal.individual_steps.each do |step|
      step.reload
      step.complete!
      if completer
        step.update(completer: completer)
      end
    end
  end
end
