class ReportsController < ApplicationController
  before_action ->{authorize report}, only: [:show, :destroy]

  def create
    report = current_user.reports.build(report_params)
    report.save!
    respond_to do |format|
      format.json { render json: report.as_json, status: :created, location: report }
    end
  end

  def index
    @reports = current_user.all_reports
  end

  def show
    @report = report
  end

  def destroy

  end

  private

  def report
    @_report ||= Report.find(params[:id])
  end

  def report_params
    params.permit(:name, :query)
  end
end
