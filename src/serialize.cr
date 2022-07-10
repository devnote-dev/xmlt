require "xml"
require "./annotations"

module XMLT
  module Serializable
    def to_xml : String
      {% begin %}
        {% props = {} of Nil => Nil %}
        {% for ivar in @type.instance_vars %}
          {% anno = ivar.annotation(Field) %}
          {% props[ivar.id] = {
            type: ivar.type,
            key:  (anno && anno[:key]) || ivar.id.stringify,
            root: (anno && anno[:root]) || ""
          } %}
        {% end %}

        str = XML.build do |xml|
          xml.element({{ @type.id.stringify }}) do
            {% for name, prop in props %}
            xml.element({{ name.id.stringify }}) { xml.text @{{ name }}.to_s }
            {% end %}
          end
        end

        str
      {% end %}
    end
  end
end
