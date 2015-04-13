describe ExceptionPolicy do
  class SomePolicy
    include ExceptionPolicy

    def fail!
      check(false, "Fail failed")
    end

    def success!
      check(true, "Success failed")
    end
  end

  let (:policy) {SomePolicy.new(:some_user, :some_record)}
  describe "#method_missing" do
    it "converts questions into booleans" do
      expect(policy.fail?).to be(false)
      expect(policy.success?).to be(true)
    end

    it "continues to operate as expected on others" do
      expect(->{policy.no_method}).to raise_exception(NoMethodError)
      expect(->{policy.no_method?}).to raise_exception(NoMethodError)
    end
  end

  describe "#check" do
    it "doesn't raise an exception on success" do
      expect(policy.success!).to be(true)
    end

    it "does raise an exception on failure" do
      expect(->{policy.fail!}).to raise_exception(Pundit::NotAuthorizedError)
      begin
        policy.fail!
      rescue Pundit::NotAuthorizedError => exc
        expect(exc.message).to eq('Fail failed')
        expect(exc.query).to eq(:fail!)
        expect(exc.record).to eq(:some_record)
        expect(exc.policy).to eq(policy)
      end
    end
  end
end
