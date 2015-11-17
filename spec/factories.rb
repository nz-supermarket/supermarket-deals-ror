FactoryGirl.define do
  sequence(:date) { |n| (n).days.ago }

  sequence :decimals do
    characteristic = (0..99).to_a.sample
    mantissa = (0..99).to_a.sample / 100.0
    characteristic + mantissa
  end
end
