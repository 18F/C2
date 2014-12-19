module ApplicationHelper
  # Variation of http://git.io/ugBzaQ
  def humanized_options_for_select(options)
    options = options.map do |val|
      [val.humanize, val]
    end
    options_for_select(options)
  end

  def signed_in?
    session[:user] && !session[:user].empty?
  end

end
