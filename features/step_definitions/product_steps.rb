include NavigationHelpers

When(/^I go to (.*?)$/) do |arg1|
  path_to("the home page")
end

Then(/^I should see "(.*?)"$/) do |arg1|
  have_content(arg1)
end

Then(/^I should see the following:$/) do |table|
  table.diff!(Product.all.to_a)
end

Then(/^products should have (\d+) item$/) do |count|
	Product.all.count == count
end