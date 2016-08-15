class HelpController < ApplicationController
  layout "help"
  skip_before_action :authenticate_user!, only: [:index, :show]
  skip_before_action :check_disabled_client

  def index
    @pages = page_names.sort
  end

  def show
    page = params[:id]
    # prevent rendering of any non-help template
    @new_features = new_features_page?(page)

    if page_names.include?(page)
      render "help/#{page}"
    else
      raise ActionController::RoutingError.new("Not Found")
    end
  end

  protected

  def new_features_page?(page)
    page == "new_features"
  end

  def page_names
    dir = Rails.root.join("app", "views", "help", "*.md")
    files = Dir.glob(dir)
    files.map{|file| File.basename(file, ".md") }
  end
end
