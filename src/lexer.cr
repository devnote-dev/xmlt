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

    def skip_whitespace : Nil
      if [' ', '\n', '\r', '\t'].includes? @current
        next_char
        skip_whitespace
      end
    end

    def read_attr_key
      key = [] of Char
      value = ""

      puts "reading attr key"
      loop do
        case @current
        when '='
          next_char
          value = read_attr_value
          break
        else
          key << @current
        end

        next_char
      end

      {"key" => key.join, "value" => value}
    end

    def read_attr_value
      value = [] of Char
      quotes = @current == '"'
      escaped = false

      puts "reading attr value"
      loop do
        case @current
        when '"'
          throw :unexpected unless quotes
          break unless escaped
          escaped = false
        when '\\'
          throw :unexpected unless quotes
          escaped = !escaped
        when ' ', '?', '>'
          break unless quotes
        else
          value << @current
        end

        next_char
      end
      puts "done"

      skip_whitespace
      value.join
    end

    def read_key
      is_key = true

      puts "reading key"
      skip_whitespace
      loop do
        case @current
        when '\0'
          throw :eof
        when '<'
          case next_char
          when '?' then @token.type = :head
          when '/' then @token.type = :el_close
          else
            @token.type = :el_open
          end
        when '?'
          break if next_char == '>'
          throw :unexpected
        when '>'
          break
        when ' '
          is_key = false
        else
          if is_key
            @token.key << @current
          else
            @token.attributes << read_attr_key
          end
        end

        next_char
      end

      puts "done"
      if @token.type == :el_open
        read_value
      else
        next_token
      end
    end

    def read_value
      escaped = false

      puts "reading value"
      loop do
        case @current
        when '\0'
          throw :eof
        when '\\'
          escaped = !escaped
        when '<'
          break unless escaped
          escaped = false
        else
          @token.value << @current
        end

        next_char
      end

      next_token
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