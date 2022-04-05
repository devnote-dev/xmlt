module XMLT
  struct Token
    property kind       : Symbol
    property attributes : Array(Hash(String, String))
    property value      : Array(Char)
    property line       : Int32
    property column     : Int32

    def initialize
      @kind = :none
      @attributes = [] of Hash(String, String)
      @value = [] of Char
      @line = 1
      @column = 0
    end
  end

  class Lexer
    property input    : Array(Char)
    property token    : Token
    property parsed   : Array(Token)
    property pos      : Int32
    property line     : Int32
    property column   : Int32
    property current  : Char

    def initialize(input : String)
      @input = input.chars
      @token = Token.new
      @parsed = [] of Token
      @pos = 0
      @line = 1
      @column = 0
      @current = @input[0]
    end

    def run : Array(Token)
      read_element
      @parsed
    end

    def next_char : Char
      @pos += 1
      @column += 1
      @current = @input[@pos]? || '\0'
      @current
    end

    def next_token
      @token.line = @line
      @token.column = @column
      @parsed << @token
      @token = Token.new

      read_element
    end

    def is_whitespace? : Bool
      [' ', '\n', '\r', '\t'].includes? @current
    end

    def skip_whitespace
      loop do
        break unless is_whitespace?
        @line += 1 if @current == '\n'
        next_char
      end
    end

    def read_element
      skip_whitespace

      loop do
        case @current
        when '\0'
          @token.kind = :eof
          break
        when '<'
          read_key
        else
          read_value
        end

        next_char
      end

      next_token unless @token.kind == :eof
    end

    def read_key
      next_char

      case @current
      when '?'
        @token.kind = :declaration
        read_declaration
      when '/'
        @token.kind = :close_tag
        next_char

        loop do
          case @current
          when '>'
            break
          when .ascii_letter?, '_'
            @token.value << @current
          else
            throw "unexpected character '#{@current}'"
          end

          next_char
        end
      when '!'
        @token.kind = :comment
        read_comment
      when .ascii_letter?, '_'
        @token.kind = :open_tag
        loop do
          case @current
          when '>', '\0'
            break
          when ' ', '\n', '\r', '\t'
            skip_whitespace
            read_attributes
            break
          when .ascii_letter?, '_'
            @token.value << @current
          else
            throw "unexpected character '#{@current}'"
          end

          next_char
        end
      else
        throw "invalid element key character '#{@current}'"
      end

      next_char
      next_token
    end

    def read_declaration
      unless next_char == 'x' && next_char == 'm' && next_char == 'l'
        throw "invalid declaration element"
      end

      next_char
      loop do
        skip_whitespace
        case @current
        when '?'
          throw "invalid declaration element" unless next_char == '>'
          break
        when .ascii_letter?
          read_attributes
          break
        else
          throw "unexpected character '#{@current}'"
        end
      end
    end

    def read_attributes
      attrs = [] of Hash(String, String)
      key = [] of Char

      loop do
        skip_whitespace
        case @current
        when '?'
          throw "unexpected character '?'" unless next_char == '>'
          break
        when '>'
          break
        when '='
          next_char
          attrs << {"key" => key.join, "value" => read_string}
          key.clear
        when .ascii_letter?, '_'
          key << @current
        else
          throw "unexpected character '#{@current}'"
        end

        next_char
      end

      @token.attributes = attrs
    end

    def read_string
      value = [] of Char

      next_char if @current == '"'
      until @current == '"'
        value << @current
        next_char
      end

      value.join
    end

    def read_value
      @token.kind = :value

      loop do
        case @current
        when '<', '\0'
          break
        else
          @token.value << @current
        end

        next_char
      end

      next_token
    end

    def read_comment
      unless next_char == '-' && next_char == '-'
        throw "invalid comment element"
      end

      next_char
      until @current == '-'
        @token.value << @current
        next_char
      end

      unless next_char == '-' && next_char == '>'
        throw "invalid comment element"
      end
    end

    private def throw(message : String) : NoReturn
      raise message + " (line #{@line}, column #{@column})"
    end
  end
end
