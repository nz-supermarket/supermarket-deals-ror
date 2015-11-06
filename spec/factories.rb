FactoryGirl.define do
  sequence :date do |n|
    (n).days.from_now
  end

  sequence :decimals do
    (0.0..99.99).to_a.sample
  end
end
