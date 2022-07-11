require "./annotations"
require "./objects"
require "./serialize"

# A library for serializing and deserializing XML documents with classes and structs.
# This follows the same includable syntax used in the standard library's JSON and YAML modules.
#
# ### Basic Usage
# ```
# require "xmlt"
#
# xml_str = %(<Numbers><one>1</one><two>2</two><three>3</three></Numbers>)
# hash = Hash(String, Int32).from_xml xml_str, root: "Numbers"
# puts hash # => {"one" => 1, "two" => 2, "three" => 3}
#
# puts hash.to_xml # => <one>1</one><two>2</two><three>3</three>
# ```
#
# ### Structured Usage
# ```
# require "xmlt"
#
# class Animal
#   # include the module so we can (de)serialize it
#   include XMLT::Serializable
#
#   property name : String
#   @[XMT::Field(key: "species")]
#   property kind : String
#   @[XMLT::Field(omit_nil: true)]
#   property family : String?
#
#   def initialize(@name, @kind, @family = nil)
#   end
# end
#
# fox = Animal.new "fox", "mammal"
# fox.to_xml # => <Animal><species>mammal</species></Animal>
#
# fox.family = "dog"
# fox.to_xml # => <Animal><species>mammal</species><family>dog</family></Animal>
module XMLT
  VERSION = "0.1.0"
end
