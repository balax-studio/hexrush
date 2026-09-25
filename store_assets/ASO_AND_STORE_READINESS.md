# HexRush ASO Planı ve Mağaza Metinleri

Bu belge, HexRush'ın mevcut oyun döngüsüne göre Google Play ve Apple App Store mağaza sayfalarını düzenlemek için hazırlanmıştır. Ana hedef, arama sonucundan mağaza sayfasına geçişi (CTR) ve mağaza sayfasından yüklemeye dönüşümü artırmaktır. Anahtar kelime hacmi ve rekabeti için ülke bazlı mağaza verisi henüz yoktur; aşağıdaki kümeler başlangıç hipotezidir ve yayın sonrası ölçülmelidir.

## Ürün ve konumlandırma

Kod ve README'ye göre HexRush; sis altındaki altıgen arazileri açma, kaynak karolarını fethetme, üretim binaları kurma, pazarda takas yapma ve kalıcı ilerleme etrafında şekilleniyor. Görsel kimlik izometrik voksel, anlatı çerçevesi ise bozkır ve Kağanlık. Önerilen kısa vaat: **Sisleri aç, altıgenleri fethet, bozkırını büyüt.**

Hedef kitle; altıgen harita ve kaynak yönetimi seven strateji oyuncuları, idle üretim oyuncuları ve izometrik voksel diorama arayan tek oyunculu/casual kitleleridir.

Kodda Google Mobile Ads SDK ve ödüllü reklam akışları mevcut; bu nedenle “reklamsız” denmemeli. Çevrimdışı oynanış iddiası mağaza vaadi yapılmadan önce uçak modunda gerçek cihazda doğrulanmalı. Gizlilik dosyasındaki veri toplama beyanı da reklam SDK'sının gerçek yapılandırmasıyla eşleştirilmeli.

## Arama temaları

Aşağıdakiler hacim sıralaması değil, test edilecek başlangıç hipotezleridir. Ülke ve mağaza dili bazında veriler geldikçe güncelleyin.

| Dil | Öncelikli temalar | Uzun kuyruk / niyet |
|---|---|---|
| Türkçe | altıgen strateji, strateji oyunu, şehir kurma, kaynak yönetimi, boşta oyun | altıgen fetih, çevrimdışı strateji oyunu, izometrik oyun, voksel oyun |
| İngilizce | hex strategy, idle strategy, hexagon game, territory builder | voxel strategy, isometric builder, offline idle game, tile conquest |

“Offline/çevrimdışı” kelimesini yalnızca bağlantısız açılış ve oynanış test edilirse kullanın. “Şehir kurma” ve “empire builder” geniş ve rekabetçi terimlerdir; yanlış beklenti oluşturmadıklarını dönüşüm ve yorumlarla ölçün. Rakip oyun adlarını anahtar kelime olarak kullanmayın.

## Google Play taslağı

Google Play başlığı 30, kısa açıklaması 80 karakterle sınırlıdır. Taslaklar bu sınırların içindedir.

| Alan | Türkçe | Karakter |
|---|---|---:|
| Başlık | `HexRush: Altıgen Strateji` | 25 |
| Kısa açıklama | `Sisleri aç, altıgenleri fethet; kaynak topla ve bozkırını büyüt.` | 64 |

**Tam açıklama (TR)**

Altıgen toprakları keşfet, sisleri aç ve kendi bozkırını kur. HexRush; bölge fetihlerini, kaynak üretimini ve izometrik voksel dünyayı bir araya getiren tek oyunculu bir strateji oyunudur.

Haritada komşu arazileri açarak orman, çayır, dağ ve farklı kaynak alanlarına ulaş. Odun, taş, gıda ve diğer kaynakları üret; uygun karolara binalar kur ve üretimini geliştir.

- Altıgen haritada adım adım genişle
- Üretim binalarını yerleştir ve kaynak akışını planla
- Pazarda kaynaklarını takas et
- Kalıcı ilerleme ve unvanlar için gelişimini sürdür
- İzometrik voksel bozkırını yakınlaştırıp keşfet

Her yeni karo, yerleşimini ve kaynak planını büyütür. HexRush'ta küçük bir başlangıçtan geniş bir kağanlığa doğru ilerle.

**English title:** `HexRush: Hex Strategy` (21 characters)

