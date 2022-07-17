require "./spec_helper"

enum Colors
  Red
  Yellow
  Green
  Blue
end

describe "Object (de)serialization" do
  describe "to_xml:" do
    it "serializes Int32" do
      123.to_xml.should eq "123"
    end

    it "serializes Int32 with key" do
      123.to_xml(key: "num").should eq "<num>123</num>\n"
    end

    it "serializes Float32" do
      12.34.to_xml.should eq "12.34"
    end

    it "serializes Float32 with key" do
      12.34.to_xml(key: "flt").should eq "<flt>12.34</flt>\n"
    end

    it "serializes String" do
      "foo bar".to_xml.should eq "foo bar"
    end

    it "serializes String with key" do
      "foo bar".to_xml(key: "str").should eq "<str>foo bar</str>\n"
    end

    it "serializes Bool" do
      true.to_xml.should eq "true"
      false.to_xml.should eq "false"
    end

    it "serializes Bool with key" do
      true.to_xml(key: "bool").should eq "<bool>true</bool>\n"
      false.to_xml(key: "bool").should eq "<bool>false</bool>\n"
    end

    it "serializes Char" do
      'e'.to_xml.should eq "e"
    end

    it "serializes Char with key" do
      'e'.to_xml(key: "chr").should eq "<chr>e</chr>\n"
    end

    it "serializes Symbol" do
      :foo_bar.to_xml.should eq "foo_bar"
    end

    it "serializes Symbol with key" do
      :foo_bar.to_xml(key: "sym").should eq "<sym>foo_bar</sym>\n"
    end

    it "serializes Path" do
      Path["/home"].to_xml.should eq "/home"
    end

    it "serializes Path with key" do
      Path["/home"].to_xml(key: "path").should eq "<path>/home</path>\n"
    end

    it "serializes Array(Int32)" do
      [1, 2, 3, 4].to_xml.should eq "<item>1</item><item>2</item><item>3</item><item>4</item>\n"
    end

    it "serializes Array(Int32) with key" do
      [1, 2, 3, 4].to_xml(key: "i").should eq "<i>1</i><i>2</i><i>3</i><i>4</i>\n"
    end

    it "serializes Deque(String)" do
      Deque{"foo", "bar", "baz"}.to_xml.should eq "<item>foo</item><item>bar</item><item>baz</item>\n"
    end

    it "serializes Deque(String) with key" do
      Deque{"foo", "bar", "baz"}.to_xml(key: "i").should eq "<i>foo</i><i>bar</i><i>baz</i>\n"
    end

    it "serializes Tuple(Float32)" do
      {0.12, 34.5, 678.9}.to_xml.should eq "<item>0.12</item><item>34.5</item><item>678.9</item>\n"
    end

    it "serializes Tuple(Float32) with key" do
      {0.12, 34.5, 678.9}.to_xml(key: "i").should eq "<i>0.12</i><i>34.5</i><i>678.9</i>\n"
    end

    it "serializes Set(String)" do
      Set{"foo", "bar", "baz"}.to_xml.should eq "<item>foo</item><item>bar</item><item>baz</item>\n"
    end

    it "serializes Set(String) with key" do
      Set{"foo", "bar", "baz"}.to_xml(key: "i").should eq "<i>foo</i><i>bar</i><i>baz</i>\n"
    end

    it "serializes an Enum" do
      Colors.to_xml.should eq "<Red/><Yellow/><Green/><Blue/>\n"
      Colors::Blue.to_xml.should eq "<Blue/>\n"
    end

    it "serializes Hash(String, Int32)" do
      {"foo" => 123, "bar" => 456, "baz" => 789}.to_xml.should eq "<foo>123</foo><bar>456</bar><baz>789</baz>\n"
    end

    it "serializes NamedTuple(foo: Int32, bar: String)" do
      {foo: 123, bar: "baz"}.to_xml.should eq "<foo>123</foo><bar>baz</bar>\n"
    end

    it "serializes Range(Int32, Int32)" do
      (1..5).to_xml.should eq "<item>1</item><item>2</item><item>3</item><item>4</item><item>5</item>\n"
    end

    it "serializes Range(Int32, Int32) with key" do
      (1..5).to_xml(key: "i").should eq "<i>1</i><i>2</i><i>3</i><i>4</i><i>5</i>\n"
    end

    it "serializes Time" do
      Time.utc(2022, 7, 16, 2, 20, 40).to_xml.should eq "2022-07-16T02:20:40Z"
    end

    it "serializes Time with key" do
      Time.utc(2022, 7, 16, 2, 20, 40).to_xml(key: "time").should eq "<time>2022-07-16T02:20:40Z</time>\n"
    end

    it "serializes Nil" do
      nil.to_xml.should be_empty
    end

    it "serializes Nil with key" do
      nil.to_xml(key: "nil").should eq "<nil/>\n"
    end
  end

  describe "from_xml:" do
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
      Nil.from_xml("").should be_nil
    end
  end
end
