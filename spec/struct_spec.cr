require "./spec_helper"

struct Location
  include XMLT::Serializable

  @[XMLT::Field(key: "lat")]
  property latitude : Float64
  @[XMLT::Field(key: "long")]
  property longitude : Float64

  def initialize(@latitude, @longitude)
  end
end

@[XMLT::Options(version: "2.0")]
struct Place
  include XMLT::Serializable

  property name : String
  property location : Location
  @[XMLT::Field(ignore_serialize: true)]
  property country : String?

  def initialize(@name, @location, @country = nil)
  end
end

describe "Struct (de)serialization" do
  it "serializes a struct" do
    loc = Location.new 0.0709, 51.4221
    place = Place.new "Crystal Palace", loc, "England"
    place.to_xml.should eq %(<?xml version="2.0"?>\n<Place><name>Crystal Palace</name></Place>\n)
  end

  it "deserializes to a struct" do
    xml_str = %(<Place><name>Crystal Palace</name><location><lat>0.0709</lat><long>51.4221</long></location></Place>)
    place = Place.from_xml xml_str

    place.name.should eq "Crystal Palace"
    place.location.latitude.should eq 0.0709
    place.location.longitude.should eq 51.4221
    place.country.should be_nil
  end
end
