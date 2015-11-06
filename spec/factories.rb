FactoryGirl.define do
  sequence :date do |n|
    (n).days.from_now
  end

  sequence :decimals { (0.0..99.99).to_a.sample }
end
