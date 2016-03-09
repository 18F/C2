module PolicyFinder
  # Proposals can have special authorization parameters in their client_data
  def self.authorizing_object(record)
    if record.is_a?(Class)
      # use an instance
      record = record.new
    end

    if record.instance_of?(Proposal) && Pundit::PolicyFinder.new(record.client_data).policy
      record.client_data
    else
      record
    end
  end

  def self.policy_for(user, record)
    record = authorizing_object(record)
    Pundit.policy(user, record)
  end
end
