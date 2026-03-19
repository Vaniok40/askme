puts 'Curățare bază de date...'
Message.destroy_all
Conversation.destroy_all
Notification.destroy_all
Like.destroy_all
Comment.destroy_all
PostTag.destroy_all
UserInterest.destroy_all
begin
  Follow.destroy_all
rescue StandardError
  nil
end
Post.destroy_all
begin
  ActiveRecord::Base.connection.execute('DELETE FROM tag_questions')
rescue StandardError
  nil
end
begin
  ActiveRecord::Base.connection.execute('DELETE FROM questions')
rescue StandardError
  nil
end
Tag.destroy_all
User.destroy_all

puts 'Creare etichete...'
tag_names = %w[
  ruby rails javascript typescript python go rust java kotlin swift
  design css html react vue angular svelte nextjs nuxtjs astro
  cariera startup productivitate remote calatorii fitness muzica
  openai securitate linux docker kubernetes devops git testing
  postgresql mysql redis mongodb graphql rest api microservices
  mobile ios android flutter react-native gaming books film
  fotografie cooking mindfulness finance crypto blockchain web3
]
tags = tag_names.map { |name| Tag.create!(name:) }

puts 'Creare utilizatori...'
user_data = [
  { name: 'Alice Admin',       username: 'alice',    email: 'alice@example.com', admin: true },
  { name: 'Bob Builder',       username: 'bob',      email: 'bob@example.com' },
  { name: 'Carol Chen',        username: 'carol',    email: 'carol@example.com' },
  { name: 'David Diaz',        username: 'david',    email: 'david@example.com' },
  { name: 'Eva Evans',         username: 'eva',      email: 'eva@example.com' },
  { name: 'Frank Ford',        username: 'frank',    email: 'frank@example.com' },
  { name: 'Grace Green',       username: 'grace',    email: 'grace@example.com' },
  { name: 'Henry Hall',        username: 'henry',    email: 'henry@example.com' },
  { name: 'Iris Ibarra',       username: 'iris',     email: 'iris@example.com' },
  { name: 'Jack Johnson',      username: 'jack',     email: 'jack@example.com' },
  { name: 'Katia Moldovan',    username: 'katia',    email: 'katia@example.com' },
  { name: 'Luca Popa',         username: 'luca',     email: 'luca@example.com' },
  { name: 'Maria Ionescu',     username: 'maria',    email: 'maria@example.com' },
  { name: 'Andrei Rusu',       username: 'andrei',   email: 'andrei@example.com' },
  { name: 'Diana Constantin',  username: 'diana',    email: 'diana@example.com' },
  { name: 'Radu Gheorghe',     username: 'radu',     email: 'radu@example.com' },
  { name: 'Sorina Dănilă',     username: 'sorina',   email: 'sorina@example.com' },
  { name: 'Mihai Stancu',      username: 'mihai',    email: 'mihai@example.com' },
  { name: 'Elena Petrescu',    username: 'elena',    email: 'elena@example.com' },
  { name: 'Vlad Marinescu',    username: 'vlad',     email: 'vlad@example.com' },
  { name: 'Ana Ciobanu',       username: 'ana',      email: 'ana@example.com' },
  { name: 'Bogdan Iancu',      username: 'bogdan',   email: 'bogdan@example.com' },
  { name: 'Cristina Marin',    username: 'cristina', email: 'cristina@example.com' },
  { name: 'Dan Neagu',         username: 'dan',      email: 'dan@example.com' },
  { name: 'Emil Sandu',        username: 'emil',     email: 'emil@example.com' },
  { name: 'Florina Vasilescu', username: 'florina',  email: 'florina@example.com' },
  { name: 'Gabi Tudose',       username: 'gabi',     email: 'gabi@example.com' },
  { name: 'Horia Dobre',       username: 'horia',    email: 'horia@example.com' },
  { name: 'Ioana Nistor',      username: 'ioana',    email: 'ioana@example.com' },
  { name: 'Julian Braescu',    username: 'julian',   email: 'julian@example.com' },
  { name: 'Karina Oprea',      username: 'karina',   email: 'karina@example.com' },
  { name: 'Liviu Rotaru',      username: 'liviu',    email: 'liviu@example.com' },
  { name: 'Mădălina Stoica',   username: 'madalina', email: 'madalina@example.com' },
  { name: 'Nicu Barbu',        username: 'nicu',     email: 'nicu@example.com' },
  { name: 'Oana Dumitrescu',   username: 'oana',     email: 'oana@example.com' },
  { name: 'Paul Alexandrescu', username: 'paul',     email: 'paul@example.com' },
  { name: 'Raluca Mitrea',     username: 'raluca',   email: 'raluca@example.com' },
  { name: 'Stefan Voicu',      username: 'stefan',   email: 'stefan@example.com' },
  { name: 'Teodora Lazar',     username: 'teodora',  email: 'teodora@example.com' },
  { name: 'Victor Ungur',      username: 'victor',   email: 'victor@example.com' },
  { name: 'Viorica Serban',    username: 'viorica',  email: 'viorica@example.com' },
  { name: 'Walter Enache',     username: 'walter',   email: 'walter@example.com' },
  { name: 'Xenia Florea',      username: 'xenia',    email: 'xenia@example.com' },
  { name: 'Yanis Popescu',     username: 'yanis',    email: 'yanis@example.com' },
  { name: 'Zara Constantin',   username: 'zara',     email: 'zara@example.com' },
  { name: 'Adrian Badea',      username: 'adrian',   email: 'adrian@example.com' },
  { name: 'Bianca Moldovan',   username: 'bianca',   email: 'bianca@example.com' },
  { name: 'Cosmin Iordache',   username: 'cosmin',   email: 'cosmin@example.com' },
  { name: 'Daria Paunescu',    username: 'daria',    email: 'daria@example.com' },
  { name: 'Eduard Stroe',      username: 'eduard',   email: 'eduard@example.com' }
]

