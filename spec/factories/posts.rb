FactoryBot.define do
  factory :post do
    association :user
    sequence(:title) { |n| "Post title #{n}" }
    body { 'Post body content.' }
  end
end
