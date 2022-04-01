require "./lexer.cr"
require "./structs.cr"

module XMLT
  VERSION = "0.1.0"
end

xml = <<-XML
<?xml version="1.0" encoding="utf-8"?>
<Person>
  <firstname>foo</firstname>
  <lastname>bar</lastname>
  <!-- <gender>baz</male> -->
</Person>
XML

tokens = XMLT::Lexer.new(xml).parse
puts tokens
