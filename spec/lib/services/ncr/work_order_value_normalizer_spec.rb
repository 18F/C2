describe Ncr::WorkOrderValueNormalizer do
  describe "#run" do
    it "keeps values nil if they are nil" do
      work_order = build(:ncr_work_order, cl_number: nil, function_code: nil, soc_code: nil)

      Ncr::WorkOrderValueNormalizer.new(work_order).run

      expect(work_order.cl_number).to be_nil
      expect(work_order.function_code).to be_nil
      expect(work_order.soc_code).to be_nil
    end

    it "converts values to nil if they are empty strings" do
      work_order = build(:ncr_work_order, cl_number: "", function_code: "", soc_code: "")

      Ncr::WorkOrderValueNormalizer.new(work_order).run

      expect(work_order.cl_number).to be_nil
      expect(work_order.function_code).to be_nil
      expect(work_order.soc_code).to be_nil
    end

    it "upcases and prepends cl_number with CL if present" do
      work_order = build(:ncr_work_order, cl_number: "123abc")

      Ncr::WorkOrderValueNormalizer.new(work_order).run

      expect(work_order.cl_number).to eq "CL123ABC"
    end

    it "upcases and prepends function_code with PG if present" do
      work_order = build(:ncr_work_order, function_code: "123abc")

      Ncr::WorkOrderValueNormalizer.new(work_order).run

      expect(work_order.function_code).to eq "PG123ABC"
    end

    it "upcases soc code if present" do
      work_order = build(:ncr_work_order, soc_code: "123abc")

      Ncr::WorkOrderValueNormalizer.new(work_order).run

      expect(work_order.soc_code).to eq "123ABC"
    end
  end
end
