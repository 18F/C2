class CommentCreator
  def initialize(parsed_email)
    @parsed_email = parsed_email
  end

  def run
    Comment.create(
      comment_text: parsed_email.comment_text,
      user: parsed_email.comment_user,
      proposal: parsed_email.proposal
    )
  end

  private

  attr_reader :parsed_email
end
