puts 'Curățare bază de date...'
Message.destroy_all
Conversation.destroy_all
Notification.destroy_all
Like.destroy_all
Comment.destroy_all
PostTag.destroy_all
UserInterest.destroy_all
Post.destroy_all
ActiveRecord::Base.connection.execute('DELETE FROM tag_questions') rescue nil
ActiveRecord::Base.connection.execute('DELETE FROM questions') rescue nil
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
  { name: 'fitness' },
  { name: 'startup' },
  { name: 'securitate' },
  { name: 'linux' },
  { name: 'remote' },
  { name: 'css' }
])

puts 'Creare utilizatori...'
admin = User.create!(
  name: 'Alice Admin',
  username: 'alice',
  email: 'alice@example.com',
  password: 'password',
  password_confirmation: 'password',
  admin: true
)

users = [admin]

[
  { name: 'Bob Builder',       username: 'bob',     email: 'bob@example.com'     },
  { name: 'Carol Chen',        username: 'carol',   email: 'carol@example.com'   },
  { name: 'David Diaz',        username: 'david',   email: 'david@example.com'   },
  { name: 'Eva Evans',         username: 'eva',     email: 'eva@example.com'     },
  { name: 'Frank Ford',        username: 'frank',   email: 'frank@example.com'   },
  { name: 'Grace Green',       username: 'grace',   email: 'grace@example.com'   },
  { name: 'Henry Hall',        username: 'henry',   email: 'henry@example.com'   },
  { name: 'Iris Ibarra',       username: 'iris',    email: 'iris@example.com'    },
  { name: 'Jack Johnson',      username: 'jack',    email: 'jack@example.com'    },
  { name: 'Katia Moldovan',    username: 'katia',   email: 'katia@example.com'   },
  { name: 'Luca Popa',         username: 'luca',    email: 'luca@example.com'    },
  { name: 'Maria Ionescu',     username: 'maria',   email: 'maria@example.com'   },
  { name: 'Andrei Rusu',       username: 'andrei',  email: 'andrei@example.com'  },
  { name: 'Diana Constantin',  username: 'diana',   email: 'diana@example.com'   },
  { name: 'Radu Gheorghe',     username: 'radu',    email: 'radu@example.com'    },
  { name: 'Sorina Dănilă',     username: 'sorina',  email: 'sorina@example.com'  },
  { name: 'Mihai Stancu',      username: 'mihai',   email: 'mihai@example.com'   },
  { name: 'Elena Petrescu',    username: 'elena',   email: 'elena@example.com'   },
  { name: 'Vlad Marinescu',    username: 'vlad',    email: 'vlad@example.com'    },
].each do |attrs|
  users << User.create!(attrs.merge(password: 'password', password_confirmation: 'password'))
end

puts 'Creare interese utilizatori...'
users.each do |user|
  tags.sample(rand(2..5)).each do |tag|
    UserInterest.find_or_create_by!(user:, tag:)
  end
end