**English short description:** `Claim hex tiles, gather resources, and grow a voxel steppe kingdom.` (66 characters)

**Full description (EN)**

Explore a hexagonal frontier, clear the fog, and shape your own steppe realm. HexRush combines tile conquest, resource production, and an isometric voxel world in a single-player strategy game.

Expand across neighboring tiles to reach forests, grasslands, mountains, and new resources. Gather what your settlement needs, place buildings on suitable terrain, and improve your production.

- Expand one hex at a time
- Place production buildings and plan your resource flow
- Trade resources at the market
- Progress through lasting upgrades and titles
- Explore an isometric voxel steppe

Every new tile gives your settlement room to grow. Start small and build a wider realm in HexRush.

**Título ES:** `HexRush: Estrategia Hex` (23 caracteres)

**Descripción breve ES:** `Conquista hexágonos, reúne recursos y expande tu reino voxel.` (61 caracteres)

**Descripción completa (ES)**

Explora una frontera de hexágonos, despeja la niebla y construye tu propio territorio de la estepa. HexRush combina conquista de tierras, producción de recursos y un mundo isométrico de vóxeles en un juego de estrategia para un jugador.

Expande tu territorio hacia bosques, praderas y montañas. Reúne recursos, coloca edificios de producción en terrenos adecuados y mejora tu economía.

- Amplía el mapa hexágono a hexágono
- Construye edificios y planifica la producción
- Intercambia recursos en el mercado
- Avanza con mejoras permanentes y títulos
- Explora una estepa isométrica de vóxeles

Cada nueva parcela da espacio para crecer. Empieza con un pequeño asentamiento y amplía tu reino en HexRush.

**Titel DE:** `HexRush: Hex-Strategie` (22 Zeichen)

**Kurzbeschreibung DE:** `Erobere Hexfelder, sammle Rohstoffe und baue dein Voxelreich aus.` (64 Zeichen)

**Vollständige Beschreibung (DE)**

Erkunde eine sechseckige Grenze, lüfte den Nebel und gestalte deine eigene Steppe. HexRush verbindet Gebietseroberung, Rohstoffproduktion und eine isometrische Voxelwelt in einem Einzelspieler-Strategiespiel.

Erweitere dein Gebiet in Wälder, Grasland und Gebirge. Sammle Rohstoffe, errichte Produktionsgebäude auf geeignetem Gelände und entwickle deine Wirtschaft weiter.

- Erweitere die Karte Hexfeld für Hexfeld
- Baue Produktionsgebäude und plane deine Rohstoffflüsse
- Tausche Rohstoffe auf dem Markt
- Entwickle dich mit dauerhaften Verbesserungen und Titeln weiter
- Erkunde eine isometrische Voxelsteppe

Jedes neue Feld bietet Platz zum Wachsen. Beginne mit einer kleinen Siedlung und erweitere dein Reich in HexRush.

## Apple App Store taslağı

Apple'da ad ve alt başlık 30 karakter; anahtar kelime alanı 100 karakterdir. Açıklama metnini arama sıralamasını yükseltecek bir alan gibi değerlendirmeyin; kullanıcıya ürünün ne sunduğunu net biçimde anlatın.

| Alan | Türkçe | Karakter |
|---|---|---:|
| Ad | `HexRush: Altıgen Strateji` | 25 |
| Alt başlık | `Sisleri aç, bozkırını büyüt` | 27 |
| Promosyon metni | `Yeni araziler aç, kaynak üretimini planla ve kağanlığını altıgen altıgen genişlet.` | 81 |

**TR keywords (91 karakter):**

`altıgen,fetih,boşta,kaynak,izometrik,voksel,bozkır,kağanlık,üretim,ticaret,harita`

**EN name:** `HexRush: Hex Strategy` (21 characters)

**EN subtitle:** `Claim tiles, build your realm` (29 characters)

**EN promotional text:** `Clear the fog, claim new hexes, and plan a growing voxel settlement across the steppe.`

**EN keywords (95 characters):**

`hex,idle,voxel,isometric,tiles,conquest,steppe,kingdom,resource,builder,trading,frontier`

**Açıklama (TR)**

Sislerle kaplı altıgen haritayı aç, yeni arazileri fethet ve bozkırındaki üretimi planla. HexRush; bölge genişletme, kaynak yönetimi ve izometrik voksel görünümünü tek oyunculu bir strateji oyununda buluşturur.

