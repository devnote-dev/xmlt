module XMLT
  class Error < Exception
    def initialize(message)
      super message
    end

    def initialize(ex : Exception, name : String, type : String)
      super "failed to deserialize '#{name}' to #{type}", cause: ex
    end
  end
end
