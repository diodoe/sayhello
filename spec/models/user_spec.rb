require 'spec_helper'

describe User do

  before(:each) do
    @attr = { 
              :name => "Example User", 
              :email => "user@example.com",  
              :password => 'password',
              :password_confimation => 'password'
    }
  end

  it "should create a new instance given valid attributes" do
    user=User.create!(@attr)
  end
  
  it "should require a password" do
    user=User.new(@attr.merge(:password=>'',:password_confirmation=>''))
    user.should_not be_valid
  end   
  
  it "should require a correct password confimation" do
    user=User.new(@attr.merge :password_confirmation=>'not correct')
    user.should_not be_valid
  end                                              
  it "should reject short password" do
    pass="a"*5
    User.new(@attr.merge(:password=>pass,:password_confirmation=>pass)).should_not be_valid
  end
  it "should reject long password" do
    pass="a"*41
    User.new(@attr.merge(:password=>pass,:password_confirmation=>pass)).should_not be_valid
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
   
   describe "password encryption" do

       before(:each) do
         @user = User.create!(@attr)
       end

       it "should have an encrypted password attribute" do
         @user.should respond_to(:encrypted_password)
       end                  
       
       it "should set the encrypted password" do
         @user.encrypted_password.should_not be_blank
       end                                           
       
       describe "has_password? method" do

         it "should be true if the passwords match" do
           @user.has_password?(@attr[:password]).should be_true
         end    

         it "should be false if the passwords don't match" do
           @user.has_password?("invalid").should be_false
         end 
       end        
       describe "authenticate method" do

         it "should return nil on email/password mismatch" do
           wrong_password_user = User.authenticate(@attr[:email], "wrongpass")
           wrong_password_user.should be_nil
         end

         it "should return nil for an email address with no user" do
           nonexistent_user = User.authenticate("bar@foo.com", @attr[:password])
           nonexistent_user.should be_nil
         end

         it "should return the user on email/password match" do
           matching_user = User.authenticate(@attr[:email], @attr[:password])
           matching_user.should == @user
         end
       end
   end
end
