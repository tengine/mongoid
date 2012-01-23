require "spec_helper"

describe Mongoid::Threaded do

  let(:object) do
    stub
  end

  describe "#begin" do

    before do
      described_class.begin(:load)
    end

    after do
      described_class.stack(:load).clear
    end

    it "adds a boolen to the load stack" do
      described_class.stack(:load).should eq([ true ])
    end
  end

  describe "#executing?" do

    context "when loading is not set" do

      it "returns false" do
        described_class.should_not be_executing(:load)
      end
    end

    context "when the stack has elements" do

      before do
        Thread.current[:"[mongoid]:load-stack"] = [ true ]
      end

      after do
        Thread.current[:"[mongoid]:load-stack"] = []
      end

      it "returns true" do
        described_class.should be_executing(:load)
      end
    end

    context "when the stack has no elements" do

      before do
        Thread.current[:"[mongoid]:load-stack"] = []
      end

      it "returns false" do
        described_class.should_not be_executing(:load)
      end
    end
  end

  describe "#stack" do

    context "when no stack has been initialized" do

      let(:loading) do
        described_class.stack(:load)
      end

      it "returns an empty stack" do
        loading.should be_empty
      end
    end

    context "when a stack has been initialized" do

      before do
        Thread.current[:"[mongoid]:load-stack"] = [ true ]
      end

      let(:loading) do
        described_class.stack(:load)
      end

      after do
        Thread.current[:"[mongoid]:load-stack"] = []
      end

      it "returns the stack" do
        loading.should eq([ true ])
      end
    end
  end

  describe "#exit" do

    before do
      described_class.begin(:load)
      described_class.exit(:load)
    end

    after do
      described_class.stack(:load).clear
    end

    it "removes a boolen from the stack" do
      described_class.stack(:load).should be_empty
    end
  end

  describe "#clear_safety_options!" do

    before do
      described_class.safety_options = { :w => 3 }
      described_class.clear_safety_options!
    end

    it "removes all safety options" do
      described_class.safety_options.should be_nil
    end
  end

  describe "#identity_map" do

    before do
      Thread.current[:"[mongoid]:identity-map"] = object
    end

    after do
      Thread.current[:"[mongoid]:identity-map"] = nil
    end

    it "returns the object with the identity map key" do
      described_class.identity_map.should eq(object)
    end
  end

  describe "#insert" do

    before do
      Thread.current[:"[mongoid][test]:insert-consumer"] = object
    end

    after do
      Thread.current[:"[mongoid][test]:insert-consumer"] = nil
    end

    it "returns the object with the insert key" do
      described_class.insert("test").should eq(object)
    end
  end

  describe "#set_insert" do

    before do
      described_class.set_insert("test", object)
    end

    after do
      described_class.set_insert("test", nil)
    end

    let(:consumer) do
      described_class.insert("test")
    end

    it "sets the insert consumer" do
      consumer.should eq(object)
    end
  end

  describe "#safety_options" do

    before do
      described_class.safety_options = { :w => 3 }
    end

    after do
      described_class.safety_options = nil
    end

    let(:options) do
      described_class.safety_options
    end

    it "sets the safety options" do
      options.should eq({ :w => 3 })
    end
  end

  describe "#scope_stack" do

    it "returns the default with the scope stack key" do
      described_class.scope_stack.should be_a(Hash)
    end
  end

  describe "#update_consumer" do

    before do
      Thread.current[:"[mongoid][Person]:update-consumer"] = object
    end

    after do
      Thread.current[:"[mongoid][Person]:update-consumer"] = nil
    end

    it "returns the object with the update key" do
      described_class.update_consumer(Person).should eq(object)
    end
  end

  describe "#set_update_consumer" do

    before do
      described_class.set_update_consumer(Person, object)
    end

    after do
      Thread.current[:"[mongoid][Person]:update-consumer"] = nil
    end

    it "sets the object with the update key" do
      described_class.update_consumer(Person).should eq(object)
    end
  end

  describe "#timeless" do

    before do
      described_class.timeless = true
    end

    after do
      described_class.timeless = false
    end

    it "returns the timeless value" do
      described_class.timeless.should be_true
    end
  end

  describe "#timestamping?" do

    context "when timeless is not set" do

      it "returns true" do
        described_class.should be_timestamping
      end
    end

    context "when timeless is true" do

      before do
        described_class.timeless = true
      end

      after do
        described_class.timeless = false
      end

      it "returns false" do
        described_class.should_not be_timestamping
      end
    end
  end

  describe "#begin_validate" do

    let(:person) do
      Person.new
    end

    before do
      described_class.begin_validate(person)
    end

    after do
      described_class.exit_validate(person)
    end

    it "marks the document as being validated" do
      described_class.validations_for(Person).should eq([ person.id ])
    end
  end

  describe "#exit_validate" do

    let(:person) do
      Person.new
    end

    before do
      described_class.begin_validate(person)
      described_class.exit_validate(person)
    end

    it "unmarks the document as being validated" do
      described_class.validations_for(Person).should be_empty
    end
  end

  describe "#validated?" do

    let(:person) do
      Person.new
    end

    context "when the document is validated" do

      before do
        described_class.begin_validate(person)
      end

      after do
        described_class.exit_validate(person)
      end

      it "returns true" do
        described_class.validated?(person).should be_true
      end
    end

    context "when the document is not validated" do

      it "returns false" do
        described_class.validated?(person).should be_false
      end
    end
  end
end
