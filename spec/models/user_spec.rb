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
   
   describe "admin attribute" do

    before(:each) do
      @user = User.create!(@attr)
    end

    it "should respond to admin" do
      @user.should respond_to(:admin)
    end

    it "should not be an admin by default" do
      @user.should_not be_admin
    end

    it "should be convertible to an admin" do
      @user.toggle!(:admin)
      @user.should be_admin
    end
  end
  describe "micropost associations" do

    before(:each) do
      @user = User.create(@attr)
      @mp1 = Factory(:micropost, :user => @user, :created_at => 1.day.ago)
      @mp2 = Factory(:micropost, :user => @user, :created_at => 1.hour.ago)
    end

    it "should have a microposts attribute" do
      @user.should respond_to(:microposts)
    end

    it "should have the right microposts in the right order" do
      @user.microposts.should == [@mp2, @mp1]
    end
    
    it "should destroy associated microposts" do
      @user.destroy
      [@mp1, @mp2].each do |micropost|
        Micropost.find_by_id(micropost.id).should be_nil#this not raise an error
        #this raise an error
        #lambda do 
        #  Micropost.find(micropost.id)
        #end.should raise_error(ActiveRecord::RecordNotFound)
      end
    end
    describe "status feed" do
        it "should have a feed" do
          @user.should respond_to(:feed)
        end
  
        it "should include the user's microposts" do
          @user.feed.include?(@mp1).should be_true
          @user.feed.include?(@mp2).should be_true
        end
  
        it "should not include a different user's microposts" do
          mp3 = Factory(:micropost,
                        :user => Factory(:user, :email => Factory.next(:email)))
          @user.feed.include?(mp3).should be_false
        end
    end
  end
end
