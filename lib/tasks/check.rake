namespace :check do
  desc "Report all non-admin Users with a null client_slug"
  task client_slug: :environment do
    User.where(client_slug: nil).each do |user|
      next if user.admin?
      puts "missing: #{user.id} #{user.email_address}"
    end
  end
end
