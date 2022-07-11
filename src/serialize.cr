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
            when Nil
              {% if prop[:omit_null] %}
              xml.element({{ prop[:key] }}) { }
              {% end %}
            when Array, Deque, Tuple, Set
              xml.element({{ prop[:key] }}) { value.to_xml xml, {{ prop[:item_key] }} }
            else
              xml.element({{ prop[:key] }}) { value.to_xml xml }
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
