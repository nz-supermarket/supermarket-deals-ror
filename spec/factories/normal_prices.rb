# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :normal_price, class: 'NormalPrice' do
    price       { generate(:decimals) }
    sequence(:date)  { |n| n.days.ago }
    association :product
  end
end
