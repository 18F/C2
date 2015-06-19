class HelpController < ApplicationController
  layout 'help'

  def index
    dir = Rails.root.join('app', 'views', 'help', '*.md')
    files = Dir.glob(dir)
    @pages = files.map{|file| File.basename(file, '.md') }.sort
  end

  def show
    page = params[:id]
    # TODO make sure this isn't a security hole
    render "help/#{page}"
  end
end
