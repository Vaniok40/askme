FactoryBot.define do
  factory :user do
    sequence(:name)     { |n| "User #{n}" }
    sequence(:username) { |n| "user#{n}" }
    sequence(:email)    { |n| "user#{n}@example.com" }
    password              { 'password' }
    password_confirmation { 'password' }
    admin { false }

    trait :admin do
      admin { true }
    end
  end
end
