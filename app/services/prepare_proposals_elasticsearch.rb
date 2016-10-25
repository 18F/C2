class PrepareProposalsElasticsearch
  def default_indexed
    {
      include: {
        comments: comment_values,
        steps: step_values
      }
    }
  end

  def step_values
    {
      include: {
        completed_by: { methods: [:display_name], only: [:display_name] }
      }
    }
  end

  def comment_values
    {
      include: {
        user: { methods: [:display_name], only: [:display_name] }
      }
    }
  end
end
