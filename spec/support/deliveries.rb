def deliveries
  ActionMailer::Base.deliveries
end

def email_recipients
  deliveries.map {|email| email.to[0] }.sort
end
