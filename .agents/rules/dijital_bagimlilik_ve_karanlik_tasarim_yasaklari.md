# Dijital Bağımlılık ve Karanlık Tasarım (Dark Patterns) Yasakları

Bu kural belgesi, HexRush projesinde dijital kölelik ve bağımlılık yaratan 18 mekanik, görsel ve fonksiyonel manipülasyona karşı kesin yasakları ve etik alternatif standartlarını belirler.

---

## 1. Psikolojik ve Davranışsal Mekanik Yasakları

1. **Değişken Oranlı Pekiştirme (Skinner Box / Lootbox) Yasağı:**
   - Rastgele ödüllü ganimet kutusu, gacha, şans çarkı veya belirsiz oranlı ödül sistemleri KESİNLİKLE YASAKTIR.
   - *Etik Standart:* Tüm ödüller (`QuestModel.rewardAmount`, `baseProductionRate`, `getTamgaMultiplier`) %100 deterministiktir ve önceden şeffafça ilan edilir.

2. **Seri/Zincir Baskısı (Streak Pressure) Yasağı:**
   - Oyuncuyu "günü kaçırırsan serin yanar" korkusuyla oyuna bağlayan günlük zincir sayaçları ve sıfırlanma cezaları KESİNLİKLE YASAKTIR.
   - *Etik Standart:* İlerleme geriye gitmez. Yalnızca ileriye doğru artan ve kopuşlarda sıfırlanmayan kümülatif sayaçlar (`totalSessions`, `totalMigrations`) kullanılır.

3. **Batık Maliyet Sömürüsü (Sunk Cost Exploitation) Yasağı:**
   - Oyuncunun harcadığı emeği terk etmesini imkansız kılacak soft-lock veya sıfırlanamayan kilitler yasaktır.
   - *Etik Standart:* Büyük Göç (`resetGame`) mekanizması geçmiş emeği kalıcı Tamga çarpanına dönüştürür; `demolishBuilding` ile araziyi yeniden yapılandırma ve %50 kaynak iadesi güvence altına alınır.

4. **Suni Kıtlık ve FOMO (Kaçırma Korkusu) Yasağı:**
   - "Son 2 saat!", "Yalnızca bugün geçerli!" gibi suni aciliyet ve kaçırma anksiyetesi yaratan süreli etkinlik sayaçları KESİNLİKLE YASAKTIR.
   - *Etik Standart:* Mevsim döngüsü (`SeasonModel`) deterministiktir. Her mevsim 300 saniye sürer ve periyodik olarak geri gelir; hiçbir şey kalıcı olarak "kaçırılamaz".

5. **Manipülatif Zeigarnik Etkisi Yasağı:**
   - Oyuncuyu çevrimdışıyken rahatsız edecek süreli veya ucu açık ceza görevleri yasaktır.
   - *Etik Standart:* Görev ilerleme çubukları süre kısıtlamasızdır; oyuncunun kendi stratejik ritminde ve gönüllü olarak takip edilir.

---

## 2. Görsel ve İşitsel Tetikleyici Standartları

1. **Kırmızı Bildirim Rozetleri (Red Badges) Yasağı:**
   - İkonların veya butonların üzerinde stres ve mikro-anksiyete yaratan kırmızı aciliyet rozetleri/sayıları KESİNLİKLE YASAKTIR.
   - *Etik Standart:* Yalnızca oyuncunun açıkça izin verdiği durumlar için Arkeolojik Neo-Brutalist kehribar sarısı (`#D97706`) sakin gösterge noktaları kullanılır.

2. **Casino Estetiği ve Sentetik Game Juice Yasağı:**
   - Patlayan konfetiler, neon parıltılar, slot makinesi şıngırtıları veya ekranı sarsan yapay dopamin efektleri KESİNLİKLE YASAKTIR.
   - *Etik Standart:* Organik taş, ahşap ve demir sesleri (`TactileAudioService`), hafif dokunsal haptik titreşim (`HapticFeedback.lightImpact`) ve 3-4px Neo-Brutalist kenarlık vurguları kullanılır.

3. **Kıl Payı Kaçırma İllüzyonu (Near-Miss) Yasağı:**
   - Çarkların veya ödül akışlarının kasten "büyük ödüle çok yaklaştın" hissi verecek şekilde hileli kodlanması KESİNLİKLE YASAKTIR.
   - *Etik Standart:* Ekonomi ve maliyet hesaplamaları matematiksel olarak kesindir; aldatıcı hata veya teşvik mesajları verilemez.

---

## 3. Fonksiyonel Sistem ve Arayüz Standartları

1. **Sonsuz Kaydırma ve Durma Sinyalsizliği Yasağı:**
   - Kullanıcının zaman algısını yok eden sınırsız içerik akışları yasaktır. Haritada doğal sis sınırları (`TileState.fog`) ve stratejik odak noktaları korunur.

2. **Aşağı Çekip Yenileme (Pull-to-Refresh Slot Hareketi) Yasağı:**
   - Slot makinesi refleksini taklit eden çek-bırak döngüleri arayüzde yer alamaz.

3. **Otomatik Oynatma ve İradesiz Tüketim Yasağı:**
   - Oyuncunun onayı olmaksızın eylemleri otomatik başlatan mekanizmalar yasaktır. Her fetih ve inşa kararı oyuncunun iradesine bağlıdır.

4. **Bilişsel Ayrışma ve Karmaşık Sanal Paralar:**
   - Oyun içi kaynaklar (Gıda, Odun, Taş, Demir, Tamga) tamamen mekanik üretim çıktısıdır; oyuncunun algısını bulandıran yapay çoklu mikro-para dönüşüm hileleri yasaktır.

5. **Yapay Gecikme ve Ödeyerek Geçme (Pay-to-Skip) Yasağı:**
   - Sırf oyuncuya para veya reklam satmak için kasten konulmuş 24 saatlik suni bekleme duvarları KESİNLİKLE YASAKTIR.

---

## 4. Sosyal Onay ve Kabile Psikolojisi İlkeleri

1. **Sosyal Borçlandırma Yasağı:**
   - "Arkadaşın hediye yolladı, hemen geri dön" türü suçluluk ve sosyal borç mekanizmaları yasaktır. Oyun tek oyunculu ve huzurlu bir derin strateji alanıdır.

2. **Yapay Statü ve Toksik Liderlik Baskısı Yasağı:**
   - Oyuncuları birbirine kırdıran para tabanlı VIP statüleri yasaktır. Unvanlar (`claimTitle`) yalnızca oyuncunun kişisel stratejik başarısını belgeleyen arkeolojik kitabelerdir.

3. **Geciktirilmiş ve Toplu Dopamin Yağmuru Yasağı:**
   - Bildirimleri kasten havuzlayıp tek seferde yağdırarak dopamin şoku yaratma taktikleri yasaktır. Çevrimdışı kazançlar (`calculateOfflineGains`) şeffaf ve sakin bir rapor olarak sunulur.

---

## 5. Doğrulama Kapısı (Gate Check)

Geliştirilen her yeni özellik şu 3 etik filtreden geçmelidir:
1. *Bu özellik oyuncuyu kaygı veya FOMO ile mi oyuna çekiyor, yoksa derin strateji tatminiyle mi?*
2. *Oyuncu oynamayı bıraktığında bir şey kaybediyor mu? (Kaybetmemelidir!)*
3. *Görsel/işitsel geri bildirim organik ve Neo-Brutalist mi, yoksa casino tarzı sentetik mi?*
