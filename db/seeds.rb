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

# ── Tags (50+) ────────────────────────────────────────────────────────────────
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

# ── Users (50+) ───────────────────────────────────────────────────────────────
puts 'Creare utilizatori...'
user_data = [
  { name: 'Alice Admin',        username: 'alice',    email: 'alice@example.com', admin: true },
  { name: 'Bob Builder',        username: 'bob',      email: 'bob@example.com' },
  { name: 'Carol Chen',         username: 'carol',    email: 'carol@example.com' },
  { name: 'David Diaz',         username: 'david',    email: 'david@example.com' },
  { name: 'Eva Evans',          username: 'eva',      email: 'eva@example.com' },
  { name: 'Frank Ford',         username: 'frank',    email: 'frank@example.com' },
  { name: 'Grace Green',        username: 'grace',    email: 'grace@example.com' },
  { name: 'Henry Hall',         username: 'henry',    email: 'henry@example.com' },
  { name: 'Iris Ibarra',        username: 'iris',     email: 'iris@example.com' },
  { name: 'Jack Johnson',       username: 'jack',     email: 'jack@example.com' },
  { name: 'Katia Moldovan',     username: 'katia',    email: 'katia@example.com' },
  { name: 'Luca Popa',          username: 'luca',     email: 'luca@example.com' },
  { name: 'Maria Ionescu',      username: 'maria',    email: 'maria@example.com' },
  { name: 'Andrei Rusu',        username: 'andrei',   email: 'andrei@example.com' },
  { name: 'Diana Constantin',   username: 'diana',    email: 'diana@example.com' },
  { name: 'Radu Gheorghe',      username: 'radu',     email: 'radu@example.com' },
  { name: 'Sorina Dănilă',      username: 'sorina',   email: 'sorina@example.com' },
  { name: 'Mihai Stancu',       username: 'mihai',    email: 'mihai@example.com' },
  { name: 'Elena Petrescu',     username: 'elena',    email: 'elena@example.com' },
  { name: 'Vlad Marinescu',     username: 'vlad',     email: 'vlad@example.com' },
  { name: 'Ana Ciobanu',        username: 'ana',      email: 'ana@example.com' },
  { name: 'Bogdan Iancu',       username: 'bogdan',   email: 'bogdan@example.com' },
  { name: 'Cristina Marin',     username: 'cristina', email: 'cristina@example.com' },
  { name: 'Dan Neagu',          username: 'dan',      email: 'dan@example.com' },
  { name: 'Emil Sandu',         username: 'emil',     email: 'emil@example.com' },
  { name: 'Florina Vasilescu',  username: 'florina',  email: 'florina@example.com' },
  { name: 'Gabi Tudose',        username: 'gabi',     email: 'gabi@example.com' },
  { name: 'Horia Dobre',        username: 'horia',    email: 'horia@example.com' },
  { name: 'Ioana Nistor',       username: 'ioana',    email: 'ioana@example.com' },
  { name: 'Julian Braescu',     username: 'julian',   email: 'julian@example.com' },
  { name: 'Karina Oprea',       username: 'karina',   email: 'karina@example.com' },
  { name: 'Liviu Rotaru',       username: 'liviu',    email: 'liviu@example.com' },
  { name: 'Mădălina Stoica',    username: 'madalina', email: 'madalina@example.com' },
  { name: 'Nicu Barbu',         username: 'nicu',     email: 'nicu@example.com' },
  { name: 'Oana Dumitrescu',    username: 'oana',     email: 'oana@example.com' },
  { name: 'Paul Alexandrescu',  username: 'paul',     email: 'paul@example.com' },
  { name: 'Raluca Mitrea',      username: 'raluca',   email: 'raluca@example.com' },
  { name: 'Stefan Voicu',       username: 'stefan',   email: 'stefan@example.com' },
  { name: 'Teodora Lazar',      username: 'teodora',  email: 'teodora@example.com' },
  { name: 'Ungur Victor',       username: 'ungur',    email: 'ungur@example.com' },
  { name: 'Viorica Serban',     username: 'viorica',  email: 'viorica@example.com' },
  { name: 'Walter Enache',      username: 'walter',   email: 'walter@example.com' },
  { name: 'Xenia Florea',       username: 'xenia',    email: 'xenia@example.com' },
  { name: 'Yanis Popescu',      username: 'yanis',    email: 'yanis@example.com' },
  { name: 'Zara Constantin',    username: 'zara',     email: 'zara@example.com' },
  { name: 'Adrian Badea',       username: 'adrian',   email: 'adrian@example.com' },
  { name: 'Bianca Moldovan',    username: 'bianca',   email: 'bianca@example.com' },
  { name: 'Cosmin Iordache',    username: 'cosmin',   email: 'cosmin@example.com' },
  { name: 'Daria Paunescu',     username: 'daria',    email: 'daria@example.com' },
  { name: 'Eduard Stroe',       username: 'eduard',   email: 'eduard@example.com' }
]

