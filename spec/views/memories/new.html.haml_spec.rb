require 'spec_helper'

describe "memories/new" do
  before(:each) do
    assign(:memory, stub_model(Memory,
      :photo => "MyString"
    ).as_new_record)
  end

  it "renders new memory form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", memories_path, "post" do
      assert_select "input#memory_photo[name=?]", "memory[photo]"
    end
  end
end
