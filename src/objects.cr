require "xml"

class Object
  def self.from_xml(xml : String, *, root : String? = nil)
    new XML.parse(xml, XML::ParserOptions::NOBLANKS), root: root
  end
end

struct Int
  # Returns an XML string representation of the object.
  def to_xml(*, key : String? = nil, indent = nil) : String
    if key
      XML.build_fragment(indent: indent) { |xml| xml.element(key) { xml.text to_s } }
    else
      to_s
    end
  end

  def to_xml(xml : XML::Builder) : Nil
    xml.text to_s
  end

  def self.from_xml(value : String)
    value.to_i
  end

  def self.from_xml(node : XML::Node)
    node.content.to_i
  end
end

struct Float
  # Returns an XML string representation of the object.
  def to_xml(*, key : String? = nil, indent = nil) : String
    if key
      XML.build_fragment(indent: indent) { |xml| xml.element(key) { xml.text to_s } }
    else
      to_s
    end
  end

  def to_xml(xml : XML::Builder) : Nil
    xml.text to_s
  end

  def self.from_xml(value : String)
    value.to_f
  end

  def self.from_xml(node : XML::Node)
    node.content.to_f
  end
end

class String
  # Returns an XML string representation of the object.
  def to_xml(*, key : String? = nil, indent = nil) : String
    if key
      XML.build_fragment(indent: indent) { |xml| xml.element(key) { xml.text self } }
    else
      self
    end
  end

  def to_xml(xml : XML::Builder) : Nil
    xml.text self
  end

  def self.from_xml(value : String)
    value
  end

  def self.from_xml(node : XML::Node)
    node.content
  end
end

struct Bool
  # Returns an XML string representation of the object.
  def to_xml(*, key : String? = nil, indent = nil) : String
    if key
      XML.build_fragment(indent: indent) { |xml| xml.element(key) { xml.text to_s } }
    else
      to_s
    end
  end

  def to_xml(xml : XML::Builder) : Nil
    xml.text to_s
  end

  def self.from_xml(value : String)
    case value
    when "true"   then true
    when "false"  then false
    else          raise "cannot parse value to bool"
    end
  end

  def self.from_xml(node : XML::Node)
    from_xml node.content
  end
end

struct Char
  # Returns an XML string representation of the object.
  def to_xml(*, key : String? = nil, indent = nil) : String
    if key
      XML.build_fragment(indent: indent) { |xml| xml.element(key) { xml.text to_s } }
    else
      to_s
    end
  end

  def to_xml(xml : XML::Builder) : Nil
    xml.text to_s
  end

  def self.from_xml(value : String)
    raise("invalid character sequence") if value.chars.size > 1
    value.chars[0] || '\0'
  end

  def self.from_xml(node : XML::Node)
    from_xml node.content
  end
end

struct Symbol
  # Returns an XML string representation of the object.
  def to_xml(*, key : String? = nil, indent = nil) : String
    if key
      XML.build_fragment(indent: indent) { |xml| xml.element(key) { xml.text to_s } }
    else
      to_s
    end
  end

  def to_xml(xml : XML::Builder) : Nil
    xml.text to_s
  end
end

struct Path
  # Returns an XML string representation of the object.
  def to_xml(*, key : String? = nil, indent = nil) : String
    if key
      XML.build_fragment(indent: indent) { |xml| xml.element(key) { xml.text @name } }
    else
      @name
    end
  end

  def to_xml(xml : XML::Builder) : Nil
    xml.text @name
  end

  def self.from_xml(value : String)
    new value
  end

  def self.from_xml(node : XML::Node)
    new node.content
  end
end

class Array(T)
  # Returns an XML string representation of the object.
  def to_xml(*, key : String = "item", indent = nil) : String
    XML.build_fragment(indent: indent) do |xml|
      each { |i| xml.element(key) { i.to_xml xml } }
    end
  end

  def to_xml(xml : XML::Builder, key : String) : Nil
    each { |i| xml.element(key) { i.to_xml xml } }
  end

  def self.from_xml(value : String)
    from_xml XML.parse value
  end

  def self.from_xml(node : XML::Node)
    arr = new
    node.children.each do |node|
      arr << T.from_xml node
    end
    arr
  end
end

class Deque(T)
  # Returns an XML string representation of the object.
  def to_xml(*, key : String = "item", indent = nil) : String
    XML.build_fragment(indent: indent) do |xml|
      each { |i| xml.element(key) { i.to_xml xml } }
    end
  end

  def to_xml(xml : XML::Builder, key : String) : Nil
    each { |i| xml.element(key) { i.to_xml xml } }
  end

  def self.from_xml(node : XML::Node)
    deq = new
    node.children.each do |node|
      deq << T.from_xml node
    end
    deq
  end
end

struct Tuple(*T)
  # Returns an XML string representation of the object.
  def to_xml(*, key : String = "item", indent = nil) : String
    XML.build_fragment(indent: indent) do |xml|
      each { |i| xml.element(key) { i.to_xml xml } }
    end
  end

  def to_xml(xml : XML::Builder, key : String) : Nil
    each { |i| xml.element(key) { i.to_xml xml } }
  end

  def self.from_xml(value : String)
    from_xml XML.parse value
  end

  def self.from_xml(node : XML::Node)
    {% begin %}
      new(
        {% for i in 0...T.size %}
          (self[{{ i }}].from_xml node.children[{{ i }}]),
        {% end %}
      )
    {% end %}
  end
end

