# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :product do
    name "MyString"
    volume "MyString"
    sku 1
    special "9.99"
    normal "9.99"
    diff "9.99"
    aisle "MyString"
    discount "9.99"
  end
end
