include_recipe "mongodb::default"

mongodb_instance "mongodb" do
  port 27017
end
