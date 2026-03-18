puts 'Curățare bază de date...'
Like.destroy_all
Comment.destroy_all
PostTag.destroy_all
TagQuestion.destroy_all
UserInterest.destroy_all
Post.destroy_all
Question.destroy_all
Tag.destroy_all
User.destroy_all

puts 'Creare etichete...'
tags = Tag.create!([
                     { name: 'ruby' },
                     { name: 'rails' },
                     { name: 'javascript' },
                     { name: 'design' },
                     { name: 'cariera' },
                     { name: 'openai' },
                     { name: 'productivitate' },
                     { name: 'calatorii' },
                     { name: 'muzica' },
                     { name: 'fitness' }
                   ])

puts 'Creare utilizatori...'
admin = User.create!(
  name: 'Alice Admin',
  username: 'alice',
  email: 'alice@example.com',
  password: 'password',
  password_confirmation: 'password',
  color: '#402E2A',
  admin: true
)

users = [admin]

[
  { name: 'Bob Builder',    username: 'bob',    email: 'bob@example.com',    color: '#1a6b4a' },
  { name: 'Carol Chen',     username: 'carol',  email: 'carol@example.com',  color: '#2c4a8c' },
  { name: 'David Diaz',     username: 'david',  email: 'david@example.com',  color: '#7b3f00' },
  { name: 'Eva Evans',      username: 'eva',    email: 'eva@example.com',    color: '#5c0a5a' },
  { name: 'Frank Ford',     username: 'frank',  email: 'frank@example.com',  color: '#0a4a5c' },
  { name: 'Grace Green',    username: 'grace',  email: 'grace@example.com',  color: '#3a5c1a' },
  { name: 'Henry Hall',     username: 'henry',  email: 'henry@example.com',  color: '#5c3a1a' },
  { name: 'Iris Ibarra',    username: 'iris',   email: 'iris@example.com',   color: '#1a3a5c' },
  { name: 'Jack Johnson',   username: 'jack',   email: 'jack@example.com',   color: '#5c1a3a' }
].each do |attrs|
  users << User.create!(attrs.merge(password: 'password', password_confirmation: 'password'))
end

puts 'Creare interese utilizatori...'
users.each do |user|
  tags.sample(rand(2..4)).each do |tag|
    UserInterest.create!(user:, tag:)
  end
end

puts 'Creare postări...'
post_data = [
  {
    title: 'Cum să începi cu Ruby on Rails în 2026',
    body: "Rails rămâne unul dintre cele mai productive framework-uri web. Iată ce am învățat după ce am construit trei aplicații în acest an. #ruby #rails\n\nAbordarea convenție-în-loc-de-configurare economisește enorm de mult timp, mai ales pentru aplicații centrate pe CRUD.",
    user: users[0]
  },
  {
    title: 'De ce am trecut de la React la Hotwire',
    body: "După ani de lupte cu oboseala JavaScript, Hotwire și Turbo mi-au redat bucuria construirii. #javascript #rails\n\nModelul mental este mai simplu și codul rezultat este mult mai puțin complex.",
    user: users[1]
  },
  {
    title: '10 principii de design pe care orice developer ar trebui să le cunoască',
    body: "Design-ul bun nu înseamnă să faci lucrurile să arate frumos — înseamnă claritate. #design\n\n1. Ierarhia ghidează privirea. 2. Contrastul creează focusul. 3. Spațiul alb nu este spațiu pierdut.",
    user: users[2]
  },
  {
    title: 'Cum am obținut primul meu rol de senior engineer',
    body: "Căutarea jobului a durat patru luni, dar iată ce a funcționat cu adevărat. #cariera\n\nProiectele din portofoliu bat orice CV. A fi specific cu privire la impact contează mai mult decât lista de tehnologii.",
    user: users[3]
  },
  {
    title: 'Cum mi-am construit un sistem de productivitate cu text simplu',
    body: "Am încercat fiecare aplicație de to-do. Nimic nu a rămas până nu m-am întors la baze. #productivitate\n\nUn singur fișier markdown, revizuit în fiecare dimineață, este sistemul meu de doi ani.",
    user: users[4]
  },
  {
    title: 'Integrarea OpenAI într-o aplicație Rails — ghid practic',
    body: "API-ul pare simplu, dar utilizarea în producție are niște capcane reale. #openai #ruby #rails\n\nRate limiting, răspunsuri în streaming și estimarea costurilor sunt cele trei lucruri pe care nimeni nu ți le spune.",
    user: users[5]
  },
  {
    title: 'Călătorie solo în Asia de Sud-Est cu bugetul unui developer',
    body: "Munca remote a schimbat totul despre modul în care călătoresc. #calatorii\n\nBali, Chiang Mai și Ho Chi Minh City au oferit fiecare ceva diferit ca bază pentru muncă profundă.",
    user: users[6]
  },
  {
    title: 'Albumele care mi-au definit sesiunile de coding în acest an',
    body: "Muzica și coding-ul au o conexiune mai profundă decât recunosc majoritatea oamenilor. #muzica #productivitate\n\nLucrările ambientale ale lui Brian Eno, Bonobo și playlist-urile lo-fi hip hop servesc fiecare moduri cognitive diferite.",
    user: users[7]
  },
  {
    title: 'Cum am alergat un semi-maraton lucrând full time',
    body: "Antrenamentul nu necesită ore. Necesită consecvență. #fitness\n\nȘaisprezece săptămâni, cinci alergări pe săptămână, niciuna mai lungă de 75 de minute — acesta este tot planul.",
    user: users[8]
  },
  {
    title: 'Ce mi-aș fi dorit să știu înainte de a construi un produs SaaS',
    body: "Partea tehnică este cea mai ușoară. #rails #cariera\n\nDescoperirea clienților, psihologia prețurilor și analiza churn sunt ceea ce determină cu adevărat dacă reușești.",
    user: users[9]
  }
]

