require "spec_helper"

describe Mongoid::Fields::Internal::Object do

  describe "#cast_on_read?" do

    let(:field) do
      described_class.instantiate(:test)
    end

    it "returns false" do
      field.should_not be_cast_on_read
    end
  end

  describe "#eval_default" do

    context "when the default value is a proc" do

      let(:field) do
        described_class.instantiate(:test, :default => lambda { 1 })
      end

      it "returns the called proc" do
        field.eval_default(nil).should eq(1)
      end
    end

    context "when the default value is not a proc" do

      let(:field) do
        described_class.instantiate(:test, :default => "test")
      end

      it "returns the default value" do
        field.default_val.should eq("test")
      end
    end
  end

  describe "#deserialize" do

    let(:field) do
      described_class.instantiate(:test)
    end

    let(:value) do
      field.deserialize("testing")
    end

    it "returns the provided value" do
      value.should eq("testing")
    end
  end

  describe "#initialize" do

    let(:field) do
      described_class.instantiate(:test, :type => Integer, :label => "test")
    end

    it "sets the name" do
      field.name.should eq(:test)
    end

    it "sets the label" do
      field.label.should eq("test")
    end

    it "sets the options" do
      field.options.should eq({ :type => Integer, :label => "test" })
    end
  end

  describe ".option" do

    let(:options) do
      Mongoid::Fields.options
    end

    let(:handler) do
      proc {}
    end

    it "stores the custom option in the options hash" do
      options.expects(:[]=).with(:option, handler)
      Mongoid::Fields.option(:option, &handler)
    end
  end

  describe ".options" do

    it "returns a hash of custom options" do
      Mongoid::Fields.options.should be_a Hash
    end

    it "is memoized" do
      Mongoid::Fields.options.should
        equal(Mongoid::Fields.options)
    end
  end

  describe "#selection" do

    let(:field) do
      described_class.instantiate(:test)
    end

    context "when providing a single value" do

      it "returns the value" do
        field.selection("test").should eq("test")
      end
    end

    context "when providing a complex criteria" do

      let(:criteria) do
        { "$ne" => "test" }
      end

      it "returns the criteria" do
        field.selection(criteria).should eq(criteria)
      end
    end
  end

  describe "#serialize" do

    let(:field) do
      described_class.instantiate(:test)
    end

    let(:value) do
      field.serialize("testing")
    end

    it "returns the provided value" do
      value.should eq("testing")
    end
  end
end
