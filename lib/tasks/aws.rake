namespace :aws do
  namespace :ssh do
    desc "Display a sample SSH config for connecting to CAP AWS machines"
    task :config do
      require 'active_support/core_ext/string/strip'
      require 'aws-sdk'


      def find_by_name(instances, name)
        instances.find do |instance|
          instance.tags.any? do |tag|
            tag.key == 'Name' && tag.value == name
          end
        end
      end


      ec2 = Aws::EC2::Client.new(region: 'us-west-2')
      resp = ec2.describe_instances(
        filters: [
          {
            name: 'tag:Description',
            values: ['cap-dev']
          }
        ]
      )
      instances = resp.reservations.flat_map(&:instances)
      nat = find_by_name(instances, 'cf-cap-dev-nat')
      asg = find_by_name(instances, 'cf-cap-dev-asg')

      puts <<-SSH.strip_heredoc
        Host cap-dev-nat
          HostName #{nat.public_ip_address}
          User ec2-user
          ForwardAgent yes
        Host cap-dev
          HostName #{asg.private_ip_address}
          User ubuntu
          ProxyCommand ssh cap-dev-nat nc %h %p
      SSH
    end
  end
end