puts 'Creare postări...'
post_data = [
  {
    title: 'Cum să începi cu Ruby on Rails în 2026',
    body: "Rails rămâne unul dintre cele mai productive framework-uri web. Iată ce am învățat după ce am construit trei aplicații în acest an.\n\nAbordarea convenție-în-loc-de-configurare economisește enorm de mult timp, mai ales pentru aplicații centrate pe CRUD. Gemurile ecosistemului sunt mature și documentația este excelentă.",
    user: users[0], tags: tags.select { |t| %w[ruby rails].include?(t.name) }
  },
  {
    title: 'De ce am trecut de la React la Hotwire',
    body: "După ani de lupte cu oboseala JavaScript, Hotwire și Turbo mi-au redat bucuria construirii.\n\nModelul mental este mai simplu și codul rezultat este mult mai puțin complex. Nu mai am nevoie de un API separat doar ca să afișez date pe ecran.",
    user: users[1], tags: tags.select { |t| %w[javascript rails].include?(t.name) }
  },
  {
    title: '10 principii de design pe care orice developer ar trebui să le cunoască',
    body: "Design-ul bun nu înseamnă să faci lucrurile să arate frumos — înseamnă claritate.\n\n1. Ierarhia ghidează privirea. 2. Contrastul creează focusul. 3. Spațiul alb nu este spațiu pierdut. 4. Consistența construiește încredere. 5. Feedback-ul imediat reduce anxietatea.",
    user: users[2], tags: tags.select { |t| %w[design css].include?(t.name) }
  },
  {
    title: 'Cum am obținut primul meu rol de senior engineer',
    body: "Căutarea jobului a durat patru luni, dar iată ce a funcționat cu adevărat.\n\nProiectele din portofoliu bat orice CV. A fi specific cu privire la impact contează mai mult decât lista de tehnologii. Am menționat metrici concrete în fiecare răspuns la interviu.",
    user: users[3], tags: tags.select { |t| %w[cariera].include?(t.name) }
  },
  {
    title: 'Sistemul meu de productivitate cu text simplu',
    body: "Am încercat fiecare aplicație de to-do. Nimic nu a rămas până nu m-am întors la baze.\n\nUn singur fișier markdown, revizuit în fiecare dimineață, este sistemul meu de doi ani. Simplitatea nu este o limitare — este o caracteristică.",
    user: users[4], tags: tags.select { |t| %w[productivitate].include?(t.name) }
  },
  {
    title: 'Integrarea OpenAI într-o aplicație Rails — ghid practic',
    body: "API-ul pare simplu, dar utilizarea în producție are niște capcane reale.\n\nRate limiting, răspunsuri în streaming și estimarea costurilor sunt cele trei lucruri pe care nimeni nu ți le spune. Adaugă întotdeauna un timeout și gestionează erorile de rețea explicit.",
    user: users[5], tags: tags.select { |t| %w[openai ruby rails].include?(t.name) }
  },
  {
    title: 'Călătorie solo în Asia de Sud-Est cu bugetul unui developer',
    body: "Munca remote a schimbat totul despre modul în care călătoresc.\n\nBali, Chiang Mai și Ho Chi Minh City au oferit fiecare ceva diferit ca bază pentru muncă profundă. Viteza internetului a fost surprinzător de bună în toate trei.",
    user: users[6], tags: tags.select { |t| %w[calatorii remote].include?(t.name) }
  },
  {
    title: 'Albumele care mi-au definit sesiunile de coding în acest an',
    body: "Muzica și coding-ul au o conexiune mai profundă decât recunosc majoritatea oamenilor.\n\nLucrările ambientale ale lui Brian Eno, Bonobo și playlist-urile lo-fi hip hop servesc fiecare moduri cognitive diferite. Folosesc muzică cu versuri doar pentru sarcini repetitive.",
    user: users[7], tags: tags.select { |t| %w[muzica productivitate].include?(t.name) }
  },
  {
    title: 'Cum am alergat un semi-maraton lucrând full time',
    body: "Antrenamentul nu necesită ore. Necesită consecvență.\n\nȘaisprezece săptămâni, cinci alergări pe săptămână, niciuna mai lungă de 75 de minute — acesta este tot planul. Trezitul la 6 dimineața nu este opțional.",
    user: users[8], tags: tags.select { |t| %w[fitness].include?(t.name) }
  },
  {
    title: 'Ce mi-aș fi dorit să știu înainte de a construi un produs SaaS',
    body: "Partea tehnică este cea mai ușoară.\n\nDescoperirea clienților, psihologia prețurilor și analiza churn sunt ceea ce determină cu adevărat dacă reușești. Am pierdut șase luni construind funcționalități pe care nimeni nu le-a cerut.",
    user: users[9], tags: tags.select { |t| %w[rails cariera startup].include?(t.name) }
  },
  {
    title: 'Securitatea aplicațiilor web — greșeli comune în Rails',
    body: "Mass assignment, SQL injection și CSRF sunt încă responsabile pentru breșe reale în 2026.\n\nStrong parameters nu sunt opționale. Toate intrările utilizatorului trebuie sanitizate. Auditează gemurile periodic cu bundler-audit.",
    user: users[10], tags: tags.select { |t| %w[rails securitate].include?(t.name) }
  },
  {
    title: 'De ce folosesc Linux ca developer și nu mă mai întorc',
    body: "Trecerea de la macOS a fost inconfortabilă în prima săptămână, libertatea a venit în a doua.\n\nTerminalul nativ, controlul total asupra sistemului și absența bloatware-ului fac diferența. WSL2 pe Windows este o opțiune bună dacă nu vrei să sari direct.",
    user: users[11], tags: tags.select { |t| %w[linux].include?(t.name) }
  },
  {
    title: 'Cum să construiești un startup cu un singur developer',
    body: "Echipele mici nu sunt un dezavantaj — sunt o superputere dacă joci corect.\n\nFocusul pe o singură problemă, decizia rapidă și absența birocrației îți permit să livrezi mai repede decât orice echipă de zece persoane.",
    user: users[12], tags: tags.select { |t| %w[startup cariera rails].include?(t.name) }
  },
  {
    title: 'CSS Grid vs Flexbox — când să folosești ce',
    body: "Ambele sunt instrumente esențiale și se completează reciproc.\n\nFlexbox pentru alinierea elementelor pe o singură axă, Grid pentru layout-uri bidimensionale complexe. Greșeala clasică este să forțezi Grid pentru tot sau să abuzi de Flexbox nested.",
    user: users[13], tags: tags.select { |t| %w[css design].include?(t.name) }
  },
  {
    title: 'Remote first — cum să lucrezi eficient de acasă pe termen lung',
    body: "Munca remote nu este pentru toată lumea, dar poate fi optimizată.\n\nBiroul dedicat, programul fix și pauzele structurate sunt non-negociabile. Comunicarea asincronă scrisă bine înlocuiește 80% din ședințe.",
    user: users[14], tags: tags.select { |t| %w[remote productivitate].include?(t.name) }
  },
  {
    title: 'Cum am lansat primul meu gem Ruby open source',
    body: "Contribuția open source nu trebuie să înceapă cu un framework mare.\n\nAm rezolvat o problemă mică pe care o aveam eu și am publicat-o. Documentația contează la fel de mult ca și codul. Testele automate sunt obligatorii dacă vrei contribuitori.",
    user: users[15], tags: tags.select { |t| %w[ruby cariera].include?(t.name) }
  },
  {
    title: 'Meditația și coding-ul — o combinație neașteptată',
    body: "Zece minute de meditație dimineața îmi îmbunătățesc calitatea concentrării pentru restul zilei.\n\nNu este despre liniște — este despre a antrena capacitatea de a reveni la sarcină după distragere. Exact ce face debugging-ul mai puțin frustrant.",
    user: users[16], tags: tags.select { |t| %w[productivitate fitness].include?(t.name) }
  },
  {
    title: 'JavaScript async/await — înțeles cu adevărat',
    body: "Mulți folosesc async/await fără să înțeleagă event loop-ul din spate.\n\nPromise-urile sunt fundamentul. Async/await este zahăr sintactic peste ele. Greșelile clasice: await în loop-uri, neutilizarea Promise.all pentru apeluri paralele.",
    user: users[17], tags: tags.select { |t| %w[javascript].include?(t.name) }
  },
  {
    title: 'Cum să negociezi salariul ca developer — ghid complet',
    body: "Negocierea nu este agresivă — este profesionistă și așteptată.\n\nCercetează piața înainte. Primul care spune un număr pierde putere. Counter-oferta scrisă este mai eficientă decât o conversație verbală.",
    user: users[18], tags: tags.select { |t| %w[cariera].include?(t.name) }
  },
  {
    title: 'Arhitectura event-driven în Rails — o introducere practică',
    body: "Active Job și cozile de mesaje schimbă fundamental modul în care gândești aplicațiile.\n\nDecuplarea prin evenimente face codul mai testabil și mai rezistent la schimbare. Sidekiq + Redis este combinația standard, dar Solid Queue merită atenție în 2026.",
    user: users[19], tags: tags.select { |t| %w[ruby rails].include?(t.name) }
  }
]

