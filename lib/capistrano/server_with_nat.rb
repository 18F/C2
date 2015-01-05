require 'capistrano/ec2_tagged'
require 'net/ssh/proxy/command'


def nat_server(name)
  ec2_tagged('Name' => name).each do |ip|
    server ip, user: 'ec2-user', roles: %w{nat}
  end
end

def asg_server(name)
  nat = primary(:nat)
  ec2_tagged('Name' => name).each do |asg_ip|
    server asg_ip, user: 'ubuntu', roles: %w{app}, ssh_options: {
      proxy: Net::SSH::Proxy::Command.new("ssh #{nat.user}@#{nat.hostname} -W %h:%p")
    }
  end
end

def cloud_cutter_env(cc_env)
  nat_server "cf-cap-#{cc_env}-nat"
  asg_server "cf-cap-#{cc_env}-asg"
end