struct Set(T)
  # Returns an XML string representation of the object.
  def to_xml(*, key : String = "item", indent = nil) : String
    XML.build_fragment(indent: indent) do |xml|
      each { |i| xml.element(key) { i.to_xml xml } }
    end
  end

  def to_xml(xml : XML::Builder, key : String) : Nil
    each { |i| xml.element(key) { i.to_xml xml } }
  end

  def self.from_xml(value : String)
    from_xml XML.parse value
  end

  def self.from_xml(node : XML::Node)
    set = new
    node.children.each do |node|
      set << T.from_xml node
    end
    set
  end
end

struct Enum
  # Returns an XML string representation of all the members in the enum.
  def self.to_xml(*, key : String? = nil, indent = nil) : String
    if key
      XML.build_fragment(indent: indent) do |xml|
        names.each { |n| xml.element(key) { xml.text n } }
      end
    else
      XML.build_fragment(indent: indent) do |xml|
        names.each { |n| xml.element(n) { } }
      end
    end
  end

  # Returns an XML string representation of the object.
  def to_xml(*, indent = nil) : String
    XML.build_fragment(indent: indent) do |xml|
      xml.element(to_s) { }
    end
  end

  def to_xml(xml : XML::Builder) : Nil
    xml.element(to_s) { }
  end

  def self.from_xml(value : String)
    from_xml XML.parse value
  end

  def self.from_xml(node : XML::Node)
    parse node.children.empty? ? node.name : node.children[0].name
  end
end

struct Union(*T)
  def self.from_xml(node : XML::Node)
    {% begin %}
      if T.types.includes? Nil
        return nil
      {% for type in %w(Int Float String Bool) %}
      elsif T.types.includes? {{ type.id }}
        return {{ type.id }}.from_xml node
      {% end %}
      end

      {% primitives = [String, Bool, Nil] + Number::Primitive.union_types %}
      {% non_primitives = T.reject { |t| primitives.includes? t } %}

      {% if non_primitives.size == 1 %}
        return {{ non_primitives[0] }}.from_xml node
      {% else %}
        {% for type in non_primitives %}
          begin
            value = {{ type.id }}.to_xml node
            return value if value
          rescue
          end
        {% end %}
      {% end %}

      raise "Couldn't parse #{self} from element"
    {% end %}
  end
end

class Hash(K, V)
  # Returns an XML string representation of the object.
  def to_xml(*, indent = nil) : String
    XML.build_fragment(indent: indent) { |xml| to_xml xml }
  end

  def to_xml(xml : XML::Builder) : Nil
    each { |k, v| xml.element(k.to_s) { v.to_xml xml } }
  end

  def self.from_xml(value : String)
    from_xml XML.parse value
  end

  def self.from_xml(node : XML::Node)
    hash = new
    node.children.each do |n|
      hash[n.name.as?(K) || K.from_xml(n)] = V.from_xml n
    end
    hash
  end
end

struct NamedTuple
  # Returns an XML string representation of the object.
  def to_xml(*, indent = nil) : String
    XML.build_fragment(indent: indent) { |xml| to_xml xml }
  end

  def to_xml(xml : XML::Builder) : Nil
    each { |k, v| xml.element(k.to_s) { v.to_xml xml } }
  end

  def self.from_xml(value : String)
    from_xml XML.parse value
  end

  def self.from_xml(node : XML::Node)
    {% begin %}
      {% for key, type in T %}
        if child = node.children.find { |n| n.name == {{ key.id.stringify }} }
          %var{key.id} = self[{{ key.symbolize }}].from_xml child
        elsif {{ type }}.nilable?
          %var{key.id} = nil
        else
          raise "Missing XML element '#{{{ key.id.stringify }}}'"
        end
      {% end %}

      new(
        {% for key, type in T %}
          {{ key.id.stringify }}: %var{key.id}.as({{ type }}),
        {% end %}
      )
    {% end %}
  end
end

struct Range(B, E)
  # Returns an XML string representation of the object.
  def to_xml(*, key : String = "item", indent = nil) : String
    to_a.to_xml key: key, indent: indent
  end

  def to_xml(xml : XML::Builder) : Nil
    to_a.to_xml xml
  end

  def self.from_xml(value : String)
    from_xml XML.parse value
  end

  def self.from_xml(node : XML::Node)
    b = B.from_xml node.children.first
    e = E.from_xml node.children.to_a.last
    new b, e
  end
end

struct Time
  # Returns an XML string representation of the object.
  def to_xml(*, key : String? = nil, indent = nil) : String
    fmt = Format::RFC_3339.format self
    if key
      XML.build_fragment(indent: indent) { |xml| xml.element(key) { xml.text fmt } }
    else
      fmt
    end
  end

  def to_xml(xml : XML::Builder) : Nil
    fmt = Format::RFC_3339.format self
    xml.text fmt
  end

  def self.from_xml(value : String)
    Format::RFC_3339.parse value
  end

  def self.from_xml(node : XML::Node)
    Format::RFC_3339.parse node.content
  end

  struct Format
    # Returns an XML string representation of the object.
    def to_xml(value : Time, *, key : String? = nil, indent = nil) : String
      fmt = format value
      if key
        XML.build_fragment(indent: indent) { |xml| xml.element(key) { xml.text fmt } }
      else
        fmt
      end
    end

    def to_xml(value : Time, xml : XML::Builder) : Nil
      format(value).to_xml xml
    end
  end
end

struct Nil
  # Returns an XML string representation of the object.
  def to_xml(key : String? = nil) : String
    if key
      XML.build_fragment { |xml| xml.element(key) { } }
    else
      ""
    end
  end

  def to_xml(_x) : Nil
  end

  def self.from_xml(_x)
  end
end
