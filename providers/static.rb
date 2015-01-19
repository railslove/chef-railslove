
action :before_compile do
end

action :before_deploy do
end

action :before_migrate do
end

action :before_symlink do
  link "#{new_resource.release_path}/public" do
    to "#{new_resource.release_path}"
  end
end

action :before_restart do
end

action :after_restart do
end
