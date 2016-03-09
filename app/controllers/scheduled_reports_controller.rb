class ScheduledReportsController < ApplicationController
  before_action -> { authorize scheduled_report }, only: [:show, :destroy, :update]

  def create
    scheduled_report = current_user.scheduled_reports.build(scheduled_report_params)
    scheduled_report.save!
    flash[:success] = "Your subscription has been updated to #{scheduled_report.frequency}."
    respond_to do |format|
      format.json { render json: scheduled_report.as_json, status: :created, location: scheduled_report }
      format.html { redirect_to report_path(scheduled_report.report) }
    end
  end

  def update
    scheduled_report.frequency = scheduled_report_params[:frequency]
    scheduled_report.save!
    flash[:success] = "Your subscription has been updated to #{scheduled_report.frequency}."
    respond_to do |format|
      format.json { render json: scheduled_report.as_json, location: scheduled_report }
      format.html { redirect_to report_path(scheduled_report.report) }
    end
  end

  private

  def scheduled_report
    @_scheduled_report ||= ScheduledReport.find(params[:id])
  end

  def scheduled_report_params
    params.permit(:name, :frequency, :report_id)
  end
end
