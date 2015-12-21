class ClientDataCollectionDecorator < Draper::CollectionDecorator
  include Rails.application.routes.url_helpers

  def initialize(client_data_relation)
    @client_data_relation = client_data_relation
  end

  def results
    @client_data_relation.map do |row|
      start_date = Time.zone.local(row["year"].to_i, row["month"].to_i, 1)
      end_date = start_date + 1.month
      {
        path: query_proposals_path(
          start_date: start_date.strftime("%Y-%m-%d"),
          end_date: end_date.strftime("%Y-%m-%d"),
        ),
        month: I18n.t("date.abbr_month_names")[start_date.month],
        year: start_date.year,
        count: row["count"].to_i,
        cost: row["cost"].to_f
      }
    end
  end
end
