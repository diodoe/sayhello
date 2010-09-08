require 'spec_helper'

describe User do

  before(:each) do
    @attr = { :name => "Example User", :email => "user@example.com" }
  end

  it "should create a new instance given valid attributes" do
    User.create!(@attr)
  end
  
  it "should require a name" do
    no_name_user = User.new(@attr.merge :name=> '')
    no_name_user.should_not be_valid
  end  
  
  it "should reject names too long" do
    long_name= "a" * 51
    long_name_user = User.new(@attr.merge :name=> long_name)
    long_name_user.should_not be_valid
  end
  
  it "should require an email" do
    no_name_user = User.new(@attr.merge :email=> '')
    no_name_user.should_not be_valid
  end   
  
  it "should accept valid email addresses" do
    emails = %w[me@me,com foobar.com lovely@comma]
    emails.each do |email|
      invalid_email_user = User.new(@attr.merge :email=> email)
      invalid_email_user.should_not be_valid    
    end
  end       
  it "should have an unique email address" do
     user = User.create!(@attr)
     user_with_duplicate_email = User.new(@attr)
     user_with_duplicate_email.should_not be_valid
   end 
   
   it "should have an unique email address up to case" do
      user = User.create!(@attr)
      user_with_duplicate_email = User.new(@attr.merge :email => @attr[:email].upcase )
      user_with_duplicate_email.should_not be_valid
    end
end
