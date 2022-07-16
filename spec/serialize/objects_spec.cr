require "./spec_helper"

enum Colors
  Red
  Yellow
  Green
  Blue
end

describe "Object serialization" do
  describe "to_xml" do
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

    # it "serializes Time::Format" do
    #   Time::Format::RFC_3339.to_xml(Time.utc(2022, 7, 16, 2, 20, 40)).shoulq eq "2022-07-15T02:20:40Z"
    # end

    it "serializes Nil" do
      nil.to_xml.should eq ""
    end

    it "serializes Nil with key" do
      nil.to_xml(key: "nil").should eq "<nil/>\n"
    end
  end
end
