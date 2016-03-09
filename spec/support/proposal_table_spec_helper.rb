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

  def reviewable_proposals_table
    within(reviewable_proposals_section) do
      tables[0]
    end
  end

  def pending_proposals_table
    within(pending_proposals_section) do
      tables[0]
    end
  end

  def cancelled_proposals_table
    within(cancelled_proposals_section) do
      tables[0]
    end
  end

  def reviewable_proposals_section
    "#proposals-pending-review"
  end

  def pending_proposals_section
    "#proposals-pending"
  end

  def cancelled_proposals_section
    "#proposals-cancelled"
  end
end
