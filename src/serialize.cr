require "xml"
require "./annotations"

module XMLT
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
              omit_nil: (anno_field && anno_field[:omit_nil]) || false,
              attrs:    (anno_attrs && anno_attrs.named_args),
              cdata:    !!anno_cdata
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
  end
end
