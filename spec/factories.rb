FactoryGirl.define do
  sequence :date do |n|
    (n).days.from_now
  end
end
