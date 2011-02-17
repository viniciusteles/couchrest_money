require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe PositiveMoney do
  describe "validations" do
    before(:each) do
      @positive_money = PositiveMoney.new
    end
    
    it "doesn't accept negative amounts" do
      @positive_money.amount = "-0,01"
      @positive_money.valid?
      @positive_money.should have_errors
      @positive_money.should contain_error(:amount, "tem que ser um valor maior ou igual a zero")
    end
    
    it "accepts zero" do
      @positive_money.amount = 0
      @positive_money.valid?
      @positive_money.should_not have_errors
    end
    
    it "accepts a number greater than zero" do
      @positive_money.amount = 0.01
      @positive_money.valid?
      @positive_money.should_not have_errors
    end
  end
end