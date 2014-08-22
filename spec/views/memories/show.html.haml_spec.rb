require 'spec_helper'

describe "memories/show" do
  before(:each) do
    @memory = assign(:memory, stub_model(Memory,
      :photo => "Photo"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Photo/)
  end
end
