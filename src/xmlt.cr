require "./lexer.cr"
require "./structs.cr"

module XMLT
  VERSION = "0.1.0"
end

tokens = XMLT::Lexer.new(%(<?xml encoding="utf-8" version="1.0"?><one>1</one>)).parse
puts tokens
