module ProposalTableSpecHelper
  def expect_order(element, proposals)
    content = element.text
    last_idx = content.index(proposals[0].public_id)
    proposals[1..-1].each do |proposal|
      idx = content.index(proposal.public_id)
      expect(idx).to be > last_idx
      last_idx = idx
    end
  end

  def tables
    page.all('.tabular-data')
  end

  def reviewable_proposals_section
    tables[0]
  end

  def pending_proposals_section
    tables[1]
  end

  def cancelled_proposals_section
    tables[1]
  end
end