users = user_data.map do |attrs|
  User.create!(attrs.merge(password: 'password', password_confirmation: 'password'))
end

# ── User Interests ────────────────────────────────────────────────────────────
puts 'Creare interese utilizatori...'
users.each do |user|
  tags.sample(rand(3..7)).each do |tag|
    UserInterest.find_or_create_by!(user:, tag:)
  end
end

# ── Posts (50+) ───────────────────────────────────────────────────────────────
puts 'Creare postări...'
post_data = [
  { title: 'Cum să începi cu Ruby on Rails în 2026',
    body: "Rails rămâne unul dintre cele mai productive framework-uri web. Iată ce am învățat după ce am construit trei aplicații în acest an.\n\nAbordarea convenție-în-loc-de-configurare economisește enorm de mult timp, mai ales pentru aplicații centrate pe CRUD. Gemurile ecosistemului sunt mature și documentația este excelentă.", tag_names: %w[ruby rails] },
  { title: 'De ce am trecut de la React la Hotwire',
    body: "După ani de lupte cu oboseala JavaScript, Hotwire și Turbo mi-au redat bucuria construirii.\n\nModelul mental este mai simplu și codul rezultat este mult mai puțin complex. Nu mai am nevoie de un API separat.", tag_names: %w[javascript rails] },
  { title: '10 principii de design pe care orice developer ar trebui să le cunoască',
    body: "Design-ul bun nu înseamnă să faci lucrurile să arate frumos — înseamnă claritate.\n\n1. Ierarhia ghidează privirea. 2. Contrastul creează focusul. 3. Spațiul alb nu este spațiu pierdut.", tag_names: %w[design css] },
  { title: 'Cum am obținut primul meu rol de senior engineer',
    body: "Căutarea jobului a durat patru luni, dar iată ce a funcționat cu adevărat.\n\nProiectele din portofoliu bat orice CV. A fi specific cu privire la impact contează mai mult decât lista de tehnologii.", tag_names: %w[cariera] },
  { title: 'Sistemul meu de productivitate cu text simplu',
    body: "Am încercat fiecare aplicație de to-do. Nimic nu a rămas până nu m-am întors la baze.\n\nUn singur fișier markdown, revizuit în fiecare dimineață, este sistemul meu de doi ani.", tag_names: %w[productivitate] },
  { title: 'Integrarea OpenAI într-o aplicație Rails — ghid practic',
    body: "API-ul pare simplu, dar utilizarea în producție are niște capcane reale.\n\nRate limiting, răspunsuri în streaming și estimarea costurilor sunt cele trei lucruri pe care nimeni nu ți le spune.", tag_names: %w[openai ruby rails] },
  { title: 'Călătorie solo în Asia de Sud-Est cu bugetul unui developer',
    body: "Munca remote a schimbat totul despre modul în care călătoresc.\n\nBali, Chiang Mai și Ho Chi Minh City au oferit fiecare ceva diferit ca bază pentru muncă profundă.", tag_names: %w[calatorii remote] },
  { title: 'Albumele care mi-au definit sesiunile de coding în acest an',
    body: "Muzica și coding-ul au o conexiune mai profundă decât recunosc majoritatea oamenilor.\n\nLucrările ambientale ale lui Brian Eno, Bonobo și playlist-urile lo-fi hip hop servesc fiecare moduri cognitive diferite.", tag_names: %w[muzica productivitate] },
  { title: 'Cum am alergat un semi-maraton lucrând full time',
    body: "Antrenamentul nu necesită ore. Necesită consecvență.\n\nȘaisprezece săptămâni, cinci alergări pe săptămână, niciuna mai lungă de 75 de minute — acesta este tot planul.", tag_names: %w[fitness] },
  { title: 'Ce mi-aș fi dorit să știu înainte de a construi un produs SaaS',
    body: "Partea tehnică este cea mai ușoară.\n\nDescoperirea clienților, psihologia prețurilor și analiza churn sunt ceea ce determină cu adevărat dacă reușești.", tag_names: %w[rails cariera startup] },
  { title: 'Securitatea aplicațiilor web — greșeli comune în Rails',
    body: "Mass assignment, SQL injection și CSRF sunt încă responsabile pentru breșe reale în 2026.\n\nStrong parameters nu sunt opționale. Toate intrările utilizatorului trebuie sanitizate.", tag_names: %w[rails securitate] },
  { title: 'De ce folosesc Linux ca developer și nu mă mai întorc',
    body: "Trecerea de la macOS a fost inconfortabilă în prima săptămână, libertatea a venit în a doua.\n\nTerminalul nativ, controlul total asupra sistemului și absența bloatware-ului fac diferența.", tag_names: %w[linux] },
  { title: 'Cum să construiești un startup cu un singur developer',
    body: "Echipele mici nu sunt un dezavantaj — sunt o superputere dacă joci corect.\n\nFocusul pe o singură problemă, decizia rapidă și absența birocrației îți permit să livrezi mai repede.", tag_names: %w[startup cariera rails] },
  { title: 'CSS Grid vs Flexbox — când să folosești ce',
    body: "Ambele sunt instrumente esențiale și se completează reciproc.\n\nFlexbox pentru alinierea elementelor pe o singură axă, Grid pentru layout-uri bidimensionale complexe.", tag_names: %w[css design] },
  { title: 'Remote first — cum să lucrezi eficient de acasă pe termen lung',
    body: "Munca remote nu este pentru toată lumea, dar poate fi optimizată.\n\nBiroul dedicat, programul fix și pauzele structurate sunt non-negociabile.", tag_names: %w[remote productivitate] },
  { title: 'Cum am lansat primul meu gem Ruby open source',
    body: "Contribuția open source nu trebuie să înceapă cu un framework mare.\n\nAm rezolvat o problemă mică pe care o aveam eu și am publicat-o. Documentația contează la fel de mult ca și codul.", tag_names: %w[ruby cariera] },
  { title: 'Meditația și coding-ul — o combinație neașteptată',
    body: "Zece minute de meditație dimineața îmi îmbunătățesc calitatea concentrării pentru restul zilei.\n\nNu este despre liniște — este despre a antrena capacitatea de a reveni la sarcină după distragere.", tag_names: %w[productivitate fitness] },
  { title: 'JavaScript async/await — înțeles cu adevărat',
    body: "Mulți folosesc async/await fără să înțeleagă event loop-ul din spate.\n\nPromise-urile sunt fundamentul. Async/await este zahăr sintactic peste ele.", tag_names: %w[javascript] },
  { title: 'Cum să negociezi salariul ca developer — ghid complet',
    body: "Negocierea nu este agresivă — este profesionistă și așteptată.\n\nCercetează piața înainte. Primul care spune un număr pierde putere.", tag_names: %w[cariera] },
  { title: 'Arhitectura event-driven în Rails — o introducere practică',
    body: "Active Job și cozile de mesaje schimbă fundamental modul în care gândești aplicațiile.\n\nDecuplarea prin evenimente face codul mai testabil și mai rezistent la schimbare.", tag_names: %w[ruby rails] },
  { title: 'TypeScript în 2026 — merită dacă vii din JavaScript pur?',
    body: "Răspunsul scurt: absolut da.\n\nSistemul de tipuri prinde erori la compilare pe care altfel le-ai descoperi în producție. Curba de învățare este rezonabilă dacă știi deja JavaScript bine.", tag_names: %w[typescript javascript] },
  { title: 'Docker pentru developeri — de la zero la containerizat',
    body: "Containerizarea aplicației tale nu este rocket science, dar există câteva concepte cheie.\n\nDockerfile, docker-compose și volumele sunt primele trei lucruri de înțeles bine.", tag_names: %w[docker devops] },
  { title: 'PostgreSQL — funcționalități avansate pe care le ignori',
    body: "Indexuri parțiale, JSONB, window functions și full-text search sunt disponibile nativ.\n\nDe ce să adaugi complexitate cu un alt serviciu când PostgreSQL poate face asta?", tag_names: %w[postgresql] },
  { title: 'Cum să citești mai multe cărți tehnice și să reții informația',
    body: "Tehnica Feynman aplicată la cărți tehnice: citește, explică altcuiva, identifică lacunele.\n\nLuarea de notițe active, nu pasive, face diferența între a citi și a înțelege.", tag_names: %w[productivitate books] },
  { title: 'Kubernetes — de ce îl eviți și de ce ar trebui să reconsideri',
    body: "Kubernetes are o reputație de complexitate meritată, dar pentru sistemele distribuite este standardul.\n\nÎncepând cu Minikube local și cu un cluster managed în cloud este calea pragmatică.", tag_names: %w[kubernetes devops] },
  { title: 'Python pentru developeri Ruby — comparație sinceră',
    body: "Am petrecut trei luni scriind Python serios după șase ani de Ruby.\n\nSintaxa este diferită, dar mentalitatea este similară. Data science-ul este motivul principal să faci switch-ul.", tag_names: %w[python ruby] },
  { title: 'GraphQL vs REST — alegerea corectă pentru proiectul tău',
    body: "Nu există un câștigător universal. Contextul contează.\n\nGraphQL excelează când clienții au nevoi de date diverse. REST este mai simplu de cache-uit și de debuggat.", tag_names: %w[graphql rest api] },
  { title: 'Git — comenzile pe care le folosesc zilnic și pe care nu le știai',
    body: "git bisect, git worktree și git reflog m-au salvat de mai multe ori.\n\nInteractivul rebase și fixup sunt esențiale pentru un istoric curat.", tag_names: %w[git] },
  { title: 'Cum am redus bundle size-ul cu 60% în aplicația noastră React',
    body: "Tree shaking, code splitting și lazy loading sunt primele trei unelte.\n\nAnalizând bundle-ul cu webpack-bundle-analyzer am descoperit că importam întreaga librărie lodash pentru trei funcții.", tag_names: %w[react javascript] },
  { title: 'Mobile first — de ce designul pentru mobil trebuie să vină primul',
    body: "Proiectarea pentru constrângeri te face mai creativ și mai focusat.\n\nMajoritatea traficului web vine de pe mobil. Adăugarea de complexitate pentru desktop este mai ușoară decât eliminarea ei.", tag_names: %w[design mobile] },
  { title: 'Redis — mai mult decât un cache',
    body: "Pub/Sub, sorted sets pentru leaderboards, rate limiting și session storage.\n\nRedis este un cuțit elvețian al infrastructurii moderne. Știu că îl folosești ca cache — încearcă și restul.", tag_names: %w[redis] },
  { title: 'Cum testez aplicațiile Rails — strategia mea completă',
    body: "Model specs pentru logica de business, request specs pentru API-uri, system specs pentru fluxuri critice.\n\nEvit fixture-urile în favoarea factory-urilor. Testele rapide care rulează des bat testele lente.", tag_names: %w[rails testing ruby] },
  { title: 'Burnout ca developer — semne, cauze și recuperare',
    body: "Am trecut prin burnout în 2024 și mi-a luat șase luni să revin.\n\nSemnele timpurii: lipsa motivației pentru proiecte care te entuziasmau, erori banale repetate, cinism față de muncă.", tag_names: %w[cariera productivitate] },
  { title: 'Fotografiez arhitectura urbană — ce am învățat în doi ani',
    body: "Compoziția bate echipamentul în 90% din situații.\n\nLuminatrul de aur (prima oră după răsărit și ultima înainte de apus) transformă scenele banale în ceva magic.", tag_names: %w[fotografie] },
  { title: 'Cum să gătești sănătos când lucrezi mult — rețetele mele de bază',
    body: "Batch cooking duminica îmi salvează săptămâna.\n\nCinci rețete simple pe care le rotesc: bowl cu quinoa, supă de linte, paste cu legume, orez cu tofu, salată de naut.", tag_names: %w[cooking fitness] },
  { title: 'Flutter vs React Native — experiența mea cu amândouă',
    body: "Am construit o aplicație în fiecare și iată concluzia sinceră.\n\nFlutter are o experiență de developer mai consistentă. React Native are un ecosistem mai mare dacă vii din web.", tag_names: %w[flutter react-native mobile] },
  { title: 'Cum să dai review la cod — arta feedback-ului constructiv',
    body: "Reviewul de cod este o conversație, nu o judecată.\n\nPropune, nu impune. Explică de ce, nu doar ce. Laudă ce e bine, nu doar critică ce e rău.", tag_names: %w[cariera git testing] },
  { title: 'Svelte — de ce îl consider viitorul frontend-ului',
    body: "Zero virtual DOM, bundle minim, sintaxă curată — Svelte face toate compromisurile corecte.\n\nDacă aș începe un proiect nou azi, Svelte + SvelteKit ar fi alegerea mea implicită.", tag_names: %w[svelte javascript] },
  { title: 'Microservicii — când să le adopți și când să le eviți',
    body: "Nu orice aplicație are nevoie de microservicii. De fapt, majoritatea nu au nevoie.\n\nStartup-ul cu doi developeri nu are nevoie de Kubernetes. Monolitul bine structurat scalează mai bine decât crezi.", tag_names: %w[microservices devops] },
  { title: 'Mindfulness pentru programatori — practici care funcționează',
    body: "Nu e despre yoga și cristale — e despre a fi prezent la munca ta.\n\nPauzele conștiente la fiecare 90 minute, respirația profundă înainte de ședințe grele, journaling seara.", tag_names: %w[mindfulness productivitate] },
  { title: 'Cum să construiești un API REST solid în Rails',
    body: "Versioning, rate limiting, autentificare cu JWT și documentare cu OpenAPI sunt fundamentale.\n\nRăspunsurile consistente, codurile HTTP corecte și gestionarea erorilor elegantă îți vor face viața mai ușoară.", tag_names: %w[rails rest api] },
  { title: 'Go pentru developeri Ruby — primele impresii după 3 luni',
    body: "Compilarea rapidă, performanța și simplicitatea sunt punctele forte.\n\nLipsa generics (înainte de 1.18) și verbozitatea gestionării erorilor sunt cele mai mari diferențe față de Ruby.", tag_names: %w[go ruby] },
  { title: 'Cum investesc ca developer — portofoliul meu simplu',
    body: "Nu sunt expert financiar, dar iată ce funcționează pentru mine.\n\nIndex funds pe termen lung, fond de urgență de 6 luni, contribuție automată lunară — asta e tot sistemul.", tag_names: %w[finance] },
  { title: 'Vim vs VS Code — cel mai vechi război al editorelor',
    body: "Am folosit ambele serios. Răspunsul meu: depinde de ce faci și cum gândești.\n\nVim are o curbă abruptă dar recompensa în viteză este reală. VS Code câștigă la ecosistem și onboarding.", tag_names: %w[productivitate linux] },
  { title: 'Astro — framework-ul care a schimbat ce cred despre web',
    body: "Islands architecture și zero JavaScript by default sunt idei revoluționare.\n\nPentru site-uri predominant statice cu componente interactive punctuale, Astro este alegerea perfectă.", tag_names: %w[astro javascript] },
  { title: 'Cum am construit o aplicație SaaS în weekend',
    body: "Duminică seara am avut un MVP funcțional cu plăți integrate.\n\nStripe, Rails, Hotwire și un template de UI — acesta este stack-ul care permite livrare în ore, nu luni.", tag_names: %w[startup rails] },
  { title: 'NextJS 15 — ce s-a schimbat și ce trebuie să știi',
    body: "Server Components, Turbopack stabil și îmbunătățiri la caching schimbă modul de lucru.\n\nMigrarea de la Pages Router la App Router merită efortul pentru proiectele noi.", tag_names: %w[nextjs react javascript] },
  { title: 'Fotografierea cu telefonul — sfaturi de la un amator serios',
    body: "Cel mai bun aparat foto este cel pe care îl ai cu tine.\n\nCompoziția regulii treimilor, lumina naturală din lateral și editarea minimă în Lightroom Mobile fac diferența.", tag_names: %w[fotografie mobile] },
  { title: 'Securitatea parolelor — ce faci greșit probabil',
    body: "Password manager, autentificare în doi pași și parole unice pentru fiecare serviciu.\n\nNu, 'Parola1234!' nu este o parolă bună oricât de mult îți place. Un manager de parole rezolvă toate problemele.", tag_names: %w[securitate] },
  { title: 'Cum să înveți o tehnologie nouă eficient',
    body: "Build something. Nu citi 20 de tutoriale înainte să scrii o singură linie de cod.\n\nProiectul de jucărie, cât mai mic și mai concret, este cel mai rapid drum spre competență reală.", tag_names: %w[cariera productivitate] },
  { title: 'MongoDB vs PostgreSQL — alegerea în funcție de use case',
    body: "Schema flexibilă a MongoDB este atrăgătoare, dar ACID și relațiile din PostgreSQL câștigă pe termen lung.\n\nPentru date cu structură variabilă și volum masiv, MongoDB are sensul lui.", tag_names: %w[mongodb postgresql] }
]