users = user_data.map do |attrs|
  User.create!(attrs.merge(password: 'password', password_confirmation: 'password'))
end

puts 'Creare interese utilizatori...'
users.each do |user|
  tags.sample(rand(4..8)).each { |tag| UserInterest.find_or_create_by!(user:, tag:) }
end

puts 'Creare postări...'

titles_pool = [
  'Cum să începi cu %s în 2026',
  'De ce am ales %s pentru proiectul meu',
  'Ghid practic: %s pentru începători',
  'Lecții învățate după un an de %s',
  'Top 5 trucuri în %s pe care nu le știai',
  'Greșeli comune în %s și cum să le eviți',
  'Viitorul %s — ce urmează?',
  '%s vs alternative — comparație sinceră',
  'Cum am optimizat performanța cu %s',
  'De la zero la productiv cu %s',
  'Arhitectura modernă cu %s',
  'Testarea aplicațiilor %s — ghid complet',
  'Securitate și %s — ce trebuie să știi',
  'Scalabilitate cu %s în producție',
  'Comunitatea %s — resurse și oameni'
]

bodies_pool = [
  "Am petrecut ultimele luni explorând această tehnologie și iată ce am descoperit.\n\nPrimul lucru care m-a surprins a fost cât de repede poți ajunge la un produs funcțional. Documentația este excelentă și comunitatea răspunde rapid la întrebări.",
  "Tranziția nu a fost ușoară, dar a meritat fiecare oră investită.\n\nEcosistemul este matur, tooling-ul este solid și codul rezultat este mult mai ușor de întreținut. Recomand oricui să facă pasul.",
  "Există câteva concepte cheie pe care trebuie să le înțelegi înainte să începi.\n\nOdată ce le stăpânești, totul devine intuitiv. Am făcut greșeala să sar peste fundamente și am plătit cu ore de debugging.",
  "Nu toate proiectele au nevoie de această soluție, dar când se potrivește, se potrivește perfect.\n\nCriterii de decizie: volumul de date, complexitatea domeniului și experiența echipei sunt cei trei factori principali.",
  "Am implementat asta în producție acum 6 luni și nu am avut niciun regret.\n\nPerformanța s-a îmbunătățit cu 40%, codul a devenit mai clar și onboarding-ul noilor colegi a fost mult mai rapid.",
  "Să fiu sincer: am rezistit mult timp înainte să încerc.\n\nPrima impresie a fost copleșitoare, dar după două săptămâni totul a dat clic. Curba de învățare este reală, dar recompensa merită.",
  "Proiectul meu side a fost terenul de joacă perfect pentru a explora aceste concepte.\n\nAm documentat fiecare pas și iată ce ar fi trebuit să știu de la început.",
  "Cel mai important lucru pe care l-am învățat: nu există soluție universală.\n\nContextul contează enorm. Ce funcționează pentru un startup de 3 oameni nu funcționează neapărat pentru o echipă de 50.",
  "Am comparat mai multe abordări înainte să mă decid.\n\nCriteriile mele: viteză de dezvoltare, mentenabilitate pe termen lung și compatibilitatea cu restul stack-ului. Iată concluzia la care am ajuns.",
  "Sfatul meu principal: construiește ceva real, nu doar tutoriale.\n\nTutorialele îți arată happy path-ul. Proiectele reale te învață să gestionezi edge cases, erori neașteptate și cerințe care se schimbă."
]

