describe 'Version check', :js do
  it 'occurs if the proposal is modified in after seeing the profile page' do
    proposal = create(:proposal, :with_parallel_approvers)
    login_as(proposal.approvers.first)
    time = Time.current

    Timecop.freeze(time) do
      visit proposal_path(proposal)

      Timecop.travel(time + 1.minute) do
        proposal.touch
        click_on 'Approve'
      end
    end

    expect(page).to have_content('This request has recently changed.')
    expect(current_path).to eq(proposal_path(proposal))
  end
end
