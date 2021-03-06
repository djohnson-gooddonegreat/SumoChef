# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  email      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe User do

  before do 
  	@user = User.new(name_first: "Example", name_last: "User", user_name: "exam user", email: "user@example.com", 
  								password: "foobar", password_confirmation: "foobar")
  end

  subject { @user }

  it { should respond_to(:name_first) }
  it { should respond_to(:name_middle) }
  it { should respond_to(:name_last) }
  it { should respond_to(:email) }
  it { should respond_to(:user_name) }
  it { should respond_to(:password_digest) }
  it { should respond_to(:password) }
  it { should respond_to(:remember_token) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:authenticate) }
  it { should respond_to(:recipes) }
  it { should respond_to(:shopping_lists) }

  it { should be_valid }

  describe "when first is not present" do
  	before { @user.name_first=" " }
  	it { should_not be_valid}
  end
  describe "when last is not present" do
  	before { @user.name_last=" " }
  	it { should_not be_valid}
  end


  describe "when email is not present" do
  	before { @user.email=" " }
  	it { should_not be_valid}
  end

  describe "when first name is too long" do
  	before { @user.name_first= "a" * 26 }
  	it { should_not be_valid}
  end
  describe "when last name is too long" do
  	before { @user.name_last= "a" * 26 }
  	it { should_not be_valid}
  end

  describe "when email format is invalid" do
  	it "should be invalid" do
  		addresses = %w[user@foo,com user_at_foo.org example.user@foo.
                     foo@bar_baz.com foo@bar+baz.com]
      addresses.each do |invalid_address|
      	@user.email = invalid_address
      	@user.should_not be_valid
      end
   end
  end

  describe "when email format is valid" do
  	it "should be valid" do
  		addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
      addresses.each do |valid_address|
      	@user.email = valid_address
      	@user.should be_valid
      end
   end
  end

  describe "when email address is already taken" do
  	before do
  		user_with_same_email = @user.dup
  		user_with_same_email.email = @user.email.upcase
  		user_with_same_email.save
  	end

  	it { should_not be_valid }
  end

  describe "email address is mixed case" do
  	let(:mixed_case_email) { "mIXedCase123@FOoBar.com" }
  	it "should be saved as all lower case" do
  		@user.email = mixed_case_email
  		@user.save
  		@user.reload.email.should == mixed_case_email.downcase
  	end
  end

  describe "when user_name address is already taken" do
  	before do
  		user_with_same_user_name = @user.dup
  		user_with_same_user_name.user_name = @user.user_name.upcase
  		user_with_same_user_name.save
  	end

  	it { should_not be_valid }
  end
  describe "user name is mixed case" do
  	let(:mixed_case_user_name) { "mIXedCase123" }
  	it "should be saved as all lower case" do
  		@user.user_name = mixed_case_user_name
  		@user.save
  		@user.reload.user_name.should == mixed_case_user_name.downcase
  	end
  end


  describe "when password is not present" do
  	before { @user.password = @user.password_confirmation = " " }
  	it { should_not be_valid }
  end

  describe "when password confirmation does not match" do
  	before { @user.password_confirmation = "mismatch" }
  	it { should_not be_valid }
  end

  describe "when password confirmation is nil" do
  	before { @user.password_confirmation = nil }
  	it { should_not be_valid }
  end

  describe "return value of authenicate method" do
  	before { @user.save }
  	let(:found_user) { User.find_by_email(@user.email) }

  	describe "with valid password" do
  		it { should == found_user.authenticate(@user.password) }
  	end

  	describe "with invalid password" do
  		let(:user_for_invalid_password) { found_user.authenticate("invalid") }

  		it { should_not == user_for_invalid_password }
  		specify { user_for_invalid_password.should be_false }
  	end

  	describe "with a password that's too short" do
  		before { @user.password = @user.password_confirmation = "a" * 5 }
  		it { should be_invalid }
  	end
  end

  describe "remember token" do
    before { @user.save }
    its(:remember_token) { should_not be_blank }
  end


  describe "checking for active shopping lists" do
    before { @user.save }

    describe "there shouldn't be any active" do
      describe "without any shopping lists" do
        its(:any_active_shopping_lists?) { should == false }
      end

      describe "with inactive shopping list" do
        before { @user.shopping_lists.create(description: "This is a List", state: "inactive") }
        its(:any_active_shopping_lists?) { should == false }
      end
    end

    describe "there should be one active" do
      before { @user.shopping_lists.create(description: "This is a List", state: "active") }
      its(:any_active_shopping_lists?) { should == true }
    end
  end

  describe "Recipe Associations" do
    before { @user.save }
    let!(:older_recipe) do
      FactoryGirl.create(:recipe, user: @user, created_at: 1.day.ago)
    end
    let!(:newer_recipe) do
      FactoryGirl.create(:recipe, user: @user, created_at: 1.hour.ago)
    end

    it "should have recipes in the correct order" do
      @user.recipes.should == [newer_recipe, older_recipe]
    end

    it "should destroy associated recipes" do
      recipes = @user.recipes.dup
      @user.destroy
      recipes.should_not be_empty
      recipes.each do |recipe|
        Recipe.find_by_id(recipe.id).should be_nil
      end
    end
  end

end
