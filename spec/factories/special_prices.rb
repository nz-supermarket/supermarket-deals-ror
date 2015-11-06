# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :special_price, class: 'SpecialPrice' do
    price       { generate(:decimals) }
    date        { generate(:date) }
    association product
  end
end
