# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :product do
    name        "MyString"
    volume      "MyString"
    sku         {rand(10000..20000)}
    aisle       "MyString"
    link_to_cd  "http://local/product/1"
  end
end
