Ohai.plugin(:PostgresqlReplication) do
  provides "postgresql"

  collect_data do
    if Dir.glob("/var/lib/postgresql/**/main").any?
      postgresql Mash.new
      postgresql[:master] = Dir.glob("/var/lib/postgresql/**/main/recovery.conf").empty?
    end
  end

end