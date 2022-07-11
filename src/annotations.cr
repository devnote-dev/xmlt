module XMLT
  # Defines the XML attributes to be serialized with the property it is annotated with.
  # This accepts key-value pairs that will be serialized directly with the property.
  #
  # ### Example
  # ```
  # require "xmlt"
  #
  # struct Shape
  #   include XMLT::Serializable
  #
  #   @[XMLT::Attributes(dimension: 2)]
  #   property name : String
  #
  #   def initialize(@name); end
  # end
  #
  # square = Shape.new "square"
  # puts square.to_xml # => <Shape><name dimension="2">square</name></Shape>
  annotation Attributes; end

  # Marks the property to be serialized as CData or deserialized from CData.
  #
  # ### Example
  # ```
  # require "xmlt"
  #
  # struct Multiple
  #   include XMLT::Serializable
  #
  #   property number : Int32
  #   @[XMLT::CData]
  #   property multiples : Array(Int32)
  #
  #   def initialize(@number)
  #     @multiples = (1..10).map &.* @number
  #   end
  # end
  #
  # mult = Multiple.new 4
  # puts mult.to_xml # =>
  # # <?xml version="1.0"?>
  # # <Multiple><number>4</number><![CDATA[[4, 8, 12, 16, 20, 24, 28, 32, 36, 40]]]></Multiple>
  annotation CData; end

  # Modifies the serialization and deserialization of a property based on the keys set.
  # Not all keys work for serializing or deserializing, see the available keys to find
  # out which apply to serializing/deserializing.
  #
  # ### Available keys:
  # **key**: the name of the property or element to serialize to / deserialize from
  # (default is the property name).
  #
  # **item_key**: the name of the item key, this only applies to Arrays, Deques, Tuples,
  # and Sets (default is "item").
  #
  # **ignore**: ignore the field when serializing and deserializing (default is false).
  #
  # **omit_nil**: ignore serializing the property if it is nil (default is false).
  annotation Field; end

  # Defines the XML document options and indent option for the serializer.
  #
  # Available keys:
  # **version**: the XML document version (default is "1.0").
  #
  # **encoding**: the XML document encoding type (default is empty/nil).
  #
  # **indent**: the indent level for formatting the serialized XML document
  # (default is empty/nil). Accepted values are: integer, string.
  annotation Options; end
end