Komşu karoları açarak ormanlara, çayırlara ve dağlara ulaş. Kaynak topla, araziye uygun üretim binaları kur ve yerleşimini geliştirmek için pazarda takas yap.

- Altıgen arazilerde adım adım genişle
- Üretim binalarını kur ve geliştir
- Kaynaklarını yönet, pazarda takas et
- Kalıcı gelişim ve unvanlar kazan
- Voksel bozkırını izometrik açıdan keşfet

Küçük bir başlangıçtan büyüyen bir kağanlığa ilerle. Her karo, kurduğun düzeni genişletir.

**Description (EN)**

Clear the fog across a hexagonal map, claim new land, and plan a growing steppe settlement. HexRush brings territory expansion, resource management, and an isometric voxel world together in a single-player strategy game.

Reveal neighboring tiles to reach forests, grasslands, and mountains. Gather resources, place production buildings on suitable terrain, and trade at the market as your settlement grows.

- Expand across a hex map one tile at a time
- Build and upgrade production buildings
- Manage resources and trade at the market
- Earn lasting progression and titles
- Explore an isometric voxel steppe

Begin with a small settlement and shape a wider realm, one hex at a time.

**Nombre ES:** `HexRush: Estrategia Hex` (23 caracteres)

**Subtítulo ES:** `Conquista tierras hexagonales` (29 caracteres)

**Texto promocional ES:** `Despeja la niebla, conquista nuevas tierras y planifica la producción de tu reino voxel.`

**Palabras clave ES (92 caracteres):**

`hexágono,conquista,recursos,estepa,vóxel,isométrico,territorio,producción,mercado,estrategia`

**Descripción (ES)**

Abre caminos entre hexágonos cubiertos por la niebla y desarrolla tu territorio en la estepa. HexRush combina expansión, gestión de recursos y una estética isométrica de vóxeles en una experiencia de estrategia para un jugador.

Explora bosques, praderas y montañas al revelar parcelas vecinas. Reúne recursos, construye edificios de producción en el terreno adecuado e intercambia bienes en el mercado.

- Expande tu territorio parcela a parcela
- Construye y mejora edificios de producción
- Gestiona e intercambia recursos
- Desbloquea progreso permanente y títulos
- Explora una estepa isométrica de vóxeles

Empieza con un pequeño asentamiento y dale forma a un reino cada vez más amplio.

**Name DE:** `HexRush: Hex-Strategie` (22 Zeichen)

**Untertitel DE:** `Erobere Felder, baue dein Reich` (30 Zeichen)

**Werbetext DE:** `Lüfte den Nebel, erobere neue Hexfelder und plane die Produktion deiner Voxelsteppe.`

**Keywords DE (97 Zeichen):**

`hexagon,strategie,eroberung,rohstoffe,steppe,voksel,isometrisch,gebiet,produktion,handel,aufbau`

**Beschreibung (DE)**

Lüfte den Nebel über einer sechseckigen Karte und baue dein Gebiet in der Steppe aus. HexRush verbindet Gebietserweiterung, Rohstoffverwaltung und eine isometrische Voxelwelt in einem Einzelspieler-Strategiespiel.

Decke benachbarte Felder auf und erreiche Wälder, Grasland und Gebirge. Sammle Rohstoffe, errichte passende Produktionsgebäude und tausche Waren auf dem Markt.

- Erweitere dein Gebiet Feld für Feld
- Errichte und verbessere Produktionsgebäude
- Verwalte und tausche Rohstoffe
- Schalte dauerhafte Fortschritte und Titel frei
- Erkunde eine isometrische Voxelsteppe

Beginne mit einer kleinen Siedlung und forme Schritt für Schritt ein größeres Reich.

## Mağaza görseli ve tıklanabilirlik planı

İlk ekran görüntüsünde en güçlü gerçek oyun sahnesini ve tek, okunur mesajı kullanın. Telefon çerçevesi veya pazarlama yazısı oyun alanını kapatmamalı.

