require 'spec_helper'

describe "memories/edit" do
  before(:each) do
    @memory = assign(:memory, stub_model(Memory,
      :photo => "MyString"
    ))
  end

  it "renders the edit memory form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", memory_path(@memory), "post" do
      assert_select "input#memory_photo[name=?]", "memory[photo]"
    end
  end
end
