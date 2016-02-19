# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :product do
    name        Faker::Commerce.product_name
    volume      Faker::Lorem.word
    sku         {rand(10000..20000)}
    aisle       Faker::Lorem.words(4, true).join(', ')
    link_to_cd  Faker::Internet.url('local/products')
  end
end
