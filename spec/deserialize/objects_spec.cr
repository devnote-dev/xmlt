require "../spec_helper"

private enum Colors
  Red
  Yellow
  Green
  Blue
end

describe "Object deserialization" do
  describe "from_xml" do
    it "deserializes to Int32" do
      Int.from_xml("<num>123</num>").should eq 123
    end

    it "deserializes to Float32" do
      Float.from_xml("<flt>12.34</flt>").should eq 12.34
    end

    it "deserializes to String" do
      String.from_xml("<str>foo bar</str>").should eq "foo bar"
    end

    it "deserializes to Bool" do
      Bool.from_xml("<bool>true</bool>").should eq true
      Bool.from_xml("<bool>false</bool>").should eq false
    end

    it "deserializes to Char" do
      Char.from_xml("<chr>e</chr>").should eq 'e'
    end

    it "deserializes to Path" do
      Path.from_xml("<path>/home</path>").should eq Path["/home"]
    end

    it "deserializes to Array(String)" do
      Array(String).from_xml("<arr><item>foo</item><item>bar</item><item>baz</item></arr>").should eq ["foo", "bar", "baz"]
    end

    it "deserializes to Deque(Int32)" do
      Deque(Int32).from_xml("<deq><item>1</item><item>2</item><item>3</item><item>4</item></deq>").should eq Deque{1, 2, 3, 4}
    end

    it "deserializes to Tuple(Float32)" do
      Tuple(String, String, String).from_xml("<deq><item>foo</item><item>bar</item><item>baz</item></deq>").should eq({"foo", "bar", "baz"})
    end

    it "deserializes to Set(Float32)" do
      Set(Float64).from_xml("<set><item>0.12</item><item>34.5</item><item>678.9</item></set>").should eq Set{0.12, 34.5, 678.9}
    end

    it "deserializes to an Enum" do
      Colors.from_xml("<col><Green/></col>").should eq Colors::Green
      Colors.from_xml("<col><yellow></yellow></col>").should eq Colors::Yellow
    end

    it "deserializes to Hash(String, Int32)" do
      Hash(String, Int32).from_xml("<hash><foo>123</foo><bar>456</bar><baz>789</baz></hash>").should eq({"foo" => 123, "bar" => 456, "baz" => 789})
    end

    it "deserializes to NamedTuple(foo: String, baz: Int32)" do
      NamedTuple(foo: String, baz: Int32).from_xml("<ntup><foo>bar</foo><baz>123</baz></ntup>").should eq({foo: "bar", baz: 123})
    end

    it "deserializes to Range(Int32, Int32)" do
      Range(Int32, Int32).from_xml("<rng><item>1</item><item>2</item><item>3</item><item>4</item><item>5</item></rng>").should eq 1..5
    end

    it "deserializes to Time" do
      Time.from_xml("<time>2022-07-16T02:20:40Z</time>").should eq Time.utc(2022, 7, 16, 2, 20, 40)
    end

    it "deserializes to Nil" do
      Nil.from_xml("").should eq nil
    end
  end
end
