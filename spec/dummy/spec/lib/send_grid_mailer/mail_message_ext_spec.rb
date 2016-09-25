require "rails_helper"

describe Mail::Message do
  describe "#template_id" do
    it "has template_id attr_accessor" do
      subject.template_id = "X"
      expect(subject.template_id).to eq("X")
    end
  end

  let(:personalization) { subject.send(:personalization) }

  describe "#substitute" do
    before do
      @substitution = subject.substitute("%subject%", "Hi!")
    end

    it "creates substitution with valid data" do
      expect(@substitution.substitution).to eq("%subject%" => "Hi!")
    end

    it "adds substitution to personalization object" do
      expect(personalization.substitutions.size).to eq(1)
    end

    it "adds substitution to collection" do
      subject.substitute("%body%", "blah")
      expect(personalization.substitutions.size).to eq(2)
    end
  end
end
