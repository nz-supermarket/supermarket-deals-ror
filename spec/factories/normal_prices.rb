# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :normal_price, :class => 'NormalPrice' do
    price   '9.99'
    date    { generate(:date) }
    product nil
  end
end
