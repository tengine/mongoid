require 'spec_helper'

describe Mongoid::DefaultScope do

  describe ".default_scope" do

    let(:criteria) do
      Acolyte.all
    end

    it "applies the scope to any criteria" do
      criteria.options.should eq({ :sort => [[ :name, :asc ]] })
    end

    context "when combining with a named scope" do

      let(:scoped) do
        Acolyte.active
      end

      it "applies the default scope" do
        scoped.options.should eq({ :sort => [[ :name, :asc ]] })
      end
    end

    context "when calling unscoped" do

      let(:unscoped) do
        Acolyte.unscoped
      end

      it "does not contain the default scoping" do
        unscoped.options.should eq({})
      end

      context "when applying a named scope after" do

        let(:named) do
          Acolyte.unscoped.active
        end

        it "does not contain the default scoping" do
          named.options.should eq({})
        end

        context "when applying multiple scopes after" do

          let(:multiple) do
            named.named
          end

          it "does not contain the default scoping" do
            multiple.options.should eq({})
          end
        end
      end
    end
  end

  context "when providing a default scope on root documents" do

    let!(:fir) do
      Tree.create(:name => "Fir",   :evergreen => true )
    end

    let!(:pine) do
      Tree.create(:name => "Pine",  :evergreen => true )
    end

    let!(:birch) do
      Tree.create(:name => "Birch", :evergreen => false)
    end

    it "returns them in the correct order" do
      Tree.all.entries.should eq([ birch, fir, pine ])
    end

    it "respects other scopes" do
      Tree.verdant.entries.should eq([ fir, pine ])
    end
  end

  context "when providing a default scope on an embedded document" do

    let!(:person) do
      Person.create(:ssn => "111-11-1111")
    end

    let!(:tron) do
      person.videos.create(:title => "Tron")
    end

    let!(:bladerunner) do
      person.videos.create(:title => "Bladerunner")
    end

    it "respects the default scope" do
      person.reload.videos.all.should eq([ bladerunner, tron ])
    end
  end
end
