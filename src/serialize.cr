require "xml"
require "./annotations"

module XMLT
  module Serializable
    def to_xml : String
      {% begin %}
        {% props = {} of Nil => Nil %}
        {% anno_ops = @type.annotation(Options) %}
        {% for ivar in @type.instance_vars %}
          {% anno_field = ivar.annotation(Field) %}
          {% unless anno_field && anno_field[:ignore] %}
            {% props[ivar.id] = {
              key:        ((anno_field && anno_field[:key]) || ivar).id.stringify,
              item_key:   (anno_field && anno_field[:item_key]),
              omit_null:  (anno_field && anno_field[:omit_null]) || false
            } %}
          {% end %}
        {% end %}

        str = XML.build({{ anno_ops[:version] }}, {{ anno_ops[:encoding] }}, {{ anno_ops[:indent] }}) do |xml|
          xml.element({{ @type.id.stringify }}) do
            {% for name, prop in props %}
            case value = {{ name }}
            when Number, String, Char, Bool, Symbol, Path
              xml.element({{ prop[:key] }}) { xml.text value.to_s }
            when Nil
              {% if prop[:omit_null] %}
              next
              {% else %}
              xml.element({{ prop[:key] }}) { }
              {% end %}
            when Array, Tuple, Set
              xml.element({{ prop[:key] }}) do
                value.each do |i|
                  xml.element({{ (prop[:item_key] && prop[:item_key].id.stringify) || "item" }}) do
                    xml.text i.to_s
                  end
                end
              end
            when Hash, NamedTuple
              xml.element({{ prop[:key] }}) do
                value.each do |k, v|
                  xml.element(k.to_s) { xml.text v.to_s }
                end
              end
            when Time
              xml.element({{ prop[:key] }}) do
                xml.text Time::Format::RFC_3339.format value
              end
            else
              on_serialize_error {{ prop[:key] }}
            end
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
