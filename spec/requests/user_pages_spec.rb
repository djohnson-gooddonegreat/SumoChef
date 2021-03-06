require 'spec_helper'

describe "User pages" do
	subject { page }

	describe "Sign up" do
		before { visit signup_path }
		
		it { should have_selector('h1',    text: 'Sign up') }
    it { should have_selector('title', text: full_title('Sign up')) }
  end

	describe "profile page" do
		let(:user) { FactoryGirl.create(:user) }
    let!(:r1) { FactoryGirl.create(:recipe, user: user, recipe_name: "Recipe Name 1") }
    let!(:r2) { FactoryGirl.create(:recipe, user: user, recipe_name: "Recipe Name 2") }

		before { visit user_path(user) }

		it { should have_selector('h1',	  text: user.user_name) }
		it { should have_selector('title', text: user.user_name) }

    describe "Recipes" do
      it { should have_content(r1.recipe_name) }
      it { should have_content(r2.recipe_name) }
      it { should have_content(user.recipes.count) }
    end
	end

  describe "signup" do

    before { visit signup_path }

    let(:submit) { "Create my account" }

    describe "with invalid information" do
      it "should not create a user" do
        expect { click_button submit }.not_to change(User, :count)
      end

      describe "after submission" do
        before { click_button submit }

        it { should have_selector('title', text: 'Sign up') }
        it { should have_content('error') }
      end

    end
    
    describe "with valid information" do

      before do
        fill_in "Name first",            with: "Example"
        fill_in "Name middle",           with: "User"
        fill_in "Name last",             with: "One"
        fill_in "Email",                 with: "user@example.com"
        fill_in "User name",             with: "example"
        fill_in "Password",              with: "foobar"
        fill_in "Password confirmation", with: "foobar"
      end

      it "should create a user" do
        expect{ click_button submit }.to change(User, :count).by(1)
      end

      describe "after saving the user" do
        before { click_button submit }
        let(:user) { User.find_by_email('user@example.com') }

        it { should have_selector('title', text: user.user_name) }
        it { should have_selector('div.alert.alert-success', text: 'Welcome') }

        it { should have_link('Sign out') }
      end

    end
  end  
end
