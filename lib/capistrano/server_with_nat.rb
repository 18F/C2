require 'net/ssh/proxy/command'

def server_with_nat(nat_name, asg_name)
  nat_user = 'ec2-user'
  nat_ips = ec2_tagged('Name' => nat_name)
  nat_ips.each do |ip|
    server ip, user: nat_user, roles: %w{nat}
  end

  ec2_tagged('Name' => asg_name).each do |asg_ip|
    server asg_ip, user: 'ubuntu', roles: %w{app}, ssh_options: {
      proxy: Net::SSH::Proxy::Command.new("ssh #{nat_user}@#{nat_ips.first} -W %h:%p")
    }
  end
end
