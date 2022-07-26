class SerializableError < Exception
  def initialize(msg)
    super msg
  end

  def initialize(err : Exception, name : String, type : String)
    super "Failed to deserialize '#{name}' to #{type}:\n#{err}"
  end
end