posts = post_data.each_with_index.map do |attrs, i|
  post_tag_names = attrs.delete(:tag_names)
  post_tags = tags.select { |t| post_tag_names.include?(t.name) }
  post = Post.create!(attrs.merge(user: users[i % users.size]))
  post_tags.each { |tag| PostTag.create!(post:, tag:) }
  post
end

# ── Follows (50+) ─────────────────────────────────────────────────────────────
puts 'Creare urmăriri...'
follow_count = 0
users.each do |follower|
  targets = (users - [follower]).sample(rand(4..10))
  targets.each do |followed|
    Follow.find_or_create_by!(follower:, followed:)
    follow_count += 1
  end
end
puts "  #{follow_count} urmăriri create"

# ── Likes (50+ per post roughly; ensure 50+ total) ────────────────────────────
puts 'Creare aprecieri...'
posts.each do |post|
  users.sample(rand(5..15)).each do |user|
    Like.find_or_create_by!(post:, user:)
  end
end

# ── Comments (50+) ────────────────────────────────────────────────────────────
puts 'Creare comentarii...'
comment_texts = [
  'Foarte bine scris, mulțumesc că ai împărtășit!',
  'Am avut aceeași experiență — sunt total de acord.',
  'Poți detalia al treilea punct? Sunt curios.',
  'Asta este exact ce aveam nevoie să citesc azi.',
  'Postare grozavă! Ai scris ceva pe tema continuării?',
  'Salvat la favorite. Mă întorc la asta la următorul proiect.',
  'Nu sunt de acord cu punctul doi, dar restul este excelent.',
  'Am împărtășit asta cu întreaga echipă. Foarte util.',
  'Îmi place abordarea practică, mai degrabă decât teoria pură.',
  'Cât timp ți-a luat să îți dai seama de toate acestea?',
  'Exact ce căutam, mersi mult!',
  'O perspectivă interesantă, nu mă gândisem la asta.',
  'Aplicat imediat în proiectul meu. Funcționează perfect.',
  'Aș adăuga că experiența personală contează enorm.',
  'Super conținut, continuă tot așa!',
  'Am o întrebare legată de implementare — ai folosit vreo gem specifică?',
  'Asta rezolvă o problemă cu care mă luptam de săptămâni.',
  'Bookmarked. Revin cu feedback după ce implementez.',
  'Ar fi interesant un articol de follow-up cu exemple de cod.',
  'Perspectivă refreshing — diferit de ce citesc de obicei.'
]

