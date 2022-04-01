module XMLT
  struct Token
    property type       : Symbol
    property key        : Array(Char)
    property attributes : Array(Hash(String, String))
    property value      : Array(Char)
    property line       : Int32
    property column     : Int32

    def initialize
      @type = :none
      @key = [] of Char
      @attributes = Array(Hash(String, String)).new
      @value = [] of Char
      @line = 1
      @column = 1
    end
  end

  class Lexer
    property parsed   : Array(Token)
    property input    : Array(Char)
    property token    : Token
    property pos      : Int32
    property current  : Char

    def initialize(input : String)
      @parsed = [] of Token
      @input = input.chars
      @token = Token.new
      @pos = 0
      @current = @input[0]

      next_token
    end

    def parse : Array(Token)
      next_token
      @parsed.reject { |t| t.type == :none }
    end

    def next_char : Char
      @pos += 1
      @token.column += 1
      @current = @input[@pos]? || '\0'
      @current
    end

    def next_token : Nil
      @parsed << @token
      @token = Token.new
      skip_whitespace

      case @current
      when '\0' then @token.type = :eof
      when '<'  then read_key
      when '>'  then read_value
      else
        throw :unexpected
      end

      @parsed << @token if @token.type == :eof
    end

    def skip_whitespace
      if [' ', '\n', '\r', '\t'].includes? @current
        @token.line += 1 if @current == '\n'
        next_char
        skip_whitespace
      end
    end

    def read_key
      skip_whitespace

      loop do
        case @current
        when '\0'
          throw :eof
        when '<'
          case next_char
          when '?'
            @token.type = :declaration
            read_declaration
          when '!'
            @token.type = :comment
            read_comment
            return next_token
          when '/'
            @token.type = :el_close
          else
            @token.type = :el_open
            while @current.ascii_letter?
              @token.key << @current
            end
          end
        when '?'
          raise "invalid declaration element" unless next_char == '>'
          next_char
          return next_token
        when '>'
          next_char
          break
        when ' ', .ascii_letter?
          @token.attributes << read_attribute
        else
          throw :unexpected
        end
      end

      next_token
    end

    def read_declaration
      unless next_char == 'x' && next_char == 'm' && next_char == 'l'
        throw "invalid declaration element"
      end

      @token.key += ['x', 'm', 'l']
    end

    def read_comment
      if next_char == '-'
        unless next_char == '-'
          throw :unexpected
        end
      else
        throw :unexpected
      end

      next_char
      loop do
        if @current == '-'
          if next_char == '-'
            if next_char == '>'
              break
            else
              @token.value << @current
            end
          else
            @token.value << @current
          end
        else
          @token.value << @current
        end
      end
    end

    def read_attribute
      key = [] of Char
      value = ""

      skip_whitespace
      until @current == '='
        key << @current
        next_char
      end
      value = read_string

      {"key" => key.join, "value" => value}
    end

    def read_value
      until @current == '<'
        @token.value << @current
        next_char
      end
    end

    def read_string
      value = [] of Char

      until @current == '"'
        value << @current
        next_char
      end

      value.join
    end

    private def throw(message : String) : NoReturn
      raise message + " (line %d, column %d)" % [@token.line, @token.column]
    end

    private def throw(key : Symbol, extra : String? = nil) : NoReturn
      errors = {
        :unexpected => "unexpected character '#{@current}'",
        :expected => "expected '#{extra}'; got '#{@current}'",
        :eof => "unexpected EOF"
      }

      throw errors[key]
    end
  end
end