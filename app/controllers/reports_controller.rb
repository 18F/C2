class ReportsController < ApplicationController
  before_action -> { authorize report }, only: [:show, :destroy, :preview]

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
    @subscribed = report.subscribed?(current_user)
    @subscription = report.subscription_for(current_user)
  end

  def preview
    @report = report
    ReportMailer.scheduled_report(report.name, report, current_user).deliver_later
    flash[:success] = "Success! The report has been sent."
    redirect_to report_path(@report)
  end

  def destroy
    report.destroy!
    respond_to do |format|
      format.json { render json: report.as_json, status: 202 }
      format.html { redirect_to reports_path }
    end
  end

  private

  def report
    @_report ||= Report.find(params[:id])
  end

  def report_params
    params.permit(:name, :query)
  end
end