posts.each do |post|
  users.sample(rand(3..8)).each do |user|
    Comment.create!(post:, user:, body: comment_texts.sample)
  end
end

# ── Conversations & Messages (50+ messages) ───────────────────────────────────
puts 'Creare conversații și mesaje...'
msg_pairs = [
  ['Salut! Am văzut postarea ta, super utilă!', 'Mulțumesc, mă bucur că ți-a plăcut!', 'Am și o întrebare, ai timp?',
   'Sigur, spune!'],
  ['Bună! Colaborăm pe acel proiect open source?', 'Da, cu plăcere. Ce rol vrei?', 'Mă ocup de frontend dacă e ok.',
   'Perfect, am nevoie de ajutor acolo.'],
  ['Ai recomandări de cursuri pentru securitate web?', 'PortSwigger Web Security Academy e gratuit și excelent.',
   'Mulțumesc, încerc!', 'Succes, e dens dar merită.'],
  ['Ce editor folosești zilnic?', 'Neovim de 2 ani, nu mă mai întorc.', 'Setup-ul pare complicat.',
   'Îți trimit config-ul meu dacă vrei.'],
  ['Ai văzut noul release Rails 8?', 'Da! Solid Queue e un game changer.', 'Nu mai ai nevoie de Redis deloc.',
   'Exact, simplifică infrastructura.'],
  ['Lucrezi remote full time?', 'Da, de 3 ani. Tu?', 'De un an, încă mă adaptez.',
   'Cel mai greu e granița muncă/viață.'],
  ['Cum îți organizezi task-urile?', 'Un simplu fișier todo.md cu git.', 'Interesant, nu m-am gândit la asta.',
   'E surprinzător de eficient.'],
  ['Ai putea să îmi revizuiești PR-ul?', 'Sigur, trimite link-ul.', 'Îți mulțumesc anticipat!',
   'Nicio problemă, e un PR curat.'],
  ['Ce crezi despre TypeScript?', 'Merită cu siguranță, mai ales pentru proiecte mari.', 'Curba de învățare e ok?',
   'Dacă știi JS bine, e surprinzător de rapid.'],
  ['Cum ai rezolvat problema de performanță?', 'Cu indecși parțiali în PostgreSQL.', 'Wow, chiar a mers?',
   'De la 2s la 80ms pe query-ul principal.'],
  ['Recomandă-mi o carte de arhitectură software.', 'Clean Architecture de Uncle Bob e clasicul.',
   'Am auzit controverse despre ea.', 'Ia ce e bun și adaptează la contextul tău.'],
  ['Ce stack folosești pentru proiectul nou?', 'Rails + Hotwire + PostgreSQL. Clasic și fiabil.',
   'Nu ai luat în calcul Node?', 'Pentru aplicații CRUD, Rails e imbatabil în productivitate.']
]

user_pairs = users.combination(2).to_a.sample(20)
user_pairs.each_with_index do |(sender, recipient), i|
  convo = Conversation.create!(sender:, recipient:)
  msgs = msg_pairs[i % msg_pairs.size]
  msgs.each_with_index do |body, idx|
    speaker = idx.even? ? sender : recipient
    Message.create!(conversation: convo, user: speaker, body:, read: idx < msgs.size - 1)
  end
end

# ── Notifications ─────────────────────────────────────────────────────────────
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
puts "  #{Like.count} aprecieri"
puts "  #{Comment.count} comentarii"
puts "  #{Follow.count} urmăriri"
puts "  #{UserInterest.count} interese utilizatori"
puts "  #{Conversation.count} conversații"
puts "  #{Message.count} mesaje"
puts "  #{Notification.count} notificări"
