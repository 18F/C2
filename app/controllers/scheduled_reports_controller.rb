class ScheduledReportsController < ApplicationController
  before_action -> { authorize scheduled_report }, only: [:show, :destroy, :update]

  def create
    scheduled_report = current_user.scheduled_reports.build(scheduled_report_params)
    save_and_respond(scheduled_report, :created)
  end

  def update
    scheduled_report.frequency = scheduled_report_params[:frequency]
    save_and_respond(scheduled_report, :ok)
  end

  private

  def save_and_respond(scheduled_report, status = 200)
    scheduled_report.save!
    flash[:success] = "Subscription updated! You'll now receive #{scheduled_report.frequency} reports."
    respond_to do |format|
      format.json { render json: scheduled_report.as_json, status: status, location: scheduled_report }
      format.html { redirect_to report_path(scheduled_report.report) }
    end
  end

  def scheduled_report
    @_scheduled_report ||= ScheduledReport.find(params[:id])
  end

  def scheduled_report_params
    params.permit(:name, :frequency, :report_id)
  end
end