posts = post_data.map { |attrs| Post.create!(attrs) }

puts 'Creare întrebări...'
question_data = [
  { text: 'Care este cel mai bun mod de a învăța Ruby on Rails de la zero? #ruby #rails', user: users[1],
    author: users[2] },
  { text: 'Cum gestionezi job-urile în background într-o aplicație Rails? #rails', user: users[0], author: users[3] },
  { text: 'Ce framework CSS recomanzi pentru un proiect nou? #design', user: users[2], author: users[4] },
  { text: 'Cât de importantă este contribuția open source pentru cariera unui developer? #cariera', user: users[3],
    author: users[5] },
  { text: 'Ce instrumente de productivitate folosești efectiv zilnic? #productivitate', user: users[4],
    author: users[6] },
  { text: 'Merită să înveți JavaScript în profunzime în 2026? #javascript', user: users[5], author: users[7] },
  { text: 'Care este rutina ta de dimineață ca developer remote?', user: users[6], author: users[8] },
  { text: 'Cum rămâi motivat în timpul proiectelor lungi? #cariera #productivitate', user: users[7], author: users[9] },
  { text: 'Ce carte ți-a schimbat modul de a gândi despre design-ul software? #design', user: users[8],
    author: users[0] },
  { text: 'Cum echilibrezi fitness-ul cu un job de dev solicitant? #fitness', user: users[9], author: users[1] }
]

answers = [
  'Aș începe cu ghidurile oficiale Rails, apoi aș construi un proiect mic care te interesează cu adevărat. Teoria fără practică nu se fixează.',
  'Sidekiq este alegerea principală. Bazat pe Redis, fiabil, iar dashboard-ul UI este cu adevărat util pentru monitorizare.',
  'Tailwind CSS pentru viteză utility-first, dar mai întâi învață fundamentele CSS simplu ca să înțelegi ce face.',
  'Extrem de important — nu pentru cod în sine, ci pentru a învăța să comunici în contextul unui codebase profesional.',
  'Obsidian pentru notițe, Toggl pentru urmărirea timpului și un caiet de hârtie pentru planificarea zilnică. Simplul câștigă.',
  'Absolut. DOM-ul, pattern-urile async și bucla de evenimente sunt cunoștințe de bază pe care orice framework le construiește.',
  'Plimbare, cafea, 30 de minute de citit înainte de a deschide orice ecran. Face primul bloc de concentrare mult mai ascuțit.',
  'Milestone-uri mici și publicare publică. Nimic nu bate sentimentul că cineva folosește ceva ce ai construit.',
  'A Philosophy of Software Design de John Ousterhout. Mi-a schimbat complet modul de a gândi despre complexitate.',
  'Tratează antrenamentele ca pe întâlniri — intră primele în calendar și celelalte lucruri se potrivesc în jurul lor.'
]

questions = question_data.each_with_index.map do |attrs, i|
  Question.create!(attrs.merge(answer: answers[i]))
end

puts 'Creare aprecieri...'
posts.each do |post|
  users.sample(rand(2..6)).each do |user|
    Like.find_or_create_by!(post:, user:)
  end
end

puts 'Creare comentarii...'
comment_texts = [
  'Foarte bine scris, mulțumesc că ai împărtășit!',
  'Am avut aceeași experiență — sunt total de acord cu punctul tău de vedere.',
  'Poți detalia al treilea punct? Sunt curios despre detalii.',
  'Asta este exact ce aveam nevoie să citesc azi.',
  'Postare grozavă! Ai scris ceva pe tema continuării?',
  'Salvat la favorite. Mă întorc la asta când încep următorul meu proiect.',
  'Nu sunt de acord cu punctul doi, dar restul este excelent.',
  'Am împărtășit asta cu întreaga mea echipă. Foarte util.',
  'Îmi place abordarea practică de aici, mai degrabă decât teoria pură.',
  'Cât timp ți-a luat să îți dai seama de toate acestea?'
]

posts.each do |post|
  users.sample(rand(2..4)).each_with_index do |user, _i|
    Comment.create!(
      post:,
      user:,
      body: comment_texts.sample
    )
  end
end

puts ''
puts 'Gata! Date inițiale create:'
puts "  #{User.count} utilizatori     (admin: alice@example.com / password)"
puts "  #{Tag.count} etichete"
puts "  #{Post.count} postări"
puts "  #{Question.count} întrebări"
puts "  #{Like.count} aprecieri"
puts "  #{Comment.count} comentarii"
puts "  #{UserInterest.count} interese utilizatori"
