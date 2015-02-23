describe CartsHelper do
  describe '#display_status' do
    let(:current_user) { FactoryGirl.create(:user) }

    it "displays approved status" do
      cart = FactoryGirl.create(:cart, status: 'approved')
      expect(helper.display_status(cart, current_user)).to eq('Approved')
    end

    it "displays rejected status" do
      cart = FactoryGirl.create(:cart, status: 'rejected')
      expect(helper.display_status(cart, current_user)).to eq('Rejected')
    end

    context "pending" do
      context "parallel" do
        it "displays outstanding approvers" do
          cart = FactoryGirl.create(:cart_with_approvals, flow: 'parallel')
          expect(helper.display_status(cart, current_user)).to eq("<em>Waiting for review from:</em> Liono Approver1, Liono Approver2")
        end

        it "excludes approved approvals" do
          cart = FactoryGirl.create(:cart_with_approvals, flow: 'parallel')
          cart.approvals.first.approve!
          expect(helper.display_status(cart, current_user)).to eq("<em>Waiting for review from:</em> Liono Approver2")
        end

        it "references the current user" do
          cart = FactoryGirl.create(:cart_with_approvals, flow: 'parallel')
          current_user = cart.approvers.first
          expect(helper.display_status(cart, current_user)).to eq("<strong>Please review</strong>")
        end
      end

      context "linear" do
        it "displays the first approver" do
          cart = FactoryGirl.create(:cart_with_approvals, flow: 'linear')
          expect(helper.display_status(cart, current_user)).to eq("<em>Waiting for review from:</em> Liono Approver1")
        end

        it "excludes approved approvals" do
          cart = FactoryGirl.create(:cart_with_approvals, flow: 'linear')
          cart.approvals.first.approve!
          expect(helper.display_status(cart, current_user)).to eq("<em>Waiting for review from:</em> Liono Approver2")
        end

        it "references the current user" do
          cart = FactoryGirl.create(:cart_with_approvals, flow: 'linear')
          current_user = cart.approvers.first
          expect(helper.display_status(cart, current_user)).to eq("<strong>Please review</strong>")
        end
      end
    end
  end

  describe '#parallel_approval_is_pending?' do
    let (:user) { FactoryGirl.create(:user) }
    let (:cart) { FactoryGirl.create(:cart, flow: 'parallel') }
    let (:approval) { FactoryGirl.create(:approval, cart_id: cart.id, user_id: user.id) }
    subject { helper.parallel_approval_is_pending?(cart, user) }

    context 'linear' do
      it 'returns false with non-parallel carts' do
        cart.update_attributes(flow: 'linear')
        expect(subject).to eq false
      end
    end

    context 'parallel' do
      it 'returns true with pending approval' do
        approval
        expect(subject).to eq(true)
      end

      it 'returns false with a non-pending approval' do
        approval.update_attributes(status: 'approved')
        expect(subject).to eq(false)
      end

      it 'returns false with a non-existent approval' do
        expect(subject).to eq(false)
      end
    end
  end

  describe '#current_linear_approval?' do
    let (:user) { FactoryGirl.create(:user) }
    let (:cart) { FactoryGirl.create(:cart, flow: 'linear') }
    let (:approval) { FactoryGirl.create(:approval, cart_id: cart.id, user_id: user.id, status: 'pending') }
    subject { helper.current_linear_approval?(cart, user) }

    it 'returns false with non-linear carts' do
      cart.update_attributes(flow: 'parallel')
      expect(subject).to eq false
    end

    it 'returns true when the approval is next' do
      approval
      expect(subject).to eq true
    end
  end

  describe '#display_response_actions' do
    it 'checks parallel and linear cart requirements' do
      user = FactoryGirl.create(:user)
      cart = FactoryGirl.create(:cart, flow: 'linear')
      cart.add_approver user.email_address

      expect(helper).to receive(:parallel_approval_is_pending?)
      expect(helper).to receive(:current_linear_approval?)
      helper.display_response_actions?(cart, user)
    end
  end
end
