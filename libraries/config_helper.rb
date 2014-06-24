module ConfigHelper
  def self.to_attribute(attr)
    if attr.kind_of?(Array)
      attr.inspect
    elsif attr.to_s[/^:/]
      attr
    elsif attr.kind_of?(String)
      "\"#{attr}\""
    else
      attr
    end
  end
end
