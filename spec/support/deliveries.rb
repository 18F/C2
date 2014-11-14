def email_recipients
  ActionMailer::Base.deliveries.map {|email| email.to[0] }.sort
end
