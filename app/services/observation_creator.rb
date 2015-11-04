class ObservationCreator
  def initialize(observer:, proposal_id:, reason: nil, observer_adder: nil)
    @observer = observer
    @proposal_id = proposal_id
    @reason = reason
    @observer_adder = observer_adder
  end

  def run
    create_observation

    if adding_observer_via_proposal_page?
      send_observation_added_email

      if reason.present?
        add_observation_comment
      end
    end

    observation
  end

  private

  attr_reader :observer, :proposal_id, :reason, :observer_adder

  def create_observation
    proposal.observations << observation
    proposal.observers(true) #invalidate relation cache
  end

  def proposal
    @proposal ||= Proposal.find(proposal_id)
  end

  def observation
    @observation ||=
      Observation.new(user: observer, role_id: observer_role.id, proposal_id: proposal_id)
  end

  def add_observation_comment
    proposal.comments.create(
      comment_text: I18n.t(
        "activerecord.attributes.observation.user_reason_comment",
        user: observer_adder.full_name,
        observer: observer.full_name,
        reason: reason
      ),
      update_comment: true,
      user: observer_adder
    )
  end

  def adding_observer_via_proposal_page?
    observer_adder.present?
  end

  def send_observation_added_email
    Dispatcher.on_observer_added(observation, reason)
  end

  def observer_role
    Role.find_or_create_by(name: "observer")
  end
end
