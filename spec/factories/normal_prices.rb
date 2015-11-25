# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :normal_price, class: 'NormalPrice' do
    price       { generate(:decimals) }
    date        { generate(:date) }
    association :product
  end
end