posts = []
users.each do |user|
  post_count = rand(5..10)
  post_count.times do
    topic = tags.sample.name.capitalize
    title = titles_pool.sample % topic
    body  = bodies_pool.sample
    post_tags = tags.sample(rand(1..4))

    post = Post.create!(title:, body:, user:)
    post_tags.each { |tag| PostTag.find_or_create_by!(post:, tag:) }
    posts << post
  end
end

puts "  #{posts.size} postări create"

puts 'Creare urmăriri...'
users.each do |follower|
  targets = (users - [follower]).sample(rand(8..18))
  targets.each { |followed| Follow.find_or_create_by!(follower:, followed:) }
end

puts 'Creare aprecieri...'
users.each do |user|
  posts.sample(rand(15..40)).each { |post| Like.find_or_create_by!(post:, user:) }
end

puts 'Creare comentarii...'
comment_texts = [
  'Foarte bine scris, mulțumesc că ai împărtășit!',
  'Am avut aceeași experiență — sunt total de acord.',
  'Poți detalia acest punct? Sunt curios de detalii.',
  'Exact ce aveam nevoie să citesc azi.',
  'Postare grozavă! Ai mai scris pe tema asta?',
  'Salvat. Mă întorc la asta la următorul proiect.',
  'Nu sunt de acord cu un punct, dar restul e excelent.',
  'Am împărtășit cu întreaga echipă. Foarte util.',
  'Îmi place abordarea practică, nu doar teorie.',
  'Cât timp ți-a luat să ajungi la concluzia asta?',
  'Exact ce căutam, mersi mult!',
  'O perspectivă interesantă, nu mă gândisem la asta.',
  'Aplicat imediat. Funcționează perfect.',
  'Aș adăuga că experiența personală contează enorm.',
  'Super conținut, continuă tot așa!',
  'Ai folosit vreo gem sau librărie specifică pentru asta?',
  'Asta rezolvă o problemă cu care mă luptam de săptămâni.',
  'Bookmarked. Revin cu feedback după implementare.',
  'Ar fi interesant un follow-up cu exemple de cod.',
  'Perspectivă fresh — diferit de ce citesc de obicei.',
  'Pot să te întreb ceva legat de implementare?',
  'Am testat și la mine, rezultatele sunt similare.',
  'Punctul 3 mi s-a părut cel mai valoros. Mulțumesc!',
  'Aveam exact aceeași problemă săptămâna trecută.'
]

posts.each do |post|
  users.sample(rand(3..9)).each do |user|
    Comment.create!(post:, user:, body: comment_texts.sample)
  end
end

puts 'Creare conversații și mesaje...'

