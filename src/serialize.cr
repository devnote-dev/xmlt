require "xml"
require "./annotations"

module XMLT
  module Serializable
    def to_xml : String
      {% begin %}
        {% props = {} of Nil => Nil %}
        {% for ivar in @type.instance_vars %}
          {% anno_field = ivar.annotation(Field) %}
          {% unless anno_field && anno_field[:ignore] %}
            {% props[ivar.id] = {
              type:       ivar.type,
              key:        ((anno_field && anno_field[:key]) || ivar).id.stringify,
              item_key:   (anno_field && anno_field[:item_key]),
              omit_null:  (anno_field && anno_field[:omit_null]) || false
            } %}
          {% end %}
        {% end %}

        str = XML.build do |xml|
          xml.element({{ @type.id.stringify }}) do
            {% for name, prop in props %}
            case value = {{ name }}
            when Number, String, Char, Bool
              xml.element({{ name.id.stringify }}) { xml.text value.to_s }
            when Nil
              {% if props[:omit_null] %}
              next
              {% else %}
              xml.element({{ name.id.stringify }}) { }
              {% end %}
            when Array, Tuple
              xml.element({{ name.id.stringify }}) do
                value.each do |i|
                  xml.element({{ props[:item_key] ? props[:item_key].id.stringify : "item" }}) do
                    xml.text i.to_s
                  end
                end
              end
            when Hash, NamedTuple
              xml.element({{ name.id.stringify }}) do
                value.each do |k, v|
                  xml.element(k.to_s) { xml.text v.to_s }
                end
              end
            else
              on_serialize_error {{ name.id.stringify }}
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
