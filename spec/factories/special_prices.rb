# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :special_price, :class => 'SpecialPrice' do
    price   '9.99'
    date    { generate(:date) }
    product nil
  end
end
