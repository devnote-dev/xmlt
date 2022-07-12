require "xml"
require "./annotations"

module XMLT
  # The `XMLT::Serializable` module generates methods for serializing and deserializing
  # classes or structs when included.
  #
  # ### Example
  # ```
  # require "xmlt"
  #
  # class Location
  #   include XMLT::Serializable
  #
  #   @[XMLT::Field(key: "lat")]
  #   property latitude : Float64
  #   @[XMLT::Field(key: "long")]
  #   property longitude : Float64
  # end
  #
  # class House
  #   include XMLT::Serializable
  #
  #   property address : String
  #   @[XMLT::Field(omit_nil: true)]
  #   property location : Location?
  # end
  #
  # xml = <<-XML
  #   <House>
  #     <address>Crystal Palace</address>
  #     <location>
  #       <long>51.4221</long>
  #       <lat>0.0709</lat>
  #     </location>
  #   </House>
  # XML
  #
  # house = House.from_xml xml, root: "House"
  # pp house # =>
  # # House(
  # #   @address="Crystal Palace",
  # #   @location=Location(
  # #     @latitude=0.0709,
  # #     @longitude=51.4221
  # #   )
  # # )
  #
  # puts house.to_xml # =>
  # # <House>
  # #   <address>Crystal Palace</address>
  # #   <location>
  # #     <long>51.4221</long>
  # #     <lat>0.0709</lat>
  # #   </location>
  # # </House>
  # ```
  #
  # ### Usage
  # Including `XMLT::Serializable` will create `#to_xml` methods for all methods on the
  # class or struct. These methods serialize serialize their value to an XML format with
  # the key being the name of the property unless overriden. Nil values will serialize to
  # a self-closing element unless omitted, whereas empty values (e.g. empty strings) will
  # serialize to a normal empty element.
  #
  # ### Annotations
  # How properties are serialized and deserialized can be modified using annotations:
  # * `XMLT::Attributes`: defines the attributes to be serialized with the property
  # * `XMLT::CData`: sets the property to be (de)serialized as CData
  # * `XMLT::Field`: sets general (de)serialization options
  # * `XMLT::Options`: sets the XML document and indent options
  module Serializable
    def to_xml : String
      {% begin %}
        {% props = {} of Nil => Nil %}
        {% for ivar in @type.instance_vars %}
          {% anno_field = ivar.annotation(Field) %}
          {% anno_attrs = ivar.annotation(Attributes) %}
          {% anno_cdata = ivar.annotation(CData) %}
          {% unless anno_field && anno_field[:ignore] %}
            {% props[ivar.id] = {
                key:      ((anno_field && anno_field[:key]) || ivar).id.stringify,
                item_key: (anno_field && anno_field[:item_key]),
                omit_nil: (anno_field && anno_field[:omit_nil]),
                attrs:    (anno_attrs && anno_attrs.named_args),
                cdata:    !!anno_cdata,
            } %}
          {% end %}
        {% end %}

        {% anno_ops = @type.annotation(Options) %}
        %version = {{ (anno_ops && anno_ops[:version]) || nil }}
        %encoding = {{ anno_ops && anno_ops[:encoding] || nil }}
        %indent = {{ anno_ops && anno_ops[:indent] || nil }}
        str = XML.build(%version, %encoding, %indent) do |xml|
          xml.element({{ @type.id.stringify }}) do
            {% for name, prop in props %}
              value = {{ name }}
              attrs = {{ prop[:attrs] }}
              {% if prop[:cdata] %}
                xml.cdata value.to_s
                xml.attributes(attrs) if attrs
              {% else %}
                case value
                when Number, String, Char, Bool, Symbol, Path, Enum, Hash, NamedTuple, Range, Time
                  xml.element({{ prop[:key] }}) do
                    value.to_xml xml
                    xml.attributes(attrs) if attrs
                  end
                when Nil
                  {% unless prop[:omit_nil] %}
                    xml.element({{ prop[:key] }}) { xml.attributes(attrs) if attrs }
                  {% end %}
                when Array, Deque, Tuple, Set
                  xml.element({{ prop[:key] }}) do
                    value.to_xml xml, {{ prop[:item_key] }}
                    xml.attributes(attrs) if attrs
                  end
                else
                  on_serialize_error value.to_s
                end
              {% end %}
            {% end %}
          end
        end

        str
      {% end %}
    end

    def on_serialize_error(key : String)
    end

    macro included
      def self.new(xml : XML::Node, *, root : String? = nil)
        root ||= {{ @type.id.stringify }}
        if node = xml.children.find { |n| n.name == root }
          from_xml_node node
        else
          raise "Root element '#{root}' not found"
        end
      end

      private def self.from_xml_node(xml : XML::Node)
        instance = allocate
        instance.initialize __xml_deserializable: xml
        GC.add_finalizer(instance) if instance.responds_to? :finalize
        instance
      end

      macro inherited
        def self.new(xml : XML::Node)
          from_xml_node xml
        end
      end
    end

    def initialize(*, __xml_deserializable xml : XML::Node)
      {% begin %}
        {% props = {} of Nil => Nil %}
        {% for ivar in @type.instance_vars %}
          {% anno_field = ivar.annotation(Field) %}
          {% props[ivar.id] = {
              type:        ivar.type,
              key:         ((anno_field && anno_field[:key]) || ivar).id.stringify,
              has_default: ivar.has_default_value? || ivar.type.nilable?,
              default:     ivar.default_value,
          } %}
          %var{props[ivar.id][:key]} = nil
        {% end %}

        {% for name, prop in props %}
          if node = xml.children.find { |n| n.name == {{ prop[:key] }} }
            begin
              %var{name} = {{ prop[:type] }}.from_xml node
            rescue
              raise "Failed to deserialize '#{{{ name.id.stringify }}}' to type #{{{ prop[:type].id.stringify }}}"
            end
          elsif {{ prop[:has_default] }}
            %var{name} = {{ prop[:default] }}
          else
            raise "Missing XML element '#{{{ prop[:key] }}}'"
          end
        {% end %}

        {% for name, prop in props %}
          if %var{name}.nil? !{{ prop[:default] }} && !Union({{ prop[:type] }}).nilable?
            raise "Missing XML element '#{{{ prop[:key] }}}'"
          else
            @{{ name }} = %var{name}
          end
        {% end %}
      {% end %}
    end
  end
end
