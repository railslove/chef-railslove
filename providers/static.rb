
action :before_compile do
end

action :before_deploy do
end

action :before_migrate do
end

action :before_symlink do
  Chef::Log.debug "Railslove-Static running before_symlink: #{new_resource.dependency_managers}"

  link "#{new_resource.release_path}/public" do
    to new_resource.release_path
    not_if { ::File.directory?("#{new_resource.release_path}/public") }
  end

  if new_resource.dependency_managers.include?("npm")
    Chef::Log.info "Running npm install"
    directory "#{new_resource.path}/shared/node_modules" do
      owner new_resource.owner
      group new_resource.group
      mode '0755'
    end
    link "#{new_resource.release_path}/node_modules" do
      to "#{new_resource.path}/shared/node_modules"
    end

    npm_command = "npm"

    execute "#{npm_command} install" do
      cwd new_resource.release_path
      user new_resource.owner
      environment(
        "HOME" => "/srv/www"
      )
    end
  end

  if new_resource.dependency_managers.include?("bower")
    Chef::Log.info "Running bower install"
    directory "#{new_resource.path}/shared/bower_components" do
      owner new_resource.owner
      group new_resource.group
      mode '0755'
    end

    link "#{new_resource.release_path}/bower_components" do
      to "#{new_resource.path}/shared/bower_components"
    end

    execute "npm install -g bower" do
      cwd new_resource.release_path
      environment(
        "HOME" => "/srv/www"
      )
    end

    bower_command = "bower"

    execute "#{bower_command} install" do
      cwd new_resource.release_path
      user new_resource.owner
      environment(
        "HOME" => "/srv/www"
      )
    end
  end

  if new_resource.build_tools.include?("ember")
    Chef::Log.info "Running ember build"

    execute "npm install -g ember-cli" do
      cwd new_resource.release_path
      environment(
        "HOME" => "/srv/www"
      )
    end

    ember_command = "ember"

    execute "#{ember_command} build --environment=#{new_resource.environment_name}" do
      cwd new_resource.release_path
      user new_resource.owner
      environment(
        "HOME" => "/srv/www"
      )
    end

    execute "rm -rf #{new_resource.release_path}/public"
    execute "ln -sfnv #{new_resource.release_path}/dist #{new_resource.release_path}/public"

  end




  new_resource.updated_by_last_action(true)
end

action :before_restart do
end

action :after_restart do
end
