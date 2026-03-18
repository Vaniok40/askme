puts "Cleaning database..."
Like.destroy_all
Comment.destroy_all
PostTag.destroy_all
TagQuestion.destroy_all
UserInterest.destroy_all
Post.destroy_all
Question.destroy_all
Tag.destroy_all
User.destroy_all

puts "Creating tags..."
tags = Tag.create!([
  { name: "ruby" },
  { name: "rails" },
  { name: "javascript" },
  { name: "design" },
  { name: "career" },
  { name: "openai" },
  { name: "productivity" },
  { name: "travel" },
  { name: "music" },
  { name: "fitness" }
])

puts "Creating users..."
admin = User.create!(
  name:                  "Alice Admin",
  username:              "alice",
  email:                 "alice@example.com",
  password:              "password",
  password_confirmation: "password",
  color:                 "#402E2A",
  admin:                 true
)

users = [admin]

[
  { name: "Bob Builder",    username: "bob",    email: "bob@example.com",    color: "#1a6b4a" },
  { name: "Carol Chen",     username: "carol",  email: "carol@example.com",  color: "#2c4a8c" },
  { name: "David Diaz",     username: "david",  email: "david@example.com",  color: "#7b3f00" },
  { name: "Eva Evans",      username: "eva",    email: "eva@example.com",    color: "#5c0a5a" },
  { name: "Frank Ford",     username: "frank",  email: "frank@example.com",  color: "#0a4a5c" },
  { name: "Grace Green",    username: "grace",  email: "grace@example.com",  color: "#3a5c1a" },
  { name: "Henry Hall",     username: "henry",  email: "henry@example.com",  color: "#5c3a1a" },
  { name: "Iris Ibarra",    username: "iris",   email: "iris@example.com",   color: "#1a3a5c" },
  { name: "Jack Johnson",   username: "jack",   email: "jack@example.com",   color: "#5c1a3a" }
].each do |attrs|
  users << User.create!(attrs.merge(password: "password", password_confirmation: "password"))
end

puts "Creating user interests..."
users.each do |user|
  tags.sample(rand(2..4)).each do |tag|
    UserInterest.create!(user: user, tag: tag)
  end
end

puts "Creating posts..."
post_data = [
  {
    title: "Getting started with Ruby on Rails in 2026",
    body:  "Rails is still one of the most productive web frameworks out there. Here's what I've learned after building three apps this year. #ruby #rails\n\nThe convention-over-configuration approach saves enormous amounts of time, especially for CRUD-heavy applications.",
    user:  users[0]
  },
  {
    title: "Why I switched from React to Hotwire",
    body:  "After years of wrestling with JavaScript fatigue, Hotwire and Turbo gave me back the joy of building. #javascript #rails\n\nThe mental model is simpler and the resulting code is far less complex.",
    user:  users[1]
  },
  {
    title: "10 design principles every developer should know",
    body:  "Good design is not about making things look pretty — it's about clarity. #design\n\n1. Hierarchy guides the eye. 2. Contrast creates focus. 3. Whitespace is not wasted space.",
    user:  users[2]
  },
  {
    title: "How I landed my first senior engineering role",
    body:  "The job search took four months but here's what actually worked. #career\n\nPortfolio projects beat resume bullets every time. Being specific about impact matters more than listing technologies.",
    user:  users[3]
  },
  {
    title: "Building a personal productivity system with plain text",
    body:  "I've tried every todo app. Nothing stuck until I went back to basics. #productivity\n\nA single markdown file, reviewed every morning, has been my system for two years now.",
    user:  users[4]
  },
  {
    title: "Integrating OpenAI into a Rails app — a practical guide",
    body:  "The API is deceptively simple, but production usage has some real gotchas. #openai #ruby #rails\n\nRate limiting, streaming responses, and cost estimation are the three things nobody tells you about.",
    user:  users[5]
  },
  {
    title: "Solo travel in Southeast Asia on a developer's budget",
    body:  "Remote work changed everything about how I travel. #travel\n\nBali, Chiang Mai, and Ho Chi Minh City each offered something different as a base for deep work.",
    user:  users[6]
  },
  {
    title: "The albums that defined my coding sessions this year",
    body:  "Music and coding have a deeper connection than most people acknowledge. #music #productivity\n\nBrian Eno's ambient works, Bonobo, and lo-fi hip hop playlists all serve different cognitive modes.",
    user:  users[7]
  },
  {
    title: "Running a half marathon while working full time",
    body:  "Training doesn't require hours. It requires consistency. #fitness\n\nSixteen weeks, five runs per week, none longer than 75 minutes — that's the whole plan.",
    user:  users[8]
  },
  {
    title: "What I wish I knew before building a SaaS product",
    body:  "The technical side is the easy part. #rails #career\n\nCustomer discovery, pricing psychology, and churn analysis are what actually determine whether you succeed.",
    user:  users[9]
  }
]

