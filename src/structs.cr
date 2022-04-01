module XMLT
  struct Any
    alias AnyType = String | Int64 | Float64 | Bool | Array(Any) | Hash(String, Any) | Nil

    getter value

    def initialize(@value)
    end

    def to_s
      @value.inspect
    end

    def to_s(io)
      io << to_s
    end
  end

  struct Element
    property type       : Symbol
    property key        : String?
    property value      : Any
    property attributes : Hash(String, Any)

    def initialize(@type, *, key : String? = nil, value : Any = nil, **attributes)
      @key = key
      @value = value
      @attributes = attributes
    end

    def as_text : String
      String.build do |str|
        str << "<#{@key}>"
        if @value.inspect.lines.size > 0
          @value.inspect.lines.each { |line| str << line << "\n\t" }
        else
          str << @value.inspect
        end
        str << "</#{@key}>"
      end
    end

    def as_comment : String
      String.build do |str|
        str << "<!--\n"
        @value.inspect.lines.each { |line| str << line << "\n\t" }
        str << "\n-->"
      end
    end
  end
end
