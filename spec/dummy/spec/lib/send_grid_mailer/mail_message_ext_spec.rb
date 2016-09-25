require "rails_helper"

describe Mail::Message do
  it "has template_id attr_accessor" do
    subject.template_id = "X"
    expect(subject.template_id).to eq("X")
  end
end
