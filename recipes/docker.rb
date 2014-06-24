node.set['docker']['package']['repo_url'] = 'https://get.docker.io/ubuntu'
include_recipe 'docker'

credentials = begin
  Chef::EncryptedDataBagItem.load("docker", "registry")
rescue Net::HTTPServerException => e
  Hash.new("")
end

docker_registry node['railslove']['docker']['registry_url'] do
  username credentials['username']
  password credentials['password']
  email credentials['email']
  only_if { credentials.kind_of?(Chef::EncryptedDataBagItem) }
end

node['railslove']['docker']['containers'].each do |container|
  begin
    config = data_bag_item('containers', container)
    image = config.delete('image')
    docker_image image

    docker_container image do
      config.each do |key, value|
        eval("#{key} #{ConfigHelper.to_attribute(value)}")
      end
    end
  rescue Net::HTTPServerException => e
    Chef::Log.warn("#{e}: cannot fetch data bag item: #{container}")
  end
end
