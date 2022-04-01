module XMLT
  class Builder
    property version  : String
    property encoding : String
    property children : Hash(String, Element)

    def initialize(version : String = nil, encoding : String = nil)
      @version = version || "1.0"
      @encoding = encoding || "utf-8"
      @children = {} of String => Element
    end

    def self.new(version : String = nil, encoding : String = nil, &)
      new version, encoding
      yield self
    end

    def set_version(@version)
      self
    end

    def set_version(&block : -> String)
      set_version block.call
    end

    def set_encoding(@encoding)
      self
    end

    def set_encoding(&block : -> String)
      set_encoding &block.call
    end

    private def add_nested(child, key, value, stack = 0)
    end

    def add_element(key : String, value : Any, attributes : Hash(String, Any))
      if parent = @children[key]?
        parent[key]
      end
    end

    def add_comment(comment : String)
      @children << Element.new :comment, value: comment
      self
    end

    def add_comment(&block : -> String)
      add_comment block.call
    end

    def build : String
      # TODO
      ""
    end
  end
end
