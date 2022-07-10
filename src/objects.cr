require "xml"

struct Int
  def to_xml(*, key : String? = nil, indent = nil) : String
    if key
      XML.build_fragment(indent: indent) { |xml| xml.element(key) { xml.text to_s } }
    else
      to_s
    end
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
end

class String
  def to_xml(*, key : String? = nil, indent = nil) : String
    if key
      XML.build_fragment(indent: indent) { |xml| xml.element(key) { xml.text to_s } }
    else
      to_s
    end
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
end

struct Char
  def to_xml(*, key : String? = nil, indent = nil) : String
    if key
      XML.build_fragment(indent: indent) { |xml| xml.element(key) { xml.text to_s } }
    else
      to_s
    end
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
end

struct Path
  def to_xml(*, key : String? = nil, indent = nil) : String
    if key
      XML.build_fragment(indent: indent) { |xml| xml.element(key) { xml.text @name } }
    else
      @name
    end
  end
end

class Array
  def to_xml(*, key : String = "item", indent = nil) : String
    XML.build_fragment(indent: indent) do |xml|
      map(&.to_xml).each { |i| xml.element(key) { xml.text i } }
    end
  end
end

class Deque
  def to_xml(*, key : String = "item", indent = nil) : String
    XML.build_fragment(indent: indent) do |xml|
      map(&.to_xml).each { |i| xml.element(key) { xml.text i } }
    end
  end
end

struct Tuple
  def to_xml(*, key : String = "item", indent = nil) : String
    XML.build_fragment(indent: indent) do |xml|
      map(&.to_xml).each { |i| xml.element(key) { xml.text i } }
    end
  end
end

struct Set
  def to_xml(*, key : String = "item", indent = nil) : String
    XML.build_fragment(indent: indent) do |xml|
      map(&.to_xml).each { |i| xml.element(key) { xml.text i } }
    end
  end
end

class Hash
  def to_xml(*, indent = nil) : String
    XML.build_fragment(indent: indent) do |xml|
      each { |k, v| xml.element(k) { xml.text v.to_xml } }
    end
  end
end

struct NamedTuple
  def to_xml(*, indent = nil) : String
    XML.build_fragment(indent: indent) do |xml|
      each { |k, v| xml.element(k) { xml.text v.to_xml } }
    end
  end
end

struct Range
    def to_xml(*, key : String = "item", indent = nil) : String
    to_a.to_xml key: key, indent: indent
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

  struct Format
    def to_xml(value : Time, *, key : String? = nil, indent = nil) : String
      fmt = format value
      if key
        XML.build_fragment(indent: indent) { |xml| xml.element(key) { xml.text fmt } }
      else
        fmt
      end
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
end
