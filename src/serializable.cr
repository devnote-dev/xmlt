require "xml"
require "./annotations"
require "./errors"

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
  #   <Place>
  #     <address>Crystal Palace</address>
  #     <location>
  #       <long>51.4221</long>
  #       <lat>0.0709</lat>
  #     </location>
  #   </Place>
  # XML
  #
  # place = Place.from_xml xml, root: "Place"
  # pp place # =>
  # # Place(
  # #   @address="Crystal Palace",
  # #   @location=Location(
  # #     @latitude=0.0709,
  # #     @longitude=51.4221
  # #   )
  # # )
  #
  # puts place.to_xml # =>
  # # <Place>
  # #   <address>Crystal Palace</address>
  # #   <location>
  # #     <long>51.4221</long>
  # #     <lat>0.0709</lat>
  # #   </location>
  # # </Place>
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
          {% unless anno_field && (anno_field[:ignore] || anno_field[:ignore_serialize]) %}
            {% anno_attrs = ivar.annotation(Attributes) %}
            {% anno_cdata = ivar.annotation(CData) %}
            {% props[ivar.id] = {
                key:      ((anno_field && anno_field[:key]) || ivar).id.stringify,
                item_key: (anno_field && anno_field[:item_key]) || "item",
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
                xml.element({{ prop[:key] }}) do
                  xml.cdata value.to_s
                  xml.attributes(attrs) if attrs
                end
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
        if xml.name == root
          from_xml_node xml
        elsif node = xml.children.find { |n| n.name == root }
          from_xml_node node
        else
          raise SerializableError.new "Root element '#{root}' not found"
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

    # Creates a new instance of the class or struct from an XML node.
    def initialize(*, __xml_deserializable xml : XML::Node)
      {% begin %}
        {% props = {} of Nil => Nil %}
        {% for ivar in @type.instance_vars %}
          {% anno_field = ivar.annotation(Field) %}
          {% unless anno_field && (anno_field[:ignore] || anno_field[:ignore_deserialize]) %}
            {% props[ivar.id] = {
                type:        ivar.type,
                key:         ((anno_field && anno_field[:key]) || ivar).id.stringify,
                has_default: ivar.has_default_value? || ivar.type.nilable?,
                default:     ivar.default_value,
                new_root:    anno_field && anno_field[:new_root]
            } %}
            %var{props[ivar.id][:key]} = nil
          {% end %}
        {% end %}

        {% for name, prop in props %}
          if node = xml.children.find { |n| n.name == {{ prop[:key] }} }
            begin
              {% if prop[:new_root] %}
                %var{name} = {{ prop[:type] }}.from_xml node, root: {{ prop[:key] }}
              {% else %} 
                %var{name} = {{ prop[:type] }}.from_xml node
              {% end %}
            rescue ex
              raise SerializableError.new ex, {{ name.id.stringify }}, {{ prop[:type].id.stringify }}
            end
          elsif {{ prop[:has_default] }}
            %var{name} = {{ prop[:default] }}
          else
            raise SerializableError.new "Missing XML element '#{{{ prop[:key] }}}'"
          end
        {% end %}

        {% for name, prop in props %}
          unless %var{name} || {{ prop[:has_default] }} || Union({{ prop[:type] }}).nilable?
            raise SerializableError.new "Missing XML element '#{{{ prop[:key] }}}'"
          else
            @{{ name }} = %var{name}.as({{ prop[:type] }})
          end
        {% end %}
      {% end %}
    end
  end
end