| Sıra | Ekrandaki mesaj | Gösterilecek gerçek sahne |
|---:|---|---|
| 1 | **SİSLERİ AÇ. TOPRAĞINI BÜYÜT.** | Kağan otağı, açılan sis sınırı ve farklı altıgen araziler |
| 2 | **YENİ ALTIGENLER FETHET** | Yeni komşu karonun açılması ve kaynak geri bildirimi |
| 3 | **ÜRETİMİNİ PLANLA** | Farklı arazi türlerine kurulmuş gerçek üretim binaları |
| 4 | **KAYNAKLARINI TAKAS ET** | Pazar arayüzü ve takas edilebilir kaynaklar |
| 5 | **KAĞANLIĞINI GELİŞTİR** | Otağ, kalıcı ilerleme veya unvan ekranı; sürümde gerçekten varsa |

İlk görseli iki vaatle sınayın: A) altıgen fetih, B) izometrik voksel dünya. Simge küçük boyutta ayırt edilen tek bir güçlü şekle odaklansın; küçük yazı kullanmayın. Google Play mağaza deneylerinde ve App Store Product Page Optimization'da ikon/ilk ekran görüntüsü varyantlarını test edin. Her testte tek ana değişkeni değiştirin.

Video açılışı ilk saniyede sisin açılması ve yeni karonun görünmesini göstermeli; sonra bina kurma, üretim ve pazar akışını sergilemeli. Gerçek oynanış kullanın.

## Ölçüm ve iterasyon

1. Türkçe, İngilizce, İspanyolca ve Almanca listelemeleri ayrı yerelleştirin; metinleri hedef dilde doğal arama ifadelerine göre düzenleyin.
2. Bağlantısız açılış, çevrimdışı üretim, reklam sıklığı ve içerik kapsamı gibi her iddiayı cihazda doğrulayın.
3. İlk beş ekran görüntüsünü gerçek cihazda okunabilirlik ve metin kırpılması açısından kontrol edin.
4. Yayından sonra ülke, dil ve mağaza arama terimine göre gösterim, ürün sayfası ziyareti ve yükleme dönüşümünü takip edin. Düşük gösterim keşif/sorgu eşleşmesi; yüksek ziyaret ama düşük yükleme ise görseller veya sayfa vaadi sorunu olabilir.
5. Başlık ve anahtar kelime değişikliklerini küçük partiler halinde yapın; aynı anda çok alan değiştirirseniz etkiyi ayıramazsınız.
6. Yeterli trafik oluşunca Google Play Store Listing Experiments ve App Store Product Page Optimization testlerini çalıştırın; istatistiksel güven oluşmadan kazanan ilan etmeyin.

## Doğruluk ve mağaza beyanı denetimi

- **Ödüllü reklam:** Google Mobile Ads SDK ve ödüllü reklam servisleri mevcut. “Reklamsız” veya “reklam içermez” yazmayın.
- **Çevrimdışı:** Offline kazanç akışı var; bu, oyunun tamamen çevrimdışı oynandığını tek başına kanıtlamaz. Uçak modunda açılış ve temel döngüyü doğrulamadan bu vaadi eklemeyin.
- **Görsel iddialar:** “60 FPS”, “sıfır pil tüketimi”, “en iyi/benzersiz” gibi kanıt gerektiren mutlak iddiaları kullanmayın.
- **Veri güvenliği:** Gizlilik politikası ve Data Safety/App Privacy beyanlarını reklam SDK'sı dahil tüm SDK'ların güncel yapılandırması ve gerçek veri akışıyla doğrulayın.
- **Sınıflandırma:** Yaş derecelendirmesini “her yaş” varsayımıyla belirlemeyin; reklam, bildirim ve içerik özelliklerine göre mağaza anketini doldurun.

## Kapsam ve referanslar

Bu çalışma depodaki README, oyun özellik izleri, reklam entegrasyonu ve önceki `store_assets` taslağına dayanır. Mağaza hesabı analitiği, ülke bazlı sorgu hacmi, rakip sıralaması ve canlı dönüşüm verisi olmadan kesin hacim veya CTR artışı vaat edilemez.

- Apple metadata ve anahtar kelime alanı: [Creating Your Product Page](https://developer.apple.com/app-store/product-page/)
- Apple ürün sayfası varyant testi: [Product Page Optimization](https://developer.apple.com/help/app-store-connect/create-product-page-optimization-tests/overview)
- Google Play ad ve açıklama karakter sınırları: [Set up your app](https://support.google.com/googleplay/android-developer/answer/9859152)
- Google Play mağaza listeleme deneyleri: [Run A/B tests on your store listing](https://support.google.com/googleplay/android-developer/answer/12053285)
