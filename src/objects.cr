class Object
  def to_xml(*, indent : XMLT::IndentOptions = nil) : String
    String.build do |str|
      to_xml str
    end
  end

  def to_xml(io : IO, *, indent : XMLT::IndentOptions = nil) : Nil
    to_xml io
  end

  private def self.parse_xml(xml : String) : XML::Node
    node = XML.parse xml, XML::ParserOptions::NOBLANKS
    if child = node.first_element_child
      child
    else
      raise XMLT::Error.new "failed to parse XML from string value"
    end
  end

    def self.from_xml(node : XML::Node)
    new node
  end

  def self.from_xml(xml : String)
    from_xml parse_xml xml
  end

  def self.from_xml(node : XML::Node, *, root : String)
    new node, root: root
  end

  def self.from_xml(xml : String, *, root : String)
    from_xml parse_xml(xml), root: root
  end
end

struct Nil
  def to_xml(*, key : String? = nil, indent : XMLT::IndentOptions = nil) : String
    if key
      XML.build_fragment(indent: indent) { |xml| xml.element(key) { } }
    else
      ""
    end
  end

  def to_xml(io : IO, *, key : String? = nil, indent : XMLT::IndentOptions = nil) : Nil
    io << to_xml key: key, indent: indent
  end

  def to_xml(xml : XML::Builder) : Nil
  end

  def self.new(xml : XML::Node)
  end
end

{% for base in %w(8 16 32 64 128) %}
struct Int{{ base.id }}
  def self.new(node : XML::Node)
    node.content.to_i{{ base.id }}
  end

  def to_xml(*, key : String? = nil, indent : XMLT::IndentOptions = nil) : String
    if key
      XML.build_fragment(indent: indent) { |xml| xml.element(key) { xml.text to_s } }
    else
      to_s
    end
  end

  def to_xml(io : IO, *, key : String? = nil, indent : XMLT::IndentOptions = nil) : Nil
    io << to_xml key: key, indent: indent
  end

  def to_xml(xml : XML::Builder) : Nil
    xml.text to_s
  end
end
{% end %}

{% for base in %w(32 64) %}
struct Float{{ base.id }}
  def self.new(node : XML::Node)
    node.content.to_f{{ base.id }}
  end

  def to_xml(*, key : String? = nil, indent : XMLT::IndentOptions = nil) : String
    if key
      XML.build_fragment(indent: indent) { |xml| xml.element(key) { xml.text to_s } }
    else
      to_s
    end
  end

  def to_xml(io : IO, *, key : String? = nil, indent : XMLT::IndentOptions = nil) : Nil
    io << to_xml key: key, indent: indent
  end

  def to_xml(xml : XML::Builder) : Nil
    xml.text to_s
  end
end
{% end %}

class String
  def self.new(node : XML::Node)
    node.content.dup
  end

  def to_xml(*, key : String? = nil, indent : XMLT::IndentOptions = nil) : String
    if key
      XML.build_fragment(indent: indent) { |xml| xml.element(key) { xml.text to_s } }
    else
      to_s
    end
  end

  def to_xml(io : IO, *, key : String? = nil, indent : XMLT::IndentOptions = nil) : Nil
    io << to_xml key: key, indent: indent
  end

  def to_xml(xml : XML::Builder) : Nil
    xml.text to_s
  end
end

struct Bool
  def self.new(xml : XML::Node)
    new node.content
  end

  def to_xml(*, key : String? = nil, indent : XMLT::IndentOptions = nil) : String
    if key
      XML.build_fragment(indent: indent) { |xml| xml.element(key) { xml.text to_s } }
    else
      to_s
    end
  end

  def to_xml(io : IO, *, key : String? = nil, indent : XMLT::IndentOptions = nil) : Nil
    io << to_xml key: key, indent: indent
  end

  def to_xml(xml : XML::Builder) : Nil
    xml.text to_s
  end
end

struct Char
  def to_xml(*, key : String? = nil, indent : XMLT::IndentOptions = nil) : String
    if key
      XML.build_fragment(indent: indent) { |xml| xml.element(key) { xml.text to_s } }
    else
      to_s
    end
  end

  def to_xml(io : IO, *, key : String? = nil, indent : XMLT::IndentOptions = nil) : Nil
    io << to_xml key: key, indent: indent
  end

  def to_xml(xml : XML::Builder) : Nil
    xml.text to_s
  end

  def self.from_xml(node : XML::Node)
    raise XMLT::Error.new("invalid character sequence") unless node.content.chars.size != 1
    node.content.chars[0]
  end

  def self.from_xml(xml : String)
    from_xml parse_xml xml
  end
