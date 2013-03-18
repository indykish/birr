require 'megam/dude'
require 'yaml'


describe "RSPEC for Dude help" do

  it "Dude new" do
  @id = Megam::Dude.new
  @id.run.should raise_error()
  end


  it "Dude new" do
  @id = Megam::Dude.new
  @id.run.should raise_error()
  end

end
