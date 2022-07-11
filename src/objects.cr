require "xml"

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
end

class Array
  # Returns an XML string representation of the object.
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
  # Returns an XML string representation of the object.
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
  # Returns an XML string representation of the object.
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
  # Returns an XML string representation of the object.
  def to_xml(*, key : String = "item", indent = nil) : String
    XML.build_fragment(indent: indent) do |xml|
      each { |i| xml.element(key) { i.to_xml xml } }
    end
  end

  def to_xml(xml : XML::Builder, key : String) : Nil
    each { |i| xml.element(key) { i.to_xml xml } }
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
      xml.element(to_s.underscore) { }
    end
  end

  def to_xml(xml : XML::Builder) : Nil
    xml.text to_s.underscore
  end
end

class Hash
  # Returns an XML string representation of the object.
  def to_xml(*, indent = nil) : String
    XML.build_fragment(indent: indent) { |xml| to_xml xml }
  end

  def to_xml(xml : XML::Builder) : Nil
    each { |k, v| xml.element(k.to_s) { v.to_xml xml } }
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
end

struct Range
  # Returns an XML string representation of the object.
  def to_xml(*, key : String = "item", indent = nil) : String
    to_a.to_xml key: key, indent: indent
  end

  def to_xml(xml : XML::Builder) : Nil
    to_a.to_xml xml
  end
end

struct Time
  # Returns an XML string representation of the object.
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

  def to_xml(xml : XML::Builder) : Nil
  end
end