msg_snippets = [
  ['Salut! Am văzut postarea ta, super utilă!', 'Mulțumesc, mă bucur că ți-a plăcut!',
   'Am și o întrebare dacă ai timp.', 'Sigur, spune!'],
  ['Bună! Colaborăm pe proiectul open source?', 'Da, cu plăcere. Ce rol vrei?', 'Mă ocup de frontend.',
   'Perfect, am nevoie de ajutor acolo.'],
  ['Ai recomandări de cursuri pentru securitate?', 'PortSwigger Academy e gratuit și excelent.', 'Mulțumesc, încerc!',
   'Succes, e dens dar merită.'],
  ['Ce editor folosești zilnic?', 'Neovim de 2 ani, nu mă mai întorc.', 'Setup-ul pare complicat.',
   'Îți trimit config-ul dacă vrei.'],
  ['Ai văzut noul release Rails 8?', 'Da! Solid Queue e un game changer.', 'Nu mai ai nevoie de Redis.',
   'Exact, simplifică infrastructura.'],
  ['Lucrezi remote full time?', 'Da, de 3 ani. Tu?', 'De un an, încă mă adaptez.',
   'Cel mai greu e granița muncă/viață.'],
  ['Cum îți organizezi task-urile?', 'Un simplu fișier todo.md cu git.', 'Interesant, nu m-am gândit la asta.',
   'E surprinzător de eficient.'],
  ['Ai putea să îmi revizuiești PR-ul?', 'Sigur, trimite link-ul.', 'Îți mulțumesc anticipat!',
   'Nicio problemă, e curat.'],
  ['Ce crezi despre TypeScript?', 'Merită, mai ales pentru proiecte mari.', 'Curba de învățare e ok?',
   'Dacă știi JS bine, e rapid.'],
  ['Cum ai rezolvat problema de performanță?', 'Cu indecși parțiali în PostgreSQL.', 'Chiar a mers?',
   'De la 2s la 80ms pe query-ul principal.'],
  ['Recomandă-mi o carte de arhitectură.', 'Clean Architecture de Uncle Bob e clasicul.', 'Am auzit controverse.',
   'Ia ce e bun și adaptează.'],
  ['Ce stack folosești pentru proiectul nou?', 'Rails + Hotwire + PostgreSQL.', 'Nu ai luat în calcul Node?',
   'Pentru CRUD, Rails e imbatabil.'],
  ['Bună ziua! Am o problemă cu deploy-ul.', 'Ce eroare primești?', 'Timeout la migrări.',
   'Rulează migrările separat înainte de restart.'],
  ['Lucrezi la ceva interesant acum?', 'Un tool de monitorizare cu Rails și WebSockets.',
   'Sună interesant! Open source?', 'Plănuiesc să îl public luna viitoare.'],
  ['Ai experiență cu Docker în producție?', 'Da, 2 ani. Ce te interesează?', 'Cum gestionezi secretele?',
   'Docker secrets + Vault pentru proiecte serioase.'],
  ['Ce părere ai despre Svelte?', 'Mi-a plăcut mult, foarte simplu.', 'Merită pentru proiecte noi?',
   'Absolut, mai ales dacă nu ai nevoie de SSR complex.'],
  ['Cum faci code review eficient?', 'Comentarii precise cu sugestii concrete.', 'Cât timp aloci?',
   'Maximum 45 minute per PR, altfel obosești.'],
  ['Ai folosit vreodată Redis pentru altceva decât cache?', 'Da, pub/sub și rate limiting.', 'Cum e pentru pub/sub?',
   'Simplu și rapid, funcționează bine la scală medie.'],
  ['Cum alegi între monolith și microservicii?', 'Monolith până când simți nevoia reală.',
   'Care e semnul că ai nevoie?', 'Când echipe diferite se blochează unele pe altele.'],
  ['Ai un sistem de backup pentru proiecte personale?', 'Git + backup automat pe Backblaze B2.', 'Cât costă?',
   'Aproape nimic, câțiva dolari pe lună.']
]

conversation_pairs = users.combination(2).to_a.sample(55)
conversation_pairs.each_with_index do |(sender, recipient), i|
  convo = Conversation.create!(sender:, recipient:)
  msgs = msg_snippets[i % msg_snippets.size]
  rounds = rand(1..3)
  (msgs * rounds).each_with_index do |body, idx|
    speaker = idx.even? ? sender : recipient
    Message.create!(conversation: convo, user: speaker, body:, read: idx < (msgs.size * rounds) - 1)
  end
end

puts 'Creare notificări...'
Like.all.each do |like|
  next if like.user == like.post.user

  Notification.find_or_create_by!(
    user: like.post.user,
    actor: like.user,
    notifiable: like.post,
    kind: 'like',
    read: [true, false].sample
  )
end

Comment.all.each do |comment|
  next if comment.user == comment.post.user

  Notification.find_or_create_by!(
    user: comment.post.user,
    actor: comment.user,
    notifiable: comment,
    kind: 'comment',
    read: [true, false].sample
  )
end

puts ''
puts 'Gata! Date inițiale create:'
puts "  #{User.count} utilizatori     (admin: alice@example.com / password)"
puts "  #{Tag.count} etichete"
puts "  #{Post.count} postări"
puts "  #{Follow.count} urmăriri"
puts "  #{Like.count} aprecieri"
puts "  #{Comment.count} comentarii"
puts "  #{UserInterest.count} interese utilizatori"
puts "  #{Conversation.count} conversații"
puts "  #{Message.count} mesaje"
puts "  #{Notification.count} notificări"
