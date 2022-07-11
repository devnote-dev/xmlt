require "xml"

struct Int
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

struct Float
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

class String
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
end

struct Bool
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

struct Char
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

struct Symbol
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
end

class Array
  def to_xml(*, key : String = "item", indent = nil) : String
    XML.build_fragment(indent: indent) do |xml|
      each { |i| xml.element(key) { i.to_xml xml } }
    end
  end

  def to_xml(xml : XML::Builder, key : String) : Nil
    each { |i| xml.element(key) { i.to_xml xml } }
  end
end

class Deque
  def to_xml(*, key : String = "item", indent = nil) : String
    XML.build_fragment(indent: indent) do |xml|
      each { |i| xml.element(key) { i.to_xml xml } }
    end
  end

  def to_xml(xml : XML::Builder, key : String) : Nil
    each { |i| xml.element(key) { i.to_xml xml } }
  end
end

struct Tuple
  def to_xml(*, key : String = "item", indent = nil) : String
    XML.build_fragment(indent: indent) do |xml|
      each { |i| xml.element(key) { i.to_xml xml } }
    end
  end

  def to_xml(xml : XML::Builder, key : String) : Nil
    each { |i| xml.element(key) { i.to_xml xml } }
  end
end

struct Set
  def to_xml(*, key : String = "item", indent = nil) : String
    XML.build_fragment(indent: indent) do |xml|
      each { |i| xml.element(key) { i.to_xml xml } }
    end
  end

  def to_xml(xml : XML::Builder, key : String) : Nil
    each { |i| xml.element(key) { i.to_xml xml } }
  end
end

class Hash
  def to_xml(*, indent = nil) : String
    XML.build_fragment(indent: indent) { |xml| to_xml xml }
  end

  def to_xml(xml : XML::Builder) : Nil
    each { |k, v| xml.element(k.to_s) { v.to_xml xml } }
  end
end

struct NamedTuple
  def to_xml(*, indent = nil) : String
    XML.build_fragment(indent: indent) { |xml| to_xml xml }
  end

  def to_xml(xml : XML::Builder) : Nil
    each { |k, v| xml.element(k.to_s) { v.to_xml xml } }
  end
end

struct Range
  def to_xml(*, key : String = "item", indent = nil) : String
    to_a.to_xml key: key, indent: indent
  end

  def to_xml(xml : XML::Builder) : Nil
    to_a.to_xml xml
  end
end

struct Time
  def to_xml(*, key : String? = nil, indent = nil) : String
    fmt = Time::Format::RFC_3339.format self
    if key
      XML.build_fragment(indent: indent) { |xml| xml.element(key) { xml.text fmt } }
    else
      fmt
    end
  end

  def to_xml(xml : XML::Builder) : Nil
    fmt = Time::Format::RFC_3339.format self
    xml.text fmt
  end

  struct Format
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
  def to_xml(key : String? = nil) : String
    if key
      XML.build_fragment { |xml| xml.element(key) { } }
    else
      ""
    end
  end

  def to_xml(xml : XML::Builder) : Nil
  end
end
