include_recipe "mongodb::10gen_repo"

mongodb_instance "mongodb" do
  port 27017
end