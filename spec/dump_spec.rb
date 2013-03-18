require 'megam/Birr'
require 'yaml'


describe "RSPEC for Birr help" do

  it "Birr new" do
  @id = Megam::Birr.new
  @id.run.should raise_error()
  end


  it "Birr new" do
  @id = Megam::Birr.new
  @id.run.should raise_error()
  end

end