posts = post_data.map { |attrs| Post.create!(attrs) }

puts "Creating questions..."
question_data = [
  { text: "What is the best way to learn Ruby on Rails from scratch? #ruby #rails", user: users[1], author: users[2] },
  { text: "How do you handle background jobs in a Rails app? #rails", user: users[0], author: users[3] },
  { text: "What CSS framework do you recommend for a new project? #design", user: users[2], author: users[4] },
  { text: "How important is open source contribution for a developer career? #career", user: users[3], author: users[5] },
  { text: "What productivity tools do you actually use daily? #productivity", user: users[4], author: users[6] },
  { text: "Is JavaScript still worth learning deeply in 2026? #javascript", user: users[5], author: users[7] },
  { text: "What is your morning routine as a remote developer?", user: users[6], author: users[8] },
  { text: "How do you stay motivated during long projects? #career #productivity", user: users[7], author: users[9] },
  { text: "What book changed how you think about software design? #design", user: users[8], author: users[0] },
  { text: "How do you balance fitness with a demanding dev job? #fitness", user: users[9], author: users[1] }
]

answers = [
  "I'd start with the official Rails guides, then build a small project you actually care about. Theory without practice doesn't stick.",
  "Sidekiq is the go-to. Redis-backed, reliable, and the UI dashboard is genuinely useful for monitoring.",
  "Tailwind CSS for utility-first speed, but learn plain CSS fundamentals first so you understand what it's doing.",
  "Hugely important — not for the code itself but for learning to communicate in a professional codebase context.",
  "Obsidian for notes, Toggl for time tracking, and a paper notebook for daily planning. Simple wins.",
  "Absolutely. The DOM, async patterns, and the event loop are foundational knowledge that any framework builds on.",
  "Walk, coffee, 30 minutes of reading before opening any screen. It makes the first focus block much sharper.",
  "Small milestones and shipping publicly. Nothing beats the feeling of someone using something you built.",
  "A Philosophy of Software Design by John Ousterhout. Changed how I think about complexity completely.",
  "Treat workouts like meetings — they go in the calendar first and other things fit around them."
]

questions = question_data.each_with_index.map do |attrs, i|
  Question.create!(attrs.merge(answer: answers[i]))
end

puts "Creating likes..."
posts.each do |post|
  users.sample(rand(2..6)).each do |user|
    Like.find_or_create_by!(post: post, user: user)
  end
end

puts "Creating comments..."
comment_texts = [
  "Really well written, thanks for sharing!",
  "I had the same experience — totally agree with your take.",
  "Could you elaborate on the third point? I'm curious about the details.",
  "This is exactly what I needed to read today.",
  "Great post! Have you written anything on the follow-up topic?",
  "Bookmarked. Coming back to this when I start my next project.",
  "Disagree on point two, but the rest is spot on.",
  "Shared this with my whole team. Very useful.",
  "Love the practical approach here rather than just theory.",
  "How long did it take you to figure all this out?"
]

posts.each do |post|
  users.sample(rand(2..4)).each_with_index do |user, i|
    Comment.create!(
      post: post,
      user: user,
      body: comment_texts.sample
    )
  end
end

puts ""
puts "Done! Seeded:"
puts "  #{User.count} users     (admin: alice@example.com / password)"
puts "  #{Tag.count} tags"
puts "  #{Post.count} posts"
puts "  #{Question.count} questions"
puts "  #{Like.count} likes"
puts "  #{Comment.count} comments"
puts "  #{UserInterest.count} user interests"
