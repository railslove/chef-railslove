
action :before_compile do

  Chef::Log.info("Railslove-Rails running before compile")
  if new_resource.bundler.nil?
    new_resource.bundler new_resource.gems.any? { |gem, ver| gem == 'bundler' }
  end

  new_resource.environment.update({
    "RAILS_ENV" => new_resource.environment_name,
    "PATH" => [Gem.default_bindir, ENV['PATH']].join(':')
  })

  new_resource.symlink_before_migrate.update({
    "database.yml" => "config/database.yml"
  })

end

action :before_deploy do
  Chef::Log.info "Railslove-Rails running before deploy"
  new_resource.environment['RAILS_ENV'] = new_resource.environment_name

  install_gems

end

action :before_migrate do
  Chef::Log.info "Railslove-Rails running before migrate"
  if new_resource.bundler
    Chef::Log.info "Running bundle install"
    directory "#{new_resource.path}/shared/vendor_bundle" do
      owner new_resource.owner
      group new_resource.group
      mode '0755'
    end
    directory "#{new_resource.release_path}/vendor" do
      owner new_resource.owner
      group new_resource.group
      mode '0755'
    end
    link "#{new_resource.release_path}/vendor/bundle" do
      to "#{new_resource.path}/shared/vendor_bundle"
    end
    common_groups = %w{development test cucumber staging production}
    common_groups += new_resource.bundler_without_groups
    common_groups -= [new_resource.environment_name]
    common_groups = common_groups.join(' ')
    # Check for a Gemfile.lock
    bundler_deployment = ::File.exists?(::File.join(new_resource.release_path, "Gemfile.lock"))
    execute "#{bundle_command} install --path=vendor/bundle #{bundler_deployment ? "--deployment " : ""}--without #{common_groups}" do
      cwd new_resource.release_path
      user new_resource.owner
      environment new_resource.environment
    end
  end

end

action :before_symlink do

  Chef::Log.info "Railslove-Rails running before symlink"

  if new_resource.precompile_assets.nil?
    new_resource.precompile_assets ::File.exists?(::File.join(new_resource.release_path, "config", "assets.yml"))
  end

  if new_resource.precompile_assets
    command = "rake assets:precompile"
    command = "#{bundle_command} exec #{command}" if new_resource.bundler
    execute command do
      cwd new_resource.release_path
      user new_resource.owner
      environment new_resource.environment
    end
  end

end

action :before_restart do
end

action :after_restart do
end


protected

def bundle_command
  new_resource.bundle_command
end

def install_gems
  new_resource.gems.each do |gem, opt|
    if opt.is_a?(Hash)
      ver = opt['version']
      src = opt['source']
    elsif opt.is_a?(String)
      ver = opt
    end
    gem_package gem do
      action :install
      source src if src
      version ver if ver && ver.length > 0
    end
  end
end

