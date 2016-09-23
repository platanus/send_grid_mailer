require 'rails_helper'

describe SendGridMailer do
  before do
    helper_example
  end

  it 'has a version number' do
    expect(SendGridMailer::VERSION).not_to be nil
  end

  it 'uses fixtures' do
    file = fixture_file_upload("image.png", "image/png")
    expect(file.original_filename).to eq("image.png")
  end
end
