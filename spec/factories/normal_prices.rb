# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :normal_price, :class => 'NormalPrices' do
    price "9.99"
    date "2015-01-24 11:05:37"
    product nil
  end
end
