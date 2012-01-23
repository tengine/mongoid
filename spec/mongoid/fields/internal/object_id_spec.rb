require "spec_helper"

describe Mongoid::Fields::Internal::ObjectId do

  let(:field) do
    described_class.instantiate(:test, :type => BSON::ObjectId)
  end

  let(:object_id) do
    BSON::ObjectId.new
  end

  describe "#deserialize" do

    it "returns self" do
      field.deserialize(object_id).should eq(object_id)
    end
  end

  describe "#selection" do

    let(:object_id_string) do
      "4c52c439931a90ab29000003"
    end

    context "when providing a single value" do

      it "converts the value to an object id" do
        field.selection(object_id_string).should eq(
          BSON::ObjectId.from_string(object_id_string)
        )
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

    let(:object_id_string) do
      "4c52c439931a90ab29000003"
    end

    context "with a blank string" do

      it "returns nil" do
        field.serialize("").should be_nil
      end
    end

    context "with a populated string" do

      it "returns an object id" do
        field.serialize(object_id_string).should eq(
          BSON::ObjectId.from_string(object_id_string)
        )
      end
    end

    context "with an object id" do

      it "returns self" do
        field.serialize(object_id).should eq(object_id)
      end
    end
  end
end
