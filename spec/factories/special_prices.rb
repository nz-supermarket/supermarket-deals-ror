# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :special_price, :class => 'SpecialPrices' do
    price "9.99"
    date "2015-01-24 11:06:34"
    product nil
  end
end