posts = post_data.map do |attrs|
  post_tags = attrs.delete(:tags)
  post = Post.create!(attrs)
  post_tags.each { |tag| PostTag.create!(post:, tag:) }
  post
end

puts 'Creare aprecieri...'
posts.each do |post|
  users.sample(rand(3..9)).each do |user|
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
  'Cât timp ți-a luat să îți dai seama de toate acestea?',
  'Exact ce căutam, mersi mult!',
  'O perspectivă interesantă, nu mă gândisem la asta.',
  'Aplicat imediat în proiectul meu. Funcționează perfect.',
  'Aș adăuga că experiența personală contează enorm aici.',
  'Super conținut, continua tot așa!'
]

posts.each do |post|
  users.sample(rand(2..6)).each do |user|
    Comment.create!(post:, user:, body: comment_texts.sample)
  end
end

puts 'Creare conversații și mesaje...'
msg_snippets = [
  ['Salut! Am văzut postarea ta despre Rails, super utilă!', 'Mulțumesc, mă bucur că ți-a plăcut!', 'Am și eu o întrebare legată de Hotwire, ai timp?', 'Sigur, spune!'],
  ['Bună! Colaborăm pe proiectul ăla open source?', 'Da, cu plăcere. Ce rol vrei să îți asumi?', 'Mă ocup de frontend dacă e ok.', 'Perfect, am nevoie de ajutor acolo.'],
  ['Ai recomandări de cursuri pentru securitate web?', 'PortSwigger Web Security Academy e gratuit și excelent.', 'Mulțumesc, o să încerc!', 'Succes, e destul de dens dar merită.'],
  ['Ce editor folosești zilnic?', 'Neovim de vreo 2 ani, nu mă mai întorc.', 'Nu mi-e frică să încerc dar setup-ul pare complicat.', 'Îți trimit config-ul meu dacă vrei.'],
  ['Ai văzut noul release Rails 8?', 'Da! Solid Queue și Solid Cache sunt game changers.', 'Nu mai ai nevoie de Redis deloc acum.', 'Exact, simplifică enorm infrastructura.'],
  ['Lucrezi remote full time?', 'Da, de 3 ani. Tu?', 'De un an, încă mă adaptez.', 'Cel mai greu e să trasezi granița muncă/viață personală.'],
  ['Cum îți organizezi task-urile?', 'Un simplu fișier todo.md sincronizat cu git.', 'Interesant, nu m-am gândit la asta.', 'E surprinzător de eficient pentru proiecte solo.'],
  ['Bună ziua! Ai putea să îmi revizuiești PR-ul?', 'Sigur, trimite link-ul.', 'Îți mulțumesc anticipat!', 'Nicio problemă, e un PR curat.'],
]

user_pairs = users.combination(2).to_a.sample(12)
user_pairs.each_with_index do |(sender, recipient), i|
  convo = Conversation.create!(sender:, recipient:)
  msgs = msg_snippets[i % msg_snippets.size]
  msgs.each_with_index do |body, idx|
    speaker = idx.even? ? sender : recipient
    Message.create!(conversation: convo, user: speaker, body:, read: idx < msgs.size - 1)
  end
end

puts 'Creare notificări...'
# like notifications
Like.limit(30).each do |like|
  next if like.user == like.post.user
  Notification.find_or_create_by!(
    user: like.post.user,
    actor: like.user,
    notifiable: like.post,
    kind: 'like',
    read: [true, false].sample
  )
end

# comment notifications
Comment.limit(30).each do |comment|
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
puts "  #{Like.count} aprecieri"
puts "  #{Comment.count} comentarii"
puts "  #{UserInterest.count} interese utilizatori"
puts "  #{Conversation.count} conversații"
puts "  #{Message.count} mesaje"
puts "  #{Notification.count} notificări"
