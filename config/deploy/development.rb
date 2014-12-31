require 'net/ssh/proxy/command'

nat_user = 'ec2-user'
nat_ips = ec2_tagged('Name' => 'cf-cap-dev-nat')
nat_ips.each do |ip|
  server ip, user: nat_user, roles: %w{nat}
end

ec2_tagged('Name' => 'cf-cap-dev-asg').each do |asg_ip|
  server asg_ip, user: 'ubuntu', roles: %w{app}, ssh_options: {
    proxy: Net::SSH::Proxy::Command.new("ssh #{nat_user}@#{nat_ips.first} -W %h:%p")
  }
end
