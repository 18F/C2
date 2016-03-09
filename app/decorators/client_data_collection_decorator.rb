class ClientDataCollectionDecorator < Draper::CollectionDecorator
  include Rails.application.routes.url_helpers

  def initialize(client_data_relation)
    @client_data_relation = client_data_relation
  end

  def results
    @client_data_relation.map do |row|
      {
        path: query_path(row),
        month: I18n.t("date.abbr_month_names")[start_date(row).month],
        year: start_date(row).year,
        count: row["count"].to_i,
        cost: row["cost"].to_f
      }
    end
  end

  private

  def query_path(row)
    query_proposals_path(
      start_date: formatted_start_date(row),
      end_date: formatted_end_date(row)
    )
  end

  def formatted_start_date(row)
    start_date(row).strftime("%Y-%m-%d")
  end

  def formatted_end_date(row)
    end_date(row).strftime("%Y-%m-%d")
  end

  def start_date(row)
    Time.zone.local(row["year"].to_i, row["month"].to_i, 1)
  end

  def end_date(row)
    start_date(row) + 1.month
  end
end
