module RailsloveSharedAttributes
  def self.included(klass)
    klass.attribute :data_bag, :kind_of => String, :default => "applications", :name_attribute => true
    klass.attribute :cookbook, :kind_of => String, :default => "railslove"
    klass.attribute :user, :kind_of => String, :default => "rails"
    klass.attribute :group, :kind_of => String, :default => "rails"
    klass.attribute :home, :kind_of => String, :default => "/srv/www/"
    klass.attribute :deploy_group, :kind_of => String, :default => "deployer"
  end
end
