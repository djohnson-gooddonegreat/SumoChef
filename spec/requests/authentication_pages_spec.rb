require 'spec_helper'

describe "Authentication Pages" do
	subject { page }

	describe "signin page" do
		before { visit signin_path }

		it { should have_selector('h1',    text: 'Sign in') }
		it { should have_selector('title', text: 'Sign in') }
	end

	describe "signin" do
		before { visit signin_path }

		describe "with invalid information" do
			before { click_button "Sign in"}

			it { should have_selector('h1',  text: 'Sign in') }
			it { should have_selector('div.alert.alert-error',  text: 'Invalid') }

			describe "after visiting another page" do
        		before { click_link "Home" }
        		it { should_not have_selector('div.alert.alert-error') }
      	end
		end

		describe "with valid information" do
			let(:user) { FactoryGirl.create(:user) }
			before do
				fill_in "User name",    with: user.user_name.upcase
				fill_in "Password", with: user.password
				click_button "Sign in"
			end

			it { should have_selector('title', text: user.user_name) }
			it { should have_link('Profile', href: user_path(user)) }
			it { should have_link('Sign out', href: signout_path) }
			it { should_not have_link('Sign in', href: signin_path) }

			describe "followed by signout" do
				before { click_link 'Sign out' }
				it { should have_link('Sign in') }
			end
		end
	end

	describe "authorization" do
		let(:user) { FactoryGirl.create(:user) }

		describe "in recipes controller" do

			describe "submitting to the create action" do
				before { post recipes_path }
				specify { response.should redirect_to(signin_path) }
			end

			describe "submitting to the destroy action" do
				before { delete recipe_path(FactoryGirl.create(:recipe)) }
				specify { response.should redirect_to(signin_path) }
			end

		end
	end
end
