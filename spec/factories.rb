FactoryGirl.define do
  sequence(:date) { |n| Date.today - (n).days }

  sequence :decimals do
    characteristic = (0..99).to_a.sample
    mantissa = (0..99).to_a.sample / 100.0
    characteristic + mantissa
  end
end
