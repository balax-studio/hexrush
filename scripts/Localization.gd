class_name Localization
extends RefCounted

## 4 Küresel Dil Desteği (TR, EN, ES, DE) Sözlük ve Çeviri Motoru.

const SUPPORTED_LANGUAGES = ["tr", "en", "es", "de"]

static var current_lang: String = "tr"

const STRINGS = {
	"tr": {
		# Üst Bar & Envanter
		"food": "Gıda",
		"wood": "Odun",
		"flour": "Un",
		"plank": "Kereste",
		"land": "Toprak",
		"crowns": "Kraliyet Tacı",
		
		# Biyomlar
		"biome_meadow": "Çayır",
		"biome_forest": "Orman",
		"biome_mountain": "Dağ",
		"biome_sea": "Deniz",
		
		# İpuçları
		"hint_castle_1": "Şatoyu Seviye 2'ye yükselterek Odunculuğun kilidini aç! (Gerekli: 6 🥡)",
		"hint_castle_2": "Şatoyu Seviye 3'e yükselterek Değirmen & Kereste Fabrikasını aç! (18 🥡 + 10 🪵)",
		"hint_expand": "Yeni altıgen fethet: Üstel maliyet | Fabrikalarla katma değerli ürün üret!",
		"hint_no_food": "Gıda tükendi! Mısır tarlalarını hasat et veya işçi kulübesi kur.",
		
		# İnşaat Menüsü
		"build_title_meadow": "🌾 Çayır İnşaat Menüsü",
		"build_title_forest": "🌲 Orman İnşaat Menüsü",
		"build_title_sea": "🌊 Deniz İnşaat Menüsü",
		"free": "ÜCRETSİZ",
		"build_btn": "İnşa Et",
		"corn_name": "Mısır Tarlası",
		"corn_desc": "Temel gıda üretimi (Geliştirildikçe hızlanır).",
		"windmill_name": "Değirmen (Tier 2)",
		"windmill_desc": "Gıdayı Un'a çevirir (Komşu tarladan %100 hız).",
		"lumberjack_name": "Oduncu Kulübesi",
		"lumberjack_desc": "Temel odun üretimi (Geliştirildikçe hızlanır).",
		"sawmill_name": "Kereste Fabrikası (Tier 2)",
		"sawmill_desc": "Odunu Kalas'a çevirir (Komşu oduncudan %100 hız).",
		"worker_name": "İşçi Kulübesi",
		"worker_desc": "Komşulardan otomatik hammadde taşır.",
		"bridge_name": "Ahşap Köprü",
		"bridge_desc": "Açık deniz geçişini sağlar ve komşu karalara ulaşım açar.",
		"locked_castle_3": "🔒 ŞATO SEVİYE 3",
		
		# Üretim Menüleri
		"level": "Seviye",
		"per_sec": "/sn",
		"collect": "Topla",
		"upgrade": "Geliştir",
		"full": "DOLU",
		"supply_neighbor": "🟢 Komşu Tarladan (%100 Hız)",
		"supply_neighbor_wood": "🟢 Komşu Oduncudan (%100 Hız)",
		"supply_global": "🟡 Ana Ambardan (%50 Hız)",
		"capacity": "Kapasite",
		"connected_facilities": "Bağlı Tesisler",
		"total_transferred": "Taşındı",
		"auto_carry": "Otomatik Taşıma",
		
		# Şato Menüsü
		"castle_title": "🏰 Krallık Şatosu",
		"global_bonus": "Küresel Üretim & Taşıma Bonusu",
		"next_unlock": "Sonraki Kilit",
		"max_level": "MAKSİMUM SEVİYE",
		"max_power_active": "👑 Krallık Maksimum Efsanevi Gücüne Ulaştı!",
		
		# Toast Bildirimleri
		"toast_free_tile": "✨ İlk arsanı ÜCRETSİZ fethettin! (+1 Toprak)",
		"toast_buy_tile": "🏰 %d 🥡 Gıda karşılığında yeni arsa fethedildi! (+1 Toprak)",
		"toast_mountain_conquered": "🏔️ Dağ Fethedildi! Arkasındaki 1 birim sınırındaki tüm araziler açığa çıkarıldı.",
		"toast_mountain_info": "🏔️ Fethedilmiş Dağ Zirvesi. Çevredeki tüm topraklar görüş alanında.",
		"toast_no_food_tile": "⚠️ Yetersiz Gıda! Yeni altıgen açmak için %d 🥡 Gıda gerekli.",
		"toast_adjacent_required": "⚠️ Yalnızca sınır komşunuz olan arazileri fethedebilirsiniz!",
		"toast_need_bridge": "⚠️ Açık Deniz Engeli! Denizden geçiş için önce bu deniz karosuna köprü inşa etmelisin.",
		"toast_bridge_need_land": "⚠️ Köprü inşa etmek için en az 1 komşu kara parçası gereklidir.",
		"toast_forest_locked": "🔒 Orman Kilitli! Odunculuk için Şatoyu Seviye 2'ye (Derebeylik) yükselt.",
		"toast_no_build_biome": "ℹ️ Bu biyomda henüz inşa edilebilir yapı bulunmuyor.",
		"toast_built_corn": "🌽 Mısır Tarlası inşa edildi!",
		"toast_built_windmill": "🌾 Değirmen kuruldu! Un üretimi başladı.",
		"toast_built_lumberjack": "🪓 Oduncu Kulübesi kuruldu! Odun üretimi başladı.",
		"toast_built_sawmill": "🪵 Kereste Fabrikası kuruldu! Kalas üretimi başladı.",
		"toast_built_worker": "🛖 İşçi Kulübesi kuruldu! Otomatik taşıma başladı.",
		"toast_built_bridge": "🌉 Köprü inşa edildi! Deniz ötesi kara fethine açıldı.",
		"toast_collected_food": "🥡 +%.2f Gıda ambarına eklendi!",
		"toast_collected_wood": "🪵 +%.2f Odun kereste ambarına eklendi!",
		"toast_collected_flour": "🌾 +%.2f Un ambarına eklendi!",
		"toast_collected_plank": "🪵 +%.2f Kereste/Kalas ambarına eklendi!",
		"toast_upgraded": "✨ %s Seviye %d'e yükseltildi!",
		"toast_castle_upgraded": "👑 Krallık %s kademesine yükseltildi! (+%%25 Küresel Hız)",
		"toast_insufficient_res": "⚠️ Yetersiz Kaynak!",
		"toast_prestige_success": "👑 Krallık Yeniden Doğdu! +%d Taç ve kalıcı +%%%d Üretim Bonusu kazanıldı!",
		"toast_saved": "💾 Oyun kaydedildi.",
		
		# Çevrimdışı Gelir Modalı
		"offline_welcome": "👑 Krallığına Hoş Geldin!",
		"offline_desc": "Sen yokken krallığın çalışmaya devam etti (%s boyunca):",
		"offline_claim": "Tümünü Al",
		"offline_claim_3x": "📺 3x Al (Bonus)",
		
		# Ayarlar & İstatistik & Prestij
		"settings_title": "⚙️ Ayarlar & Krallık Yönetimi",
		"tab_general": "🌐 Genel & Ses",
		"tab_stats": "📊 İstatistikler",
		"tab_prestige": "👑 Prestij (Rebirth)",
		"language_select": "Dil Seçimi / Language:",
		"sfx_volume": "Ses Efektleri (SFX):",
		"mute": "Sessiz",
		
		# İstatistikler
		"stat_playtime": "Toplam Oynama Süresi",
		"stat_conquered": "Fethedilen Toprak",
		"stat_total_food": "Toplam Üretilen Gıda",
		"stat_total_wood": "Toplam Üretilen Odun",
		"stat_total_flour": "Toplam Üretilen Un",
		"stat_total_plank": "Toplam Üretilen Kereste",
		"stat_rebirths": "Yapılan Prestij (Rebirth) Sayısı",
		
		# Prestij Ekranı
		"prestige_title": "👑 Krallığı Yeniden Doğur (Rebirth)",
		"prestige_desc": "Krallığını sıfırlayarak kalıcı Kraliyet Taçları kazan. Her taç üretimi ve taşımayı kalıcı olarak %5 hızlandırır!",
		"current_crowns": "Mevcut Taçlar",
		"current_bonus": "Mevcut Kalıcı Bonus",
		"earned_crowns": "Sıfırlanınca Kazanılacak Taç",
		"rebirth_btn": "👑 Krallığı Sıfırla & Yeniden Doğur",
		"rebirth_need_more": "⚠️ Taç kazanmak için daha fazla üretim yapmalısın!",
		"prestige_confirm_title": "⚠️ Krallığı Sıfırlamak İstediğinden Emin Misin?",
		"prestige_confirm_desc": "Harita, binalar ve mevcut kaynakların sıfırlanacak. Karşılığında +%d Kraliyet Tacı kazanacak ve kalıcı üretim çarpanını +%%%d yapacaksın!",
		"confirm": "Evet, Yeniden Doğur!",
		"cancel": "İptal"
	},
	
	"en": {
		# TopBar & Inventory
		"food": "Food",
		"wood": "Wood",
		"flour": "Flour",
		"plank": "Plank",
		"land": "Land",
		"crowns": "Royal Crowns",
		
		# Biomes
		"biome_meadow": "Meadow",
		"biome_forest": "Forest",
		"biome_mountain": "Mountain",
		"biome_sea": "Sea",
		
		# Hints
		"hint_castle_1": "Upgrade Castle to Level 2 to unlock Lumberjack! (Req: 6 🥡)",
		"hint_castle_2": "Upgrade Castle to Level 3 to unlock Windmill & Sawmill! (18 🥡 + 10 🪵)",
		"hint_expand": "Conquer new land: Scaled Cost | Process raw resources into refined goods!",
		"hint_no_food": "Out of food! Harvest corn fields or build a worker hut.",
		
		# Build Menu
		"build_title_meadow": "🌾 Meadow Build Menu",
		"build_title_forest": "🌲 Forest Build Menu",
		"build_title_sea": "🌊 Sea Build Menu",
		"free": "FREE",
		"build_btn": "Build",
		"corn_name": "Corn Field",
		"corn_desc": "Basic food production.",
		"windmill_name": "Windmill (Tier 2)",
		"windmill_desc": "Converts Food into Flour.",
		"lumberjack_name": "Lumberjack Hut",
		"lumberjack_desc": "Basic wood production.",
		"sawmill_name": "Sawmill (Tier 2)",
		"sawmill_desc": "Converts Wood into Planks.",
		"worker_name": "Worker Hut",
		"worker_desc": "Transfers resources from neighbors.",
		"bridge_name": "Wooden Bridge",
		"bridge_desc": "Crosses open sea and unlocks neighbor land.",
		"locked_castle_3": "🔒 CASTLE LV. 3",
		
		# Production Menus
		"level": "Level",
		"per_sec": "/sec",
		"collect": "Collect",
		"upgrade": "Upgrade",
		"full": "FULL",
		"supply_neighbor": "🟢 Neighbor Farm (100% Speed)",
		"supply_neighbor_wood": "🟢 Neighbor Lumberjack (100% Speed)",
		"supply_global": "🟡 Global Storage (50% Speed)",
		"capacity": "Capacity",
		"connected_facilities": "Connected Facilities",
		"total_transferred": "Transferred",
		"auto_carry": "Auto Transfer",
		
		# Castle Menu
		"castle_title": "🏰 Kingdom Castle",
		"global_bonus": "Global Production & Transport Bonus",
		"next_unlock": "Next Unlock",
		"max_level": "MAX LEVEL",
		"max_power_active": "👑 Kingdom Reached Legendary Maximum Power!",
		
		# Toasts
		"toast_free_tile": "✨ First land conquered for FREE! (+1 Land)",
		"toast_buy_tile": "🏰 Land conquered for %d 🥡 Food! (+1 Land)",
		"toast_mountain_conquered": "🏔️ Mountain Conquered! All lands within 1-unit boundary revealed.",
		"toast_mountain_info": "🏔️ Conquered Mountain Peak. All surrounding lands in line of sight.",
		"toast_no_food_tile": "⚠️ Not enough food! %d 🥡 Food required to unlock hex.",
		"toast_adjacent_required": "⚠️ You can only conquer lands adjacent to your owned territory!",
		"toast_need_bridge": "⚠️ Open Sea Barrier! Build a bridge across this sea tile first.",
		"toast_bridge_need_land": "⚠️ Bridge requires connection to at least 1 adjacent land tile.",
		"toast_forest_locked": "🔒 Forest Locked! Upgrade Castle to Level 2 (Fiefdom) first.",
		"toast_no_build_biome": "ℹ️ No constructible buildings for this biome yet.",
		"toast_built_corn": "🌽 Corn Field constructed!",
		"toast_built_windmill": "🌾 Windmill built! Flour production started.",
		"toast_built_lumberjack": "🪓 Lumberjack Hut built! Wood production started.",
		"toast_built_sawmill": "🪵 Sawmill built! Plank production started.",
		"toast_built_worker": "🛖 Worker Hut built! Auto-transport active.",
		"toast_built_bridge": "🌉 Bridge built! Oversea lands unlocked for conquest.",
		"toast_collected_food": "🥡 +%.2f Food added to storage!",
		"toast_collected_wood": "🪵 +%.2f Wood added to storage!",
		"toast_collected_flour": "🌾 +%.2f Flour added to storage!",
		"toast_collected_plank": "🪵 +%.2f Planks added to storage!",
		"toast_upgraded": "✨ %s upgraded to Level %d!",
		"toast_castle_upgraded": "👑 Kingdom promoted to %s! (+25% Global Speed)",
		"toast_insufficient_res": "⚠️ Insufficient Resources!",
		"toast_prestige_success": "👑 Kingdom Reborn! +%d Crowns and permanent +%d%% bonus earned!",
		"toast_saved": "💾 Game saved.",
		
		# Offline Gains Modal
		"offline_welcome": "👑 Welcome Back, Sovereign!",
		"offline_desc": "Your kingdom worked diligently while you were away (%s):",
		"offline_claim": "Claim All",
		"offline_claim_3x": "📺 Claim 3x (Bonus)",
		
		# Settings & Stats & Prestige
		"settings_title": "⚙️ Settings & Kingdom Management",
		"tab_general": "🌐 General & Audio",
		"tab_stats": "📊 Statistics",
		"tab_prestige": "👑 Prestige (Rebirth)",
		"language_select": "Language Selection:",
		"sfx_volume": "Sound Effects (SFX):",
		"mute": "Mute",
		
		# Stats
		"stat_playtime": "Total Playtime",
		"stat_conquered": "Total Conquered Lands",
		"stat_total_food": "Total Food Produced",
		"stat_total_wood": "Total Wood Produced",
		"stat_total_flour": "Total Flour Produced",
		"stat_total_plank": "Total Planks Produced",
		"stat_rebirths": "Total Prestige (Rebirths) Done",
		
		# Prestige Screen
		"prestige_title": "👑 Rebirth Kingdom (Prestige)",
		"prestige_desc": "Reset your kingdom to gain Royal Crowns. Each crown permanently boosts all production and transfer speeds by +5%!",
		"current_crowns": "Current Crowns",
		"current_bonus": "Current Permanent Bonus",
		"earned_crowns": "Crowns on Reset",
		"rebirth_btn": "👑 Reset & Rebirth Kingdom",
		"rebirth_need_more": "⚠️ Produce more resources to earn crowns!",
		"prestige_confirm_title": "⚠️ Are You Sure You Want to Rebirth?",
		"prestige_confirm_desc": "Map, buildings and resources will reset. In return, you will gain +%d Royal Crowns and increase permanent bonus to +%d%%!",
		"confirm": "Yes, Rebirth!",
		"cancel": "Cancel"
	},
	
	"es": {
		# TopBar & Inventory
		"food": "Comida",
		"wood": "Madera",
		"flour": "Harina",
		"plank": "Tablón",
		"land": "Tierra",
		"crowns": "Coronas Reales",
		
		# Biomes
		"biome_meadow": "Pradera",
		"biome_forest": "Bosque",
		"biome_mountain": "Montaña",
		"biome_sea": "Mar",
		
		# Hints
		"hint_castle_1": "¡Mejora el Castillo a Nivel 2 para desbloquear Leñadores! (Req: 6 🥡)",
		"hint_castle_2": "¡Mejora el Castillo a Nivel 3 para desbloquear Molino y Aserradero! (18 🥡 + 10 🪵)",
		"hint_expand": "Conquista tierra: Costo Escalonado | ¡Procesa materias primas!",
		"hint_no_food": "¡Sin comida! Cosecha campos de maíz o construye cabañas de obreros.",
		
		# Build Menu
		"build_title_meadow": "🌾 Menú de Pradera",
		"build_title_forest": "🌲 Menú de Bosque",
		"build_title_sea": "🌊 Menú de Mar",
		"free": "GRATIS",
		"build_btn": "Construir",
		"corn_name": "Campo de Maíz",
		"corn_desc": "Producción básica de comida.",
		"windmill_name": "Molino (Nivel 2)",
		"windmill_desc": "Convierte comida en harina.",
		"lumberjack_name": "Cabaña de Leñador",
		"lumberjack_desc": "Producción básica de madera.",
		"sawmill_name": "Aserradero (Nivel 2)",
		"sawmill_desc": "Convierte madera en tablones.",
		"worker_name": "Cabaña de Obreros",
		"worker_desc": "Transporte automático de vecinos.",
		"bridge_name": "Puente de Madera",
		"bridge_desc": "Permite cruzar el mar y desbloquea tierras.",
		"locked_castle_3": "🔒 CASTILLO NV. 3",
		
		# Production Menus
		"level": "Nivel",
		"per_sec": "/seg",
		"collect": "Recolectar",
		"upgrade": "Mejorar",
		"full": "LLENO",
		"supply_neighbor": "🟢 Granja Vecina (100% Velocidad)",
		"supply_neighbor_wood": "🟢 Leñador Vecino (100% Velocidad)",
		"supply_global": "🟡 Almacén Global (50% Velocidad)",
		"capacity": "Capacidad",
		"connected_facilities": "Instalaciones Conectadas",
		"total_transferred": "Transportado",
		"auto_carry": "Transporte Automático",
		
		# Castle Menu
		"castle_title": "🏰 Castillo del Reino",
		"global_bonus": "Bono Global de Producción",
		"next_unlock": "Próximo Desbloqueo",
		"max_level": "NIVEL MÁXIMO",
		"max_power_active": "👑 ¡Poder Legendario Máximo Alcanzado!",
		
		# Toasts
		"toast_free_tile": "✨ ¡Primera tierra conquistada GRATIS! (+1 Tierra)",
		"toast_buy_tile": "🏰 ¡Tierra conquistada por %d 🥡 Comida! (+1 Tierra)",
		"toast_mountain_conquered": "🏔️ ¡Montaña Conquistada! Todas las tierras dentro del límite de 1 unidad reveladas.",
		"toast_mountain_info": "🏔️ Pico de Montaña Conquistado. Todas las tierras circundantes a la vista.",
		"toast_no_food_tile": "⚠️ ¡Comida insuficiente! Se requiere %d 🥡 Comida.",
		"toast_adjacent_required": "⚠️ ¡Solo puedes conquistar tierras adyacentes a tu territorio!",
		"toast_need_bridge": "⚠️ ¡Barrera de Mar! Construye un puente en este mar primero.",
		"toast_bridge_need_land": "⚠️ El puente requiere conexión con al menos 1 tierra adyacente.",
		"toast_forest_locked": "🔒 ¡Bosque bloqueado! Mejora el castillo a Nivel 2 primero.",
		"toast_no_build_biome": "ℹ️ No hay construcciones para este bioma todavía.",
		"toast_built_corn": "🌽 ¡Campo de Maíz construido!",
		"toast_built_windmill": "🌾 ¡Molino construido! Producción de harina iniciada.",
		"toast_built_lumberjack": "🪓 ¡Cabaña de Leñador construida!",
		"toast_built_sawmill": "🪵 ¡Aserradero construido! Producción de tablones iniciada.",
		"toast_built_worker": "🛖 ¡Cabaña de Obreros construida!",
		"toast_built_bridge": "🌉 ¡Puente construido! Tierras de ultramar desbloqueadas.",
		"toast_collected_food": "🥡 ¡+%.2f Comida añadida!",
		"toast_collected_wood": "🪵 ¡+%.2f Madera añadida!",
		"toast_collected_flour": "🌾 ¡+%.2f Harina añadida!",
		"toast_collected_plank": "🪵 ¡+%.2f Tablones añadidos!",
		"toast_upgraded": "✨ ¡%s mejorado a Nivel %d!",
		"toast_castle_upgraded": "👑 ¡Reino ascendido a %s! (+25% Velocidad Global)",
		"toast_insufficient_res": "⚠️ ¡Recursos Insuficientes!",
		"toast_prestige_success": "👑 ¡Reino Renacido! +%d Coronas y +%d%% bono permanente ganados.",
		"toast_saved": "💾 Partida guardada.",
		
		# Offline Gains Modal
		"offline_welcome": "👑 ¡Bienvenido de vuelta, Soberano!",
		"offline_desc": "Tu reino siguió trabajando mientras estabas fuera (%s):",
		"offline_claim": "Reclamar Todo",
		"offline_claim_3x": "📺 Reclamar 3x (Bono)",
		
		# Settings & Stats & Prestige
		"settings_title": "⚙️ Ajustes y Gestión del Reino",
		"tab_general": "🌐 General y Sonido",
		"tab_stats": "📊 Estadísticas",
		"tab_prestige": "👑 Prestigio (Renacer)",
		"language_select": "Seleccionar Idioma:",
		"sfx_volume": "Efectos de Sonido (SFX):",
		"mute": "Silenciar",
		
		# Stats
		"stat_playtime": "Tiempo Total de Juego",
		"stat_conquered": "Total de Tierras Conquistadas",
		"stat_total_food": "Total de Comida Producida",
		"stat_total_wood": "Total de Madera Producida",
		"stat_total_flour": "Total de Harina Producida",
		"stat_total_plank": "Total de Tablones Producidos",
		"stat_rebirths": "Total de Renacimientos Realizados",
		
		# Prestige Screen
		"prestige_title": "👑 Renacer el Reino (Prestigio)",
		"prestige_desc": "Reinicia tu reino para ganar Coronas Reales. ¡Cada corona aumenta la velocidad de producción permanentemente en +5%!",
		"current_crowns": "Coronas Actuales",
		"current_bonus": "Bono Permanente Actual",
		"earned_crowns": "Coronas al Reiniciar",
		"rebirth_btn": "👑 Reiniciar y Renacer el Reino",
		"rebirth_need_more": "⚠️ ¡Produce más recursos para ganar coronas!",
		"prestige_confirm_title": "⚠️ ¿Seguro que quieres Renacer?",
		"prestige_confirm_desc": "El mapa, edificios y recursos se reiniciarán. ¡A cambio ganarás +%d Coronas y aumentarás el bono permanente a +%d%%!",
		"confirm": "¡Sí, Renacer!",
		"cancel": "Cancelar"
	},
	
	"de": {
		# TopBar & Inventory
		"food": "Nahrung",
		"wood": "Holz",
		"flour": "Mehl",
		"plank": "Bretter",
		"land": "Land",
		"crowns": "Königskronen",
		
		# Biomes
		"biome_meadow": "Wiese",
		"biome_forest": "Wald",
		"biome_mountain": "Berg",
		"biome_sea": "Meer",
		
		# Hints
		"hint_castle_1": "Burg auf Stufe 2 verbessern, um Holzfäller freizuschalten! (Benötigt: 6 🥡)",
		"hint_castle_2": "Burg auf Stufe 3 verbessern für Mühle & Sägewerk! (18 🥡 + 10 🪵)",
		"hint_expand": "Neues Land erobern: Skalierte Kosten | Rohstoffe verarbeiten!",
		"hint_no_food": "Keine Nahrung! Ernte Maisfelder oder baue eine Arbeiterhütte.",
		
		# Build Menu
		"build_title_meadow": "🌾 Wiesen-Baumenü",
		"build_title_forest": "🌲 Wald-Baumenü",
		"build_title_sea": "🌊 Meeres-Baumenü",
		"free": "KOSTENLOS",
		"build_btn": "Bauen",
		"corn_name": "Maisfeld",
		"corn_desc": "Grundlegende Nahrungsproduktion.",
		"windmill_name": "Windmühle (Stufe 2)",
		"windmill_desc": "Verarbeitet Nahrung zu Mehl.",
		"lumberjack_name": "Holzfällerhütte",
		"lumberjack_desc": "Grundlegende Holzproduktion.",
		"sawmill_name": "Sägewerk (Stufe 2)",
		"sawmill_desc": "Verarbeitet Holz zu Brettern.",
		"worker_name": "Arbeiterhütte",
		"worker_desc": "Automatischer Warentransport von Nachbarn.",
		"bridge_name": "Holzbrücke",
		"bridge_desc": "Ermöglicht Überquerung und schaltet Nachbarland frei.",
		"locked_castle_3": "🔒 BURG STUFE 3",
		
		# Production Menus
		"level": "Stufe",
		"per_sec": "/sek",
		"collect": "Sammeln",
		"upgrade": "Verbessern",
		"full": "VOLL",
		"supply_neighbor": "🟢 Nachbarfeld (100% Tempo)",
		"supply_neighbor_wood": "🟢 Nachbarholzfäller (100% Tempo)",
		"supply_global": "🟡 Hauptlager (50% Tempo)",
		"capacity": "Kapazität",
		"connected_facilities": "Verbundene Betriebe",
		"total_transferred": "Transportiert",
		"auto_carry": "Auto-Transport",
		
		# Castle Menu
		"castle_title": "🏰 Königsburg",
		"global_bonus": "Globaler Produktionsbonus",
		"next_unlock": "Nächste Freischaltung",
		"max_level": "MAXIMALE STUFE",
		"max_power_active": "👑 Legendäre maximale Macht erreicht!",
		
		# Toasts
		"toast_free_tile": "✨ Erstes Land KOSTENLOS erobert! (+1 Land)",
		"toast_buy_tile": "🏰 Land für %d 🥡 Nahrung erobert! (+1 Land)",
		"toast_mountain_conquered": "🏔️ Berg erobert! Alle Ländereien im 1-Einheiten-Umkreis aufgedeckt.",
		"toast_mountain_info": "🏔️ Eroberter Berggipfel. Alle umliegenden Ländereien im Sichtfeld.",
		"toast_no_food_tile": "⚠️ Zu wenig Nahrung! %d 🥡 Nahrung erforderlich.",
		"toast_adjacent_required": "⚠️ Du kannst nur Ländereien erobern, die an dein Gebiet angrenzen!",
		"toast_need_bridge": "⚠️ Offenes Meer! Baue zuerst eine Brücke auf diesem Seefeld.",
		"toast_bridge_need_land": "⚠️ Brücke erfordert Verbindung zu mindestens 1 Landfeld.",
		"toast_forest_locked": "🔒 Wald gesperrt! Burg zuerst auf Stufe 2 bringen.",
		"toast_no_build_biome": "ℹ️ Noch keine Gebäude für dieses Biom verfügbar.",
		"toast_built_corn": "🌽 Maisfeld errichtet!",
		"toast_built_windmill": "🌾 Windmühle errichtet! Mehlproduktion gestartet.",
		"toast_built_lumberjack": "🪓 Holzfällerhütte errichtet!",
		"toast_built_sawmill": "🪵 Sägewerk errichtet! Bretterproduktion gestartet.",
		"toast_built_worker": "🛖 Arbeiterhütte errichtet! Transport aktiv.",
		"toast_built_bridge": "🌉 Brücke gebaut! Überseeländer freigeschaltet.",
		"toast_collected_food": "🥡 +%.2f Nahrung ins Lager gelegt!",
		"toast_collected_wood": "🪵 +%.2f Holz ins Lager gelegt!",
		"toast_collected_flour": "🌾 +%.2f Mehl ins Lager gelegt!",
		"toast_collected_plank": "🪵 +%.2f Bretter ins Lager gelegt!",
		"toast_upgraded": "✨ %s auf Stufe %d verbessert!",
		"toast_castle_upgraded": "👑 Königreich zu %s erhoben! (+25% Globale Geschwindigkeit)",
		"toast_insufficient_res": "⚠️ Unzureichende Ressourcen!",
		"toast_prestige_success": "👑 Königreich wiedergeboren! +%d Kronen und +%d%% Dauerbonus erhalten!",
		"toast_saved": "💾 Spiel gespeichert.",
		
		# Offline Gains Modal
		"offline_welcome": "👑 Willkommen zurück, Herrscher!",
		"offline_desc": "Dein Königreich hat fleißig weitergearbeitet (%s lang):",
		"offline_claim": "Alles beanspruchen",
		"offline_claim_3x": "📺 3x beanspruchen (Bonus)",
		
		# Settings & Stats & Prestige
		"settings_title": "⚙️ Einstellungen & Reichsverwaltung",
		"tab_general": "🌐 Allgemein & Ton",
		"tab_stats": "📊 Statistiken",
		"tab_prestige": "👑 Prestige (Wiedergeburt)",
		"language_select": "Sprachauswahl:",
		"sfx_volume": "Soundeffekte (SFX):",
		"mute": "Stumm",
		
		# Stats
		"stat_playtime": "Gesamte Spielzeit",
		"stat_conquered": "Gesamte eroberte Ländereien",
		"stat_total_food": "Gesamte Nahrung produziert",
		"stat_total_wood": "Gesamtes Holz produziert",
		"stat_total_flour": "Gesamtes Mehl produziert",
		"stat_total_plank": "Gesamte Bretter produziert",
		"stat_rebirths": "Gesamte Wiedergeburten durchgeführt",
		
		# Prestige Screen
		"prestige_title": "👑 Königreich Wiedergeburt (Prestige)",
		"prestige_desc": "Setze dein Königreich zurück, um Königskronen zu erhalten. Jede Krone erhöht dauerhaft alle Produktionsgeschwindigkeiten um +5%!",
		"current_crowns": "Aktuelle Kronen",
		"current_bonus": "Aktueller Dauerbonus",
		"earned_crowns": "Kronen bei Reset",
		"rebirth_btn": "👑 Königreich zurücksetzen & neu starten",
		"rebirth_need_more": "⚠️ Produziere mehr Waren, um Kronen zu verdienen!",
		"prestige_confirm_title": "⚠️ Bist du sicher, dass du neu starten möchtest?",
		"prestige_confirm_desc": "Karte, Gebäude und Waren werden zurückgesetzt. Du erhältst im Gegenzug +%d Kronen und steigerst deinen Dauerbonus auf +%d%%!",
		"confirm": "Ja, Neu Starten!",
		"cancel": "Abbrechen"
	}
}

static func tr_t(key: String, args: Array = []) -> String:
	var lang_dict = STRINGS.get(current_lang, STRINGS["tr"])
	var text: String = lang_dict.get(key, STRINGS["tr"].get(key, key))
	if args.size() > 0:
		return text % args
	return text

static func set_language(lang: String) -> void:
	if lang in SUPPORTED_LANGUAGES:
		current_lang = lang
