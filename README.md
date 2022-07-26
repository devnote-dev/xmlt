# XML Transformer
A library for serializing and deserializing XML documents with classes and structs. This follows the same includable syntax used in the standard library's JSON and YAML modules.

## Installation
1. Add the dependency to your `shard.yml`:

```yaml
dependencies:
  xmlt:
    github: devnote-dev/xmlt
```

2. Run `shards install`

## Basic Usage
```crystal
require "xmlt"

xml_str = %(<Numbers><one>1</one><two>2</two><three>3</three></Numbers>)
hash = Hash(String, Int32).from_xml xml_str, root: "Numbers"
puts hash # => {"one" => 1, "two" => 2, "three" => 3}

puts hash.to_xml # => <one>1</one><two>2</two><three>3</three>
```

## Structured Usage
```crystal
require "xmlt"

class Animal
  # include the module so we can (de)serialize it
  include XMLT::Serializable

  property name : String
  @[XMT::Field(key: "species")]
  property kind : String
  @[XMLT::Field(omit_nil: true)]
  property family : String?

  def initialize(@name, @kind, @family = nil)
  end
end

fox = Animal.new "fox", "mammal"
fox.to_xml # => <Animal><species>mammal</species></Animal>

fox.family = "dog"
fox.to_xml # => <Animal><species>mammal</species><family>dog</family></Animal>
```

## Contributing
1. Fork it (<https://github.com/devnote-dev/xmlt/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors
- [Devonte](https://github.com/devnote-dev) - creator and maintainer

This repository is managed under the MIT license.

© 2022 devnote-dev
