include NavigationHelpers
require 'uri'
require 'cgi'
require 'capybara/cucumber'

require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))
module WithinHelpers
  def with_scope(locator)
    locator ? within(locator) { yield } : yield
  end
end
World(WithinHelpers)

Given(/^product does exists?(?: with #{capture_fields})?$/) do |fields|
  params = {}
  fields.split(',').each do |item|
    key_value = item.split(': ')
    params[key_value[0].strip.to_sym] = key_value[1].gsub("\"",'')
  end
  Product.create(params)
end

Given(/^the following products$/) do |table|
  table.hashes.each do |attributes|
    Product.create!(attributes)
  end
end

When(/^I go to (.*?)$/) do |arg1|
  path = path_to("the home page")
  page = visit("http://localhost:3000" + path)
end

Then(/^I should see the following products:$/) do |table|
  table.hashes.each do |attributes|
    attributes.each do |value|
      step "I should have [#{value[0]}, #{value[1]}]"
      step "I should see [#{value[0]}, #{value[1]}] on page"
    end
  end
end

Then(/^products should have (\d+) item$/) do |count|
  Product.all.count == count
end

Then(/^I should have \[(.*?), (.*?)\]$/) do |key, value|
    binding.pry
  if value.include? "NZ$" or value.include? '%'
    actual = Product.all.select{ |a| ('%.2f' % a[key.to_sym]) == value.gsub("NZ$",'').gsub("%",'') }.first[key.to_sym]
    actual = '%.2f' % actual
  else
    actual = Product.all.select{ |a| a[key.to_sym].to_s == value }.first[key.to_sym] 
  end
  actual.eql? value.gsub("NZ$",'').gsub('%','')
end

Then(/^I should see \[(.*?), (.*?)\] on page$/) do |key, value|
  page.should have_content(value)
end

Then(/^product's (.*?) must be "(.*?)"$/) do |key, value|
  step "I should have [#{key}, #{value}]"
end

Then /^(?:|I )should see "([^"]*)"(?: within "([^"]*)")?$/ do |text, selector|
  with_scope(selector) do
    if page.respond_to? :should
      page.should have_content(text)
    else
      assert page.has_content?(text)
    end
  end
end

Then /^(?:|I )should not see "([^"]*)"(?: within "([^"]*)")?$/ do |text, selector|
  with_scope(selector) do
    if page.respond_to? :should
      page.should have_no_content(text)
    else
      assert page.has_no_content?(text)
    end
  end
end
