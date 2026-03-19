FactoryBot.define do
  factory :comment do
    association :post
    association :user
    body { 'Great post!' }
  end
end
