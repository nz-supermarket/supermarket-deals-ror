# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :special_price, class: 'SpecialPrice' do
    price       { generate(:decimals) }
    date        { Faker::Date.between(90.days.ago, Date.today) }
    association :product
  end
end
