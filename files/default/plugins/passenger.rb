Ohai.plugin(:Passenger) do
  provides "passenger"

  collect_data do
    passenger Mash.new
    passenger[:version] = %x{passenger-config about version}.chomp
  end

end
