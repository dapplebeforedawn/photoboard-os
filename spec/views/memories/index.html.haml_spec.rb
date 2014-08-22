require 'spec_helper'

describe "memories/index" do
  before(:each) do
    assign(:memories, [
      stub_model(Memory,
        :photo => "Photo"
      ),
      stub_model(Memory,
        :photo => "Photo"
      )
    ])
  end

  it "renders a list of memories" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Photo".to_s, :count => 2
  end
end
