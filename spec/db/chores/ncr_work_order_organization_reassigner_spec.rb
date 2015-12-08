require "#{Rails.root}/db/chores/ncr_work_order_organization_reassigner"

describe Ncr::WorkOrderOrganizationReassigner do
  describe "#run" do
    it "reassigns work order organizations from strings to foreign keys" do
      work_order = double(org_code: "P04T0003 (192X,192M) BRANCH B")
      allow(Ncr::WorkOrder).to receive(:all).and_return([work_order])
      ncr_organization = create(:ncr_organization, code: "P04T0003", name: "(192X, 192M) BRANCH B")
      allow(work_order).to receive(:update).with(ncr_organization: ncr_organization)

      Ncr::WorkOrderOrganizationReassigner.new.run

      expect(work_order).to have_received(:update).with(ncr_organization: ncr_organization)
    end

    it "does not assign an organization to work orders without an org code" do
      work_order_with_empty_string = double(org_code: "", update: true)
      work_order_with_nil = double(org_code: nil, update: true)
      allow(Ncr::WorkOrder).to receive(:all).and_return([
        work_order_with_empty_string,
        work_order_with_nil
      ])

      Ncr::WorkOrderOrganizationReassigner.new.run

      expect(work_order_with_empty_string).not_to have_received(:update)
      expect(work_order_with_nil).not_to have_received(:update)
    end
  end

  describe "#unrun" do
    it "assigns work order org_code based on ncr_organization data" do
      org_code = "P04T0003 (192X,192M) BRANCH B"
      ncr_organization = create(:ncr_organization, code: "P04T0003", name: "(192X,192M) BRANCH B")
      work_order = double(ncr_organization: ncr_organization)
      allow(Ncr::WorkOrder).to receive(:all).and_return([work_order])
      allow(work_order).to receive(:update).with(org_code: org_code)

      Ncr::WorkOrderOrganizationReassigner.new.unrun

      expect(work_order).to have_received(:update).with(org_code: org_code)
    end

    it "does not assign an org_code for work orders without an organization" do
      work_order = double(ncr_organization: nil, update: true)
      allow(Ncr::WorkOrder).to receive(:all).and_return([work_order])

      Ncr::WorkOrderOrganizationReassigner.new.unrun

      expect(work_order).not_to have_received(:update)
    end
  end
end