end

struct Symbol
  def to_xml(*, key : String? = nil, indent : XMLT::IndentOptions = nil) : String
    if key
      XML.build_fragment(indent: indent) { |xml| xml.element(key) { xml.text to_s } }
    else
      to_s
    end
  end

  def to_xml(io : IO, *, key : String? = nil, indent : XMLT::IndentOptions = nil) : Nil
    io << to_xml key: key, indent: indent
  end

  def to_xml(xml : XML::Builder) : Nil
    xml.text to_s
  end
end

struct Path
  def self.new(xml : XML::Node)
    new xml.content
  end

  def to_xml(*, key : String? = nil, indent : XMLT::IndentOptions = nil) : String
    if key
      XML.build_fragment(indent: indent) { |xml| xml.element(key) { xml.text @name } }
    else
      @name
    end
  end

  def to_xml(io : IO, *, key : String? = nil, indent : XMLT::IndentOptions = nil) : Nil
    io << to_xml key: key, indent: indent
  end

  def to_xml(xml : XML::Builder) : Nil
    xml.text @name
  end
end

class Array(T)
  def self.new(node : XML::Node)
    arr = new
    node.children.each do |child|
      arr << T.new child
    end
  end

  def to_xml(*, key : String = "item", indent : XMLT::IndentOptions = nil) : String
    XML.build_fragment(indent: indent) do |xml|
      each { |i| xml.element(key) { i.to_xml xml } }
    end
  end

  def to_xml(io : IO, *, key : String = "item", indent : XMLT::IndentOptions = nil) : Nil
    io << to_xml key: key, indent: indent
  end

  def to_xml(xml : XML::Builder, key : String) : Nil
    each { |i| xml.element(key) { i.to_xml xml } }
  end
end

class Deque(T)
  def self.new(node : XML::Node)
    deq = new
    node.children.each do |child|
      deq << T.new child
    end
  end

  def to_xml(*, key : String = "item", indent : XMLT::IndentOptions = nil) : String
    XML.build_fragment(indent: indent) do |xml|
      each { |i| xml.element(key) { i.to_xml xml } }
    end
  end

  def to_xml(io : IO, *, key : String = "item", indent : XMLT::IndentOptions = nil) : Nil
    io << to_xml key: key, indent: indent
  end

  def to_xml(xml : XML::Builder, key : String) : Nil
    each { |i| xml.element(key) { i.to_xml xml } }
  end
end

struct Tuple(*T)
  def self.new(node : XML::Node)
    {% begin %}
      new(
        {% for i in 0...T.size %}
          (self[{{ i }}].new node.children[{{ i }}]),
        {% end %}
      )
    {% end %}
  end

  def to_xml(*, key : String = "item", indent : XMLT::IndentOptions = nil) : String
    XML.build_fragment(indent: indent) do |xml|
      each { |i| xml.element(key) { i.to_xml xml } }
    end
  end

  def to_xml(io : IO, *, key : String = "item", indent : XMLT::IndentOptions = nil) : Nil
    io << to_xml key: key, indent: indent
  end

  def to_xml(xml : XML::Builder, key : String) : Nil
    each { |i| xml.element(key) { i.to_xml xml } }
  end
end

struct Union(*T)
  def self.new(node : XML::Node)
    {% begin %}
      {% for type in T %}
        {% if Number::Primitive.union_types.includes?(type) || type == Bool %}
          return {{ type }}.new node
        {% elsif type == String %}
          return node.content.dup
        {% end %}
      {% end %}
      {% primitives = [Nil, String, Bool] + Number::Primitive.union_types %}
      {% others = T.reject { |t| primitives.includes?(t) } %}
      {% if others.size == 1 %}
        return {{ others[0] }}.from_xml node
      {% else %}
        {% for type in others %}
          begin
            return {{ type }}.from_xml node
          rescue XMLT::Error
          end
        {% end %}
        {% if T.includes?(Nil) %}
          return nil
        {% else %}
          raise XMLT::Error.new "could not parse #{self} from '#{node.content}'"
        {% end %}
      {% end %}
    {% end %}
  end
end
