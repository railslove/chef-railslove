Ohai.plugin(:Passenger) do
  provides "passenger"

  collect_data do
    passenger Mash.new
    version = %x{passenger-config about version}.chomp
    if version
      passenger[:version] = version.to_s[/\d+(\.\d+)+/]
    end
  end

end
