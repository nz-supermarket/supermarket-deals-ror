# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :product do
    name            { Faker::Commerce.product_name }
    volume          { Faker::Lorem.word }
    sequence(:sku)  { |n| 10_000 + n }
    aisle           { Faker::Lorem.words(4, true).join(', ') }
    link_to_cd      { Faker::Internet.url('local/products') }

    factory :product_with_prices do
      after(:create) do |product|
        create_list(:normal_price, 300, product_id: product.id)
        create_list(:special_price, 30, product_id: product.id)
      end
    end
  end
end
