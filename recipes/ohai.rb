include_recipe "ohai"

node["railslove"]["ohai_plugins"].each do |plugin|
  cookbook_file "#{node["ohai"]["plugin_path"]}/#{plugin}.rb" do
    source "#{plugin}.rb"
    user "root"
    group "root"
  end
end
