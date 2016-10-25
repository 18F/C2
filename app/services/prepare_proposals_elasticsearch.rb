class PrepareProposalsElasticsearch
  def default_indexed
    {
      include: {
        comments: {
          include: {
            user: { methods: [:display_name], only: [:display_name] }
          }
        },
        steps: {
          include: {
            completed_by: { methods: [:display_name], only: [:display_name] }
          }
        }
      }
    }
  end
end
