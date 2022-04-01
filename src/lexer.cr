module XMLT
  struct Token
    property type    : Symbol
    property key     : Array(Char)
    property attributes : Array(Hash(String, String))
    property value   : Array(Char)
    property line    : Int32
    property column  : Int32

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
    property parsed : Array(Token)
    property input  : Array(Char)
    property token  : Token
    property pos    : Int32
    property current : Char

    def initialize(input : String)
      puts input

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

    def next_char : Nil
      @pos += 1
      @token.column += 1
      @current = @input[@pos]? || '\0'
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
        unexpected_char
      end

      @parsed << @token if @token.type == :eof
    end

    def skip_whitespace : Nil
      if [' ', '\n', '\r', '\t'].includes? @current
        next_char
        skip_whitespace
      end
    end

    def read_attr_key : Hash(String, String)
      key = [] of Char
      value = uninitialized String

      loop do
        case @current
        when '='
          next_char
          value = read_attr_value
          break
        when .ascii_letter?
          key << @current
        else
          unexpected_char
        end

        next_char
      end

      {"key" => key.join, "value" => value}
    end

    # TODO: read until > or ?> or space instead of separate
    def read_attr_value : String
      value = [] of Char
      expected = @current == '"' ? :str : :num
      escaped = true

      loop do
        case @current
        when '"', '?', '>'
          break unless escaped
          escaped = false
        when '\\'
          escaped = true
        when .ascii_number?, '.'
          value << @current
        when ' '
          break if expected == :num
        else
          if expected == :num
            unexpected_char unless ['b', 'e', 'x'].includes? @current
          end
          value << @current
        end

        next_char
      end

      next_char
      value.join
    end

    def read_key
      next_char
      is_key = true

      loop do
        case @current
        when '?'
          unexpected_char unless prev = @input[@pos - 1]?
          if prev == '<'
            @token.type = :head
          else
            next_char
            if @current == '>'
              next_char
              return next_token
            else
              unexpected_char
            end
          end
        when '>'
          break
        when ' '
          is_key = false
          skip_whitespace
        when .ascii_letter?
          if is_key
            @token.type = :element if @token.type == :none
            @token.key << @current
          else
            @token.attributes << read_attr_key
          end
        else
          unexpected_char
        end

        next_char
      end

      return next_token if @token.type == :head
      read_value
      close_key = [] of Char
      skip_whitespace

      loop do
        case @current
        when '<'
          next_char
          unless @current == '/'
            raise "expected closing bracket, got '#{@current}'"
          end
        when '>', '\0'
          break
        when .ascii_letter?
          close_key << @current
        when .ascii_number?
          raise "cannot use numbers in keys"
        else
          unexpected_char
        end

        next_char
      end

      unless @token.key.join == close_key.join
        raise "mismatched closing keys (line %d, column %d)" % [@token.line, @token.column]
      end

      next_token
    end

    def read_value : Nil
      next_char

      loop do
        case @current
        when '<', '\0'
          break
        when .ascii_alphanumeric?
          @token.value << @current
        else
          unexpected_char
        end

        next_char
      end
    end

    private def unexpected_char
      raise "unexpected character '%s' (line %d, column %d)" % [
        @current, @token.line, @token.column
      ]
    end
  end
end