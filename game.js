/**
 * Idle Kingdom Clicker — Mobile-First Web Edition
 * 100% Pure HTML5 Canvas + Web Audio + Vanilla JS
 */

// =============================================================================
// 1. LOCALIZATION (4 KÜRESEL DİL DESTEĞİ)
// =============================================================================

const STRINGS = {
  tr: {
    food: "Gıda",
    wood: "Odun",
    flour: "Un",
    plank: "Kereste",
    bread: "Ekmek",
    furniture: "Mobilya",
    stone: "Taş",
    iron: "Demir",
    land: "Toprak",
    crowns: "Kraliyet Tacı",
    free: "ÜCRETSİZ",
    build_btn: "İnşa Et",
    level: "Seviye",
    per_sec: "/sn",
    collect: "Topla",
    upgrade: "Geliştir",
    full: "DOLU",
    capacity: "Kapasite",
    auto_carry: "Otomatik Taşıma",
    connected_facilities: "Bağlı Tesisler",
    total_transferred: "Taşındı",
    supply_neighbor: "🟢 Komşu Tarladan (%100)",
    supply_neighbor_wood: "🟢 Komşu Oduncudan (%100)",
    supply_neighbor_flour: "🟢 Komşu Değirmenden (%100)",
    supply_neighbor_plank: "🟢 Komşu Kereste Fabrikasından (%100)",
    supply_neighbor_stone: "🟢 Komşu Taş Ocağından (%100)",
    supply_global: "🟡 Ana Ambardan (%50)",
    
    // Biyomlar & Yapılar
    corn_name: "Mısır Tarlası",
    corn_desc: "Temel gıda üretimi.",
    windmill_name: "Değirmen (Tier 2)",
    windmill_desc: "Gıdayı Un'a çevirir.",
    bakery_name: "Taş Fırın (Tier 3)",
    bakery_desc: "Un ve Gıdadan Ekmek üretir (Yüksek kâr).",
    lumberjack_name: "Oduncu Kulübesi",
    lumberjack_desc: "Temel odun üretimi.",
    sawmill_name: "Kereste Fabrikası (Tier 2)",
    sawmill_desc: "Odunu Kalas'a çevirir.",
    furniture_name: "Mobilyacı (Tier 3)",
    furniture_desc: "Kalas ve Odundan Mobilya üretir (Yüksek kâr).",
    quarry_name: "Taş Ocağı (Maden)",
    quarry_desc: "Dağlardan saf taş çıkarır.",
    mine_name: "Demir Madeni (Maden)",
    mine_desc: "Taş ve odundan demir külçeleri eritir.",
    worker_name: "İşçi Kulübesi",
    worker_desc: "Komşulardan otomatik hammadde taşır.",
    watchtower_name: "Gözcü Kulesi",
    watchtower_desc: "Gece akıncılarına karşı krallığı korur ve ganimet toplar.",
    castle_title: "🏰 Krallık Şatosu",
    global_bonus: "Küresel Üretim & Taşıma Bonusu",
    next_unlock: "Sonraki Kilit",
    max_level: "MAKSİMUM SEVİYE",
    max_power_active: "👑 Krallık Maksimum Gücüne Ulaştı!",
    locked_castle_3: "🔒 ŞATO SV. 3",
    locked_castle_4: "🔒 ŞATO SV. 4",
    
    // Menü Başlıkları
    build_title_meadow: "🌾 Çayır İnşaat Menüsü",
    build_title_forest: "🌲 Orman İnşaat Menüsü",
    build_title_sea: "🌊 Deniz İnşaat Menüsü",
    build_title_mountain: "🏔️ Dağ & Madencilik Menüsü",
    settings_title: "⚙️ Ayarlar & Krallık Yönetimi",
    tab_general: "🌐 Genel & Ses",
    tab_stats: "📊 İstatistikler",
    tab_prestige: "👑 Prestij",
    tab_talents: "⚡ Yetenekler",
    language_select: "Dil Seçimi / Language:",
    sfx_volume: "Ses Efektleri (SFX):",
    mute: "Sessiz",
    unmute: "Ses Açık",
    
    // İpuçları
    hint_castle_1: "Şatoyu Seviye 2'ye yükselterek Odunculuğun kilidini aç! (Gerekli: 6 🥡)",
    hint_castle_2: "Şatoyu Seviye 3'e yükselterek Değirmen & Kereste Fabrikasını aç! (18 🥡 + 10 🪵)",
    hint_expand: "Yeni altıgen fethet: Üstel maliyet | Fabrikalarla katma değerli ürün üret!",
    hint_no_food: "Gıda tükendi! Mısır tarlalarını hasat et veya işçi kulübesi kur.",
    
    // Binalar
    bridge_name: "Ahşap Köprü",
    bridge_desc: "Açık deniz geçişini sağlar ve komşu karalara ulaşım açar.",

    // Toastlar
    toast_free_tile: "✨ İlk arsanı ÜCRETSİZ fethettin! (+1 Toprak)",
    toast_buy_tile: "🏰 {0} 🥡 Gıda karşılığında yeni arsa fethedildi! (+1 Toprak)",
    toast_mountain_conquered: "🏔️ Dağ Fethedildi! Taş & Demir Madenciliği için hazır.",
    toast_mountain_info: "🏔️ Fethedilmiş Dağ Zirvesi. Taş Ocağı ve Demir Madeni inşa edebilirsiniz.",
    toast_no_food_tile: "⚠️ Yetersiz Gıda! Yeni altıgen açmak için {0} 🥡 Gıda gerekli.",
    toast_adjacent_required: "⚠️ Yalnızca sınır komşunuz olan arazileri fethedebilirsiniz!",
    toast_need_bridge: "⚠️ Açık Deniz Engeli! Denizden geçiş için önce bu deniz karosuna köprü inşa etmelisin.",
    toast_bridge_need_land: "⚠️ Köprü inşa etmek için en az 1 komşu kara parçası gereklidir.",
    toast_forest_locked: "🔒 Orman Kilitli! Odunculuk için Şatoyu Seviye 2'ye yükselt.",
    toast_no_build_biome: "ℹ️ Bu biyomda henüz inşa edilebilir yapı bulunmuyor.",
    toast_built_corn: "🌽 Mısır Tarlası inşa edildi!",
    toast_built_windmill: "🌾 Değirmen kuruldu! Un üretimi başladı.",
    toast_built_bakery: "🍞 Taş Fırın kuruldu! Ekmek üretimi başladı.",
    toast_built_lumberjack: "🪓 Oduncu Kulübesi kuruldu! Odun üretimi başladı.",
    toast_built_sawmill: "🪵 Kereste Fabrikası kuruldu! Kalas üretimi başladı.",
    toast_built_furniture: "🪑 Mobilya Atölyesi kuruldu! Mobilya üretimi başladı.",
    toast_built_quarry: "🪨 Taş Ocağı kuruldu! Taş üretimi başladı.",
    toast_built_mine: "⛏️ Demir Madeni kuruldu! Demir üretimi başladı.",
    toast_built_worker: "🛖 İşçi Kulübesi kuruldu! Otomatik taşıma başladı.",
    toast_built_watchtower: "🏹 Gözcü Kulesi kuruldu! Gece savunması aktif.",
    toast_built_bridge: "🌉 Köprü inşa edildi! Deniz ötesi kara fethine açıldı.",
    toast_collected_food: "🥡 +{0} Gıda ambarına eklendi!",
    toast_collected_wood: "🪵 +{0} Odun kereste ambarına eklendi!",
    toast_collected_flour: "🌾 +{0} Un ambarına eklendi!",
    toast_collected_plank: "🪵 +{0} Kereste/Kalas ambarına eklendi!",
    toast_collected_bread: "🍞 +{0} Ekmek ambarına eklendi!",
    toast_collected_furniture: "🪑 +{0} Mobilya ambarına eklendi!",
    toast_collected_stone: "🪨 +{0} Taş ambarına eklendi!",
    toast_collected_iron: "⛏️ +{0} Demir ambarına eklendi!",
    toast_chest_found: "🎁 Gizemli Hazine Sandığı Açıldı! Bolca kaynak kazanıldı!",
    toast_talent_bought: "⚡ Yetenek Geliştirildi!",
    toast_upgraded: "✨ {0} Seviye {1}'e yükseltildi!",
    toast_castle_upgraded: "👑 Krallık {0} kademesine yükseltildi! (+%25 Küresel Hız)",
    toast_insufficient_res: "⚠️ Yetersiz Kaynak!",
    toast_prestige_success: "👑 Krallık Yeniden Doğdu! +{0} Taç ve kalıcı +%{1} Üretim Bonusu kazanıldı!",
    
    // Çevrimdışı & Prestij
    offline_welcome: "👑 Krallığına Hoş Geldin!",
    offline_desc: "Sen yokken krallığın çalışmaya devam etti ({0} boyunca):",
    offline_claim: "Tümünü Al",
    offline_claim_3x: "📺 3x Al (Bonus)",
    stat_playtime: "Toplam Oynama Süresi",
    stat_conquered: "Fethedilen Toprak",
    stat_total_food: "Toplam Üretilen Gıda",
    stat_total_wood: "Toplam Üretilen Odun",
    stat_total_flour: "Toplam Üretilen Un",
    stat_total_plank: "Toplam Üretilen Kereste",
    stat_total_bread: "Toplam Üretilen Ekmek",
    stat_total_furniture: "Toplam Üretilen Mobilya",
    stat_total_stone: "Toplam Üretilen Taş",
    stat_total_iron: "Toplam Üretilen Demir",
    stat_rebirths: "Yapılan Prestij Sayısı",
    prestige_desc: "Krallığını sıfırlayarak kalıcı Kraliyet Taçları kazan. Her taç üretimi ve taşımayı kalıcı olarak %5 hızlandırır!",
    current_crowns: "Mevcut Taçlar",
    earned_crowns: "Sıfırlanınca Kazanılacak Taç",
    rebirth_btn: "👑 Krallığı Sıfırla & Yeniden Doğur",
    rebirth_need_more: "⚠️ Taç kazanmak için daha fazla kaynak üretmelisin!",
    prestige_confirm_title: "⚠️ Krallığı Sıfırlamak İstediğinden Emin Misin?",
    prestige_confirm_desc: "Harita, binalar ve mevcut kaynakların sıfırlanacak. Karşılığında +{0} Taç kazanacaksın (+%{1} Kalıcı Bonus)!",
    confirm: "Evet, Yeniden Doğur!",
    cancel: "İptal"
  },

  en: {
    food: "Food",
    wood: "Wood",
    flour: "Flour",
    plank: "Plank",
    bread: "Bread",
    furniture: "Furniture",
    stone: "Stone",
    iron: "Iron",
    land: "Land",
    crowns: "Royal Crowns",
    free: "FREE",
    build_btn: "Build",
    level: "Level",
    per_sec: "/sec",
    collect: "Collect",
    upgrade: "Upgrade",
    full: "FULL",
    capacity: "Capacity",
    auto_carry: "Auto Transfer",
    connected_facilities: "Connected Facilities",
    total_transferred: "Transferred",
    supply_neighbor: "🟢 Neighbor Farm (100%)",
    supply_neighbor_wood: "🟢 Neighbor Lumberjack (100%)",
    supply_neighbor_flour: "🟢 Neighbor Windmill (100%)",
    supply_neighbor_plank: "🟢 Neighbor Sawmill (100%)",
    supply_neighbor_stone: "🟢 Neighbor Quarry (100%)",
    supply_global: "🟡 Global Silo (50%)",
    
    corn_name: "Corn Field",
    corn_desc: "Basic food production.",
    windmill_name: "Windmill (Tier 2)",
    windmill_desc: "Processes food into flour.",
    bakery_name: "Stone Bakery (Tier 3)",
    bakery_desc: "Processes flour and food into bread.",
    lumberjack_name: "Lumberjack Hut",
    lumberjack_desc: "Basic wood production.",
    sawmill_name: "Sawmill (Tier 2)",
    sawmill_desc: "Processes wood into planks.",
    furniture_name: "Furniture Maker (Tier 3)",
    furniture_desc: "Processes planks and wood into furniture.",
    quarry_name: "Stone Quarry",
    quarry_desc: "Extracts solid stone from mountains.",
    mine_name: "Iron Mine",
    mine_desc: "Smelts iron ore from stone and wood.",
    worker_name: "Worker Hut",
    worker_desc: "Auto-gathers resources from neighbors.",
    watchtower_name: "Watchtower",
    watchtower_desc: "Defends the realm against night raiders and claims loot.",
    castle_title: "🏰 Kingdom Castle",
    global_bonus: "Global Production & Transport Bonus",
    next_unlock: "Next Unlock",
    max_level: "MAX LEVEL",
    max_power_active: "👑 Kingdom Reached Max Power!",
    locked_castle_3: "🔒 CASTLE LV. 3",
    locked_castle_4: "🔒 CASTLE LV. 4",
    
    build_title_meadow: "🌾 Meadow Build Menu",
    build_title_forest: "🌲 Forest Build Menu",
    build_title_sea: "🌊 Sea Build Menu",
    build_title_mountain: "🏔️ Mountain & Mining Menu",
    settings_title: "⚙️ Settings & Kingdom Management",
    tab_general: "🌐 General & Audio",
    tab_stats: "📊 Statistics",
    tab_prestige: "👑 Prestige",
    tab_talents: "⚡ Talents",
    language_select: "Language Selection:",
    sfx_volume: "Sound Effects (SFX):",
    mute: "Muted",
    unmute: "Sound On",
    
    hint_castle_1: "Upgrade Castle to Level 2 to unlock Lumberjack! (Cost: 6 🥡)",
    hint_castle_2: "Upgrade Castle to Level 3 to unlock Windmill & Sawmill! (18 🥡 + 10 🪵)",
    hint_expand: "Conquer new lands: Scaled cost | Refine goods with factories!",
    hint_no_food: "Out of food! Harvest corn fields or build a worker hut.",
    
    bridge_name: "Wooden Bridge",
    bridge_desc: "Crosses open sea and unlocks neighbor land.",

    toast_free_tile: "✨ First land conquered for FREE! (+1 Land)",
    toast_buy_tile: "🏰 Land conquered for {0} 🥡 Food! (+1 Land)",
    toast_mountain_conquered: "🏔️ Mountain Conquered! Ready for Quarry and Iron Mine.",
    toast_mountain_info: "🏔️ Conquered Mountain Peak. You can build Quarries and Mines.",
    toast_no_food_tile: "⚠️ Not enough food! {0} 🥡 Food required.",
    toast_adjacent_required: "⚠️ You can only conquer lands adjacent to your owned territory!",
    toast_need_bridge: "⚠️ Open Sea Barrier! Build a bridge across this sea tile first.",
    toast_bridge_need_land: "⚠️ Bridge requires connection to at least 1 adjacent land tile.",
    toast_forest_locked: "🔒 Forest Locked! Upgrade Castle to Level 2 first.",
    toast_no_build_biome: "ℹ️ No constructible buildings for this biome yet.",
    toast_built_corn: "🌽 Corn Field constructed!",
    toast_built_windmill: "🌾 Windmill built! Flour production started.",
    toast_built_bakery: "🍞 Bakery built! Bread production started.",
    toast_built_lumberjack: "🪓 Lumberjack Hut built! Wood production started.",
    toast_built_sawmill: "🪵 Sawmill built! Plank production started.",
    toast_built_furniture: "🪑 Furniture Maker built! Furniture production started.",
    toast_built_quarry: "🪨 Stone Quarry built! Stone extraction started.",
    toast_built_mine: "⛏️ Iron Mine built! Iron smelting started.",
    toast_built_worker: "🛖 Worker Hut built! Auto-transport active.",
    toast_built_watchtower: "🏹 Watchtower built! Night defense active.",
    toast_built_bridge: "🌉 Bridge built! Oversea lands unlocked for conquest.",
    toast_collected_food: "🥡 +{0} Food added to storage!",
    toast_collected_wood: "🪵 +{0} Wood added to storage!",
    toast_collected_flour: "🌾 +{0} Flour added to storage!",
    toast_collected_plank: "🪵 +{0} Planks added to storage!",
    toast_collected_bread: "🍞 +{0} Bread added to storage!",
    toast_collected_furniture: "🪑 +{0} Furniture added to storage!",
    toast_collected_stone: "🪨 +{0} Stone added to storage!",
    toast_collected_iron: "⛏️ +{0} Iron added to storage!",
    toast_chest_found: "🎁 Mysterious Treasure Chest Opened! Wealth acquired!",
    toast_talent_bought: "⚡ Talent Upgraded!",
    toast_upgraded: "✨ {0} upgraded to Level {1}!",
    toast_castle_upgraded: "👑 Kingdom promoted to {0}! (+25% Global Speed)",
    toast_insufficient_res: "⚠️ Insufficient Resources!",
    toast_prestige_success: "👑 Kingdom Reborn! +{0} Crowns and permanent +%{1} bonus earned!",
    
    offline_welcome: "👑 Welcome Back, Sovereign!",
    offline_desc: "Your kingdom worked diligently while you were away ({0}):",
    offline_claim: "Claim All",
    offline_claim_3x: "📺 Claim 3x (Bonus)",
    stat_playtime: "Total Playtime",
    stat_conquered: "Total Conquered Lands",
    stat_total_food: "Total Food Produced",
    stat_total_wood: "Total Wood Produced",
    stat_total_flour: "Total Flour Produced",
    stat_total_plank: "Total Planks Produced",
    stat_total_bread: "Total Bread Produced",
    stat_total_furniture: "Total Furniture Produced",
    stat_total_stone: "Total Stone Produced",
    stat_total_iron: "Total Iron Produced",
    stat_rebirths: "Total Rebirths",
    prestige_desc: "Reset your kingdom to gain Royal Crowns. Each crown permanently boosts all production speeds by +5%!",
    current_crowns: "Current Crowns",
    earned_crowns: "Crowns on Reset",
    rebirth_btn: "👑 Reset & Rebirth Kingdom",
    rebirth_need_more: "⚠️ Produce more resources to earn crowns!",
    prestige_confirm_title: "⚠️ Are You Sure You Want to Rebirth?",
    prestige_confirm_desc: "Map, buildings and resources will reset. In return, you will gain +{0} Crowns (+%{1} Permanent Bonus)!",
    confirm: "Yes, Rebirth!",
    cancel: "Cancel"
  },

  es: {
    food: "Comida",
    wood: "Madera",
    flour: "Harina",
    plank: "Tablón",
    bread: "Pan",
    furniture: "Muebles",
    stone: "Piedra",
    iron: "Hierro",
    land: "Tierra",
    crowns: "Coronas Reales",
    free: "GRATIS",
    build_btn: "Construir",
    level: "Nivel",
    per_sec: "/seg",
    collect: "Recolectar",
    upgrade: "Mejorar",
    full: "LLENO",
    capacity: "Capacidad",
    auto_carry: "Transporte Auto",
    connected_facilities: "Instalaciones",
    total_transferred: "Trasladado",
    supply_neighbor: "🟢 Granja Vecina (100%)",
    supply_neighbor_wood: "🟢 Leñador Vecino (100%)",
    supply_neighbor_flour: "🟢 Molino Vecino (100%)",
    supply_neighbor_plank: "🟢 Aserradero Vecino (100%)",
    supply_neighbor_stone: "🟢 Cantera Vecina (100%)",
    supply_global: "🟡 Almacén Global (50%)",
    
    corn_name: "Campo de Maíz",
    corn_desc: "Producción básica de comida.",
    windmill_name: "Molino (Nivel 2)",
    windmill_desc: "Transforma comida en harina.",
    bakery_name: "Panadería (Nivel 3)",
    bakery_desc: "Transforma harina y comida en pan.",
    lumberjack_name: "Cabaña de Leñador",
    lumberjack_desc: "Producción básica de madera.",
    sawmill_name: "Aserradero (Nivel 2)",
    sawmill_desc: "Transforma madera en tablones.",
    furniture_name: "Mueblería (Nivel 3)",
    furniture_desc: "Transforma tablones y madera en muebles.",
    quarry_name: "Cantera de Piedra",
    quarry_desc: "Extrae piedra de las montañas.",
    mine_name: "Mina de Hierro",
    mine_desc: "Funde hierro con piedra y madera.",
    worker_name: "Cabaña de Obreros",
    worker_desc: "Transporta recursos de vecinos.",
    watchtower_name: "Torre de Vigilancia",
    watchtower_desc: "Defiende el reino contra asaltos nocturnos y recoge botín.",
    castle_title: "🏰 Castillo del Reino",
    global_bonus: "Bono Global de Producción",
    next_unlock: "Próximo Desbloqueo",
    max_level: "NIVEL MÁXIMO",
    max_power_active: "👑 ¡Poder Legendario Alcanzado!",
    locked_castle_3: "🔒 CASTILLO NV. 3",
    locked_castle_4: "🔒 CASTILLO NV. 4",
    
    build_title_meadow: "🌾 Menú de Pradera",
    build_title_forest: "🌲 Menú de Bosque",
    build_title_sea: "🌊 Menú de Mar",
    build_title_mountain: "🏔️ Menú de Montaña y Minería",
    settings_title: "⚙️ Ajustes y Gestión del Reino",
    tab_general: "🌐 General y Sonido",
    tab_stats: "📊 Estadísticas",
    tab_prestige: "👑 Prestigio",
    tab_talents: "⚡ Talentos",
    language_select: "Seleccionar Idioma:",
    sfx_volume: "Efectos de Sonido (SFX):",
    mute: "Silenciado",
    unmute: "Sonido Activo",
    
    hint_castle_1: "¡Mejora el castillo a Nivel 2 para desbloquear Leñador! (Costo: 6 🥡)",
    hint_castle_2: "¡Mejora a Nivel 3 para Molino y Aserradero! (18 🥡 + 10 🪵)",
    hint_expand: "Conquista tierras: 1 🥡 Comida | ¡Procesa materias primas!",
    hint_no_food: "¡Sin comida! Cosecha maíz o construye una cabaña de obreros.",
    
    bridge_name: "Puente de Madera",
    bridge_desc: "Cruza el mar y abre tierras vecinas.",

    toast_free_tile: "✨ ¡Primera tierra conquistada GRATIS! (+1 Tierra)",
    toast_buy_tile: "🏰 ¡Tierra conquistada por {0} 🥡 Comida! (+1 Tierra)",
    toast_mountain_conquered: "🏔️ ¡Montaña Conquistada! Cantera y Mina listas.",
    toast_mountain_info: "🏔️ Pico Conquistado. Puedes construir Canteras y Minas.",
    toast_no_food_tile: "⚠️ ¡Comida insuficiente! {0} 🥡 requerida.",
    toast_adjacent_required: "⚠️ ¡Solo puedes conquistar tierras adyacentes a tu territorio!",
    toast_need_bridge: "⚠️ ¡Barrera de Mar! Construye un puente sobre este mar primero.",
    toast_bridge_need_land: "⚠️ El puente requiere conexión con al menos 1 tierra adyacente.",
    toast_forest_locked: "🔒 ¡Bosque bloqueado! Mejora el castillo a Nivel 2 primero.",
    toast_no_build_biome: "ℹ️ Sin edificios para este bioma.",
    toast_built_corn: "🌽 ¡Campo de Maíz construido!",
    toast_built_windmill: "🌾 ¡Molino construido!",
    toast_built_bakery: "🍞 ¡Panadería construida!",
    toast_built_lumberjack: "🪓 ¡Cabaña de Leñador construida!",
    toast_built_sawmill: "🪵 ¡Aserradero construido!",
    toast_built_furniture: "🪑 ¡Mueblería construida!",
    toast_built_quarry: "🪨 ¡Cantera de Piedra construida!",
    toast_built_mine: "⛏️ ¡Mina de Hierro construida!",
    toast_built_worker: "🛖 ¡Cabaña de Obreros construida!",
    toast_built_watchtower: "🏹 ¡Torre de Vigilancia construida! Defensa nocturna activa.",
    toast_built_bridge: "🌉 ¡Puente construido!",
    toast_collected_food: "🥡 ¡+{0} Comida recolectada!",
    toast_collected_wood: "🪵 ¡+{0} Madera recolectada!",
    toast_collected_flour: "🌾 ¡+{0} Harina recolectada!",
    toast_collected_plank: "🪵 ¡+{0} Tablones recolectados!",
    toast_collected_bread: "🍞 ¡+{0} Pan recolectado!",
    toast_collected_furniture: "🪑 ¡+{0} Muebles recolectados!",
    toast_collected_stone: "🪨 ¡+{0} Piedra recolectada!",
    toast_collected_iron: "⛏️ ¡+{0} Hierro recolectado!",
    toast_chest_found: "🎁 ¡Cofre del Tesoro Abierto!",
    toast_talent_bought: "⚡ ¡Talento Mejorado!",
    toast_upgraded: "✨ ¡{0} mejorado a Nivel {1}!",
    toast_castle_upgraded: "👑 ¡Reino ascendido a {0}! (+25% Velocidad)",
    toast_insufficient_res: "⚠️ ¡Recursos Insuficientes!",
    toast_prestige_success: "👑 ¡Reino Renacido! +{0} Coronas y +%{1} bono permanente.",
    
    offline_welcome: "👑 ¡Bienvenido de vuelta, Soberano!",
    offline_desc: "Tu reino continuó trabajando ({0}):",
    offline_claim: "Reclamar Todo",
    offline_claim_3x: "📺 Reclamar 3x (Bono)",
    stat_playtime: "Tiempo Total de Juego",
    stat_conquered: "Total de Tierras Conquistadas",
    stat_total_food: "Total de Comida Producida",
    stat_total_wood: "Total de Madera Producida",
    stat_total_flour: "Total de Harina Producida",
    stat_total_plank: "Total de Tablones Producidos",
    stat_total_bread: "Total de Pan Producido",
    stat_total_furniture: "Total de Muebles Producidos",
    stat_total_stone: "Total de Piedra Producida",
    stat_total_iron: "Total de Hierro Producido",
    stat_rebirths: "Total de Renacimientos",
    prestige_desc: "Reinicia tu reino para ganar Coronas Reales. ¡Cada corona aumenta la velocidad en +5%!",
    current_crowns: "Coronas Actuales",
    earned_crowns: "Coronas al Reiniciar",
    rebirth_btn: "👑 Reiniciar y Renacer Reino",
    rebirth_need_more: "⚠️ ¡Produce más recursos para ganar coronas!",
    prestige_confirm_title: "⚠️ ¿Seguro que quieres Renacer?",
    prestige_confirm_desc: "El mapa y recursos se reiniciarán. ¡Ganarás +{0} Coronas (+%{1} Bono Permanente)!",
    confirm: "¡Sí, Renacer!",
    cancel: "Cancelar"
  },

  de: {
    food: "Nahrung",
    wood: "Holz",
    flour: "Mehl",
    plank: "Bretter",
    bread: "Brot",
    furniture: "Möbel",
    stone: "Stein",
    iron: "Eisen",
    land: "Land",
    crowns: "Königskronen",
    free: "KOSTENLOS",
    build_btn: "Bauen",
    level: "Stufe",
    per_sec: "/sek",
    collect: "Sammeln",
    upgrade: "Verbessern",
    full: "VOLL",
    capacity: "Kapazität",
    auto_carry: "Auto-Transport",
    connected_facilities: "Verbundene Betriebe",
    total_transferred: "Transportiert",
    supply_neighbor: "🟢 Nachbarfeld (100%)",
    supply_neighbor_wood: "🟢 Nachbarholzfäller (100%)",
    supply_neighbor_flour: "🟢 Nachbarmühle (100%)",
    supply_neighbor_plank: "🟢 Nachbarsägewerk (100%)",
    supply_neighbor_stone: "🟢 Nachbarsteinbruch (100%)",
    supply_global: "🟡 Hauptlager (50%)",
    
    corn_name: "Maisfeld",
    corn_desc: "Grundlegende Nahrungsproduktion.",
    windmill_name: "Windmühle (Stufe 2)",
    windmill_desc: "Verarbeitet Nahrung zu Mehl.",
    bakery_name: "Bäckerei (Stufe 3)",
    bakery_desc: "Verarbeitet Mehl und Nahrung zu Brot.",
    lumberjack_name: "Holzfällerhütte",
    lumberjack_desc: "Grundlegende Holzproduktion.",
    sawmill_name: "Sägewerk (Stufe 2)",
    sawmill_desc: "Verarbeitet Holz zu Brettern.",
    furniture_name: "Möbeltischlerei (Stufe 3)",
    furniture_desc: "Verarbeitet Bretter und Holz zu Möbeln.",
    quarry_name: "Steinbruch",
    quarry_desc: "Gewinnt soliden Stein aus den Bergen.",
    mine_name: "Eisenmine",
    mine_desc: "Schmilzt Eisenerz aus Stein und Holz.",
    worker_name: "Arbeiterhütte",
    worker_desc: "Transportiert Waren von Nachbarn.",
    watchtower_name: "Wachturm",
    watchtower_desc: "Verteidigt das Reich gegen nächtliche Überfälle und sammelt Beute.",
    castle_title: "🏰 Königsburg",
    global_bonus: "Globaler Produktionsbonus",
    next_unlock: "Nächste Freischaltung",
    max_level: "MAXIMALE STUFE",
    max_power_active: "👑 Maximale Macht erreicht!",
    locked_castle_3: "🔒 BURG STUFE 3",
    locked_castle_4: "🔒 BURG STUFE 4",
    
    build_title_meadow: "🌾 Wiesen-Baumenü",
    build_title_forest: "🌲 Wald-Baumenü",
    build_title_sea: "🌊 See-Baumenü",
    build_title_mountain: "🏔️ Berg- & Bergbaumenü",
    settings_title: "⚙️ Einstellungen & Verwaltung",
    tab_general: "🌐 Allgemein & Audio",
    tab_stats: "📊 Statistiken",
    tab_prestige: "👑 Prestige",
    tab_talents: "⚡ Talente",
    language_select: "Sprachauswahl:",
    sfx_volume: "Soundeffekte (SFX):",
    mute: "Stumm",
    unmute: "Ton Ein",
    
    hint_castle_1: "Burg auf Stufe 2 für Holzfäller verbessern! (6 🥡)",
    hint_castle_2: "Burg auf Stufe 3 für Mühle & Sägewerk! (18 🥡 + 10 🪵)",
    hint_expand: "Land erobern: Skalierte Kosten | Fabriken bauen!",
    hint_no_food: "Keine Nahrung! Mais ernten oder Arbeiter bauen.",
    
    bridge_name: "Holzbrücke",
    bridge_desc: "Überquert offenes Meer und erschließt Nachbarländer.",

    toast_free_tile: "✨ Erstes Land KOSTENLOS erobert! (+1 Land)",
    toast_buy_tile: "🏰 Land für {0} 🥡 Nahrung erobert! (+1 Land)",
    toast_mountain_conquered: "🏔️ Berg erobert! Bereit für Steinbruch & Mine.",
    toast_mountain_info: "🏔️ Eroberter Berggipfel. Du kannst Steinbrüche und Minen bauen.",
    toast_no_food_tile: "⚠️ Zu wenig Nahrung! {0} 🥡 erforderlich.",
    toast_adjacent_required: "⚠️ Du kannst nur an dein Territorium angrenzende Gebiete erobern!",
    toast_need_bridge: "⚠️ Offenes Meer! Baue zuerst eine Brücke über dieses Wasser.",
    toast_bridge_need_land: "⚠️ Brücke benötigt Verbindung zu mindestens 1 Landfeld.",
    toast_forest_locked: "🔒 Wald gesperrt! Burg zuerst auf Stufe 2 bringen.",
    toast_no_build_biome: "ℹ️ Keine Gebäude für dieses Biom verfügbar.",
    toast_built_corn: "🌽 Maisfeld errichtet!",
    toast_built_windmill: "🌾 Windmühle errichtet!",
    toast_built_bakery: "🍞 Bäckerei errichtet!",
    toast_built_lumberjack: "🪓 Holzfällerhütte errichtet!",
    toast_built_sawmill: "🪵 Sägewerk errichtet!",
    toast_built_furniture: "🪑 Möbeltischlerei errichtet!",
    toast_built_quarry: "🪨 Steinbruch errichtet!",
    toast_built_mine: "⛏️ Eisenmine errichtet!",
    toast_built_worker: "🛖 Arbeiterhütte errichtet!",
    toast_built_watchtower: "🏹 Wachturm errichtet! Nachtverteidigung aktiv.",
    toast_built_bridge: "🌉 Brücke errichtet!",
    toast_collected_food: "🥡 +{0} Nahrung gesammelt!",
    toast_collected_wood: "🪵 +{0} Holz gesammelt!",
    toast_collected_flour: "🌾 +{0} Mehl gesammelt!",
    toast_collected_plank: "🪵 +{0} Bretter gesammelt!",
    toast_collected_bread: "🍞 +{0} Brot gesammelt!",
    toast_collected_furniture: "🪑 +{0} Möbel gesammelt!",
    toast_collected_stone: "🪨 +{0} Stein gesammelt!",
    toast_collected_iron: "⛏️ +{0} Eisen gesammelt!",
    toast_chest_found: "🎁 Schatztruhe geöffnet! Reichtum erlangt!",
    toast_talent_bought: "⚡ Talent aufgewertet!",
    toast_upgraded: "✨ {0} auf Stufe {1} verbessert!",
    toast_castle_upgraded: "👑 Königreich zu {0} erhoben! (+25% Tempo)",
    toast_insufficient_res: "⚠️ Unzureichende Ressourcen!",
    toast_prestige_success: "👑 Königreich wiedergeboren! +{0} Kronen und +%{1} Dauerbonus.",
    
    offline_welcome: "👑 Willkommen zurück, Herrscher!",
    offline_desc: "Dein Königreich arbeitete weiter ({0} lang):",
    offline_claim: "Alles beanspruchen",
    offline_claim_3x: "📺 3x beanspruchen (Bonus)",
    stat_playtime: "Gesamte Spielzeit",
    stat_conquered: "Erobertes Land",
    stat_total_food: "Gesamte Nahrung",
    stat_total_wood: "Gesamtes Holz",
    stat_total_flour: "Gesamtes Mehl",
    stat_total_plank: "Gesamte Bretter",
    stat_total_bread: "Gesamtes Brot",
    stat_total_furniture: "Gesamte Möbel",
    stat_total_stone: "Gesamter Stein",
    stat_total_iron: "Gesamtes Eisen",
    stat_rebirths: "Wiedergeburten",
    prestige_desc: "Setze das Reich zurück für Königskronen. Jede Krone bringt permanent +5% Tempo!",
    current_crowns: "Aktuelle Kronen",
    earned_crowns: "Kronen bei Reset",
    rebirth_btn: "👑 Reich zurücksetzen & wiedergebären",
    rebirth_need_more: "⚠️ Produziere mehr für Kronen!",
    prestige_confirm_title: "⚠️ Wirklich wiedergebären?",
    prestige_confirm_desc: "Karte und Waren werden zurückgesetzt. Du erhältst +{0} Kronen (+%{1} Dauerbonus)!",
    confirm: "Ja, Wiedergeburt!",
    cancel: "Abbrechen"
  }
};

let currentLang = "tr";

function t(key, args = []) {
  let str = (STRINGS[currentLang] && STRINGS[currentLang][key]) || (STRINGS.tr && STRINGS.tr[key]) || key;
  if (args && args.length > 0) {
    args.forEach((arg, i) => {
      str = str.replace(new RegExp(`\\{${i}\\}`, 'g'), typeof arg === 'number' ? (arg % 1 === 0 ? arg : arg.toFixed(2)) : arg);
    });
  }
  return str;
}

// =============================================================================
// 2. PROSEDÜREL SFX SENTETİZÖRÜ (WEB AUDIO API)
// =============================================================================

class SoundSynth {
  constructor() {
    this.ctx = null;
    this.volume = 0.8;
    this.isMuted = false;
  }

  init() {
    if (!this.ctx) {
      const AudioContext = window.AudioContext || window.webkitAudioContext;
      if (AudioContext) {
        this.ctx = new AudioContext();
      }
    }
    if (this.ctx && this.ctx.state === 'suspended') {
      this.ctx.resume();
    }
  }

  playTones(freqs, duration = 0.15, type = 'sine') {
    if (this.isMuted || this.volume <= 0.01) return;
    this.init();
    if (!this.ctx) return;

    const now = this.ctx.currentTime;
    const osc = this.ctx.createOscillator();
    const gain = this.ctx.createGain();

    osc.type = type;
    const noteTime = duration / freqs.length;

    freqs.forEach((freq, idx) => {
      osc.frequency.setValueAtTime(freq, now + idx * noteTime);
    });

    gain.gain.setValueAtTime(this.volume * 0.3, now);
    gain.gain.exponentialRampToValueAtTime(0.0001, now + duration);

    osc.connect(gain);
    gain.connect(this.ctx.destination);

    osc.start(now);
    osc.stop(now + duration);
  }

  playClick() { this.playTones([880, 1320], 0.04, 'sine'); }
  playTileUnlock() { this.playTones([523.25, 659.25, 783.99], 0.16, 'triangle'); }
  playBuild() { this.playTones([220, 160, 110], 0.14, 'square'); }
  playCollect() { this.playTones([987.77, 1318.51], 0.09, 'sine'); }
  playCritHarvest() { this.playTones([523.25, 783.99, 1046.5, 1567.98, 2093.0], 0.38, 'triangle'); }
  playTradeSuccess() { this.playTones([440, 554.37, 659.25, 880, 1108.7], 0.28, 'sine'); }
  playFireBurn() { this.playTones([150, 220, 180, 290, 120], 0.25, 'sawtooth'); }
  playUpgrade() { this.playTones([440, 554.37, 659.25, 880], 0.22, 'triangle'); }
  playCastleUpgrade() { this.playTones([523.25, 659.25, 783.99, 1046.5], 0.35, 'triangle'); }
  playPrestige() { this.playTones([523.25, 659.25, 783.99, 1046.5, 1318.51, 1567.98], 0.55, 'triangle'); }
  playQuestComplete() { this.playTones([523.25, 659.25, 783.99, 1046.5, 1318.51], 0.35, 'triangle'); }
  playRaidAlarm() { this.playTones([146.83, 110.0, 146.83, 220.0], 0.45, 'sawtooth'); }
  playDiceRoll() { this.playTones([330, 440, 550, 660], 0.15, 'sine'); }
  playError() { this.playTones([180, 130], 0.12, 'square'); }
}

const audio = new SoundSynth();

// =============================================================================
// 3. HEX GRID MATEMATİĞİ & AXIAL SİSTEM
// =============================================================================

const HEX_SIZE = 75.0;
const Y_SCALE = 0.85;

const NEIGHBOR_DIRS = [
  { q: 1, r: 0 },
  { q: 1, r: -1 },
  { q: 0, r: -1 },
  { q: -1, r: 0 },
  { q: -1, r: 1 },
  { q: 0, r: 1 }
];

function hexToPixel(q, r) {
  const x = HEX_SIZE * Math.sqrt(3.0) * (q + r / 2.0);
  const y = HEX_SIZE * (3.0 / 2.0) * r * Y_SCALE;
  return { x, y };
}

function pixelToHex(px, py) {
  const unscaledY = py / Y_SCALE;
  const q = (Math.sqrt(3.0) / 3.0 * px - 1.0 / 3.0 * unscaledY) / HEX_SIZE;
  const r = (2.0 / 3.0 * unscaledY) / HEX_SIZE;
  return hexRound(q, r);
}

function hexRound(q, r) {
  const s = -q - r;
  let rq = Math.round(q);
  let rr = Math.round(r);
  let rs = Math.round(s);

  const qDiff = Math.abs(rq - q);
  const rDiff = Math.abs(rr - r);
  const sDiff = Math.abs(rs - s);

  if (qDiff > rDiff && qDiff > sDiff) {
    rq = -rr - rs;
  } else if (rDiff > sDiff) {
    rr = -rq - rs;
  }
  return { q: rq, r: rr };
}

function hexDistance(a, b) {
  const ax = a.q;
  const az = a.r;
  const ay = -ax - az;
  const bx = b.q;
  const bz = b.r;
  const by = -bx - bz;
  return Math.floor((Math.abs(ax - bx) + Math.abs(ay - by) + Math.abs(az - bz)) / 2);
}

function hexLine(a, b) {
  const n = hexDistance(a, b);
  const results = [];
  if (n === 0) {
    results.push(a);
    return results;
  }
  for (let i = 0; i <= n; i++) {
    const t = i / n;
    const ax = a.q + 0.00001;
    const az = a.r + 0.00001;
    const ay = -ax - az;
    const bx = b.q + 0.00001;
    const bz = b.r + 0.00001;
    const by = -bx - bz;

    const x = ax + (bx - ax) * t;
    const y = ay + (by - ay) * t;
    const z = az + (bz - az) * t;

    let rx = Math.round(x);
    let ry = Math.round(y);
    let rz = Math.round(z);

    const xDiff = Math.abs(rx - x);
    const yDiff = Math.abs(ry - y);
    const zDiff = Math.abs(rz - z);

    if (xDiff > yDiff && xDiff > zDiff) {
      rx = -ry - rz;
    } else if (yDiff > zDiff) {
      ry = -rx - rz;
    } else {
      rz = -rx - ry;
    }

    results.push({ q: Math.round(rx), r: Math.round(rz) });
  }
  return results;
}

function getHexCorners(size = HEX_SIZE, yScale = Y_SCALE) {
  const corners = [];
  for (let i = 0; i < 6; i++) {
    const angleDeg = 60.0 * i - 30.0;
    const angleRad = (Math.PI / 180.0) * angleDeg;
    corners.push({
      x: size * Math.cos(angleRad),
      y: size * Math.sin(angleRad) * yScale
    });
  }
  return corners;
}

// =============================================================================
// 4. ŞATO KADEMELERİ (10 SEVİYE)
// =============================================================================

const CASTLE_TITLES = [
  "Köy Şatosu", "Derebeylik Şatosu", "Kontluk Şatosu", "Düklük Şatosu",
  "Büyük Düklük Şatosu", "Prens Emareti Şatosu", "Krallık Sarayı",
  "Büyük Krallık Sarayı", "Baş İmparatorluk Sarayı", "Efsanevi Hükümdarlık Sarayı"
];

const CASTLE_UPGRADES = {
  1: { costFood: 6, costWood: 0, nextTitle: "🛡️ Derebeylik (Sv. 2)", unlock: "🪓 Odunculuk & Orman Yapıları" },
  2: { costFood: 18, costWood: 10, nextTitle: "🏰 Kontluk (Sv. 3)", unlock: "🌾 Değirmen & 🪵 Kereste Fabrikası" },
  3: { costFood: 35, costWood: 25, nextTitle: "⚔️ Düklük (Sv. 4)", unlock: "🪙 Pazar Yeri (+%75 Hız)" },
  4: { costFood: 65, costWood: 45, nextTitle: "👑 Büyük Düklük (Sv. 5)", unlock: "✨ 2x Kat Küresel Üretim Hızı" },
  5: { costFood: 110, costWood: 80, nextTitle: "🦅 Prens Emareti (Sv. 6)", unlock: "🦅 Lojistik Ağı (+%125 Hız)" },
  6: { costFood: 180, costWood: 130, nextTitle: "⚜️ Krallık (Sv. 7)", unlock: "⚜️ Vergi Dairesi (+%150 Hız)" },
  7: { costFood: 290, costWood: 210, nextTitle: "🦁 Büyük Krallık (Sv. 8)", unlock: "🦁 Başkent Savunması (+%175 Hız)" },
  8: { costFood: 450, costWood: 330, nextTitle: "🌟 Baş İmparatorluk (Sv. 9)", unlock: "🌟 3x Kat Küresel Üretim Hızı" },
  9: { costFood: 700, costWood: 500, nextTitle: "⚡ Efsanevi Hükümdarlık (Sv. 10)", unlock: "⚡ Efsanevi Zirve (+%225 Hız)" }
};

// =============================================================================
// 5. OYUN DURUMU & MOTOR (GAME STATE)
// =============================================================================

const BIOMES = {
  SEA: { 
    id: 0, 
    name: "Sea", 
    baseColor: "#1a5370", 
    topGrad: ["#236b8e", "#123f56"],
    borderColor: "#0c2c3d",
    skirtLeft: "#0f364a",
    skirtRight: "#081f2b"
  },
  MEADOW: { 
    id: 1, 
    name: "Meadow", 
    baseColor: "#498450", 
    topGrad: ["#56995e", "#3a7040"],
    borderColor: "#224426",
    skirtLeft: "#2c5231",
    skirtRight: "#19331d"
  },
  FOREST: { 
    id: 2, 
    name: "Forest", 
    baseColor: "#1d5334", 
    topGrad: ["#276b44", "#144226"],
    borderColor: "#0e2c1a",
    skirtLeft: "#194228",
    skirtRight: "#0d2617"
  },
  MOUNTAIN: { 
    id: 3, 
    name: "Mountain", 
    baseColor: "#5e544a", 
    topGrad: ["#70655a", "#4a4138"],
    borderColor: "#2d2720",
    skirtLeft: "#3c342d",
    skirtRight: "#231e1a"
  },
  SNOW_PEAK: {
    id: 4,
    name: "SnowPeak",
    baseColor: "#94a3b8",
    topGrad: ["#f1f5f9", "#cbd5e1"],
    borderColor: "#475569",
    skirtLeft: "#64748b",
    skirtRight: "#334155"
  },
  DESERT_OASIS: {
    id: 5,
    name: "DesertOasis",
    baseColor: "#d97706",
    topGrad: ["#f59e0b", "#b45309"],
    borderColor: "#78350f",
    skirtLeft: "#92400e",
    skirtRight: "#78350f"
  },
  WONDER: {
    id: 6,
    name: "Wonder",
    baseColor: "#0f172a",
    topGrad: ["#1e293b", "#0f172a"],
    borderColor: "#06b6d4",
    skirtLeft: "#1e1b4b",
    skirtRight: "#090d16"
  },
  CAVERN: {
    id: 10,
    name: "Cavern",
    baseColor: "#18181b",
    topGrad: ["#27272a", "#09090b"],
    borderColor: "#3f3f46",
    skirtLeft: "#27272a",
    skirtRight: "#09090b"
  },
  MAGMA: {
    id: 11,
    name: "Magma",
    baseColor: "#ea580c",
    topGrad: ["#f97316", "#c2410c"],
    borderColor: "#7c2d12",
    skirtLeft: "#9a3412",
    skirtRight: "#431407"
  },
  CRYSTAL: {
    id: 12,
    name: "Crystal",
    baseColor: "#0284c7",
    topGrad: ["#38bdf8", "#0369a1"],
    borderColor: "#075985",
    skirtLeft: "#0369a1",
    skirtRight: "#0c4a6e"
  }
};

function getTieredBiome(q, r) {
  const dist = (Math.abs(q) + Math.abs(q + r) + Math.abs(r)) / 2;
  const rand = Math.random();

  if (dist <= 3) {
    const pool = [BIOMES.MEADOW, BIOMES.MEADOW, BIOMES.FOREST, BIOMES.FOREST, BIOMES.MOUNTAIN, BIOMES.SEA];
    return pool[Math.floor(rand * pool.length)];
  } else if (dist <= 6) {
    const pool = [BIOMES.MEADOW, BIOMES.FOREST, BIOMES.MOUNTAIN, BIOMES.SNOW_PEAK, BIOMES.DESERT_OASIS, BIOMES.SEA];
    return pool[Math.floor(rand * pool.length)];
  } else {
    if (rand < 0.12) return BIOMES.WONDER;
    const pool = [BIOMES.SNOW_PEAK, BIOMES.DESERT_OASIS, BIOMES.MOUNTAIN, BIOMES.FOREST, BIOMES.MEADOW];
    return pool[Math.floor(rand * pool.length)];
  }
}

class GameState {
  constructor() {
    this.food = 1.0;
    this.wood = 1.0;
    this.flour = 0.0;
    this.plank = 0.0;
    this.bread = 0.0;
    this.furniture = 0.0;
    this.stone = 0.0;
    this.iron = 0.0;

    this.crowns = 0;
    this.totalRebirths = 0;
    this.ownedCount = 1;
    this.purchasedMeadowCount = 0;
    this.purchasedForestCount = 0;
    this.purchasedSeaCount = 0;
    this.purchasedMountainCount = 0;
    this.purchasedSnowPeakCount = 0;
    this.purchasedDesertCount = 0;
    this.purchasedWonderCount = 0;
    this.castleLevel = 1;

    // Göktürk Damgası / Büyük Bozkır Göçü (Prestige 2.0)
    this.tamgas = 0;
    this.totalMigrations = 0;
    this.toreTalents = {
      gokTengri: { rainBlessing: 0, shamanAura: 0 },
      kulTigin: { braveHeart: 0, steelKorgan: 0 },
      tonyukuk: { silkNetwork: 0, pavedRoads: 0 }
    };

    // Dinamik Bozkır Mevsimleri & Zud Afeti
    this.season = "SPRING"; // SPRING, SUMMER, AUTUMN, WINTER
    this.seasonTimer = 0.0; // 45 saniye/mevsim
    this.seasonYear = 1;
    this.isZud = false;
    this.pavedRoads = {};
    this.packMules = [];

    // Ergenekon Yeraltı Dünyası (2. Katman Haritası)
    this.activeLayer = "SURFACE"; // "SURFACE" veya "UNDERGROUND"
    this.undergroundUnlocked = false;
    this.undergroundTiles = {};
    this.obsidian = 0.0;
    this.mithril = 0.0;
    this.statTotalObsidian = 0.0;
    this.statTotalMithril = 0.0;

    this.relics = {
      axe: false,
      cornucopia: false,
      standard: false,
      shield: false
    };

    this.quests = {
      fast: null,
      strat: null,
      epic: null
    };

    this.activeEncounter = null;
    this.encounterTimer = 0.0;
    this.shamanBoostTimer = 0.0;
    this.lastRaidNight = -1;

    this.talents = {
      workerSpeed: 0,
      boostAll: 0,
      eagleEye: 0,
      treasureHunter: 0,
      conquestMaster: 0
    };

    this.frenzyTimer = 0.0;
    this.animDayTime = 0.0;
    this.chestSpawnTimer = 0.0;
    this.activeChests = [];

    // Kariyer İstatistikleri
    this.statTotalFood = 0.0;
    this.statTotalWood = 0.0;
    this.statTotalFlour = 0.0;
    this.statTotalPlank = 0.0;
    this.statTotalBread = 0.0;
    this.statTotalFurniture = 0.0;
    this.statTotalStone = 0.0;
    this.statTotalIron = 0.0;
    this.statTotalConquered = 1;
    this.statPlaytime = 0.0;

    // Unvanlar & Başarımlar (Titles & Achievements)
    this.titles = {
      farmer: false,
      lumberjack: false,
      conqueror: false,
      khagan: false,
      nomad: false,
      zudMaster: false,
      ergenekonLord: false,
      merchant: false
    };
    this.marketTradesCount = 0;
    this.warmedTilesCount = 0;

    // Altıgen Karolar: key = "q,r" -> Tile Object
    this.tiles = {};
    
    this.selectedTile = null;
    this.autoSaveTimer = 0.0;
  }

  getCastleMultiplier() {
    return 1.0 + (this.castleLevel - 1) * 0.25;
  }

  getPrestigeMultiplier() {
    const talentBoost = (this.talents ? (this.talents.boostAll || 0) : 0) * 0.10;
    const khaganBonus = (this.titles && this.titles.khagan) ? 0.15 : 0.0;
    return 1.0 + this.crowns * 0.05 + talentBoost + khaganBonus;
  }

  getFrenzyMultiplier() {
    return this.frenzyTimer > 0.0 ? 10.0 : 1.0;
  }

  getGlobalMultiplier() {
    const shamanBoost = (this.shamanBoostTimer > 0.0) ? (5.0 + (this.toreTalents && this.toreTalents.gokTengri ? this.toreTalents.gokTengri.shamanAura * 1.25 : 0)) : 1.0;
    
    // Mevsim Çarpanları
    let seasonBonus = 1.0;
    if (this.season === "SPRING") seasonBonus = 1.20;
    else if (this.season === "SUMMER") seasonBonus = 1.15;
    else if (this.season === "AUTUMN") seasonBonus = 1.25;
    else if (this.season === "WINTER") {
      const zudResistance = (this.titles && this.titles.zudMaster) ? 0.95 : 0.85;
      seasonBonus = this.isZud ? zudResistance : 1.0;
    }

    // Töre Yağmur Bereketi
    const rainTalent = (this.toreTalents && this.toreTalents.gokTengri && this.toreTalents.gokTengri.rainBlessing) ? (this.toreTalents.gokTengri.rainBlessing * 0.30) : 0;
    
    return this.getCastleMultiplier() * this.getPrestigeMultiplier() * this.getFrenzyMultiplier() * shamanBoost * (seasonBonus + rainTalent);
  }

  getLandExpansionCost(q, r, biome) {
    const dist = (Math.abs(q) + Math.abs(q + r) + Math.abs(r)) / 2;
    let n = 0;
    if (biome === BIOMES.MEADOW) n = this.purchasedMeadowCount;
    else if (biome === BIOMES.FOREST) n = this.purchasedForestCount;
    else if (biome === BIOMES.SEA) n = this.purchasedSeaCount;
    else if (biome === BIOMES.MOUNTAIN) n = this.purchasedMountainCount;
    else if (biome === BIOMES.SNOW_PEAK) n = this.purchasedSnowPeakCount;
    else if (biome === BIOMES.DESERT_OASIS) n = this.purchasedDesertCount;
    else if (biome === BIOMES.WONDER) n = this.purchasedWonderCount;
    
    const conquestLvl = (this.talents && this.talents.conquestMaster) ? this.talents.conquestMaster : 0;
    const toreConquestLvl = (this.toreTalents && this.toreTalents.kulTigin && this.toreTalents.kulTigin.braveHeart) ? this.toreTalents.kulTigin.braveHeart : 0;
    const relicDiscount = (this.relics && this.relics.standard) ? 0.85 : 1.0;
    const discount = Math.max(0.25, (1.0 - conquestLvl * 0.08 - toreConquestLvl * 0.15) * relicDiscount);

    const baseCost = Math.max(1, Math.floor(1.0 * Math.pow(1.15, n) * (1.0 + 0.15 * Math.max(0, dist - 1)) * discount));
    
    // Bölge 1: 1 - 6 hex
    if (dist <= 6) {
      if (biome === BIOMES.MEADOW) return { zone: 1, food: baseCost, wood: 0, flour: 0, plank: 0, bread: 0, furniture: 0, stone: 0, iron: 0 };
      if (biome === BIOMES.FOREST) return { zone: 1, food: 0, wood: baseCost, flour: 0, plank: 0, bread: 0, furniture: 0, stone: 0, iron: 0 };
      if (biome === BIOMES.SEA) return { zone: 1, food: 0, wood: baseCost, flour: 0, plank: 0, bread: 0, furniture: 0, stone: 0, iron: 0 };
      if (biome === BIOMES.MOUNTAIN) return { zone: 1, food: baseCost, wood: baseCost, flour: 0, plank: 0, bread: 0, furniture: 0, stone: 0, iron: 0 };
      if (biome === BIOMES.SNOW_PEAK) return { zone: 1, food: baseCost, wood: baseCost * 2, flour: 0, plank: 0, bread: 0, furniture: 0, stone: baseCost, iron: 0 };
      if (biome === BIOMES.DESERT_OASIS) return { zone: 1, food: baseCost * 2, wood: baseCost, flour: 0, plank: 0, bread: 0, furniture: 0, stone: 0, iron: 0 };
      if (biome === BIOMES.WONDER) return { zone: 1, food: baseCost * 3, wood: baseCost * 3, flour: 0, plank: 0, bread: 0, furniture: 0, stone: baseCost * 2, iron: baseCost };
      return { zone: 1, food: baseCost, wood: baseCost, flour: 0, plank: 0, bread: 0, furniture: 0, stone: 0, iron: 0 };
    }
    // Bölge 2: 7 - 12 hex (Temel + Tier 2)
    else if (dist <= 12) {
      const tier2Cost = Math.max(1, Math.floor(2.0 * Math.pow(1.12, Math.max(0, n - 6)) * discount));
      if (biome === BIOMES.MEADOW) return { zone: 2, food: baseCost, wood: 0, flour: tier2Cost, plank: 0, bread: 0, furniture: 0, stone: 0, iron: 0 };
      if (biome === BIOMES.FOREST) return { zone: 2, food: 0, wood: baseCost, flour: 0, plank: tier2Cost, bread: 0, furniture: 0, stone: 0, iron: 0 };
      if (biome === BIOMES.SEA) return { zone: 2, food: 0, wood: baseCost, flour: 0, plank: tier2Cost, bread: 0, furniture: 0, stone: 0, iron: 0 };
      if (biome === BIOMES.MOUNTAIN) return { zone: 2, food: baseCost, wood: baseCost, flour: 0, plank: tier2Cost, bread: 0, furniture: 0, stone: tier2Cost, iron: 0 };
      if (biome === BIOMES.SNOW_PEAK) return { zone: 2, food: baseCost, wood: baseCost, flour: 0, plank: tier2Cost, bread: 0, furniture: 0, stone: tier2Cost * 2, iron: tier2Cost };
      if (biome === BIOMES.DESERT_OASIS) return { zone: 2, food: baseCost * 2, wood: baseCost, flour: tier2Cost * 2, plank: 0, bread: 0, furniture: 0, stone: tier2Cost, iron: 0 };
      if (biome === BIOMES.WONDER) return { zone: 2, food: baseCost * 2, wood: baseCost * 2, flour: tier2Cost, plank: tier2Cost, bread: 0, furniture: 0, stone: tier2Cost * 2, iron: tier2Cost * 2 };
      return { zone: 2, food: baseCost, wood: baseCost, flour: tier2Cost, plank: tier2Cost, bread: 0, furniture: 0, stone: tier2Cost, iron: 0 };
    }
    // Bölge 3: 13+ hex (Tier 3)
    else {
      const tier3Cost = Math.max(1, Math.floor(2.0 * Math.pow(1.10, Math.max(0, n - 12)) * discount));
      if (biome === BIOMES.MEADOW) return { zone: 3, food: baseCost, wood: 0, flour: 6, plank: 0, bread: tier3Cost, furniture: 0, stone: 0, iron: 0 };
      if (biome === BIOMES.FOREST) return { zone: 3, food: 0, wood: baseCost, flour: 0, plank: 6, bread: 0, furniture: tier3Cost, stone: 0, iron: 0 };
      if (biome === BIOMES.MOUNTAIN) return { zone: 3, food: baseCost, wood: baseCost, flour: 0, plank: 6, bread: 0, furniture: 0, stone: 6, iron: tier3Cost };
      if (biome === BIOMES.SNOW_PEAK) return { zone: 3, food: baseCost, wood: baseCost, flour: 0, plank: 6, bread: 0, furniture: 0, stone: 10, iron: tier3Cost * 2 };
      if (biome === BIOMES.DESERT_OASIS) return { zone: 3, food: baseCost * 2, wood: baseCost, flour: 10, plank: 0, bread: tier3Cost * 2, furniture: 0, stone: 6, iron: tier3Cost };
      if (biome === BIOMES.WONDER) return { zone: 3, food: baseCost * 2, wood: baseCost * 2, flour: 10, plank: 10, bread: tier3Cost * 2, furniture: tier3Cost * 2, stone: 10, iron: tier3Cost * 2 };
      return { zone: 3, food: baseCost, wood: baseCost, flour: 6, plank: 6, bread: tier3Cost, furniture: tier3Cost, stone: 6, iron: tier3Cost };
    }
  }

  getCareerTotalResources() {
    return (this.statTotalFood || 0) + (this.statTotalWood || 0) + (this.statTotalFlour || 0) + (this.statTotalPlank || 0) + (this.statTotalBread || 0) + (this.statTotalFurniture || 0) + (this.statTotalStone || 0) + (this.statTotalIron || 0) + (this.statTotalObsidian || 0) + (this.statTotalMithril || 0);
  }

  calculateEarnedCrowns() {
    const totalRes = this.getCareerTotalResources();
    const baseCrowns = Math.floor(Math.sqrt(totalRes / 20.0));
    return Math.max(1, baseCrowns * this.castleLevel);
  }

  calculateEarnedTamgas() {
    const totalRes = this.getCareerTotalResources();
    const baseTamgas = Math.floor(Math.sqrt(totalRes / 25.0) * (1.0 + this.ownedCount / 8.0));
    return Math.max(1, baseTamgas);
  }

  initFreshMap() {
    this.tiles = {};
    this.ownedCount = 1;
    this.purchasedTilesCount = 0;

    const radius = 3;

    // Şato etrafındaki 6 komşu için garantili biyom listesi (0 deniz, en az 3 çayır, en az 1 orman)
    const immediateBiomes = [BIOMES.MEADOW, BIOMES.MEADOW, BIOMES.MEADOW, BIOMES.FOREST];
    const nonSeaPool = [BIOMES.MEADOW, BIOMES.FOREST, BIOMES.MOUNTAIN];
    immediateBiomes.push(nonSeaPool[Math.floor(Math.random() * nonSeaPool.length)]);
    immediateBiomes.push(nonSeaPool[Math.floor(Math.random() * nonSeaPool.length)]);
    immediateBiomes.sort(() => Math.random() - 0.5);

    const immediateNeighbors = ["1,0", "1,-1", "0,-1", "-1,0", "-1,1", "0,1"];
    let neighborIdx = 0;

    for (let q = -radius; q <= radius; q++) {
      const r1 = Math.max(-radius, -q - radius);
      const r2 = Math.min(radius, -q + radius);
      for (let r = r1; r <= r2; r++) {
        const key = `${q},${r}`;
        if (q === 0 && r === 0) {
          this.tiles[key] = {
            q: 0, r: 0,
            state: "OWNED",
            biome: BIOMES.MEADOW,
            building: { type: "castle", level: this.castleLevel },
            hasRuins: false
          };
        } else if (immediateNeighbors.includes(key)) {
          const b = immediateBiomes[neighborIdx++];
          this.tiles[key] = {
            q, r,
            state: "HIDDEN",
            biome: b,
            building: null,
            hasRuins: (b !== BIOMES.SEA && Math.random() < 0.18)
          };
        } else {
          const b = getTieredBiome(q, r);
          this.tiles[key] = {
            q, r,
            state: "HIDDEN",
            biome: b,
            building: null,
            hasRuins: (b !== BIOMES.SEA && Math.random() < 0.18)
          };
        }
      }
    }

    if (!this.undergroundTiles || Object.keys(this.undergroundTiles).length === 0) {
      this.initUndergroundMap();
    }

    this.recalculateVisibility();
    initQuests();
  }

  initUndergroundMap() {
    this.undergroundTiles = {};
    const radius = 3;
    const underPool = [BIOMES.CAVERN, BIOMES.CAVERN, BIOMES.MAGMA, BIOMES.CRYSTAL];

    for (let q = -radius; q <= radius; q++) {
      const r1 = Math.max(-radius, -q - radius);
      const r2 = Math.min(radius, -q + radius);
      for (let r = r1; r <= r2; r++) {
        const key = `${q},${r}`;
        if (q === 0 && r === 0) {
          this.undergroundTiles[key] = {
            q: 0, r: 0,
            state: "OWNED",
            biome: BIOMES.CAVERN,
            building: { type: "underground_forge", level: 1 },
            hasRuins: false
          };
        } else {
          const b = underPool[Math.floor(Math.random() * underPool.length)];
          const isOwned = (Math.abs(q) <= 1 && Math.abs(r) <= 1 && Math.abs(q + r) <= 1);
          this.undergroundTiles[key] = {
            q, r,
            state: isOwned ? "OWNED" : "DISCOVERED",
            biome: b,
            building: isOwned ? (b === BIOMES.CRYSTAL ? { type: "crystal_mine", level: 1 } : null) : null,
            hasRuins: false
          };
        }
      }
    }
  }

  recalculateVisibility() {
    const ownedTiles = Object.values(this.tiles).filter(t => t.state === "OWNED");
    const sightRadius = 3;

    // 1. Her bir sahipli toprağın 3 birim menzilindeki yeni altıgenleri dinamik olarak üret (Spawn)
    ownedTiles.forEach(ot => {
      for (let q = -sightRadius; q <= sightRadius; q++) {
        const r1 = Math.max(-sightRadius, -q - sightRadius);
        const r2 = Math.min(sightRadius, -q + sightRadius);
        for (let r = r1; r <= r2; r++) {
          const tq = ot.q + q;
          const tr = ot.r + r;
          const key = `${tq},${tr}`;
          if (!this.tiles[key]) {
            const randB = getTieredBiome(tq, tr);
            this.tiles[key] = {
              q: tq,
              r: tr,
              state: "HIDDEN",
              biome: randB,
              building: null,
              hasRuins: (randB !== BIOMES.SEA && Math.random() < 0.18)
            };
          }
        }
      }
    });

    // 2. Her bir karo için görüş hattını (Line of Sight) hesapla:
    // En az 1 sahipli topraktan (<=3 mesafe) dağ engeli olmadan doğrudan ışın geliyorsa -> DISCOVERED
    Object.values(this.tiles).forEach(tile => {
      if (tile.state === "OWNED") return;

      let canBeSeen = false;

      for (let i = 0; i < ownedTiles.length; i++) {
        const ot = ownedTiles[i];
        const dist = hexDistance(ot, tile);
        if (dist <= sightRadius) {
          const line = hexLine(ot, tile);
          let isBlocked = false;

          for (let j = 1; j < line.length - 1; j++) {
            const midKey = `${line[j].q},${line[j].r}`;
            const midTile = this.tiles[midKey];
            if (midTile && midTile.biome === BIOMES.MOUNTAIN && midTile.state !== "OWNED") {
              isBlocked = true;
              break;
            }
          }

          if (!isBlocked) {
            canBeSeen = true;
            break;
          }
        }
      }

      if (canBeSeen) {
        tile.state = "DISCOVERED";
      } else {
        tile.state = "HIDDEN";
      }
    });
  }

  revealNeighbors(_q, _r) {
    this.recalculateVisibility();
  }

  getNeighborBuildings(q, r) {
    const buildings = [];
    NEIGHBOR_DIRS.forEach(dir => {
      const key = `${q + dir.q},${r + dir.r}`;
      const t = this.tiles[key];
      if (t && t.state === "OWNED" && t.building) {
        buildings.push(t.building);
      }
    });
    return buildings;
  }
}

const game = new GameState();

// =============================================================================
// 6. 3D İZOMETRİK CANVAS RENDER MOTORU
// =============================================================================

const canvas = document.getElementById("game-canvas");
const ctx = canvas.getContext("2d");

let camera = { x: 0, y: 0, zoom: 1.0 };
let isDragging = false;
let dragStart = { x: 0, y: 0 };
let lastTouchDist = 0;
let animWindTime = 0.0;

let screenShakeTimer = 0.0;
let screenShakeIntensity = 0.0;
let screenShakeDuration = 0.0;
let shockwaves = [];
let floatingTexts = [];

// 🌾 MİKRO YAŞAM PARÇACIKLARI & POST-PROCESSING SİSTEMİ
let roamingHerds = [];       // Koyun ve Yılkı Atları Sürüsü
let chimneyPuffs = [];       // Bacalardan Kıvrılarak Çıkan Duman
let flyingResourceGems = []; // Parabolik Uçan Kaynak Taşları
let cloudShadows = [];       // Harita Üzerinden Geçen Yumuşak Bulut Gölgeleri
let weatherStreaks = [];     // Hafif Yağmur & Bozkır Rüzgarı Parçacıkları
let tileBounceMap = {};      // Karo / Bina Tıklama Squash & Stretch Bouncesi

function triggerScreenShake(intensity = 6.0, duration = 0.2) {
  screenShakeIntensity = intensity;
  screenShakeDuration = duration;
  screenShakeTimer = duration;
  if (typeof navigator !== "undefined" && navigator.vibrate) {
    try { navigator.vibrate(Math.min(50, Math.floor(duration * 100))); } catch (e) {}
  }
}

function triggerShockwave(x, y, color = "#f8c83e") {
  shockwaves.push({ x, y, radius: 10, maxRadius: 90, alpha: 1.0, color });
}

function triggerFloatingText(x, y, text, color = "#f8c83e") {
  floatingTexts.push({ x, y, text, color, alpha: 1.0, life: 1.0 });
}

function triggerTileBounce(q, r) {
  tileBounceMap[`${q},${r}`] = { timer: 0.22, maxTime: 0.22 };
}

function triggerFlyingResource(fromX, fromY, icon = "🥡", color = "#4ade80") {
  flyingResourceGems.push({
    x: fromX,
    y: fromY,
    startX: fromX,
    startY: fromY,
    targetX: fromX + (Math.random() - 0.5) * 50,
    targetY: fromY - 75,
    icon,
    color,
    progress: 0.0,
    speed: 2.2
  });
}

function resizeCanvas() {
  const dpr = window.devicePixelRatio || 1;
  canvas.width = window.innerWidth * dpr;
  canvas.height = window.innerHeight * dpr;
  ctx.scale(dpr, dpr);
}
window.addEventListener("resize", resizeCanvas);
resizeCanvas();

// =============================================================================
// MİKRO DİNAMİK SİSTEM GÜNCELLEYİCİLERİ (MICRO-ECOSYSTEM UPDATE)
// =============================================================================

function updateCloudShadows(delta) {
  if (cloudShadows.length === 0) {
    for (let i = 0; i < 5; i++) {
      cloudShadows.push({
        x: (Math.random() - 0.5) * 1400,
        y: (Math.random() - 0.5) * 900,
        w: 220 + Math.random() * 140,
        h: 110 + Math.random() * 70,
        speed: 14 + Math.random() * 10
      });
    }
  }
  cloudShadows.forEach(c => {
    c.x += c.speed * delta;
    if (c.x > 1200) c.x = -1200;
  });
}

function updateRoamingHerds(delta) {
  const ownedMeadows = Object.values(game.tiles).filter(t => (t.state === "OWNED" || t.state === "DISCOVERED") && (t.biome === BIOMES.MEADOW || t.biome === BIOMES.MOUNTAIN));
  if (ownedMeadows.length === 0) return;

  const targetCount = Math.min(6, Math.max(2, Math.floor(ownedMeadows.length * 0.45)));
  while (roamingHerds.length < targetCount) {
    const t = ownedMeadows[Math.floor(Math.random() * ownedMeadows.length)];
    const p = hexToPixel(t.q, t.r);
    const isHorse = Math.random() > 0.45;
    roamingHerds.push({
      q: t.q,
      r: t.r,
      x: p.x + (Math.random() - 0.5) * 18,
      y: p.y + (Math.random() - 0.5) * 12 * Y_SCALE,
      targetX: p.x,
      targetY: p.y,
      type: isHorse ? "horse" : "sheep",
      waitTimer: 2.0 + Math.random() * 4.0,
      isMoving: false,
      moveSpeed: isHorse ? 24 : 12,
      facing: 1,
      animTime: Math.random() * 10
    });
  }

  roamingHerds.forEach(h => {
    h.animTime += delta;
    if (h.isMoving) {
      const dx = h.targetX - h.x;
      const dy = h.targetY - h.y;
      const dist = Math.hypot(dx, dy);
      if (dist < 2.0) {
        h.x = h.targetX;
        h.y = h.targetY;
        h.isMoving = false;
        h.waitTimer = 3.0 + Math.random() * 5.0;
      } else {
        const step = h.moveSpeed * delta;
        h.x += (dx / dist) * step;
        h.y += (dy / dist) * step;
        h.facing = dx >= 0 ? 1 : -1;
      }
    } else {
      h.waitTimer -= delta;
      if (h.waitTimer <= 0) {
        const currentTile = game.tiles[`${h.q},${h.r}`];
        if (currentTile) {
          const neighbors = [];
          NEIGHBOR_DIRS.forEach(d => {
            const nb = game.tiles[`${h.q + d.q},${h.r + d.r}`];
            if (nb && (nb.state === "OWNED" || nb.state === "DISCOVERED") && (nb.biome === BIOMES.MEADOW || nb.biome === BIOMES.MOUNTAIN)) {
              neighbors.push(nb);
            }
          });
          const nextTile = neighbors.length > 0 ? neighbors[Math.floor(Math.random() * neighbors.length)] : currentTile;
          const nextPixel = hexToPixel(nextTile.q, nextTile.r);
          h.q = nextTile.q;
          h.r = nextTile.r;
          h.targetX = nextPixel.x + (Math.random() - 0.5) * 20;
          h.targetY = nextPixel.y + (Math.random() - 0.5) * 14 * Y_SCALE;
          h.isMoving = true;
        }
      }
    }
  });
}

function updateChimneyPuffs(delta) {
  Object.values(game.tiles).forEach(t => {
    if (t.state === "OWNED" && t.building) {
      const b = t.building;
      if (b.type === "bakery" || b.type === "mine" || b.type === "worker" || b.type === "lumberjack") {
        if (Math.random() < 0.20) {
          const p = hexToPixel(t.q, t.r);
          let chimneyOffset = { x: 9, y: -32 * Y_SCALE };
          if (b.type === "mine") chimneyOffset = { x: 18, y: -24 * Y_SCALE };
          if (b.type === "worker") chimneyOffset = { x: -8, y: -32 * Y_SCALE };
          if (b.type === "lumberjack") chimneyOffset = { x: 10, y: -30 * Y_SCALE };
          
          chimneyPuffs.push({
            x: p.x + chimneyOffset.x,
            y: p.y + chimneyOffset.y,
            vx: (Math.random() - 0.5) * 3.5 + 2.5,
            vy: -11.0 - Math.random() * 7.0,
            size: 2.5 + Math.random() * 1.8,
            alpha: 0.60,
            maxLife: 2.0,
            life: 2.0
          });
        }
      }
    }
  });

  for (let i = chimneyPuffs.length - 1; i >= 0; i--) {
    const puff = chimneyPuffs[i];
    puff.x += puff.vx * delta;
    puff.y += puff.vy * delta;
    puff.size += 3.2 * delta;
    puff.life -= delta;
    puff.alpha = Math.max(0, (puff.life / puff.maxLife) * 0.5);
    if (puff.life <= 0) {
      chimneyPuffs.splice(i, 1);
    }
  }
}

function updateFlyingResources(delta) {
  for (let i = flyingResourceGems.length - 1; i >= 0; i--) {
    const gem = flyingResourceGems[i];
    gem.progress += gem.speed * delta;
    gem.x = gem.startX + (gem.targetX - gem.startX) * gem.progress;
    gem.y = gem.startY + (gem.targetY - gem.startY) * gem.progress - Math.sin(gem.progress * Math.PI) * 25;
    if (gem.progress >= 1.0) {
      flyingResourceGems.splice(i, 1);
    }
  }
}

function updateTileBounces(delta) {
  Object.keys(tileBounceMap).forEach(k => {
    tileBounceMap[k].timer -= delta;
    if (tileBounceMap[k].timer <= 0) {
      delete tileBounceMap[k];
    }
  });
}

function updateWeatherStreaks(delta) {
  if (weatherStreaks.length < 40) {
    weatherStreaks.push({
      x: (Math.random() - 0.5) * 1600,
      y: (Math.random() - 0.5) * 1200,
      len: 14 + Math.random() * 18,
      speedX: 180 + Math.random() * 90,
      speedY: 300 + Math.random() * 140,
      alpha: 0.18 + Math.random() * 0.22
    });
  }

  for (let i = 0; i < weatherStreaks.length; i++) {
    const s = weatherStreaks[i];
    s.x += s.speedX * delta;
    s.y += s.speedY * delta;
    if (s.x > 900) s.x = -900;
    if (s.y > 700) s.y = -700;
  }
}

// 🌸 Dinamik Mevsim Parçacıkları (İlkbahar Çiçeği, Yaz Parıltısı, Sonbahar Yaprağı, Zud Kar Fırtınası)
const seasonalParticles = [];

function updateSeasonalParticles(delta) {
  const maxParticles = (game.season === "WINTER" && game.isZud) ? 75 : 30;
  if (seasonalParticles.length < maxParticles) {
    let pType = "blossom";
    let pColor = "#f472b6";
    if (game.season === "SUMMER") { pType = "sparkle"; pColor = "#fde047"; }
    else if (game.season === "AUTUMN") { pType = "leaf"; pColor = "#f59e0b"; }
    else if (game.season === "WINTER") { pType = "snowflake"; pColor = "#e0f2fe"; }

    seasonalParticles.push({
      x: (Math.random() - 0.5) * 1600,
      y: (Math.random() - 0.5) * 1200,
      type: pType,
      color: pColor,
      size: 2.0 + Math.random() * 3.5,
      speedX: (game.season === "WINTER" && game.isZud ? 240 : 40) + Math.random() * 30,
      speedY: (game.season === "WINTER" && game.isZud ? 180 : 60) + Math.random() * 40,
      rot: Math.random() * Math.PI * 2,
      rotSpeed: (Math.random() - 0.5) * 4.0,
      alpha: 0.4 + Math.random() * 0.5
    });
  }

  for (let i = seasonalParticles.length - 1; i >= 0; i--) {
    const p = seasonalParticles[i];
    p.x += p.speedX * delta;
    p.y += p.speedY * delta;
    p.rot += p.rotSpeed * delta;
    if (p.x > 850 || p.y > 650) {
      p.x = -850 + Math.random() * 200;
      p.y = -650 + Math.random() * 200;
    }
  }
}

function drawSeasonalParticles() {
  if (game.activeLayer === "UNDERGROUND") return;

  ctx.save();
  seasonalParticles.forEach(p => {
    ctx.save();
    ctx.translate(p.x, p.y);
    ctx.rotate(p.rot);
    ctx.fillStyle = p.color;
    ctx.globalAlpha = p.alpha;

    if (p.type === "leaf") {
      ctx.beginPath();
      ctx.ellipse(0, 0, p.size * 1.6, p.size * 0.8, 0, 0, Math.PI * 2);
      ctx.fill();
    } else if (p.type === "blossom") {
      ctx.beginPath();
      ctx.arc(0, 0, p.size, 0, Math.PI * 2);
      ctx.fill();
    } else if (p.type === "snowflake") {
      ctx.beginPath();
      ctx.arc(0, 0, p.size * (game.isZud ? 1.4 : 1.0), 0, Math.PI * 2);
      ctx.fill();
    } else {
      ctx.fillRect(-p.size / 2, -p.size / 2, p.size, p.size);
    }
    ctx.restore();
  });
  ctx.restore();
}

// 🛤️ Taş Kervan Yolu Bağlantıları (Paved Trade Roads)
function drawPavedRoads() {
  const tiles = (game.activeLayer === "UNDERGROUND") ? game.undergroundTiles : game.tiles;
  if (!tiles) return;

  const drawnPairs = new Set();
  const ownedTiles = Object.values(tiles).filter(t => t.state === "OWNED");

  ctx.save();
  ctx.strokeStyle = "#475569";
  ctx.lineWidth = 3.5;
  if (ctx.setLineDash) ctx.setLineDash([4, 4]);

  ownedTiles.forEach(t1 => {
    const p1 = hexToPixel(t1.q, t1.r);
    const neighbors = [
      { q: t1.q + 1, r: t1.r },
      { q: t1.q + 1, r: t1.r - 1 },
      { q: t1.q,     r: t1.r - 1 },
      { q: t1.q - 1, r: t1.r },
      { q: t1.q - 1, r: t1.r + 1 },
      { q: t1.q,     r: t1.r + 1 }
    ];

    neighbors.forEach(n => {
      const key = `${n.q},${n.r}`;
      const t2 = tiles[key];
      if (t2 && t2.state === "OWNED" && (t1.building || t2.building)) {
        const pairKey = [ `${t1.q},${t1.r}`, `${t2.q},${t2.r}` ].sort().join("--");
        if (!drawnPairs.has(pairKey)) {
          drawnPairs.add(pairKey);
          const p2 = hexToPixel(t2.q, t2.r);
          ctx.beginPath();
          ctx.moveTo(p1.x, p1.y + 4 * Y_SCALE);
          ctx.lineTo(p2.x, p2.y + 4 * Y_SCALE);
          ctx.stroke();
        }
      }
    });
  });

  if (ctx.setLineDash) ctx.setLineDash([]);
  ctx.restore();
}

// 🐎 Kervan Katırları Hareketi
function updatePackMules(delta) {
  if (!game.packMules) game.packMules = [];

  if (game.packMules.length < 3 && game.activeLayer === "SURFACE") {
    const ownedBuildings = Object.values(game.tiles).filter(t => t.state === "OWNED" && t.building);
    if (ownedBuildings.length >= 2) {
      const b1 = ownedBuildings[Math.floor(Math.random() * ownedBuildings.length)];
      const b2 = ownedBuildings[Math.floor(Math.random() * ownedBuildings.length)];
      if (b1 !== b2) {
        const p1 = hexToPixel(b1.q, b1.r);
        const p2 = hexToPixel(b2.q, b2.r);
        game.packMules.push({
          startX: p1.x, startY: p1.y,
          endX: p2.x, endY: p2.y,
          x: p1.x, y: p1.y,
          progress: 0.0,
          speed: 0.12 + Math.random() * 0.08,
          facing: (p2.x >= p1.x) ? 1 : -1
        });
      }
    }
  }

  for (let i = game.packMules.length - 1; i >= 0; i--) {
    const m = game.packMules[i];
    m.progress += m.speed * delta;
    m.x = m.startX + (m.endX - m.startX) * m.progress;
    m.y = m.startY + (m.endY - m.startY) * m.progress;
    if (m.progress >= 1.0) {
      game.packMules.splice(i, 1);
    }
  }
}

// =============================================================================
// ANA CANVAS ÇİZİM MOTORU (DRAW)
// =============================================================================

function draw() {
  ctx.save();
  ctx.clearRect(0, 0, window.innerWidth, window.innerHeight);

  // 1. Arka plan Atmosferi (Yeraltı vs Bozkır)
  const isUnderground = (game.activeLayer === "UNDERGROUND");
  const bgGrad = ctx.createRadialGradient(
    window.innerWidth / 2, window.innerHeight / 2, 60,
    window.innerWidth / 2, window.innerHeight / 2, Math.max(window.innerWidth, window.innerHeight)
  );

  if (isUnderground) {
    bgGrad.addColorStop(0, "#2a0800");
    bgGrad.addColorStop(1, "#09090b");
  } else {
    bgGrad.addColorStop(0, "#0b1329");
    bgGrad.addColorStop(1, "#020617");
  }
  ctx.fillStyle = bgGrad;
  ctx.fillRect(0, 0, window.innerWidth, window.innerHeight);

  // Kamera Dönüşümü + Tok Ekran Sarsıntısı (Screen Shake)
  let shakeX = 0;
  let shakeY = 0;
  if (screenShakeTimer > 0) {
    const damping = screenShakeTimer / (screenShakeDuration || 0.1);
    shakeX = (Math.random() - 0.5) * 2 * screenShakeIntensity * damping;
    shakeY = (Math.random() - 0.5) * 2 * screenShakeIntensity * damping;
  }

  ctx.translate(window.innerWidth / 2 + camera.x + shakeX, window.innerHeight / 2 + camera.y + shakeY);
  ctx.scale(camera.zoom, camera.zoom);

  // 2. Yeryüzü Bulut Gölgeleri (Yalnızca Surface'da)
  if (!isUnderground) {
    ctx.save();
    ctx.fillStyle = "rgba(0, 0, 0, 0.18)";
    cloudShadows.forEach(c => {
      ctx.beginPath();
      ctx.ellipse(c.x, c.y * Y_SCALE, c.w * 0.5, c.h * 0.5 * Y_SCALE, 0.1, 0, Math.PI * 2);
      ctx.fill();
    });
    ctx.restore();
  }

  // 3. Karoları Y-Sort derinliğine göre sırala
  const activeTileSource = isUnderground ? (game.undergroundTiles || {}) : (game.tiles || {});
  const tileList = Object.values(activeTileSource).filter(t => t.state !== "HIDDEN");
  tileList.sort((a, b) => {
    const posA = hexToPixel(a.q, a.r);
    const posB = hexToPixel(b.q, b.r);
    return posA.y - posB.y;
  });

  // 4. Kervan Taş Yolları (Paved Roads)
  drawPavedRoads();

  // 5. Karoları ve Katmanlı 3D Toprak Kesitlerini Çiz (Stratum Skirts)
  tileList.forEach(tile => {
    drawHexTile(tile);
  });

  // 6. Yollarda Yürüyen Yüklü Kervan Katırları
  drawPackMules(animWindTime);

  // 7. Haritada Otlayan / Koşan Canlı Hayvan Sürüleri (Yalnızca Bozkır)
  if (!isUnderground) {
    drawRoamingHerds(animWindTime);
  }

  // 8. Bacalardan Yükselen Duman Pufcukları
  ctx.save();
  chimneyPuffs.forEach(p => {
    ctx.fillStyle = `rgba(226, 232, 240, ${p.alpha})`;
    ctx.beginPath();
    ctx.arc(p.x, p.y, p.size, 0, Math.PI * 2);
    ctx.fill();
  });
  ctx.restore();

  // 9. Post-Processing & Işıklandırma (Bloom & Torch Glows)
  tileList.forEach(tile => {
    if (tile.state === "OWNED") {
      const pos = hexToPixel(tile.q, tile.r);
      if (tile.building && tile.building.type === "watchtower") {
        const radGrad = ctx.createRadialGradient(pos.x + 10, pos.y - 36 * Y_SCALE, 2, pos.x + 10, pos.y - 36 * Y_SCALE, 45);
        radGrad.addColorStop(0, "rgba(245, 158, 11, 0.45)");
        radGrad.addColorStop(1, "rgba(245, 158, 11, 0.0)");
        ctx.fillStyle = radGrad;
        ctx.beginPath();
        ctx.arc(pos.x + 10, pos.y - 36 * Y_SCALE, 45, 0, Math.PI * 2);
        ctx.fill();
      } else if (tile.building && tile.building.type === "castle") {
        const radGrad = ctx.createRadialGradient(pos.x, pos.y - 20 * Y_SCALE, 4, pos.x, pos.y - 20 * Y_SCALE, 55);
        radGrad.addColorStop(0, "rgba(248, 200, 62, 0.35)");
        radGrad.addColorStop(1, "rgba(248, 200, 62, 0.0)");
        ctx.fillStyle = radGrad;
        ctx.beginPath();
        ctx.arc(pos.x, pos.y - 20 * Y_SCALE, 55, 0, Math.PI * 2);
        ctx.fill();
      } else if (tile.hasRuins || tile.biome === BIOMES.WONDER) {
        const radGrad = ctx.createRadialGradient(pos.x, pos.y - 12 * Y_SCALE, 2, pos.x, pos.y - 12 * Y_SCALE, 45);
        radGrad.addColorStop(0, "rgba(6, 182, 212, 0.45)");
        radGrad.addColorStop(1, "rgba(6, 182, 212, 0.0)");
        ctx.fillStyle = radGrad;
        ctx.beginPath();
        ctx.arc(pos.x, pos.y - 12 * Y_SCALE, 45, 0, Math.PI * 2);
        ctx.fill();
      }
    }
  });

  // 10. Dinamik Savaş Sisi (Fog of War) - Gizli Alanlar
  const hiddenTiles = Object.values(activeTileSource).filter(t => t.state === "HIDDEN");
  hiddenTiles.forEach(ht => {
    const pos = hexToPixel(ht.q, ht.r);
    const screenX = pos.x + camera.x + window.innerWidth / 2;
    const screenY = pos.y + camera.y + window.innerHeight / 2;
    if (screenX > -100 && screenX < window.innerWidth + 100 && screenY > -100 && screenY < window.innerHeight + 100) {
      const fogSway = Math.sin(animWindTime * 1.5 + ht.q * 1.2) * 8.0;
      ctx.save();
      ctx.fillStyle = isUnderground ? "rgba(9, 9, 11, 0.85)" : "rgba(15, 23, 42, 0.70)";
      ctx.beginPath();
      ctx.ellipse(pos.x + fogSway, pos.y, 46, 28 * Y_SCALE, 0, 0, Math.PI * 2);
      ctx.fill();
      ctx.restore();
    }
  });

  // 11. Parabolik Uçan Kaynak Parçacıkları (Flying Gems)
  flyingResourceGems.forEach(gem => {
    ctx.save();
    ctx.font = "bold 14px 'Outfit', sans-serif";
    ctx.textAlign = "center";
    ctx.fillStyle = gem.color;
    ctx.shadowColor = "rgba(0,0,0,0.8)";
    ctx.shadowBlur = 4;
    ctx.fillText(gem.icon, gem.x, gem.y);
    ctx.restore();
  });

  // 12. Şok Dalgalarını Çiz (Conquest Shockwaves)
  for (let i = shockwaves.length - 1; i >= 0; i--) {
    const sw = shockwaves[i];
    ctx.save();
    ctx.strokeStyle = sw.color;
    ctx.globalAlpha = Math.max(0, sw.alpha);
    ctx.lineWidth = 3.5 * (sw.alpha);
    ctx.beginPath();
    ctx.ellipse(sw.x, sw.y, sw.radius, sw.radius * Y_SCALE, 0, 0, Math.PI * 2);
    ctx.stroke();
    ctx.restore();

    sw.radius += 2.8;
    sw.alpha -= 0.035;
    if (sw.alpha <= 0 || sw.radius >= sw.maxRadius) {
      shockwaves.splice(i, 1);
    }
  }

  // 13. Yükselen Metinleri Çiz (Floating Gain Texts)
  for (let i = floatingTexts.length - 1; i >= 0; i--) {
    const ft = floatingTexts[i];
    ctx.save();
    ctx.font = "bold 13px 'JetBrains Mono', monospace";
    ctx.textAlign = "center";
    ctx.fillStyle = ft.color;
    ctx.globalAlpha = Math.max(0, ft.alpha);
    ctx.shadowColor = "rgba(0,0,0,0.8)";
    ctx.shadowBlur = 4;
    ctx.fillText(ft.text, ft.x, ft.y);
    ctx.restore();

    ft.y -= 0.8;
    ft.alpha -= 0.025;
    if (ft.alpha <= 0) {
      floatingTexts.splice(i, 1);
    }
  }

  // 14. Dinamik Mevsim Parçacıkları (Çiçek, Yaprak, Kar)
  drawSeasonalParticles();

  // 15. Gündüz / Gece Sinematik Atmosfer Tonu
  const dayCycle = (game.animDayTime || 0) % 1.0;
  if (!isUnderground) {
    if (dayCycle > 0.35 && dayCycle <= 0.6) {
      const t = (dayCycle - 0.35) / 0.25;
      ctx.save();
      ctx.fillStyle = `rgba(245, 158, 11, ${0.12 * Math.sin(t * Math.PI)})`;
      ctx.fillRect(-window.innerWidth * 2, -window.innerHeight * 2, window.innerWidth * 4, window.innerHeight * 4);
      ctx.restore();
    } else if (dayCycle > 0.6 && dayCycle <= 0.9) {
      const t = (dayCycle - 0.6) / 0.3;
      ctx.save();
      ctx.fillStyle = `rgba(15, 23, 42, ${0.32 * Math.sin(t * Math.PI)})`;
      ctx.fillRect(-window.innerWidth * 2, -window.innerHeight * 2, window.innerWidth * 4, window.innerHeight * 4);
      ctx.restore();
    }

    // 16. Yağmur Esintileri
    if (dayCycle > 0.45 && dayCycle < 0.85) {
      ctx.save();
      ctx.strokeStyle = "rgba(186, 230, 253, 0.28)";
      ctx.lineWidth = 1.2;
      for (let i = 0; i < weatherStreaks.length; i++) {
        const s = weatherStreaks[i];
        ctx.beginPath();
        ctx.moveTo(s.x, s.y);
        ctx.lineTo(s.x + s.len * 0.4, s.y + s.len);
        ctx.stroke();
      }
      ctx.restore();
    }

    // 17. Zud Kış Kar Fırtınası Don Overlay
    if (game.season === "WINTER" && game.isZud) {
      ctx.save();
      ctx.fillStyle = "rgba(224, 242, 254, 0.15)";
      ctx.fillRect(-window.innerWidth * 2, -window.innerHeight * 2, window.innerWidth * 4, window.innerHeight * 4);
      ctx.restore();
    }
  }

  ctx.restore();
}

// =============================================================================
// 3D KATMANLI STRATUM HEX BEDROCK (3D TOPRAK KESİTİ)
// =============================================================================

// =============================================================================
// ENTEGRE NEO-BRUTALIST TAŞ ROZET (HARVEST BADGE)
// =============================================================================

function drawHarvestBadge(x, y, icon, amount, time) {
  const floatOffset = Math.sin(time * 3.5) * 2.5;
  const pulse = Math.sin(time * 5.0) * 0.05 + 1.0;
  const by = y + floatOffset;

  ctx.save();
  ctx.translate(x, by);
  ctx.scale(pulse, pulse);

  // 1. Sert Ofset Gölge (Neo-Brutalist 2px 2px)
  ctx.fillStyle = "rgba(2, 6, 23, 0.85)";
  ctx.fillRect(-15 + 2, -10 * Y_SCALE + 2, 30, 18 * Y_SCALE);

  // 2. Taş Tablet Zemin
  ctx.fillStyle = "#090d16";
  ctx.fillRect(-15, -10 * Y_SCALE, 30, 18 * Y_SCALE);

  // 3. Altın Kenarlık
  ctx.strokeStyle = "#f59e0b";
  ctx.lineWidth = 1.6;
  ctx.strokeRect(-15, -10 * Y_SCALE, 30, 18 * Y_SCALE);

  // 4. İkon
  ctx.font = "12px Outfit, sans-serif";
  ctx.textAlign = "center";
  ctx.fillText(icon, 0, 3.5 * Y_SCALE);

  // 5. Altın Işıltı Köşesi
  ctx.fillStyle = "#fef08a";
  ctx.fillRect(-13, -8 * Y_SCALE, 2.5, 2.5);

  ctx.restore();
}

// =============================================================================
// 3D KATMANLI STRATUM HEX BEDROCK (3D TOPRAK KESİTİ & DİORAMA)
// =============================================================================

function drawHexTile(tile) {
  const pos = hexToPixel(tile.q, tile.r);
  const corners = getHexCorners(HEX_SIZE, Y_SCALE);
  const isDiscovered = (tile.state === "DISCOVERED");
  const bounceInfo = tileBounceMap[`${tile.q},${tile.r}`];

  ctx.save();
  ctx.translate(pos.x, pos.y);

  if (bounceInfo) {
    const bProgress = bounceInfo.timer / bounceInfo.maxTime;
    const bScale = 1.0 + Math.sin(bProgress * Math.PI) * 0.12;
    ctx.scale(bScale, bScale);
  }

  if (isDiscovered) {
    ctx.globalAlpha = 0.65;
  }

  // 1. Üç Kademeli 3D Stratum Etekleri (Organik Çim Pahı -> Tortul Kil -> Bazalt Taban)
  const l1Depth = 5.0 * Y_SCALE;  // Üst çim/toprak katmanı
  const l2Depth = 15.0 * Y_SCALE; // Orta kil ve tortul kayaç tabakası
  const l3Depth = 26.0 * Y_SCALE; // Alt koyu bazalt ana kaya tabakası

  const sLeft = tile.biome.skirtLeft || "#2c5231";
  const sRight = tile.biome.skirtRight || "#19331d";

  // --- Katman 3: Bazalt Koyu Ana Kaya (En Alt) ---
  // Sol Etek Yüzü (Hafif Işık Alır)
  ctx.fillStyle = "#090d16";
  ctx.beginPath();
  ctx.moveTo(corners[2].x, corners[2].y + l2Depth);
  ctx.lineTo(corners[3].x, corners[3].y + l2Depth);
  ctx.lineTo(corners[3].x, corners[3].y + l3Depth);
  ctx.lineTo(corners[2].x, corners[2].y + l3Depth);
  ctx.closePath();
  ctx.fill();

  // Sağ Etek Yüzü (Derin Gölgede)
  ctx.fillStyle = "#030712";
  ctx.beginPath();
  ctx.moveTo(corners[3].x, corners[3].y + l2Depth);
  ctx.lineTo(corners[4].x, corners[4].y + l2Depth);
  ctx.lineTo(corners[4].x, corners[4].y + l3Depth);
  ctx.lineTo(corners[3].x, corners[3].y + l3Depth);
  ctx.closePath();
  ctx.fill();

  // --- Katman 2: Orta Bozkır Kili & Tortul Kayaç (Terracotta / Clay) ---
  // Sol Etek Yüzü
  ctx.fillStyle = "#3e271c";
  ctx.beginPath();
  ctx.moveTo(corners[2].x, corners[2].y + l1Depth);
  ctx.lineTo(corners[3].x, corners[3].y + l1Depth);
  ctx.lineTo(corners[3].x, corners[3].y + l2Depth);
  ctx.lineTo(corners[2].x, corners[2].y + l2Depth);
  ctx.closePath();
  ctx.fill();

  // Tortul Çizgi Detayı (Sol)
  ctx.strokeStyle = "#4a3023";
  ctx.lineWidth = 1.0;
  ctx.beginPath();
  ctx.moveTo(corners[2].x, corners[2].y + l1Depth + 4 * Y_SCALE);
  ctx.lineTo(corners[3].x, corners[3].y + l1Depth + 4 * Y_SCALE);
  ctx.stroke();

  // Sağ Etek Yüzü
  ctx.fillStyle = "#261710";
  ctx.beginPath();
  ctx.moveTo(corners[3].x, corners[3].y + l1Depth);
  ctx.lineTo(corners[4].x, corners[4].y + l1Depth);
  ctx.lineTo(corners[4].x, corners[4].y + l2Depth);
  ctx.lineTo(corners[3].x, corners[3].y + l2Depth);
  ctx.closePath();
  ctx.fill();

  // --- Katman 1: Üst Organik Toprak / Biyom Pahı ---
  // Sol Etek Yüzü
  ctx.fillStyle = sLeft;
  ctx.beginPath();
  ctx.moveTo(corners[2].x, corners[2].y);
  ctx.lineTo(corners[3].x, corners[3].y);
  ctx.lineTo(corners[3].x, corners[3].y + l1Depth);
  ctx.lineTo(corners[2].x, corners[2].y + l1Depth);
  ctx.closePath();
  ctx.fill();

  // Sağ Etek Yüzü
  ctx.fillStyle = sRight;
  ctx.beginPath();
  ctx.moveTo(corners[3].x, corners[3].y);
  ctx.lineTo(corners[4].x, corners[4].y);
  ctx.lineTo(corners[4].x, corners[4].y + l1Depth);
  ctx.lineTo(corners[3].x, corners[3].y + l1Depth);
  ctx.closePath();
  ctx.fill();

  // 2. Üst Yüzey Poligonu (135° Güneş Işığı Gradyanı)
  const topGrad = ctx.createLinearGradient(
    -HEX_SIZE * 0.6, -HEX_SIZE * 0.7 * Y_SCALE,
    HEX_SIZE * 0.6, HEX_SIZE * 0.7 * Y_SCALE
  );
  const gradColors = tile.biome.topGrad || [tile.biome.baseColor, tile.biome.baseColor];
  topGrad.addColorStop(0, gradColors[0]);
  topGrad.addColorStop(1, gradColors[1]);

  ctx.fillStyle = topGrad;
  ctx.beginPath();
  ctx.moveTo(corners[0].x, corners[0].y);
  for (let i = 1; i < 6; i++) {
    ctx.lineTo(corners[i].x, corners[i].y);
  }
  ctx.closePath();
  ctx.fill();

  // 3. İç Pah (Inner Bevel) Işık ve Gölge Çizgileri
  // Üst 3 Kenar (Işık Yansıması)
  ctx.strokeStyle = "rgba(255, 255, 255, 0.18)";
  ctx.lineWidth = 1.4;
  ctx.beginPath();
  ctx.moveTo(corners[5].x, corners[5].y);
  ctx.lineTo(corners[0].x, corners[0].y);
  ctx.lineTo(corners[1].x, corners[1].y);
  ctx.lineTo(corners[2].x, corners[2].y);
  ctx.stroke();

  // Alt 3 Kenar (Gölge Yansıması)
  ctx.strokeStyle = "rgba(0, 0, 0, 0.25)";
  ctx.lineWidth = 1.4;
  ctx.beginPath();
  ctx.moveTo(corners[2].x, corners[2].y);
  ctx.lineTo(corners[3].x, corners[3].y);
  ctx.lineTo(corners[4].x, corners[4].y);
  ctx.lineTo(corners[5].x, corners[5].y);
  ctx.stroke();

  // 4. Neo-Brutalist Dış Karo Kenarlık Çizgisi
  ctx.strokeStyle = isDiscovered ? "#38bdf8" : (tile.biome.borderColor || "#1e293b");
  ctx.lineWidth = isDiscovered ? 2.6 : 1.8;
  ctx.beginPath();
  ctx.moveTo(corners[0].x, corners[0].y);
  for (let i = 1; i < 6; i++) {
    ctx.lineTo(corners[i].x, corners[i].y);
  }
  ctx.closePath();
  ctx.stroke();

  // 5. Biyom Detayları (Bina yoksa)
  if (!tile.building) {
    if (tile.hasRuins) {
      drawIsometricRuins(animWindTime);
    } else if (tile.biome === BIOMES.FOREST) {
      drawIsometricForest(animWindTime);
    } else if (tile.biome === BIOMES.MOUNTAIN) {
      drawIsometricMountain();
    } else if (tile.biome === BIOMES.MEADOW) {
      drawIsometricMeadow(animWindTime);
    } else if (tile.biome === BIOMES.SEA) {
      drawIsometricSea(animWindTime);
    } else if (tile.biome === BIOMES.SNOW_PEAK) {
      drawIsometricSnowPeak(animWindTime);
    } else if (tile.biome === BIOMES.DESERT_OASIS) {
      drawIsometricDesertOasis(animWindTime);
    } else if (tile.biome === BIOMES.WONDER) {
      drawIsometricWonder(animWindTime);
    } else if (tile.biome === BIOMES.CAVERN || tile.biome === BIOMES.MAGMA || tile.biome === BIOMES.CRYSTAL) {
      drawIsometricUndergroundCavern(tile, animWindTime);
    }
  } else {
    // 6. 3D Monolitik Bozkır Mimarisi Yapıları
    drawBuilding(tile.building, animWindTime);
  }

  // 6b. Aktif Rastgele Olay (Kervan veya Şaman)
  if (game.activeEncounter && game.activeEncounter.q === tile.q && game.activeEncounter.r === tile.r) {
    if (game.activeEncounter.type === "trader") {
      drawIsometricCaravan(animWindTime);
    } else if (game.activeEncounter.type === "shaman") {
      drawIsometricShaman(animWindTime);
    }
  }

  // 7. Aktif Hazine Sandığı (Canlı Bouncing & Parıltılı Altın Aura)
  const hasChest = (game.activeChests && game.activeChests.some(c => c.q === tile.q && c.r === tile.r));
  if (hasChest) {
    const bounce = Math.sin(animWindTime * 4.5) * 4.5;
    ctx.save();
    ctx.fillStyle = "rgba(245, 158, 11, 0.45)";
    ctx.beginPath();
    ctx.arc(0, -18 * Y_SCALE + bounce, 18, 0, Math.PI * 2);
    ctx.fill();

    ctx.font = "20px Outfit, sans-serif";
    ctx.textAlign = "center";
    ctx.fillText("🎁", 0, -10 * Y_SCALE + bounce);
    ctx.restore();
  }

  // 8. Keşif Bekleyen Parlayan Göktürk Pusulası / Tamga
  if (isDiscovered) {
    const floatCompass = Math.sin(animWindTime * 3.5) * 2.0;
    const pulseGlow = Math.sin(animWindTime * 4.0) * 0.2 + 0.8;

    ctx.save();
    ctx.translate(0, floatCompass);

    // Dış Pusula Halkası
    ctx.strokeStyle = `rgba(56, 189, 248, ${0.45 * pulseGlow})`;
    ctx.lineWidth = 1.4;
    ctx.beginPath();
    ctx.ellipse(0, 0, 16, 10 * Y_SCALE, 0, 0, Math.PI * 2);
    ctx.stroke();

    // Altın Göktürk Artı Tamgası
    ctx.strokeStyle = "#fef08a";
    ctx.lineWidth = 2.4;
    ctx.beginPath();
    ctx.moveTo(-7, 0);
    ctx.lineTo(7, 0);
    ctx.moveTo(0, -7 * Y_SCALE);
    ctx.lineTo(0, 7 * Y_SCALE);
    ctx.stroke();

    // Merkez Noktası
    ctx.fillStyle = "#38bdf8";
    ctx.beginPath();
    ctx.arc(0, 0, 2.0, 0, Math.PI * 2);
    ctx.fill();

    ctx.restore();
  }

  ctx.restore();
}

// ❄️ 3D Yontma Karlı Altay Zirvesi (Snow Peak Biome)
function drawIsometricSnowPeak(time) {
  const peaks = [
    { x: -16, y: 10 * Y_SCALE,  w: 36, h: 42 * Y_SCALE },
    { x: 14,  y: -4 * Y_SCALE,  w: 42, h: 50 * Y_SCALE },
    { x: -4,  y: -22 * Y_SCALE, w: 30, h: 36 * Y_SCALE }
  ];
  peaks.sort((a, b) => a.y - b.y);

  peaks.forEach(p => {
    // 1. Düşen Buzul Gölgesi
    ctx.fillStyle = "rgba(0, 0, 0, 0.38)";
    ctx.beginPath();
    ctx.ellipse(p.x + 8, p.y + 4, p.w * 0.6, p.w * 0.25 * Y_SCALE, Math.PI / 8, 0, Math.PI * 2);
    ctx.fill();

    // 2. Sol Yüz (Işıltılı Karlı Yamaç)
    ctx.fillStyle = "#cbd5e1";
    ctx.beginPath();
    ctx.moveTo(p.x - p.w / 2, p.y);
    ctx.lineTo(p.x, p.y + p.w * 0.18 * Y_SCALE);
    ctx.lineTo(p.x, p.y - p.h);
    ctx.closePath();
    ctx.fill();

    // 3. Sağ Yüz (Buzul Mavi Gölge)
    ctx.fillStyle = "#475569";
    ctx.beginPath();
    ctx.moveTo(p.x, p.y + p.w * 0.18 * Y_SCALE);
    ctx.lineTo(p.x + p.w / 2, p.y);
    ctx.lineTo(p.x, p.y - p.h);
    ctx.closePath();
    ctx.fill();

    // 4. Saf Kar Zirvesi
    const sH = p.h * 0.55;
    ctx.fillStyle = "#ffffff";
    ctx.beginPath();
    ctx.moveTo(p.x - p.w * 0.25, p.y - p.h + sH);
    ctx.lineTo(p.x, p.y - p.h + sH);
    ctx.lineTo(p.x, p.y - p.h);
    ctx.closePath();
    ctx.fill();

    ctx.fillStyle = "#93c5fd";
    ctx.beginPath();
    ctx.moveTo(p.x, p.y - p.h + sH);
    ctx.lineTo(p.x + p.w * 0.25, p.y - p.h + sH);
    ctx.lineTo(p.x, p.y - p.h);
    ctx.closePath();
    ctx.fill();

    // Buz Kristali Parıltısı
    const shimmer = Math.sin(time * 3.5 + p.x) * 0.4 + 0.6;
    ctx.fillStyle = `rgba(224, 242, 254, ${shimmer})`;
    ctx.beginPath();
    ctx.arc(p.x, p.y - p.h * 0.8, 1.8, 0, Math.PI * 2);
    ctx.fill();
  });
}

// 🏜️ Taklamakan & Gobi Çöl Vahası (Desert Oasis Biome)
function drawIsometricDesertOasis(time) {
  // 1. Kum Tepesi Kıvrımları
  ctx.fillStyle = "#b45309";
  ctx.beginPath();
  ctx.ellipse(-12, -8 * Y_SCALE, 20, 9 * Y_SCALE, -Math.PI / 12, 0, Math.PI * 2);
  ctx.fill();

  ctx.fillStyle = "#f59e0b";
  ctx.beginPath();
  ctx.ellipse(10, 8 * Y_SCALE, 22, 10 * Y_SCALE, Math.PI / 12, 0, Math.PI * 2);
  ctx.fill();

  // 2. Turkuaz Vaha Kaynağı (Oasis Spring Water)
  ctx.fillStyle = "#0284c7";
  ctx.beginPath();
  ctx.ellipse(0, 0, 16, 8 * Y_SCALE, 0, 0, Math.PI * 2);
  ctx.fill();

  ctx.fillStyle = "#38bdf8";
  ctx.beginPath();
  ctx.ellipse(0, 0, 11, 5 * Y_SCALE, 0, 0, Math.PI * 2);
  ctx.fill();

  // 3. Palmiye Ağaçları (Palm Trees)
  const palms = [
    { x: -14, y: -2 * Y_SCALE, sc: 1.0, lean: -0.2 },
    { x: 12,  y: -6 * Y_SCALE, sc: 0.85, lean: 0.25 }
  ];

  palms.forEach(plm => {
    // Gövde
    ctx.strokeStyle = "#78350f";
    ctx.lineWidth = 3.5 * plm.sc;
    ctx.beginPath();
    ctx.moveTo(plm.x, plm.y);
    ctx.quadraticCurveTo(plm.x + 8 * plm.lean, plm.y - 12 * plm.sc * Y_SCALE, plm.x + 12 * plm.lean, plm.y - 24 * plm.sc * Y_SCALE);
    ctx.stroke();

    const topX = plm.x + 12 * plm.lean;
    const topY = plm.y - 24 * plm.sc * Y_SCALE;
    const sway = Math.sin(time * 2.5 + plm.x) * 1.5;

    // Palmiye Yaprakları
    for (let a = 0; a < 5; a++) {
      const angle = (a / 5) * Math.PI * 2;
      const lx = topX + Math.cos(angle) * (14 * plm.sc) + sway;
      const ly = topY + Math.sin(angle) * (7 * plm.sc * Y_SCALE);
      ctx.beginPath();
      ctx.moveTo(topX, topY);
      ctx.quadraticCurveTo(topX + Math.cos(angle) * 8, topY - 5, lx, ly);
      ctx.lineWidth = 2.0;
      ctx.strokeStyle = "#16a34a";
      ctx.stroke();
    }
  });

  // 4. Kadim Taş Su Kuyusu
  ctx.fillStyle = "#334155";
  ctx.fillRect(-4, 6 * Y_SCALE, 8, 6 * Y_SCALE);
  ctx.fillStyle = "#0f172a";
  ctx.beginPath();
  ctx.arc(0, 6 * Y_SCALE, 3, 0, Math.PI * 2);
  ctx.fill();
}

// 🏛️ Orhun Kitabeleri & Kutlu Kurt Doğa Harikası (World Wonder)
function drawIsometricWonder(time) {
  // 1. Kutsal Aura (Point-Light Glow)
  const auraPulse = Math.sin(time * 2.5) * 0.15 + 0.35;
  ctx.fillStyle = `rgba(6, 182, 212, ${auraPulse})`;
  ctx.beginPath();
  ctx.ellipse(0, 0, 32, 18 * Y_SCALE, 0, 0, Math.PI * 2);
  ctx.fill();

  // 2. Taş Kaide (Stepped Stone Platform)
  ctx.fillStyle = "#1e293b";
  ctx.fillRect(-22, -6 * Y_SCALE, 44, 12 * Y_SCALE);
  ctx.fillStyle = "#334155";
  ctx.fillRect(-18, -10 * Y_SCALE, 36, 8 * Y_SCALE);

  // 3. Orhun Dikilitaşı (Ancient Göktürk Monolith)
  const monW = 14;
  const monH = 38 * Y_SCALE;
  ctx.fillStyle = "#475569";
  ctx.fillRect(-monW / 2, -monH, monW, monH);

  // Taşın Ucu (Sivri Üst)
  ctx.fillStyle = "#64748b";
  ctx.beginPath();
  ctx.moveTo(-monW / 2, -monH);
  ctx.lineTo(0, -monH - 8 * Y_SCALE);
  ctx.lineTo(monW / 2, -monH);
  ctx.closePath();
  ctx.fill();

  // 4. Parlayan Turkuaz Göktürk Runikleri (𐰋 𐰃 𐰠 𐰏 𐰀)
  ctx.font = "8px 'JetBrains Mono', monospace";
  ctx.textAlign = "center";
  const runeGlow = Math.sin(time * 3.0) * 0.3 + 0.7;
  ctx.fillStyle = `rgba(56, 189, 248, ${runeGlow})`;
  ctx.fillText("𐰋", 0, -monH * 0.7);
  ctx.fillText("𐱅", 0, -monH * 0.45);
  ctx.fillText("𐰼", 0, -monH * 0.2);

  // 5. Muhafız Balbal Heykelleri (2 Yan Balbal)
  [-14, 14].forEach(bx => {
    ctx.fillStyle = "#334155";
    ctx.fillRect(bx - 3, -12 * Y_SCALE, 6, 12 * Y_SCALE);
    ctx.fillStyle = "#64748b";
    ctx.beginPath();
    ctx.arc(bx, -14 * Y_SCALE, 3.5, 0, Math.PI * 2);
    ctx.fill();
  });

  // 6. Kutsal Meşaleler
  [-20, 20].forEach(fx => {
    ctx.fillStyle = "#78350f";
    ctx.fillRect(fx - 1.5, -8 * Y_SCALE, 3, 8 * Y_SCALE);
    const flame = Math.sin(time * 8.0 + fx) * 1.5;
    ctx.fillStyle = "#f59e0b";
    ctx.beginPath();
    ctx.arc(fx, -10 * Y_SCALE + flame, 3, 0, Math.PI * 2);
    ctx.fill();
  });
}

// 🌋 Ergenekon Yeraltı Mağarası & Dökümhane (Underground Cavern Renderer)
function drawIsometricUndergroundCavern(tile, time) {
  if (tile.biome === BIOMES.MAGMA) {
    // Akan Lav Nehri
    const lavaFlow = Math.sin(time * 2.0) * 2.0;
    ctx.fillStyle = "#c2410c";
    ctx.beginPath();
    ctx.ellipse(0, 0, 26, 14 * Y_SCALE, 0, 0, Math.PI * 2);
    ctx.fill();
    ctx.fillStyle = "#f97316";
    ctx.beginPath();
    ctx.ellipse(lavaFlow, 0, 18, 9 * Y_SCALE, 0, 0, Math.PI * 2);
    ctx.fill();
    ctx.fillStyle = "#fef08a";
    ctx.beginPath();
    ctx.ellipse(-lavaFlow, 0, 10, 4 * Y_SCALE, 0, 0, Math.PI * 2);
    ctx.fill();
  } else if (tile.biome === BIOMES.CRYSTAL) {
    // Parlayan Obsidiyen & Kristal Kümeleri
    const crystals = [
      { x: -10, y: -6 * Y_SCALE, h: 22 * Y_SCALE },
      { x: 4,   y: -10 * Y_SCALE, h: 26 * Y_SCALE },
      { x: 12,  y: 4 * Y_SCALE,  h: 18 * Y_SCALE }
    ];
    crystals.forEach(c => {
      ctx.fillStyle = "#0284c7";
      ctx.beginPath();
      ctx.moveTo(c.x - 4, c.y);
      ctx.lineTo(c.x, c.y - c.h);
      ctx.lineTo(c.x + 4, c.y);
      ctx.closePath();
      ctx.fill();
      ctx.fillStyle = "#38bdf8";
      ctx.beginPath();
      ctx.moveTo(c.x, c.y);
      ctx.lineTo(c.x, c.y - c.h);
      ctx.lineTo(c.x + 4, c.y);
      ctx.closePath();
      ctx.fill();
    });
  } else {
    // Bazalt Dikitleri (Stalagmites)
    ctx.fillStyle = "#27272a";
    ctx.beginPath();
    ctx.moveTo(-12, 6 * Y_SCALE);
    ctx.lineTo(-8, -14 * Y_SCALE);
    ctx.lineTo(-4, 6 * Y_SCALE);
    ctx.fill();
    ctx.moveTo(6, 4 * Y_SCALE);
    ctx.lineTo(10, -16 * Y_SCALE);
    ctx.lineTo(14, 4 * Y_SCALE);
    ctx.fill();
  }
}

// 🌋 Ergenekon Kadim Döküm Ocağı (Underground Master Blast Forge)
function drawIsometricUndergroundForge(b, time) {
  // 1. Zemin Döküm Ateşi Aurası
  const forgeGlow = Math.sin(time * 6.0) * 0.15 + 0.55;
  ctx.fillStyle = `rgba(234, 88, 12, ${forgeGlow})`;
  ctx.beginPath();
  ctx.ellipse(0, 0, 32, 18 * Y_SCALE, 0, 0, Math.PI * 2);
  ctx.fill();

  // 2. Taş Fırın Bloğu (Heavy Basalt Base)
  ctx.fillStyle = "#18181b";
  ctx.fillRect(-22, -12 * Y_SCALE, 44, 20 * Y_SCALE);
  ctx.fillStyle = "#27272a";
  ctx.fillRect(-18, -16 * Y_SCALE, 36, 10 * Y_SCALE);

  // 3. Kor Ateşli Döküm Haznesi (Molten Crucible Opening)
  ctx.fillStyle = "#ea580c";
  ctx.beginPath();
  ctx.arc(0, -6 * Y_SCALE, 10, 0, Math.PI * 2);
  ctx.fill();
  ctx.fillStyle = "#fef08a";
  ctx.beginPath();
  ctx.arc(0, -6 * Y_SCALE, 6, 0, Math.PI * 2);
  ctx.fill();

  // 4. Çift Döküm Bacası (Twin Chimneys with Lava Smoke)
  [-12, 12].forEach(cx => {
    ctx.fillStyle = "#3f3f46";
    ctx.fillRect(cx - 4, -32 * Y_SCALE, 8, 22 * Y_SCALE);
    // Kıvılcım Parçacıkları
    const spark = Math.sin(time * 10.0 + cx) * 2.0;
    ctx.fillStyle = "#f59e0b";
    ctx.beginPath();
    ctx.arc(cx + spark, -34 * Y_SCALE, 2.5, 0, Math.PI * 2);
    ctx.fill();
  });

  // 5. Demir Örs & Balyoz
  ctx.fillStyle = "#71717a";
  ctx.fillRect(-6, 2 * Y_SCALE, 12, 5 * Y_SCALE);
}

// 💠 Obsidiyen & Kristal Madeni (Underground Crystal Extractor)
function drawIsometricCrystalMine(b, time) {
  // 1. Zemin Kristal Parıltısı
  const aura = Math.sin(time * 4.0) * 0.2 + 0.4;
  ctx.fillStyle = `rgba(56, 189, 248, ${aura})`;
  ctx.beginPath();
  ctx.ellipse(0, 0, 26, 14 * Y_SCALE, 0, 0, Math.PI * 2);
  ctx.fill();

  // 2. Maden Giriş Portali
  ctx.fillStyle = "#0f172a";
  ctx.fillRect(-14, -12 * Y_SCALE, 28, 18 * Y_SCALE);
  ctx.strokeStyle = "#0284c7";
  ctx.lineWidth = 2.0;
  ctx.strokeRect(-14, -12 * Y_SCALE, 28, 18 * Y_SCALE);

  // 3. Büyük Parlayan Kristal Sütunu
  const crH = 26 * Y_SCALE;
  ctx.fillStyle = "#0284c7";
  ctx.beginPath();
  ctx.moveTo(-6, 0); ctx.lineTo(0, -crH); ctx.lineTo(6, 0); ctx.closePath();
  ctx.fill();
  ctx.fillStyle = "#7dd3fc";
  ctx.beginPath();
  ctx.moveTo(0, 0); ctx.lineTo(0, -crH); ctx.lineTo(6, 0); ctx.closePath();
  ctx.fill();
}

// 🐎 Yollarda Yürüyen Yüklü Kervan Katırları (Pack Mules on Trade Roads)
function drawPackMules(time) {
  if (!game.packMules || game.packMules.length === 0) return;

  game.packMules.forEach(m => {
    ctx.save();
    ctx.translate(m.x, m.y);
    ctx.scale(m.facing || 1, 1);

    const bob = Math.sin(time * 8.0) * 1.5;

    // Gölge
    ctx.fillStyle = "rgba(0,0,0,0.25)";
    ctx.beginPath();
    ctx.ellipse(0, 0, 8, 4 * Y_SCALE, 0, 0, Math.PI * 2);
    ctx.fill();

    // Katır Gövdesi
    ctx.fillStyle = "#57534e";
    ctx.beginPath();
    ctx.ellipse(0, -6 * Y_SCALE + bob, 7, 4 * Y_SCALE, 0, 0, Math.PI * 2);
    ctx.fill();

    // Katır Başı
    ctx.fillStyle = "#44403c";
    ctx.beginPath();
    ctx.arc(6, -8 * Y_SCALE + bob, 3, 0, Math.PI * 2);
    ctx.fill();

    // Heybeler & Yük Çuvalları
    ctx.fillStyle = "#d97706";
    ctx.fillRect(-3, -9 * Y_SCALE + bob, 6, 4 * Y_SCALE);
    ctx.strokeStyle = "#78350f";
    ctx.lineWidth = 1.0;
    ctx.strokeRect(-3, -9 * Y_SCALE + bob, 6, 4 * Y_SCALE);

    ctx.restore();
  });
}

// =============================================================================
// OTLAYAN KOYUN & BOZKIR ATI SÜRÜLERİ (ROAMING HERDS)
// =============================================================================

function drawRoamingHerds(time) {
  roamingHerds.forEach(h => {
    ctx.save();
    ctx.translate(h.x, h.y);
    ctx.scale(h.facing, 1);

    if (h.type === "sheep") {
      // 🐑 Bozkır Ak Koyunu (Steppe Sheep)
      const bob = h.isMoving ? Math.sin(h.animTime * 8.0) * 1.5 : Math.sin(h.animTime * 2.0) * 0.5;
      // Gölge
      ctx.fillStyle = "rgba(0,0,0,0.25)";
      ctx.beginPath();
      ctx.ellipse(0, 0, 7, 3.5 * Y_SCALE, 0, 0, Math.PI * 2);
      ctx.fill();

      // Gövde (Beyaz Yünlü Top)
      ctx.fillStyle = "#f8fafc";
      ctx.beginPath();
      ctx.ellipse(0, -5 * Y_SCALE + bob, 6.5, 4.5 * Y_SCALE, 0, 0, Math.PI * 2);
      ctx.fill();

      // Baş (Siyah Bozkır Koyunu Yüzü)
      ctx.fillStyle = "#334155";
      ctx.beginPath();
      ctx.arc(5, -6 * Y_SCALE + bob, 2.5, 0, Math.PI * 2);
      ctx.fill();

      // Bacaklar
      ctx.strokeStyle = "#1e293b";
      ctx.lineWidth = 1.2;
      const legWalk = h.isMoving ? Math.sin(h.animTime * 8.0) * 2.0 : 0;
      ctx.beginPath();
      ctx.moveTo(-3, -2 * Y_SCALE + bob); ctx.lineTo(-3 + legWalk, 0);
      ctx.moveTo(2, -2 * Y_SCALE + bob);  ctx.lineTo(2 - legWalk, 0);
      ctx.stroke();
    } else {
      // 🐎 Yılkı Atı (Wild Steppe Horse)
      const gallop = h.isMoving ? Math.sin(h.animTime * 10.0) * 2.5 : Math.sin(h.animTime * 1.5) * 0.8;
      // Gölge
      ctx.fillStyle = "rgba(0,0,0,0.3)";
      ctx.beginPath();
      ctx.ellipse(0, 0, 11, 5 * Y_SCALE, 0, 0, Math.PI * 2);
      ctx.fill();

      // Gövde (Kestane Rengi At)
      ctx.fillStyle = "#78350f";
      ctx.beginPath();
      ctx.ellipse(0, -8 * Y_SCALE + gallop, 9, 5 * Y_SCALE, 0, 0, Math.PI * 2);
      ctx.fill();

      // Boyun ve Baş
      ctx.fillStyle = "#92400e";
      ctx.beginPath();
      ctx.moveTo(4, -9 * Y_SCALE + gallop);
      ctx.lineTo(9, -15 * Y_SCALE + gallop);
      ctx.lineTo(13, -13 * Y_SCALE + gallop);
      ctx.lineTo(7, -6 * Y_SCALE + gallop);
      ctx.closePath();
      ctx.fill();

      // Yele
      ctx.fillStyle = "#1e293b";
      ctx.fillRect(5, -15 * Y_SCALE + gallop, 3, 7 * Y_SCALE);
      // Kuyruk
      const tailSway = Math.sin(time * 5.0) * 2.0;
      ctx.beginPath();
      ctx.moveTo(-8, -9 * Y_SCALE + gallop);
      ctx.quadraticCurveTo(-14, -7 * Y_SCALE + gallop + tailSway, -12, -2 * Y_SCALE);
      ctx.lineWidth = 1.8;
      ctx.strokeStyle = "#1e293b";
      ctx.stroke();

      // Bacaklar
      ctx.strokeStyle = "#451a03";
      ctx.lineWidth = 1.6;
      const legA = h.isMoving ? Math.sin(h.animTime * 10.0) * 4.0 : 0;
      ctx.beginPath();
      ctx.moveTo(-5, -4 * Y_SCALE + gallop); ctx.lineTo(-5 + legA, 0);
      ctx.moveTo(5, -4 * Y_SCALE + gallop);  ctx.lineTo(5 - legA, 0);
      ctx.stroke();
    }

    ctx.restore();
  });
}

// 🌲 3D İzometrik Ötüken Çam & Huş Korusu
function drawIsometricForest(time) {
  const trees = [
    { x: -24, y: -16 * Y_SCALE, sc: 0.90, type: "pine" },
    { x: 18,  y: -22 * Y_SCALE, sc: 0.95, type: "birch" },
    { x: -2,  y: -28 * Y_SCALE, sc: 0.85, type: "pine" },
    { x: -12, y: -2 * Y_SCALE,  sc: 1.18, type: "pine" },
    { x: 22,  y: 4 * Y_SCALE,   sc: 1.08, type: "pine" },
    { x: -26, y: 14 * Y_SCALE,  sc: 0.92, type: "birch" },
    { x: 4,   y: 18 * Y_SCALE,  sc: 1.15, type: "pine" }
  ];
  trees.sort((a, b) => a.y - b.y);

  trees.forEach(tr => {
    const sway = Math.sin(time * 2.5 + tr.x * 0.1 + tr.y * 0.2) * (1.8 * tr.sc);

    // 1. Zemin 45° İzometrik Gölgesi
    ctx.fillStyle = "rgba(0, 0, 0, 0.32)";
    ctx.beginPath();
    ctx.ellipse(tr.x + 4, tr.y + 2, 11 * tr.sc, 5 * tr.sc * Y_SCALE, Math.PI / 10, 0, Math.PI * 2);
    ctx.fill();

    if (tr.type === "birch") {
      // Bozkır Huş Ağacı (Beyaz Gövde)
      const tw = 3.5 * tr.sc;
      const th = 12 * tr.sc * Y_SCALE;
      ctx.fillStyle = "#f1f5f9";
      ctx.fillRect(tr.x - tw / 2, tr.y - th, tw, th);
      ctx.fillStyle = "#334155";
      ctx.fillRect(tr.x - tw / 2, tr.y - th * 0.5, tw, 1.5);

      // Yuvarlak Huş Tacı
      ctx.fillStyle = "#15803d";
      ctx.beginPath();
      ctx.arc(tr.x + sway, tr.y - th - 6 * tr.sc * Y_SCALE, 11 * tr.sc, 0, Math.PI * 2);
      ctx.fill();
      ctx.fillStyle = "#22c55e";
      ctx.beginPath();
      ctx.arc(tr.x - 3 + sway, tr.y - th - 8 * tr.sc * Y_SCALE, 7 * tr.sc, 0, Math.PI * 2);
      ctx.fill();
    } else {
      // Ötüken Karaçamı (Ahşap Gövde)
      const tw = 4.2 * tr.sc;
      const th = 9 * tr.sc * Y_SCALE;
      ctx.fillStyle = "#451a03";
      ctx.fillRect(tr.x - tw / 2, tr.y - th, tw, th);

      // 3 Kademeli Hacimli Çam Konileri (Sol Yüz Işık, Sağ Yüz Gölge)
      const tiers = [
        { y: tr.y - 6 * tr.sc * Y_SCALE, w: 18 * tr.sc, h: 14 * tr.sc * Y_SCALE, sw: sway * 0.3 },
        { y: tr.y - 14 * tr.sc * Y_SCALE, w: 14 * tr.sc, h: 13 * tr.sc * Y_SCALE, sw: sway * 0.6 },
        { y: tr.y - 22 * tr.sc * Y_SCALE, w: 9 * tr.sc,  h: 12 * tr.sc * Y_SCALE, sw: sway * 1.0 }
      ];

      tiers.forEach(t => {
        // Sol Yüz (Işık Alan)
        ctx.fillStyle = "#16a34a";
        ctx.beginPath();
        ctx.moveTo(tr.x - t.w / 2, t.y);
        ctx.lineTo(tr.x, t.y + t.w * 0.15 * Y_SCALE);
        ctx.lineTo(tr.x + t.sw, t.y - t.h);
        ctx.closePath();
        ctx.fill();

        // Sağ Yüz (Gölgede Kalan)
        ctx.fillStyle = "#064e3b";
        ctx.beginPath();
        ctx.moveTo(tr.x, t.y + t.w * 0.15 * Y_SCALE);
        ctx.lineTo(tr.x + t.w / 2, t.y);
        ctx.lineTo(tr.x + t.sw, t.y - t.h);
        ctx.closePath();
        ctx.fill();
      });
    }
  });
}

// 🏔️ 3D Yontma Karlı Altay Dağ Zirveleri
function drawIsometricMountain() {
  const peaks = [
    { x: -14, y: 8 * Y_SCALE,   w: 34, h: 36 * Y_SCALE },
    { x: 16,  y: -6 * Y_SCALE,  w: 38, h: 44 * Y_SCALE },
    { x: -2,  y: -20 * Y_SCALE, w: 28, h: 30 * Y_SCALE }
  ];
  peaks.sort((a, b) => a.y - b.y);

  peaks.forEach(p => {
    // 1. Zemin Düşen Gölge
    ctx.fillStyle = "rgba(0, 0, 0, 0.35)";
    ctx.beginPath();
    ctx.ellipse(p.x + 8, p.y + 4, p.w * 0.6, p.w * 0.25 * Y_SCALE, Math.PI / 8, 0, Math.PI * 2);
    ctx.fill();

    // 2. Sol Yüz (Güneş Işığı Alan Sıcak Granit)
    ctx.fillStyle = "#78716c";
    ctx.beginPath();
    ctx.moveTo(p.x - p.w / 2, p.y);
    ctx.lineTo(p.x, p.y + p.w * 0.18 * Y_SCALE);
    ctx.lineTo(p.x, p.y - p.h);
    ctx.closePath();
    ctx.fill();

    // 3. Sağ Yüz (Soğuk Bazalt Gölge)
    ctx.fillStyle = "#292524";
    ctx.beginPath();
    ctx.moveTo(p.x, p.y + p.w * 0.18 * Y_SCALE);
    ctx.lineTo(p.x + p.w / 2, p.y);
    ctx.lineTo(p.x, p.y - p.h);
    ctx.closePath();
    ctx.fill();

    // Sırt Çizgisi (Arête)
    ctx.strokeStyle = "#d6d3d1";
    ctx.lineWidth = 1.0;
    ctx.beginPath();
    ctx.moveTo(p.x, p.y + p.w * 0.18 * Y_SCALE);
    ctx.lineTo(p.x, p.y - p.h);
    ctx.stroke();

    // 4. Karlı Zirve & Buzul Gölgesi
    const sH = p.h * 0.38;
    // Sol Kar Yüzü (Saf Kar)
    ctx.fillStyle = "#ffffff";
    ctx.beginPath();
    ctx.moveTo(p.x - p.w * 0.20, p.y - p.h + sH);
    ctx.lineTo(p.x, p.y - p.h + sH);
    ctx.lineTo(p.x, p.y - p.h);
    ctx.closePath();
    ctx.fill();

    // Sağ Kar Yüzü (Mavi Buzul Gölgesi)
    ctx.fillStyle = "#bae6fd";
    ctx.beginPath();
    ctx.moveTo(p.x, p.y - p.h + sH);
    ctx.lineTo(p.x + p.w * 0.20, p.y - p.h + sH);
    ctx.lineTo(p.x, p.y - p.h);
    ctx.closePath();
    ctx.fill();
  });
}

// 🌸 Bozkır Çayırı (Rüzgarda Salınan Çimenler ve Taşlar)
function drawIsometricMeadow(time) {
  const spots = [
    { x: -20, y: -12 * Y_SCALE },
    { x: 18,  y: -14 * Y_SCALE },
    { x: -12, y: 14 * Y_SCALE },
    { x: 22,  y: 10 * Y_SCALE }
  ];
  spots.forEach(sp => {
    const sway = Math.sin(time * 2.5 + sp.x) * 1.5;
    ctx.strokeStyle = "#4ade80";
    ctx.lineWidth = 1.6;
    ctx.beginPath();
    ctx.moveTo(sp.x, sp.y);
    ctx.lineTo(sp.x - 2 + sway, sp.y - 7 * Y_SCALE);
    ctx.moveTo(sp.x, sp.y);
    ctx.lineTo(sp.x + 2 + sway, sp.y - 8 * Y_SCALE);
    ctx.stroke();

    ctx.fillStyle = "#fde047";
    ctx.beginPath();
    ctx.arc(sp.x + sway, sp.y - 9 * Y_SCALE, 1.8, 0, Math.PI * 2);
    ctx.fill();
  });

  // Küçük Çakıl Taşları
  ctx.fillStyle = "#64748b";
  ctx.beginPath();
  ctx.ellipse(-6, 4 * Y_SCALE, 3, 1.8 * Y_SCALE, 0, 0, Math.PI * 2);
  ctx.ellipse(8, -4 * Y_SCALE, 2.5, 1.5 * Y_SCALE, 0, 0, Math.PI * 2);
  ctx.fill();
}

// 🌊 Orhun / Baykal Suları (Saydam Dalgalar & Kıyı Köpüğü)
function drawIsometricSea(time) {
  const offset = Math.sin(time * 2.0) * 3.5;
  ctx.strokeStyle = "rgba(186, 230, 253, 0.65)";
  ctx.lineWidth = 2.0;
  ctx.beginPath();
  ctx.arc(-16 + offset, -8 * Y_SCALE, 10.0, 0.2, 2.8);
  ctx.stroke();
  ctx.beginPath();
  ctx.arc(14 - offset, 6 * Y_SCALE, 12.0, 0.2, 2.8);
  ctx.stroke();

  // Işıltılı Güneş Parıltısı (Specular Highlight)
  const shimmer = Math.sin(time * 4.0) * 0.4 + 0.6;
  ctx.fillStyle = `rgba(255, 255, 255, ${0.4 * shimmer})`;
  ctx.beginPath();
  ctx.ellipse(0, 0, 8, 3 * Y_SCALE, 0, 0, Math.PI * 2);
  ctx.fill();
}

// =============================================================================
// 3D MONOLİTİK BOZKIR VE GÖKTÜRK MİMARİSİ
// =============================================================================

function drawBuilding(b, time) {
  if (b.type === "castle") {
    drawIsometricCastle(b.level || game.castleLevel, time);
  } else if (b.type === "corn") {
    drawIsometricCornField(b, time);
  } else if (b.type === "windmill") {
    drawIsometricWindmill(b, time);
  } else if (b.type === "bakery") {
    drawIsometricBakery(b, time);
  } else if (b.type === "lumberjack") {
    drawIsometricLumberjack(b, time);
  } else if (b.type === "sawmill") {
    drawIsometricSawmill(b, time);
  } else if (b.type === "furniture") {
    drawIsometricFurnitureMaker(b, time);
  } else if (b.type === "quarry") {
    drawIsometricQuarry(b, time);
  } else if (b.type === "mine") {
    drawIsometricMine(b, time);
  } else if (b.type === "worker") {
    drawIsometricWorkerHut(b, time);
  } else if (b.type === "bridge") {
    drawIsometricBridge(b, time);
  } else if (b.type === "watchtower") {
    drawIsometricWatchtower(b, time);
  } else if (b.type === "underground_forge") {
    drawIsometricUndergroundForge(b, time);
  } else if (b.type === "crystal_mine") {
    drawIsometricCrystalMine(b, time);
  }
}

// 🌉 3D Ahşap Kazıklı ve Korkuluklu Köprü
function drawIsometricBridge(b, time) {
  ctx.fillStyle = "rgba(8, 28, 44, 0.45)";
  ctx.beginPath();
  ctx.ellipse(2, 3 * Y_SCALE, 28, 16 * Y_SCALE, 0, 0, Math.PI * 2);
  ctx.fill();

  const pillars = [
    { x: -22, y: -10 * Y_SCALE },
    { x: 22,  y: -10 * Y_SCALE },
    { x: -22, y: 10 * Y_SCALE },
    { x: 22,  y: 10 * Y_SCALE }
  ];
  pillars.forEach(p => {
    ctx.fillStyle = "#451a03";
    ctx.fillRect(p.x - 2.5, p.y - 6 * Y_SCALE, 5, 12 * Y_SCALE);
    ctx.strokeStyle = "rgba(186, 230, 253, 0.5)";
    ctx.lineWidth = 1.0;
    ctx.beginPath();
    ctx.arc(p.x, p.y + 6 * Y_SCALE, 3, 0, Math.PI * 2);
    ctx.stroke();
  });

  const numPlanks = 8;
  const bridgeW = 48;
  const bridgeH = 26 * Y_SCALE;

  for (let i = 0; i < numPlanks; i++) {
    const t = i / (numPlanks - 1);
    const xPos = -bridgeW * 0.5 + bridgeW * t;
    ctx.fillStyle = (i % 2 === 0) ? "#d4a373" : "#b07d4b";
    ctx.fillRect(xPos - 2.5, -bridgeH * 0.5, 4.5, bridgeH);
    ctx.strokeStyle = "#451a03";
    ctx.lineWidth = 0.8;
    ctx.strokeRect(xPos - 2.5, -bridgeH * 0.5, 4.5, bridgeH);
  }

  ctx.strokeStyle = "#451a03";
  ctx.lineWidth = 2.4;
  ctx.beginPath();
  ctx.moveTo(-bridgeW * 0.5, -bridgeH * 0.5 - 4 * Y_SCALE);
  ctx.lineTo(bridgeW * 0.5, -bridgeH * 0.5 - 4 * Y_SCALE);
  ctx.stroke();
  ctx.beginPath();
  ctx.moveTo(-bridgeW * 0.5, bridgeH * 0.5 - 1 * Y_SCALE);
  ctx.lineTo(bridgeW * 0.5, bridgeH * 0.5 - 1 * Y_SCALE);
  ctx.stroke();
}

// 🏰 3D Kağan Otağı (İmparatorluk Beyaz Keçe Çadırı, Altın Alem, At Yelesi Tuğ, Taş Kaide ve Meşaleler)
function drawIsometricCastle(level, time) {
  // 1. Zemin 45° Düşen Gölgesi
  ctx.fillStyle = "rgba(0, 0, 0, 0.42)";
  ctx.beginPath();
  ctx.ellipse(8, 8 * Y_SCALE, 48, 28 * Y_SCALE, Math.PI / 10, 0, Math.PI * 2);
  ctx.fill();

  // Zemin Taş Kaidesi
  ctx.fillStyle = "#334155";
  ctx.beginPath();
  ctx.ellipse(0, 3 * Y_SCALE, 42, 24 * Y_SCALE, 0, 0, Math.PI * 2);
  ctx.fill();
  ctx.fillStyle = "#475569";
  ctx.beginPath();
  ctx.ellipse(0, 0, 40, 22 * Y_SCALE, 0, 0, Math.PI * 2);
  ctx.fill();

  // 2. Beyaz Keçe Otağ Gövdesi (3D Silindirik Gradyan)
  const yw = 52;
  const yh = 22 * Y_SCALE;

  const yurtGrad = ctx.createLinearGradient(-yw * 0.5, 0, yw * 0.5, 0);
  yurtGrad.addColorStop(0, "#f8fafc");
  yurtGrad.addColorStop(0.5, "#e2e8f0");
  yurtGrad.addColorStop(1, "#94a3b8");

  ctx.fillStyle = yurtGrad;
  ctx.fillRect(-yw * 0.5, -yh, yw, yh);

  // Otağ Gövdesinde Göktürk İşleme Kuşağı
  ctx.fillStyle = "#991b1b";
  ctx.fillRect(-yw * 0.5, -yh * 0.65, yw, 4.5 * Y_SCALE);
  ctx.fillStyle = "#f59e0b";
  ctx.font = "bold 8px monospace";
  ctx.textAlign = "center";
  ctx.fillText("𐰋 𐱅 𐰼 𐰇", 0, -yh * 0.65 + 4 * Y_SCALE);

  // 3. Konik Kubbe Çatısı (Dome with Golden Alem)
  const domeH = 28 * Y_SCALE;
  const domeGrad = ctx.createLinearGradient(-yw * 0.5, -yh, yw * 0.5, -yh);
  domeGrad.addColorStop(0, "#f8fafc");
  domeGrad.addColorStop(0.6, "#cbd5e1");
  domeGrad.addColorStop(1, "#64748b");

  ctx.fillStyle = domeGrad;
  ctx.beginPath();
  ctx.moveTo(-yw * 0.5, -yh);
  ctx.quadraticCurveTo(0, -yh - domeH * 1.2, yw * 0.5, -yh);
  ctx.closePath();
  ctx.fill();

  // Kubbe Şangırak Açıklığı
  ctx.fillStyle = "#d97706";
  ctx.beginPath();
  ctx.ellipse(0, -yh - domeH, 10, 5.5 * Y_SCALE, 0, 0, Math.PI * 2);
  ctx.fill();

  // Altın Alem
  ctx.fillStyle = "#f59e0b";
  ctx.beginPath();
  ctx.arc(0, -yh - domeH - 4.5 * Y_SCALE, 4.5, 0, Math.PI * 2);
  ctx.fill();

  // 4. Otağ Kapısı (Oymalı Ahşap)
  ctx.fillStyle = "#1e293b";
  ctx.fillRect(-7, -12 * Y_SCALE, 14, 12 * Y_SCALE);
  ctx.fillStyle = "#78350f";
  ctx.fillRect(-6, -11 * Y_SCALE, 12, 11 * Y_SCALE);
  ctx.strokeStyle = "#f59e0b";
  ctx.lineWidth = 1.2;
  ctx.strokeRect(-6, -11 * Y_SCALE, 12, 11 * Y_SCALE);

  // Kapı Halkası
  ctx.fillStyle = "#f59e0b";
  ctx.beginPath();
  ctx.arc(3, -5 * Y_SCALE, 1.8, 0, Math.PI * 2);
  ctx.fill();

  // 5. At Yelesi Tuğ
  const tuX = 26;
  const tuY = 0;
  ctx.strokeStyle = "#94a3b8";
  ctx.lineWidth = 2.2;
  ctx.beginPath();
  ctx.moveTo(tuX, tuY);
  ctx.lineTo(tuX, tuY - 40 * Y_SCALE);
  ctx.stroke();

  ctx.fillStyle = "#f59e0b";
  ctx.beginPath();
  ctx.arc(tuX, tuY - 40 * Y_SCALE, 4.0, 0, Math.PI * 2);
  ctx.fill();

  const tuSway = Math.sin(time * 4.0) * 3.5;
  ctx.fillStyle = "#0f172a";
  ctx.beginPath();
  ctx.moveTo(tuX, tuY - 38 * Y_SCALE);
  ctx.quadraticCurveTo(tuX + 7 + tuSway, tuY - 26 * Y_SCALE, tuX + 4 + tuSway, tuY - 18 * Y_SCALE);
  ctx.lineTo(tuX - 1, tuY - 38 * Y_SCALE);
  ctx.closePath();
  ctx.fill();

  // 6. Çift Taş Meşale
  const braziers = [-26, 26];
  braziers.forEach(bx => {
    ctx.fillStyle = "#334155";
    ctx.fillRect(bx - 3.5, -6 * Y_SCALE, 7, 6 * Y_SCALE);
    
    const fSize = 4.0 + Math.sin(time * 6.5 + bx) * 1.5;
    ctx.fillStyle = "#f97316";
    ctx.beginPath();
    ctx.arc(bx, -8 * Y_SCALE, fSize, 0, Math.PI * 2);
    ctx.fill();
    ctx.fillStyle = "#fef08a";
    ctx.beginPath();
    ctx.arc(bx, -8 * Y_SCALE, fSize * 0.55, 0, Math.PI * 2);
    ctx.fill();
  });

  if (level >= 2) {
    ctx.fillStyle = "#f59e0b";
    ctx.font = "bold 14px Outfit, sans-serif";
    ctx.textAlign = "center";
    ctx.fillText("👑", 0, -yh - domeH - 12 * Y_SCALE);
  }
}

// 🌽 3D Bozkır Bostanı (Rüzgarda Salınan Mısırlar, Ahşap Çit & Minik Çiftçi)
function drawIsometricCornField(b, time) {
  // 1. Zemin Düşen Gölgesi
  ctx.fillStyle = "rgba(0, 0, 0, 0.28)";
  ctx.beginPath();
  ctx.ellipse(4, 4 * Y_SCALE, 44, 26 * Y_SCALE, 0, 0, Math.PI * 2);
  ctx.fill();

  // 2. Sürülmüş Koyu Verimli Toprak Karıkları
  const ridges = 5;
  const rWidth = 48;
  const rDepth = 34 * Y_SCALE;

  for (let i = 0; i < ridges; i++) {
    const t = i / (ridges - 1);
    const zOffset = (-rDepth * 0.5) + (rDepth * t);

    ctx.strokeStyle = "#27160c";
    ctx.lineWidth = 4.5 * Y_SCALE;
    ctx.beginPath();
    ctx.moveTo(-rWidth * 0.48, zOffset);
    ctx.lineTo(rWidth * 0.48, zOffset);
    ctx.stroke();

    ctx.strokeStyle = "#5a3825";
    ctx.lineWidth = 2.2 * Y_SCALE;
    ctx.beginPath();
    ctx.moveTo(-rWidth * 0.46, zOffset - 1.5 * Y_SCALE);
    ctx.lineTo(rWidth * 0.46, zOffset - 1.5 * Y_SCALE);
    ctx.stroke();
  }

  // 3. Ahşap Köşe Çitleri
  const posts = [
    { x: -34, y: -15 * Y_SCALE },
    { x: 34,  y: -15 * Y_SCALE },
    { x: -36, y: 13 * Y_SCALE },
    { x: 36,  y: 13 * Y_SCALE }
  ];
  posts.forEach(p => {
    ctx.fillStyle = "#78350f";
    ctx.fillRect(p.x - 2, p.y - 9 * Y_SCALE, 4, 9 * Y_SCALE);
    ctx.fillStyle = "#b45309";
    ctx.fillRect(p.x - 2, p.y - 10 * Y_SCALE, 4, 1.5 * Y_SCALE);
  });

  // 4. Salınan Mısır Sapları ve Olgun Koçanlar
  const stalks = [
    { x: -22, y: -11 * Y_SCALE, sc: 0.92 },
    { x: 0,   y: -15 * Y_SCALE, sc: 0.98 },
    { x: 22,  y: -12 * Y_SCALE, sc: 0.94 },
    { x: -15, y: 0,             sc: 1.10 },
    { x: 15,  y: -2 * Y_SCALE,  sc: 1.06 },
    { x: -24, y: 11 * Y_SCALE,  sc: 0.96 },
    { x: -2,  y: 13 * Y_SCALE,  sc: 1.14 },
    { x: 20,  y: 10 * Y_SCALE,  sc: 1.04 }
  ];
  stalks.sort((a, b) => a.y - b.y);

  stalks.forEach((st, idx) => {
    const sway = Math.sin(time * 3.2 + idx * 0.85) * (2.8 * st.sc);
    const stalkH = 24 * st.sc * Y_SCALE;

    // Sap
    ctx.strokeStyle = "#15803d";
    ctx.lineWidth = 2.4 * st.sc;
    ctx.beginPath();
    ctx.moveTo(st.x, st.y);
    ctx.quadraticCurveTo(st.x + sway * 0.5, st.y - stalkH * 0.5, st.x + sway, st.y - stalkH);
    ctx.stroke();

    // Yapraklar
    ctx.strokeStyle = "#22c55e";
    ctx.lineWidth = 1.8 * st.sc;
    ctx.beginPath();
    ctx.moveTo(st.x + sway * 0.3, st.y - stalkH * 0.35);
    ctx.quadraticCurveTo(st.x - 8 * st.sc, st.y - stalkH * 0.45, st.x - 10 * st.sc + sway, st.y - stalkH * 0.2);
    ctx.stroke();

    // Altın Mısır Koçanı
    const cobX = st.x + sway * 0.55 + 2 * st.sc;
    const cobY = st.y - stalkH * 0.55;
    ctx.fillStyle = "#eab308";
    ctx.beginPath();
    ctx.ellipse(cobX, cobY, 3.5 * st.sc, 7.0 * st.sc * Y_SCALE, Math.PI / 8, 0, Math.PI * 2);
    ctx.fill();
    ctx.fillStyle = "#ca8a04";
    ctx.beginPath();
    ctx.ellipse(cobX, cobY, 2.0 * st.sc, 4.0 * st.sc * Y_SCALE, Math.PI / 8, 0, Math.PI * 2);
    ctx.fill();
  });

  // 5. 🧑‍🌾 MİKRO YAŞAM: Tarlada Çalışan Minik Çiftçi Figürü
  const farmerWalk = Math.sin(time * 1.8) * 10.0;
  const farmerX = -4 + farmerWalk;
  const farmerY = 2 * Y_SCALE;

  // Çiftçi Gölgesi
  ctx.fillStyle = "rgba(0,0,0,0.3)";
  ctx.beginPath();
  ctx.ellipse(farmerX, farmerY, 4.5, 2.5 * Y_SCALE, 0, 0, Math.PI * 2);
  ctx.fill();

  // Çizmeler
  ctx.strokeStyle = "#334155";
  ctx.lineWidth = 1.6;
  ctx.beginPath();
  ctx.moveTo(farmerX - 1.5, farmerY);
  ctx.lineTo(farmerX - 1.5, farmerY - 4 * Y_SCALE);
  ctx.moveTo(farmerX + 1.5, farmerY);
  ctx.lineTo(farmerX + 1.5, farmerY - 4 * Y_SCALE);
  ctx.stroke();

  // Mavi Kaftan
  ctx.fillStyle = "#1d4ed8";
  ctx.fillRect(farmerX - 3, farmerY - 10 * Y_SCALE, 6, 6 * Y_SCALE);

  // Baş ve Keçe Börk
  ctx.fillStyle = "#fed7aa";
  ctx.beginPath();
  ctx.arc(farmerX, farmerY - 12 * Y_SCALE, 2.5, 0, Math.PI * 2);
  ctx.fill();
  ctx.fillStyle = "#92400e";
  ctx.fillRect(farmerX - 3, farmerY - 14.5 * Y_SCALE, 6, 2.5 * Y_SCALE);

  // Orak Sallama
  const sickleSwing = Math.sin(time * 5.5) * 0.6;
  ctx.strokeStyle = "#e2e8f0";
  ctx.lineWidth = 1.4;
  ctx.beginPath();
  ctx.moveTo(farmerX + 2, farmerY - 8 * Y_SCALE);
  ctx.lineTo(farmerX + 6 + Math.cos(sickleSwing) * 5, farmerY - 6 * Y_SCALE + Math.sin(sickleSwing) * 5);
  ctx.stroke();

  // 6. Entegre Neo-Brutalist Taş Rozet
  const accum = b.accumulated || 0;
  if (accum > 0.5) {
    drawHarvestBadge(0, -34 * Y_SCALE, "🌽", accum, time);
  }
}

// 🌾 3D Dönen Rüzgar Değirmeni (Yontma Taş Gövde & Ahşap Kanatlar)
function drawIsometricWindmill(b, time) {
  // 1. Zemin 45° Düşen Gölgesi
  ctx.fillStyle = "rgba(0, 0, 0, 0.35)";
  ctx.beginPath();
  ctx.ellipse(8, 6 * Y_SCALE, 28, 16 * Y_SCALE, Math.PI / 10, 0, Math.PI * 2);
  ctx.fill();

  // 2. Taş Silindirik Kule (Sol Yüz Işık, Sağ Yüz Gölge)
  const towerH = 34 * Y_SCALE;
  ctx.fillStyle = "#cbd5e1";
  ctx.beginPath();
  ctx.moveTo(-14, 0);
  ctx.lineTo(0, 3 * Y_SCALE);
  ctx.lineTo(0, -towerH);
  ctx.lineTo(-10, -towerH);
  ctx.closePath();
  ctx.fill();

  ctx.fillStyle = "#64748b";
  ctx.beginPath();
  ctx.moveTo(0, 3 * Y_SCALE);
  ctx.lineTo(14, 0);
  ctx.lineTo(10, -towerH);
  ctx.lineTo(0, -towerH);
  ctx.closePath();
  ctx.fill();

  // Ahşap Kapı
  ctx.fillStyle = "#451a03";
  ctx.fillRect(-3.5, -9 * Y_SCALE, 7, 9 * Y_SCALE);

  // Koni Çatı
  ctx.fillStyle = "#92400e";
  ctx.beginPath();
  ctx.moveTo(-12, -towerH);
  ctx.lineTo(12, -towerH);
  ctx.lineTo(0, -towerH - 16 * Y_SCALE);
  ctx.closePath();
  ctx.fill();

  // Un Çuvalları (Kapı Önünde)
  ctx.fillStyle = "#fef08a";
  ctx.beginPath();
  ctx.ellipse(8, -2 * Y_SCALE, 4, 3 * Y_SCALE, 0, 0, Math.PI * 2);
  ctx.ellipse(12, 0, 4.5, 3.5 * Y_SCALE, 0, 0, Math.PI * 2);
  ctx.fill();

  // 3. Dönen 4 Kafes Kanat
  const bladeAngle = time * 3.2;
  const hubY = -towerH - 2 * Y_SCALE;

  ctx.save();
  ctx.translate(0, hubY);
  ctx.rotate(bladeAngle);

  for (let i = 0; i < 4; i++) {
    ctx.rotate(Math.PI / 2);
    ctx.strokeStyle = "#451a03";
    ctx.lineWidth = 2.4;
    ctx.beginPath();
    ctx.moveTo(0, 0);
    ctx.lineTo(0, -24);
    ctx.stroke();

    ctx.fillStyle = "rgba(254, 240, 138, 0.95)";
    ctx.fillRect(2, -23, 8, 16);
    ctx.strokeStyle = "#ca8a04";
    ctx.lineWidth = 0.8;
    ctx.strokeRect(2, -23, 8, 16);
  }

  ctx.fillStyle = "#1e293b";
  ctx.beginPath();
  ctx.arc(0, 0, 4.0, 0, Math.PI * 2);
  ctx.fill();
  ctx.restore();

  // 4. Entegre Neo-Brutalist Taş Rozet
  const accum = b.accumulated || 0;
  if (accum > 0.5) {
    drawHarvestBadge(0, -towerH - 20 * Y_SCALE, "🌾", accum, time);
  }
}

// 🪓 3D Ötüken Ormancı Kampı (Kütük Kulübe, Odun Yığınları & İşçi)
function drawIsometricLumberjack(b, time) {
  // 1. Zemin Düşen Gölgesi
  ctx.fillStyle = "rgba(0, 0, 0, 0.35)";
  ctx.beginPath();
  ctx.ellipse(6, 6 * Y_SCALE, 34, 18 * Y_SCALE, Math.PI / 10, 0, Math.PI * 2);
  ctx.fill();

  // 2. Çentikli Kütük Kulübe Gövdesi
  ctx.fillStyle = "#78350f";
  ctx.fillRect(-20, -18 * Y_SCALE, 20, 18 * Y_SCALE);
  ctx.fillStyle = "#451a03";
  ctx.fillRect(0, -18 * Y_SCALE, 20, 18 * Y_SCALE);

  // Kütük Çizgileri
  for (let y = 0; y < 4; y++) {
    ctx.strokeStyle = "#291204";
    ctx.lineWidth = 1.0;
    ctx.beginPath();
    ctx.moveTo(-20, (-18 + y * 4.5) * Y_SCALE);
    ctx.lineTo(20, (-18 + y * 4.5) * Y_SCALE);
    ctx.stroke();
  }

  // Ahşap Çatı
  ctx.fillStyle = "#b45309";
  ctx.beginPath();
  ctx.moveTo(-24, -18 * Y_SCALE);
  ctx.lineTo(24, -18 * Y_SCALE);
  ctx.lineTo(0, -34 * Y_SCALE);
  ctx.closePath();
  ctx.fill();

  // Taş Baca
  ctx.fillStyle = "#475569";
  ctx.fillRect(11, -32 * Y_SCALE, 5, 14 * Y_SCALE);

  // Sundurma Feneri
  ctx.fillStyle = "#f59e0b";
  ctx.beginPath();
  ctx.arc(-14, -14 * Y_SCALE, 2.5, 0, Math.PI * 2);
  ctx.fill();

  // 3. Baltalı Kütük & Odun Yaran İşçi Figürü
  const workerX = -18;
  const workerY = -2 * Y_SCALE;
  const axeSwing = Math.sin(time * 5.0) * 0.7;

  ctx.fillStyle = "#d97706";
  ctx.fillRect(workerX - 4, workerY - 4 * Y_SCALE, 8, 5 * Y_SCALE);

  ctx.strokeStyle = "#e2e8f0";
  ctx.lineWidth = 2.0;
  ctx.beginPath();
  ctx.moveTo(workerX, workerY - 4 * Y_SCALE);
  ctx.lineTo(workerX + Math.cos(axeSwing) * 8, workerY - 12 * Y_SCALE + Math.sin(axeSwing) * 8);
  ctx.stroke();

  // İstifli Odun Yığınları
  ctx.fillStyle = "#92400e";
  ctx.beginPath();
  ctx.arc(18, -2 * Y_SCALE, 3.5, 0, Math.PI * 2);
  ctx.arc(24, -2 * Y_SCALE, 3.5, 0, Math.PI * 2);
  ctx.arc(21, -6 * Y_SCALE, 3.5, 0, Math.PI * 2);
  ctx.fill();

  // 4. Entegre Neo-Brutalist Taş Rozet
  const accum = b.accumulated || 0;
  if (accum > 0.5) {
    drawHarvestBadge(0, -36 * Y_SCALE, "🪵", accum, time);
  }
}

// 🪵 3D Kereste Fabrikası (Hızar Testeresi & Kalas Yığınları)
function drawIsometricSawmill(b, time) {
  // 1. Zemin Düşen Gölgesi
  ctx.fillStyle = "rgba(0, 0, 0, 0.35)";
  ctx.beginPath();
  ctx.ellipse(6, 6 * Y_SCALE, 36, 20 * Y_SCALE, Math.PI / 10, 0, Math.PI * 2);
  ctx.fill();

  // 2. Ağır Ahşap Karkas Gövde
  ctx.fillStyle = "#78350f";
  ctx.fillRect(-20, -16 * Y_SCALE, 40, 16 * Y_SCALE);
  ctx.fillStyle = "#92400e";
  ctx.fillRect(-24, -28 * Y_SCALE, 48, 12 * Y_SCALE);

  // Dönen Çelik Hızar Testeresi
  const sawSpin = time * 12.0;
  ctx.save();
  ctx.translate(-2, -6 * Y_SCALE);
  ctx.rotate(sawSpin);
  ctx.fillStyle = "#e2e8f0";
  ctx.beginPath();
  ctx.arc(0, 0, 8, 0, Math.PI * 2);
  ctx.fill();
  ctx.strokeStyle = "#94a3b8";
  ctx.lineWidth = 1.6;
  ctx.stroke();
  ctx.restore();

  // Kalas Yığınları
  ctx.fillStyle = "#fde68a";
  ctx.fillRect(12, -4 * Y_SCALE, 15, 3 * Y_SCALE);
  ctx.fillRect(14, -8 * Y_SCALE, 13, 3 * Y_SCALE);
  ctx.fillRect(13, -12 * Y_SCALE, 14, 3 * Y_SCALE);
  ctx.strokeStyle = "#d97706";
  ctx.lineWidth = 0.8;
  ctx.strokeRect(12, -4 * Y_SCALE, 15, 3 * Y_SCALE);
  ctx.strokeRect(14, -8 * Y_SCALE, 13, 3 * Y_SCALE);

  // 3. Entegre Neo-Brutalist Taş Rozet
  const accum = b.accumulated || 0;
  if (accum > 0.5) {
    drawHarvestBadge(0, -32 * Y_SCALE, "🪵", accum, time);
  }
}

// 🛖 3D İşçi Kulübesi (Taş Temel, Saman Çatı & Fener)
function drawIsometricWorkerHut(b, time) {
  ctx.fillStyle = "rgba(0, 0, 0, 0.32)";
  ctx.beginPath();
  ctx.ellipse(6, 6 * Y_SCALE, 32, 18 * Y_SCALE, 0, 0, Math.PI * 2);
  ctx.fill();

  ctx.fillStyle = "#e2e8f0";
  ctx.fillRect(-16, -16 * Y_SCALE, 32, 16 * Y_SCALE);

  ctx.fillStyle = "#eab308";
  ctx.beginPath();
  ctx.moveTo(-20, -16 * Y_SCALE);
  ctx.lineTo(20, -16 * Y_SCALE);
  ctx.lineTo(0, -32 * Y_SCALE);
  ctx.closePath();
  ctx.fill();

  ctx.fillStyle = "#78350f";
  ctx.fillRect(-4, -8 * Y_SCALE, 8, 8 * Y_SCALE);
  ctx.fillStyle = "#fde047";
  ctx.fillRect(8, -12 * Y_SCALE, 4, 4 * Y_SCALE);
}

// 🍞 3D Taş Ekmek Fırını (Bozkır Tandırı, Sıcak Kor Ateş & Duman)
function drawIsometricBakery(b, time) {
  // 1. Zemin Düşen Gölgesi
  ctx.fillStyle = "rgba(0, 0, 0, 0.35)";
  ctx.beginPath();
  ctx.ellipse(6, 6 * Y_SCALE, 34, 18 * Y_SCALE, Math.PI / 10, 0, Math.PI * 2);
  ctx.fill();

  // 2. Yontma Taş Duvarlar
  ctx.fillStyle = "#64748b";
  ctx.fillRect(-18, -16 * Y_SCALE, 18, 16 * Y_SCALE);
  ctx.fillStyle = "#475569";
  ctx.fillRect(0, -16 * Y_SCALE, 18, 16 * Y_SCALE);
  ctx.strokeStyle = "#1e293b";
  ctx.lineWidth = 1.0;
  ctx.strokeRect(-18, -16 * Y_SCALE, 36, 16 * Y_SCALE);

  // Kiremit Çatı
  ctx.fillStyle = "#991b1b";
  ctx.beginPath();
  ctx.moveTo(-22, -16 * Y_SCALE);
  ctx.lineTo(22, -16 * Y_SCALE);
  ctx.lineTo(0, -34 * Y_SCALE);
  ctx.closePath();
  ctx.fill();

  // Sıcak Tandır Ateşi Parıltısı
  ctx.fillStyle = "#0c0a09";
  ctx.beginPath();
  ctx.arc(0, -6 * Y_SCALE, 6.5, Math.PI, 0);
  ctx.lineTo(6.5, 0);
  ctx.lineTo(-6.5, 0);
  ctx.closePath();
  ctx.fill();

  const firePulse = Math.sin(time * 6.0) * 1.5;
  ctx.fillStyle = "#f97316";
  ctx.beginPath();
  ctx.arc(0, -3 * Y_SCALE, 4.5 + firePulse, 0, Math.PI * 2);
  ctx.fill();
  ctx.fillStyle = "#fef08a";
  ctx.beginPath();
  ctx.arc(0, -2 * Y_SCALE, 2.5, 0, Math.PI * 2);
  ctx.fill();

  // Taş Baca
  ctx.fillStyle = "#334155";
  ctx.fillRect(9, -34 * Y_SCALE, 6, 14 * Y_SCALE);

  // Ekmek Sepeti
  ctx.fillStyle = "#d97706";
  ctx.fillRect(-14, -4 * Y_SCALE, 6, 4 * Y_SCALE);
  ctx.fillStyle = "#fed7aa";
  ctx.beginPath();
  ctx.arc(-11, -5 * Y_SCALE, 2, 0, Math.PI * 2);
  ctx.fill();

  // 3. Entegre Neo-Brutalist Taş Rozet
  const accum = b.accumulated || 0;
  if (accum > 0.5) {
    drawHarvestBadge(0, -36 * Y_SCALE, "🍞", accum, time);
  }
}

// 🪑 3D Marangoz Atölyesi (Mavi Çatı, Tezgah & Kalaslar)
function drawIsometricFurnitureMaker(b, time) {
  ctx.fillStyle = "rgba(0, 0, 0, 0.35)";
  ctx.beginPath();
  ctx.ellipse(6, 6 * Y_SCALE, 36, 20 * Y_SCALE, Math.PI / 10, 0, Math.PI * 2);
  ctx.fill();

  ctx.fillStyle = "#78350f";
  ctx.fillRect(-22, -15 * Y_SCALE, 22, 15 * Y_SCALE);
  ctx.fillStyle = "#451a03";
  ctx.fillRect(0, -15 * Y_SCALE, 22, 15 * Y_SCALE);

  ctx.fillStyle = "#1e40af";
  ctx.beginPath();
  ctx.moveTo(-26, -15 * Y_SCALE);
  ctx.lineTo(26, -15 * Y_SCALE);
  ctx.lineTo(-4, -32 * Y_SCALE);
  ctx.closePath();
  ctx.fill();
  ctx.strokeStyle = "#38bdf8";
  ctx.lineWidth = 1.2;
  ctx.stroke();

  // Marangoz Tezgahı
  ctx.fillStyle = "#5c3d22";
  ctx.fillRect(-10, -5 * Y_SCALE, 20, 5 * Y_SCALE);

  // Mobilya Sandığı
  ctx.fillStyle = "#d97706";
  ctx.fillRect(12, -2 * Y_SCALE, 8, 4 * Y_SCALE);
  ctx.fillRect(14, -6 * Y_SCALE, 6, 4 * Y_SCALE);

  // Entegre Neo-Brutalist Taş Rozet
  const accum = b.accumulated || 0;
  if (accum > 0.5) {
    drawHarvestBadge(0, -34 * Y_SCALE, "🪑", accum, time);
  }
}

// 🪨 3D Taş Ocağı (Basamaklı Ocak, Ahşap Vinç & Taş Yığınları)
function drawIsometricQuarry(b, time) {
  ctx.fillStyle = "rgba(0, 0, 0, 0.35)";
  ctx.beginPath();
  ctx.ellipse(6, 6 * Y_SCALE, 38, 20 * Y_SCALE, Math.PI / 10, 0, Math.PI * 2);
  ctx.fill();

  // Basamaklı Taş Ocak Kesiti
  ctx.fillStyle = "#475569";
  ctx.fillRect(-20, -12 * Y_SCALE, 40, 12 * Y_SCALE);
  ctx.fillStyle = "#334155";
  ctx.fillRect(-16, -8 * Y_SCALE, 32, 8 * Y_SCALE);

  // Ahşap A-İskelet Vinç
  ctx.strokeStyle = "#78350f";
  ctx.lineWidth = 2.6;
  ctx.beginPath();
  ctx.moveTo(-18, -12 * Y_SCALE);
  ctx.lineTo(-18, -30 * Y_SCALE);
  ctx.lineTo(3, -26 * Y_SCALE);
  ctx.stroke();

  const ropeSway = Math.sin(time * 3.0) * 2.0;
  ctx.strokeStyle = "#cbd5e1";
  ctx.lineWidth = 1.0;
  ctx.beginPath();
  ctx.moveTo(3, -26 * Y_SCALE);
  ctx.lineTo(3 + ropeSway, -14 * Y_SCALE);
  ctx.stroke();

  // Kaldırılan Taş Blok
  ctx.fillStyle = "#94a3b8";
  ctx.fillRect(ropeSway - 2, -14 * Y_SCALE, 10, 8 * Y_SCALE);
  ctx.strokeStyle = "#475569";
  ctx.lineWidth = 0.8;
  ctx.strokeRect(ropeSway - 2, -14 * Y_SCALE, 10, 8 * Y_SCALE);

  // Yontulmuş Taş Yığınları
  ctx.fillStyle = "#cbd5e1";
  ctx.fillRect(10, -4 * Y_SCALE, 8, 6 * Y_SCALE);
  ctx.fillRect(16, -2 * Y_SCALE, 7, 5 * Y_SCALE);

  // Entegre Neo-Brutalist Taş Rozet
  const accum = b.accumulated || 0;
  if (accum > 0.5) {
    drawHarvestBadge(0, -36 * Y_SCALE, "🪨", accum, time);
  }
}

// ⛏️ 3D Ergenekon Demir Madeni & Döküm Ocağı
function drawIsometricMine(b, time) {
  ctx.fillStyle = "rgba(0, 0, 0, 0.4)";
  ctx.beginPath();
  ctx.ellipse(6, 6 * Y_SCALE, 38, 22 * Y_SCALE, Math.PI / 10, 0, Math.PI * 2);
  ctx.fill();

  // Maden Galerisi Ağzı (Adit)
  ctx.fillStyle = "#090d16";
  ctx.beginPath();
  ctx.arc(0, -10 * Y_SCALE, 13, Math.PI, 0);
  ctx.lineTo(13, 0);
  ctx.lineTo(-13, 0);
  ctx.closePath();
  ctx.fill();

  // Ahşap Portal Karkası
  ctx.fillStyle = "#78350f";
  ctx.fillRect(-16, -26 * Y_SCALE, 5, 26 * Y_SCALE);
  ctx.fillRect(11, -26 * Y_SCALE, 5, 26 * Y_SCALE);
  ctx.fillRect(-18, -28 * Y_SCALE, 36, 5 * Y_SCALE);

  // Döküm Fırını ve Kor Ateşi
  ctx.fillStyle = "#334155";
  ctx.fillRect(14, -22 * Y_SCALE, 8, 18 * Y_SCALE);
  const forgeGlow = Math.sin(time * 5.5) * 1.5;
  ctx.fillStyle = "#ef4444";
  ctx.beginPath();
  ctx.arc(18, -4 * Y_SCALE, 4.0 + forgeGlow, 0, Math.PI * 2);
  ctx.fill();
  ctx.fillStyle = "#fde047";
  ctx.beginPath();
  ctx.arc(18, -4 * Y_SCALE, 2.2, 0, Math.PI * 2);
  ctx.fill();

  // Demir Külçeleri
  ctx.fillStyle = "#94a3b8";
  ctx.fillRect(-22, -3 * Y_SCALE, 9, 3 * Y_SCALE);
  ctx.fillRect(-20, -6 * Y_SCALE, 7, 3 * Y_SCALE);
  ctx.strokeStyle = "#f8fafc";
  ctx.lineWidth = 0.8;
  ctx.strokeRect(-22, -3 * Y_SCALE, 9, 3 * Y_SCALE);

  // Entegre Neo-Brutalist Taş Rozet
  const accum = b.accumulated || 0;
  if (accum > 0.5) {
    drawHarvestBadge(0, -36 * Y_SCALE, "⛏️", accum, time);
  }
}

// 🏛️ 3D Kadim Kurgan / Balbal Taşları & Göktürk Rünleri
function drawIsometricRuins(time) {
  ctx.fillStyle = "rgba(0, 0, 0, 0.45)";
  ctx.beginPath();
  ctx.ellipse(6, 6 * Y_SCALE, 36, 20 * Y_SCALE, Math.PI / 10, 0, Math.PI * 2);
  ctx.fill();

  // Taş Kaide
  ctx.fillStyle = "#1e293b";
  ctx.fillRect(-18, -6 * Y_SCALE, 36, 6 * Y_SCALE);

  // Dikili Balbal Megalit Taşları
  const runesGlow = Math.sin(time * 3.0) * 0.4 + 0.6;
  ctx.fillStyle = "#334155";
  ctx.fillRect(-15, -28 * Y_SCALE, 9, 22 * Y_SCALE);
  ctx.fillRect(6, -28 * Y_SCALE, 9, 22 * Y_SCALE);
  ctx.fillStyle = "#475569";
  ctx.fillRect(-18, -32 * Y_SCALE, 36, 5 * Y_SCALE);

  // Parlayan Turkuaz Göktürk Tamgaları
  ctx.fillStyle = `rgba(6, 182, 212, ${runesGlow})`;
  ctx.font = "bold 12px monospace";
  ctx.textAlign = "center";
  ctx.fillText("𐰋", -10, -15 * Y_SCALE);
  ctx.fillText("𐰏", 10, -15 * Y_SCALE);
  ctx.fillText("🏛️", 0, -8 * Y_SCALE);
}

// 🏹 3D Gözcü Kulesi / Korgan
function drawIsometricWatchtower(b, time) {
  ctx.fillStyle = "rgba(0, 0, 0, 0.4)";
  ctx.beginPath();
  ctx.ellipse(6, 6 * Y_SCALE, 30, 16 * Y_SCALE, Math.PI / 10, 0, Math.PI * 2);
  ctx.fill();

  ctx.strokeStyle = "#3e1e0a";
  ctx.lineWidth = 3.2;
  ctx.beginPath();
  ctx.moveTo(-11, 0); ctx.lineTo(-11, -34 * Y_SCALE);
  ctx.moveTo(11, 0);  ctx.lineTo(11, -34 * Y_SCALE);
  ctx.moveTo(-4, -6 * Y_SCALE); ctx.lineTo(-4, -40 * Y_SCALE);
  ctx.moveTo(4, -6 * Y_SCALE);  ctx.lineTo(4, -40 * Y_SCALE);
  ctx.stroke();

  ctx.strokeStyle = "#78350f";
  ctx.lineWidth = 1.8;
  ctx.beginPath();
  ctx.moveTo(-11, -4 * Y_SCALE); ctx.lineTo(11, -30 * Y_SCALE);
  ctx.moveTo(11, -4 * Y_SCALE);  ctx.lineTo(-11, -30 * Y_SCALE);
  ctx.stroke();

  // Gözetleme Platformu
  ctx.fillStyle = "#92400e";
  ctx.fillRect(-15, -36 * Y_SCALE, 30, 5 * Y_SCALE);

  // Sivri Çatı
  ctx.fillStyle = "#b45309";
  ctx.beginPath();
  ctx.moveTo(-17, -36 * Y_SCALE);
  ctx.lineTo(0, -52 * Y_SCALE);
  ctx.lineTo(17, -36 * Y_SCALE);
  ctx.closePath();
  ctx.fill();

  // Sinyal Meşalesi Ateşi
  const fireFlicker = Math.sin(time * 6.0) * 1.5;
  ctx.fillStyle = "#f97316";
  ctx.beginPath();
  ctx.arc(10, -38 * Y_SCALE, 3.5 + fireFlicker, 0, Math.PI * 2);
  ctx.fill();
  ctx.fillStyle = "#fef08a";
  ctx.beginPath();
  ctx.arc(10, -38 * Y_SCALE, 1.8, 0, Math.PI * 2);
  ctx.fill();

  const flagWave = Math.sin(time * 4.0) * 2.5;
  ctx.fillStyle = "#dc2626";
  ctx.beginPath();
  ctx.moveTo(0, -52 * Y_SCALE);
  ctx.lineTo(8 + flagWave, -48 * Y_SCALE);
  ctx.lineTo(0, -44 * Y_SCALE);
  ctx.closePath();
  ctx.fill();

  if (b && b.level > 1) {
    ctx.fillStyle = "#f59e0b";
    ctx.beginPath();
    ctx.arc(-10, -22 * Y_SCALE, 5, 0, Math.PI * 2);
    ctx.fill();
    ctx.fillStyle = "#1e293b";
    ctx.font = "bold 9px Outfit, sans-serif";
    ctx.textAlign = "center";
    ctx.fillText(`${b.level}`, -10, -19 * Y_SCALE);
  }
}

// 🐫 3D İpek Yolu Kervanı (Gezgin Tüccar)
function drawIsometricCaravan(time) {
  const bob = Math.sin(time * 3.0) * 2.0;
  ctx.save();
  ctx.fillStyle = "rgba(245, 158, 11, 0.35)";
  ctx.beginPath();
  ctx.ellipse(0, 0, 28, 16 * Y_SCALE, 0, 0, Math.PI * 2);
  ctx.fill();

  ctx.font = "24px Outfit, sans-serif";
  ctx.textAlign = "center";
  ctx.fillText("🐫", 0, -10 * Y_SCALE + bob);

  ctx.fillStyle = "#fde047";
  ctx.font = "bold 10px Outfit, sans-serif";
  ctx.fillText("💰 TÜCCAR", 0, -26 * Y_SCALE + bob);
  ctx.restore();
}

// 🔮 3D Bozkır Şamanı (Gizemli Şaman Ritüeli)
function drawIsometricShaman(time) {
  const pulse = Math.sin(time * 4.0) * 3.0;
  ctx.save();
  ctx.fillStyle = "rgba(168, 85, 247, 0.4)";
  ctx.beginPath();
  ctx.ellipse(0, 0, 30 + pulse, (16 + pulse * 0.5) * Y_SCALE, 0, 0, Math.PI * 2);
  ctx.fill();

  ctx.font = "24px Outfit, sans-serif";
  ctx.textAlign = "center";
  ctx.fillText("🧙‍♂️", 0, -10 * Y_SCALE);

  ctx.fillStyle = "#c084fc";
  ctx.font = "bold 10px Outfit, sans-serif";
  ctx.fillText("✨ ŞAMAN", 0, -26 * Y_SCALE);
  ctx.restore();
}

// =============================================================================
// 7. OYUN DÖNGÜSÜ & EKONOMİ (PROCESS & FACTORIES)
// =============================================================================

let lastTime = performance.now();

function gameLoop(now) {
  const delta = Math.min(0.2, (now - lastTime) / 1000.0);
  lastTime = now;

  game.statPlaytime += delta;
  animWindTime += delta;
  game.autoSaveTimer += delta;
  game.animDayTime = (game.animDayTime || 0) + delta * 0.03;

  // Rastgele Hazine Sandığı Oluşturucu (40-60sn arayla)
  game.chestSpawnTimer = (game.chestSpawnTimer || 0) + delta;
  const treasureLvl = (game.talents && game.talents.treasureHunter) ? game.talents.treasureHunter : 0;
  const spawnThreshold = Math.max(18.0, 42.0 - treasureLvl * 5.0);

  if (!game.activeChests) game.activeChests = [];

  // Süresi biten sandıkları temizle
  game.activeChests.forEach(c => c.lifetime -= delta);
  game.activeChests = game.activeChests.filter(c => c.lifetime > 0);

  if (game.chestSpawnTimer >= spawnThreshold && game.activeChests.length < 3) {
    game.chestSpawnTimer = 0.0;
    const ownedTiles = Object.values(game.tiles).filter(t => t.state === "OWNED" || t.state === "DISCOVERED");
    if (ownedTiles.length > 0) {
      const targetTile = ownedTiles[Math.floor(Math.random() * ownedTiles.length)];
      const chestKey = `${targetTile.q},${targetTile.r}`;
      if (!game.activeChests.some(c => c.key === chestKey)) {
        game.activeChests.push({
          q: targetTile.q,
          r: targetTile.r,
          key: chestKey,
          lifetime: 60.0
        });
      }
    }
  }

  if (screenShakeTimer > 0) {
    screenShakeTimer -= delta;
  }

  if (game.autoSaveTimer >= 30.0) {
    game.autoSaveTimer = 0.0;
    saveGame();
  }

  if (game.shamanBoostTimer > 0) {
    game.shamanBoostTimer -= delta;
  }

  // Rastgele Olaylar & Gece Akınları
  processEncounters(delta);
  processNightRaids(delta);

  // 1. Mevsim Döngüsü (Zud Felaketi, Bahar, Yaz, Güz)
  updateSeasons(delta);

  // 2. Üretim Döngüsü (Mısır, Oduncu, Değirmen, Kereste, Fırın, Mobilya, Taş Ocağı, Demir Madeni, Yeraltı Ocağı, İşçi)
  processProduction(delta);

  // 3. Mikro Dinamik Parçacık & Canlı Doğa Güncellemeleri
  updateCloudShadows(delta);
  updateRoamingHerds(delta);
  updateChimneyPuffs(delta);
  updateFlyingResources(delta);
  updateTileBounces(delta);
  updateWeatherStreaks(delta);
  updateSeasonalParticles(delta);
  updatePackMules(delta);

  // 4. Çizim
  draw();

  // 5. UI Canlı Güncelleme
  updateUI();
  updateOpenMenuLive();
  updateQuestsUI();
  updateEncounterTimerUI();

  requestAnimationFrame(gameLoop);
}

function updateSeasons(delta) {
  game.seasonTimer = (game.seasonTimer || 0) + delta;
  const SEASON_DURATION = 45.0;

  if (game.seasonTimer >= SEASON_DURATION) {
    game.seasonTimer = 0.0;
    if (game.season === "SPRING") {
      game.season = "SUMMER";
      showToast("☀️ Yaz Mevsimi Geldi! (Tarlalar ve Değirmenler %130 Hızlandı)");
    } else if (game.season === "SUMMER") {
      game.season = "AUTUMN";
      showToast("🍂 Sonbahar Geldi! (Odunculuk ve Madencilik %120 Hızlandı)");
    } else if (game.season === "AUTUMN") {
      game.season = "WINTER";
      game.isZud = (game.seasonYear % 2 === 0);
      if (game.isZud) {
        showToast("❄️ ZUD (Kış Felaketi) Başladı! Isıtmasız Tarlalar Dondu!", true);
        const banner = document.getElementById("season-banner");
        if (banner) {
          banner.classList.remove("hidden");
          setTimeout(() => banner.classList.add("hidden"), 6000);
        }
      } else {
        showToast("❄️ Kış Mevsimi Başladı! (Taş ve Madencilik Üretimi Öncelikli)");
      }
    } else {
      game.season = "SPRING";
      game.isZud = false;
      game.seasonYear = (game.seasonYear || 1) + 1;
      showToast(`🌸 ${game.seasonYear}. Yıl İlkbaharı Başladı! Topraklar Yeşerdi.`);
    }
  }

  // Sezon gösterge butonunu güncelle
  const seasonBtn = document.getElementById("chip-season");
  if (seasonBtn) {
    const sIcons = { SPRING: "🌸 İlkbahar", SUMMER: "☀️ Yaz", AUTUMN: "🍂 Sonbahar", WINTER: game.isZud ? "❄️ Zud Felaketi" : "❄️ Kış" };
    seasonBtn.textContent = sIcons[game.season] || "🌸 İlkbahar";
    if (game.isZud && game.season === "WINTER") {
      seasonBtn.style.color = "#ef4444";
      seasonBtn.style.borderColor = "#ef4444";
    } else {
      seasonBtn.style.color = "";
      seasonBtn.style.borderColor = "";
    }
  }
}

function processProduction(delta) {
  const globalMult = game.getGlobalMultiplier();
  const foodRelicMult = (game.relics && game.relics.cornucopia) ? 1.25 : 1.0;
  const woodRelicMult = (game.relics && game.relics.axe) ? 1.25 : 1.0;
  const stoneRelicMult = (game.relics && game.relics.shield) ? 1.30 : 1.0;

  // Yüzey Üretimi
  Object.values(game.tiles || {}).forEach(tile => {
    if (tile.state !== "OWNED" || !tile.building) return;
    const b = tile.building;

    if (b.type === "corn") {
      const rate = (0.42 * Math.pow(1.5, b.level - 1)) * globalMult * foodRelicMult;
      const maxCap = rate * 30.0;
      b.accumulated = Math.min(maxCap, (b.accumulated || 0) + rate * delta);
    } else if (b.type === "lumberjack") {
      const rate = (0.35 * Math.pow(1.5, b.level - 1)) * globalMult * woodRelicMult;
      const maxCap = rate * 30.0;
      b.accumulated = Math.min(maxCap, (b.accumulated || 0) + rate * delta);
    } else if (b.type === "quarry") {
      const rate = (0.30 * Math.pow(1.5, b.level - 1)) * globalMult * stoneRelicMult;
      const maxCap = rate * 30.0;
      b.accumulated = Math.min(maxCap, (b.accumulated || 0) + rate * delta);
    } else if (b.type === "mine") {
      const rate = (0.18 * Math.pow(1.5, b.level - 1)) * globalMult * stoneRelicMult;
      const maxCap = rate * 30.0;
      b.accumulated = b.accumulated || 0;

      if (b.accumulated < maxCap) {
        const neighbors = game.getNeighborBuildings(tile.q, tile.r);
        const quarries = neighbors.filter(nb => nb.type === "quarry" && (nb.accumulated || 0) > 0.01);

        if (quarries.length > 0) {
          b.isAdjacent = true;
          const needed = rate * delta;
          const takePerQ = needed / quarries.length;
          let got = 0;
          quarries.forEach(q => {
            const take = Math.min(q.accumulated, takePerQ);
            q.accumulated -= take;
            got += take;
          });
          b.accumulated = Math.min(maxCap, b.accumulated + got);
          game.statTotalIron = (game.statTotalIron || 0) + got;
        } else {
          b.isAdjacent = false;
          const neededStone = (rate * 0.5) * delta;
          const neededWood = (rate * 0.3) * delta;
          if (game.stone >= neededStone && game.wood >= neededWood) {
            game.stone -= neededStone;
            game.wood -= neededWood;
            b.accumulated = Math.min(maxCap, b.accumulated + rate * delta);
            game.statTotalIron = (game.statTotalIron || 0) + rate * delta;
          }
        }
      }
    } else if (b.type === "windmill") {
      const rate = (0.25 * Math.pow(1.5, b.level - 1)) * globalMult * foodRelicMult;
      const maxCap = rate * 30.0;
      b.accumulated = b.accumulated || 0;

      if (b.accumulated < maxCap) {
        // Komşu tarlaları kontrol et
        const neighbors = game.getNeighborBuildings(tile.q, tile.r);
        const cornFarms = neighbors.filter(nb => nb.type === "corn" && (nb.accumulated || 0) > 0.01);

        if (cornFarms.length > 0) {
          b.isAdjacent = true;
          const needed = rate * delta;
          const takePerFarm = needed / cornFarms.length;
          let got = 0;
          cornFarms.forEach(f => {
            const take = Math.min(f.accumulated, takePerFarm);
            f.accumulated -= take;
            got += take;
          });
          b.accumulated = Math.min(maxCap, b.accumulated + got);
          game.statTotalFlour += got;
        } else {
          b.isAdjacent = false;
          const needed = (rate * 0.5) * delta;
          if (game.food >= needed) {
            game.food -= needed;
            b.accumulated = Math.min(maxCap, b.accumulated + needed);
            game.statTotalFlour += needed;
          }
        }
      }
    } else if (b.type === "sawmill") {
      const rate = (0.20 * Math.pow(1.5, b.level - 1)) * globalMult * woodRelicMult;
      const maxCap = rate * 30.0;
      b.accumulated = b.accumulated || 0;

      if (b.accumulated < maxCap) {
        const neighbors = game.getNeighborBuildings(tile.q, tile.r);
        const lumberHuts = neighbors.filter(nb => nb.type === "lumberjack" && (nb.accumulated || 0) > 0.01);

        if (lumberHuts.length > 0) {
          b.isAdjacent = true;
          const needed = rate * delta;
          const takePerHut = needed / lumberHuts.length;
          let got = 0;
          lumberHuts.forEach(l => {
            const take = Math.min(l.accumulated, takePerHut);
            l.accumulated -= take;
            got += take;
          });
          b.accumulated = Math.min(maxCap, b.accumulated + got);
          game.statTotalPlank += got;
        } else {
          b.isAdjacent = false;
          const needed = (rate * 0.5) * delta;
          if (game.wood >= needed) {
            game.wood -= needed;
            b.accumulated = Math.min(maxCap, b.accumulated + needed);
            game.statTotalPlank += needed;
          }
        }
      }
    } else if (b.type === "bakery") {
      const rate = (0.25 * Math.pow(1.5, b.level - 1)) * globalMult;
      const maxCap = rate * 40.0;
      b.accumulated = b.accumulated || 0;

      if (b.accumulated < maxCap) {
        const neighbors = game.getNeighborBuildings(tile.q, tile.r);
        const mills = neighbors.filter(nb => nb.type === "windmill" && (nb.accumulated || 0) > 0.01);

        if (mills.length > 0) {
          b.isAdjacent = true;
          const needed = rate * delta;
          const takePerMill = needed / mills.length;
          let got = 0;
          mills.forEach(m => {
            const take = Math.min(m.accumulated, takePerMill);
            m.accumulated -= take;
            got += take;
          });
          b.accumulated = Math.min(maxCap, b.accumulated + got);
          game.statTotalBread += got;
        } else {
          b.isAdjacent = false;
          const neededFlour = (rate * 0.5) * delta;
          const neededFood = (rate * 0.5) * delta;
          if (game.flour >= neededFlour && game.food >= neededFood) {
            game.flour -= neededFlour;
            game.food -= neededFood;
            b.accumulated = Math.min(maxCap, b.accumulated + rate * delta);
            game.statTotalBread += rate * delta;
          }
        }
      }
    } else if (b.type === "furniture") {
      const rate = (0.20 * Math.pow(1.5, b.level - 1)) * globalMult * woodRelicMult;
      const maxCap = rate * 40.0;
      b.accumulated = b.accumulated || 0;

      if (b.accumulated < maxCap) {
        const neighbors = game.getNeighborBuildings(tile.q, tile.r);
        const sawmills = neighbors.filter(nb => nb.type === "sawmill" && (nb.accumulated || 0) > 0.01);

        if (sawmills.length > 0) {
          b.isAdjacent = true;
          const needed = rate * delta;
          const takePerSaw = needed / sawmills.length;
          let got = 0;
          sawmills.forEach(s => {
            const take = Math.min(s.accumulated, takePerSaw);
            s.accumulated -= take;
            got += take;
          });
          b.accumulated = Math.min(maxCap, b.accumulated + got);
          game.statTotalFurniture += got;
        } else {
          b.isAdjacent = false;
          const neededPlank = (rate * 0.5) * delta;
          const neededWood = (rate * 0.5) * delta;
          if (game.plank >= neededPlank && game.wood >= neededWood) {
            game.plank -= neededPlank;
            game.wood -= neededWood;
            b.accumulated = Math.min(maxCap, b.accumulated + rate * delta);
            game.statTotalFurniture += rate * delta;
          }
        }
      }
    } else if (b.type === "worker") {
      const workerBonus = 1.0 + ((game.talents && game.talents.workerSpeed) ? game.talents.workerSpeed * 0.25 : 0.0);
      const rate = (0.80 * Math.pow(1.5, b.level - 1)) * globalMult * workerBonus;
      const neighbors = game.getNeighborBuildings(tile.q, tile.r);
      const targets = neighbors.filter(nb => (nb.accumulated || 0) > 0.001);

      if (targets.length > 0) {
        const maxTransfer = rate * delta;
        const transferPerTarget = maxTransfer / targets.length;

        targets.forEach(tgt => {
          const avail = tgt.accumulated;
          const take = Math.min(avail, transferPerTarget);
          tgt.accumulated -= take;
          b.totalGathered = (b.totalGathered || 0) + take;

          if (tgt.type === "corn") {
            game.food += take;
            game.statTotalFood += take;
          } else if (tgt.type === "lumberjack") {
            game.wood += take;
            game.statTotalWood += take;
          } else if (tgt.type === "windmill") {
            game.flour += take;
            game.statTotalFlour += take;
          } else if (tgt.type === "sawmill") {
            game.plank += take;
            game.statTotalPlank += take;
          } else if (tgt.type === "bakery") {
            game.bread += take;
            game.statTotalBread += take;
          } else if (tgt.type === "furniture") {
            game.furniture += take;
            game.statTotalFurniture += take;
          } else if (tgt.type === "quarry") {
            game.stone = (game.stone || 0) + take;
            game.statTotalStone = (game.statTotalStone || 0) + take;
          } else if (tgt.type === "mine") {
            game.iron = (game.iron || 0) + take;
            game.statTotalIron = (game.statTotalIron || 0) + take;
          } else if (tgt.type === "underground_forge") {
            game.obsidian = (game.obsidian || 0) + take;
            game.statTotalObsidian = (game.statTotalObsidian || 0) + take;
          } else if (tgt.type === "crystal_mine") {
            game.mithril = (game.mithril || 0) + take;
            game.statTotalMithril = (game.statTotalMithril || 0) + take;
          }
        });
      }
    }
  });

  // Yeraltı Ergenekon Üretimi (Dökümhane & Kristal Madeni)
  if (game.undergroundTiles) {
    Object.values(game.undergroundTiles).forEach(tile => {
      if (tile.state !== "OWNED" || !tile.building) return;
      const b = tile.building;
      if (b.type === "underground_forge") {
        const rate = (0.22 * Math.pow(1.5, b.level - 1)) * globalMult;
        const maxCap = rate * 40.0;
        b.accumulated = Math.min(maxCap, (b.accumulated || 0) + rate * delta);
      } else if (b.type === "crystal_mine") {
        const rate = (0.16 * Math.pow(1.5, b.level - 1)) * globalMult;
        const maxCap = rate * 40.0;
        b.accumulated = Math.min(maxCap, (b.accumulated || 0) + rate * delta);
      }
    });
  }
}

// =============================================================================
// 7.1. ÜÇ KATMANLI KRALİYET GÖREV SİSTEMİ (QUESTS & DECREES)
// =============================================================================

const QUEST_TYPES = {
  fast: [
    { key: "collect_wood", desc: "{0} Odun Topla", target: [20, 35, 50], reward: { wood: 30, food: 20 }, rewardText: "+30 🪵 +20 🥡", tag: "⚡ Hızlı Ferman" },
    { key: "collect_food", desc: "{0} Gıda Hasat Et", target: [25, 40, 60], reward: { food: 40, wood: 20 }, rewardText: "+40 🥡 +20 🪵", tag: "⚡ Hızlı Ferman" },
    { key: "collect_stone", desc: "{0} Taş Çıkar", target: [10, 20, 30], reward: { stone: 20, iron: 10 }, rewardText: "+20 🪨 +10 ⛏️", tag: "⚡ Hızlı Ferman" },
    { key: "conquer_tile", desc: "{0} Yeni Karo Fethet", target: [1, 2, 3], reward: { food: 30, wood: 30 }, rewardText: "+30 🥡 +30 🪵", tag: "⚡ Hızlı Ferman" }
  ],
  strat: [
    { key: "build_worker", desc: "{0} İşçi Kulübesi Kur", target: [1, 2], reward: { crowns: 1, food: 50 }, rewardText: "+1 👑 +50 🥡", tag: "🏰 Krallık Fermanı" },
    { key: "upgrade_building", desc: "{0} Bina Seviyesini Yükselt", target: [1, 2], reward: { crowns: 1, stone: 30 }, rewardText: "+1 👑 +30 🪨", tag: "🏰 Krallık Fermanı" },
    { key: "build_watchtower", desc: "{0} Gözcü Kulesi İnşa Et", target: [1, 2], reward: { crowns: 1, wood: 40, stone: 25 }, rewardText: "+1 👑 +40 🪵 +25 🪨", tag: "🏰 Krallık Fermanı" },
    { key: "conquer_forest", desc: "{0} Orman Karosu Fethet", target: [2, 3], reward: { crowns: 1, wood: 60 }, rewardText: "+1 👑 +60 🪵", tag: "🏰 Krallık Fermanı" }
  ],
  epic: [
    { key: "castle_level", desc: "Şatoyu {0}. Seviyeye Yükselt", target: [2, 3, 4], reward: { crowns: 3, relic: true }, rewardText: "+3 👑 + Kadim Eser", tag: "👑 Epik Hükümdar Fermanı" },
    { key: "conquer_total", desc: "Toplam {0} Toprak Fethet", target: [6, 12, 18], reward: { crowns: 4, relic: true }, rewardText: "+4 👑 + Kadim Eser", tag: "👑 Epik Hükümdar Fermanı" },
    { key: "defend_raid", desc: "{0} Gece Baskınını Savuştur", target: [1, 2, 3], reward: { crowns: 3, relic: true }, rewardText: "+3 👑 + Kadim Eser", tag: "👑 Epik Hükümdar Fermanı" }
  ]
};

function generateQuest(tier) {
  const pool = QUEST_TYPES[tier];
  const qDef = pool[Math.floor(Math.random() * pool.length)];
  const target = qDef.target[Math.floor(Math.random() * qDef.target.length)];
  
  let desc = qDef.desc.replace("{0}", target);
  let initialCount = 0;
  if (qDef.key === "castle_level") {
    initialCount = game ? game.castleLevel : 1;
  } else if (qDef.key === "conquer_total") {
    initialCount = game ? game.ownedCount : 1;
  }

  return {
    tier,
    key: qDef.key,
    desc,
    current: initialCount,
    target: Math.max(initialCount + 1, target),
    reward: { ...qDef.reward },
    rewardText: qDef.rewardText,
    ready: initialCount >= target
  };
}

function initQuests() {
  if (!game.quests) game.quests = {};
  if (!game.quests.fast) game.quests.fast = generateQuest("fast");
  if (!game.quests.strat) game.quests.strat = generateQuest("strat");
  if (!game.quests.epic) game.quests.epic = generateQuest("epic");
}

function updateQuestProgress(key, amount = 1) {
  if (!game.quests) initQuests();
  let anyReady = false;

  ["fast", "strat", "epic"].forEach(tier => {
    const q = game.quests[tier];
    if (q && !q.ready) {
      if (q.key === key) {
        q.current += amount;
      } else if (q.key === "castle_level") {
        q.current = game.castleLevel;
      } else if (q.key === "conquer_total") {
        q.current = game.ownedCount;
      }
      if (q.current >= q.target) {
        q.current = q.target;
        q.ready = true;
        anyReady = true;
      }
    } else if (q && q.ready) {
      anyReady = true;
    }
  });

  const badge = document.getElementById("quest-badge");
  if (badge) {
    badge.classList.toggle("hidden", !anyReady);
  }
}

function claimQuest(tier) {
  if (!game.quests || !game.quests[tier] || !game.quests[tier].ready) return;
  const q = game.quests[tier];
  const rew = q.reward;

  if (rew.food) game.food += rew.food;
  if (rew.wood) game.wood += rew.wood;
  if (rew.stone) game.stone = (game.stone || 0) + rew.stone;
  if (rew.iron) game.iron = (game.iron || 0) + rew.iron;
  if (rew.crowns) game.crowns = (game.crowns || 0) + rew.crowns;
  if (rew.relic) unlockRandomRelic();

  if (audio.playQuestComplete) audio.playQuestComplete();
  else audio.playCollect();

  triggerShockwave(0, 0, "#fde047");
  showToast(`📜 Ferman Tamamlandı! ${q.rewardText} Ambarlara Eklendi!`);
  
  game.quests[tier] = generateQuest(tier);
  saveGame();
  updateUI();
  updateQuestsUI();
  updateQuestProgress("", 0);
}

function updateQuestsUI() {
  if (!game.quests) initQuests();
  const tiers = [
    { id: "fast", descEl: "desc-quest-fast", progEl: "bar-quest-fast", countEl: "count-quest-fast", btnEl: "btn-claim-fast", rewEl: "reward-quest-fast" },
    { id: "strat", descEl: "desc-quest-strat", progEl: "bar-quest-strat", countEl: "count-quest-strat", btnEl: "btn-claim-strat", rewEl: "reward-quest-strat" },
    { id: "epic", descEl: "desc-quest-epic", progEl: "bar-quest-epic", countEl: "count-quest-epic", btnEl: "btn-claim-epic", rewEl: "reward-quest-epic" }
  ];

  tiers.forEach(tDef => {
    const q = game.quests[tDef.id];
    if (!q) return;

    const desc = document.getElementById(tDef.descEl);
    const prog = document.getElementById(tDef.progEl);
    const count = document.getElementById(tDef.countEl);
    const btn = document.getElementById(tDef.btnEl);
    const rew = document.getElementById(tDef.rewEl);

    if (desc) desc.textContent = q.desc;
    if (rew) rew.textContent = q.rewardText;
    if (count) count.textContent = `${Math.min(q.target, Math.floor(q.current))} / ${q.target}`;
    
    const pct = Math.min(100, Math.round((q.current / q.target) * 100));
    if (prog) prog.style.width = `${pct}%`;
    if (btn) {
      btn.disabled = !q.ready;
      btn.textContent = q.ready ? "Ödülü Al!" : "Devam Ediyor";
    }
  });
}

function openQuestsModal() {
  audio.playClick();
  updateQuestsUI();
  modalBackdrop.classList.remove("hidden");
  const modal = document.getElementById("quest-modal");
  if (modal) modal.classList.remove("hidden");
}

// =============================================================================
// 7.2. KADİM ESERLER SİSTEMİ (RELICS & ARTIFACTS)
// =============================================================================

const RELIC_DATA = [
  { key: "axe", name: "Göktürk Baltası", icon: "🪓", perk: "Odun ve Kereste üretimine +%25 verim.", flavor: "Bozkırın kadim demircileri tarafından dövülmüş kutsal savaş baltası." },
  { key: "cornucopia", name: "Bereket Boynuzu", icon: "🏺", perk: "Mısır ve Fırınlara +%25 üretim hızı.", flavor: "Toprağın sonsuz bereketini çağıran efsanevi tören kadehi." },
  { key: "standard", name: "Kurt Başlı Tuğ", icon: "⚔️", perk: "Toprak fetih maliyetlerinde %15 kalıcı indirim.", flavor: "Orduların önünde dalgalanan dokuz kollu kutsal sancak." },
  { key: "shield", name: "Demir Dağ Kalkanı", icon: "🛡️", perk: "Taş ve Demir madenlerine +%30 hız & Gece Savunması.", flavor: "Ergenekon Dağı'nın ilk cevheriyle dövülmüş aşılmaz kalkan." }
];

function unlockRandomRelic() {
  if (!game.relics) game.relics = { axe: false, cornucopia: false, standard: false, shield: false };
  const locked = RELIC_DATA.filter(r => !game.relics[r.key]);
  if (locked.length > 0) {
    const picked = locked[Math.floor(Math.random() * locked.length)];
    game.relics[picked.key] = true;
    showToast(`🏺 Kadim Eser Bulundu: ${picked.name}! (${picked.perk})`);
  } else {
    game.crowns = (game.crowns || 0) + 3;
    showToast(`👑 Tüm Eserler Zaten Açık! +3 Ek Kraliyet Tacı Kazanıldı!`);
  }
}

function openRelicsModal() {
  audio.playClick();
  updateRelicsUI();
  modalBackdrop.classList.remove("hidden");
  const relicsModal = document.getElementById("relics-modal");
  if (relicsModal) relicsModal.classList.remove("hidden");
}

function updateRelicsUI() {
  const container = document.getElementById("relics-grid");
  if (!container) return;
  if (!game.relics) game.relics = { axe: false, cornucopia: false, standard: false, shield: false };

  container.innerHTML = RELIC_DATA.map(r => {
    const unlocked = !!game.relics[r.key];
    return `
      <div class="relic-card ${unlocked ? 'unlocked' : ''}">
        <div class="relic-icon-title">
          <span style="font-size:1.6rem">${r.icon}</span>
          <span style="font-weight:700;color:${unlocked ? '#fde047' : 'var(--text-muted)'}">${r.name}</span>
        </div>
        <div class="relic-perk" style="color:${unlocked ? '#38bdf8' : 'var(--text-muted)'}">${r.perk}</div>
        <div class="relic-flavor" style="font-size:0.75rem;color:var(--text-muted);font-style:italic">${r.flavor}</div>
      </div>
    `;
  }).join("");
}

// =============================================================================
// 7.3. RASTGELE OLAYLAR (RANDOM ENCOUNTERS - KERVAN & ŞAMAN)
// =============================================================================

function processEncounters(delta) {
  game.encounterTimer = (game.encounterTimer || 0) + delta;
  
  if (game.activeEncounter) {
    game.activeEncounter.timeRemaining -= delta;
    if (game.activeEncounter.timeRemaining <= 0) {
      game.activeEncounter = null;
      const encModal = document.getElementById("encounter-modal");
      if (encModal && !encModal.classList.contains("hidden")) {
        closeModals();
      }
    }
  }

  if (game.encounterTimer >= 70.0 && !game.activeEncounter) {
    game.encounterTimer = 0.0;
    const ownedTiles = Object.values(game.tiles).filter(t => t.state === "OWNED");
    if (ownedTiles.length > 0) {
      const t = ownedTiles[Math.floor(Math.random() * ownedTiles.length)];
      const type = Math.random() < 0.5 ? "trader" : "shaman";
      game.activeEncounter = {
        type,
        q: t.q,
        r: t.r,
        timeRemaining: 45.0
      };
      audio.playCollect();
      showToast(type === "trader" ? "🐫 İpek Yolu Kervanı Haritada Belirdi! Tıkla ve Takas Yap!" : "🔮 Bozkır Şamanı Haritada Belirdi! Tıkla ve Kutsama Al!");
    }
  }
}

function updateEncounterTimerUI() {
  if (!game.activeEncounter) return;
  const bar = document.getElementById("encounter-timer-fill");
  if (bar) {
    const pct = Math.max(0, Math.min(100, (game.activeEncounter.timeRemaining / 45.0) * 100));
    bar.style.width = `${pct}%`;
  }
}

function openEncounterModal() {
  if (!game.activeEncounter) return;
  audio.playClick();
  const enc = game.activeEncounter;
  const modal = document.getElementById("encounter-modal");
  const icon = document.getElementById("encounter-icon");
  const title = document.getElementById("encounter-title");
  const desc = document.getElementById("encounter-desc");
  const give = document.getElementById("encounter-give");
  const get = document.getElementById("encounter-get");

  if (enc.type === "trader") {
    if (icon) icon.textContent = "🐫";
    if (title) title.textContent = "Gezgin İpek Yolu Kervanı";
    if (desc) desc.textContent = '"Uzak diyarlardan geldik hakanım! Değerli taş ve odunlarını bize sat, taç ve çılgınlık modu kazan!"';
    if (give) give.textContent = "40 🪨 Taş + 30 🪵 Odun";
    if (get) get.textContent = "2 Kraliyet Tacı (👑) + 30 sn 10x Hız";
  } else {
    if (icon) icon.textContent = "🔮";
    if (title) title.textContent = "Göktürk Şamanı Ayini";
    if (desc) desc.textContent = '"Gök Tengri adına bereket ayini yapalım! Gıda kurban et, 1 dakika boyunca tüm krallık 5 kat hızlı üretsin!"';
    if (give) give.textContent = "30 🥡 Gıda";
    if (get) get.textContent = "60 sn 5x Kutsal Üretim Bonusu";
  }

  modalBackdrop.classList.remove("hidden");
  if (modal) modal.classList.remove("hidden");
}

function acceptEncounter() {
  if (!game.activeEncounter) return;
  const enc = game.activeEncounter;
  if (enc.type === "trader") {
    if ((game.stone || 0) < 40 || game.wood < 30) {
      audio.playError();
      showToast("⚠️ Kervan için yeterli Taş veya Odun yok!", true);
      return;
    }
    game.stone -= 40;
    game.wood -= 30;
    game.crowns = (game.crowns || 0) + 2;
    game.frenzyTimer = (game.frenzyTimer || 0) + 30;
    audio.playPrestige();
    showToast("🌟 Kervan Takası Yapıldı! +2 👑 Taç & 30 sn 10x Çılgınlık Modu!");
  } else {
    if (game.food < 30) {
      audio.playError();
      showToast("⚠️ Şaman ayini için en az 30 Gıda gerekli!", true);
      return;
    }
    game.food -= 30;
    game.shamanBoostTimer = (game.shamanBoostTimer || 0) + 60;
    audio.playPrestige();
    showToast("🔥 Şaman Ayini Kabul Edildi! 60 sn Boyunca 5x Üretim Aktif!");
  }

  game.activeEncounter = null;
  closeModals();
  saveGame();
  updateUI();
}

function declineEncounter() {
  game.activeEncounter = null;
  closeModals();
}

// =============================================================================
// 7.4. SİS ZİNDANLARI & KADİM ESERLER (RUINS EXPLORATION)
// =============================================================================

let currentRuinsTile = null;

function openRuinsModal(tile) {
  currentRuinsTile = tile;
  audio.playClick();
  modalBackdrop.classList.remove("hidden");
  const modal = document.getElementById("ruins-modal");
  if (modal) modal.classList.remove("hidden");
}

function exploreRuinsSafe() {
  if (!currentRuinsTile) return;
  currentRuinsTile.hasRuins = false;
  game.food += 50;
  game.stone = (game.stone || 0) + 30;
  audio.playCollect();
  showToast("👷 İşçiler Harabeyi Temizledi: +50 🥡 Gıda & +30 🪨 Taş!");
  closeModals();
  saveGame();
  updateUI();
  updateQuestProgress("explore_ruins", 1);
}

function exploreRuinsGamble() {
  if (!currentRuinsTile) return;
  currentRuinsTile.hasRuins = false;
  if (audio.playDiceRoll) audio.playDiceRoll();

  const success = Math.random() < 0.70;
  if (success) {
    game.crowns = (game.crowns || 0) + 2;
    unlockRandomRelic();
    audio.playPrestige();
    triggerShockwave(0, 0, "#fde047");
    showToast("🌟 Zafer! Mezarın Derinliklerinde Kadim Eser ve +2 👑 Taç Bulundu!");
  } else {
    audio.playError();
    triggerScreenShake(8.0, 0.4);
    showToast("⚠️ Sis Fırtınası! Mezar boş çıktı.", true);
  }

  closeModals();
  saveGame();
  updateUI();
  updateQuestProgress("explore_ruins", 1);
}

// =============================================================================
// 7.5. GECE BASKINLARI & GÖZCÜ KULESİ MEKANİĞİ (NIGHT RAIDS)
// =============================================================================

function processNightRaids(delta) {
  const dayCycle = (game.animDayTime || 0) % 1.0;
  const currentNightId = Math.floor(game.animDayTime || 0);

  if (dayCycle >= 0.70 && dayCycle <= 0.85) {
    if (game.lastRaidNight !== currentNightId) {
      game.lastRaidNight = currentNightId;
      
      const raidBanner = document.getElementById("night-raid-banner");
      if (raidBanner) {
        raidBanner.classList.remove("hidden");
        setTimeout(() => {
          if (raidBanner) raidBanner.classList.add("hidden");
        }, 4500);
      }

      if (audio.playRaidAlarm) audio.playRaidAlarm();

      const watchtowers = Object.values(game.tiles).filter(t => t.building && t.building.type === "watchtower");
      if (watchtowers.length > 0) {
        const bonusLootFood = 25 * watchtowers.length;
        const bonusLootWood = 20 * watchtowers.length;
        const bonusLootStone = 15 * watchtowers.length;
        game.food += bonusLootFood;
        game.wood += bonusLootWood;
        game.stone = (game.stone || 0) + bonusLootStone;
        
        triggerScreenShake(5.0, 0.2);
        showToast(`🛡️ Gözcü Kuleleri Gece Baskınını Savuşturdu! Ganimet: +${bonusLootFood} 🥡 +${bonusLootWood} 🪵 +${bonusLootStone} 🪨`);
        updateQuestProgress("defend_raid", 1);
      } else {
        const lostFood = Math.min(game.food, 15);
        const lostWood = Math.min(game.wood, 10);
        game.food -= lostFood;
        game.wood -= lostWood;
        triggerScreenShake(10.0, 0.5);
        showToast(`⚠️ Gece Baskını! Savunmasız ambarlardan -${lostFood.toFixed(0)} 🥡 ve -${lostWood.toFixed(0)} 🪵 yağmalandı!`, true);
      }
      saveGame();
      updateUI();
    }
  }
}

// =============================================================================
// 8. DOKUNMATİK / FARE ETKİLEŞİMİ & TIKLAMA
// =============================================================================

function setupInputHandlers() {
  // Fare ile Sürükleme (Pan)
  canvas.addEventListener("mousedown", e => {
    isDragging = true;
    dragStart = { x: e.clientX, y: e.clientY };
  });

  window.addEventListener("mousemove", e => {
    if (!isDragging) return;
    camera.x += e.clientX - dragStart.x;
    camera.y += e.clientY - dragStart.y;
    dragStart = { x: e.clientX, y: e.clientY };
  });

  window.addEventListener("mouseup", () => {
    isDragging = false;
  });

  // Fare Tekerleği ile Zoom
  canvas.addEventListener("wheel", e => {
    e.preventDefault();
    const zoomFactor = e.deltaY < 0 ? 1.1 : 0.9;
    camera.zoom = Math.max(0.4, Math.min(2.2, camera.zoom * zoomFactor));
  }, { passive: false });

  // Mobil Dokunmatik (1 parmak sürükle, 2 parmak pinch zoom)
  canvas.addEventListener("touchstart", e => {
    if (e.touches.length === 1) {
      isDragging = true;
      dragStart = { x: e.touches[0].clientX, y: e.touches[0].clientY };
    } else if (e.touches.length === 2) {
      isDragging = false;
      const dx = e.touches[0].clientX - e.touches[1].clientX;
      const dy = e.touches[0].clientY - e.touches[1].clientY;
      lastTouchDist = Math.hypot(dx, dy);
    }
  }, { passive: true });

  canvas.addEventListener("touchmove", e => {
    if (e.touches.length === 1 && isDragging) {
      camera.x += e.touches[0].clientX - dragStart.x;
      camera.y += e.touches[0].clientY - dragStart.y;
      dragStart = { x: e.touches[0].clientX, y: e.touches[0].clientY };
    } else if (e.touches.length === 2) {
      const dx = e.touches[0].clientX - e.touches[1].clientX;
      const dy = e.touches[0].clientY - e.touches[1].clientY;
      const dist = Math.hypot(dx, dy);
      if (lastTouchDist > 0) {
        const factor = dist / lastTouchDist;
        camera.zoom = Math.max(0.4, Math.min(2.2, camera.zoom * factor));
      }
      lastTouchDist = dist;
    }
  }, { passive: true });

  canvas.addEventListener("touchend", () => {
    isDragging = false;
    lastTouchDist = 0;
  });

  // Karo Tıklaması
  canvas.addEventListener("click", e => {
    audio.init();
    const rect = canvas.getBoundingClientRect();
    const screenX = e.clientX - rect.left;
    const screenY = e.clientY - rect.top;

    // Ekran koordinatını 2D dünya koordinatına çevir
    const worldX = (screenX - window.innerWidth / 2 - camera.x) / camera.zoom;
    const worldY = (screenY - window.innerHeight / 2 - camera.y) / camera.zoom;

    const hexCoord = pixelToHex(worldX, worldY);
    const key = `${hexCoord.q},${hexCoord.r}`;
    const activeTileSource = (game.activeLayer === "UNDERGROUND") ? (game.undergroundTiles || {}) : game.tiles;
    const tile = activeTileSource[key];

    if (tile) {
      handleTileClick(tile);
    }
  });
}

function handleTileClick(tile) {
  triggerTileBounce(tile.q, tile.r);

  // 0. Aktif Rastgele Olay (Kervan veya Şaman) Tıklaması
  if (game.activeEncounter && game.activeEncounter.q === tile.q && game.activeEncounter.r === tile.r) {
    openEncounterModal();
    return;
  }

  // 1. Dinamik Hazine Sandığı Tıklaması
  const chestIdx = (game.activeChests || []).findIndex(c => c.q === tile.q && c.r === tile.r);
  if (chestIdx !== -1) {
    game.activeChests.splice(chestIdx, 1);

    const bonusCrowns = Math.floor(1 + Math.random() * 3);
    const bonusFood = Math.floor(20 + Math.random() * 30);
    const bonusWood = Math.floor(15 + Math.random() * 25);
    const bonusStone = Math.floor(10 + Math.random() * 20);
    const bonusIron = Math.floor(5 + Math.random() * 10);

    game.crowns = (game.crowns || 0) + bonusCrowns;
    game.food = (game.food || 0) + bonusFood;
    game.wood = (game.wood || 0) + bonusWood;
    game.stone = (game.stone || 0) + bonusStone;
    game.iron = (game.iron || 0) + bonusIron;

    const pos = hexToPixel(tile.q, tile.r);
    triggerShockwave(pos.x, pos.y, "#eab308");
    triggerFloatingText(pos.x, pos.y - 25, `+${bonusCrowns} 👑 +${bonusFood} 🥡 +${bonusStone} 🪨`, "#fde047");
    triggerScreenShake(8.0, 0.3);
    audio.playCoin();
    showToast(t("toast_chest_opened", [bonusCrowns, bonusFood, bonusStone, bonusIron]) || `🎁 Sandık Açıldı! +${bonusCrowns} 👑 +${bonusFood} 🥡 +${bonusStone} 🪨 +${bonusIron} ⛏️`);
    saveGame();
    updateUI();
    return;
  }

  if (tile.state === "DISCOVERED") {
    // Deniz ve Köprü Geçiş Kontrolü:
    const activeTileSource = (game.activeLayer === "UNDERGROUND") ? (game.undergroundTiles || {}) : game.tiles;
    const neighbors = NEIGHBOR_DIRS.map(d => `${tile.q + d.q},${tile.r + d.r}`);
    let hasValidAccess = false;
    let blockedByUnbridgedSea = false;

    for (const nKey of neighbors) {
      const nTile = activeTileSource[nKey];
      if (nTile && nTile.state === "OWNED") {
        if (nTile.biome !== BIOMES.SEA) {
          hasValidAccess = true;
          break;
        } else {
          if (nTile.building && nTile.building.type === "bridge") {
            hasValidAccess = true;
            break;
          } else {
            blockedByUnbridgedSea = true;
          }
        }
      }
    }

    if (!hasValidAccess) {
      audio.playError();
      if (blockedByUnbridgedSea) {
        showToast(t("toast_need_bridge"), true);
      } else {
        showToast(t("toast_adjacent_required") || "⚠️ Yalnızca sınır komşunuz olan arazileri fethedebilirsiniz!", true);
      }
      return;
    }

    // Arsa Satın Alma / Fethetme (Mesafe Bölgeleri 1-6, 7-12, 13+)
    const cost = game.getLandExpansionCost(tile.q, tile.r, tile.biome);
    const canAfford = (
      game.food >= (cost.food || 0) &&
      game.wood >= (cost.wood || 0) &&
      game.flour >= (cost.flour || 0) &&
      game.plank >= (cost.plank || 0) &&
      game.bread >= (cost.bread || 0) &&
      game.furniture >= (cost.furniture || 0) &&
      (game.stone || 0) >= (cost.stone || 0) &&
      (game.iron || 0) >= (cost.iron || 0)
    );

    if (canAfford) {
      game.food -= (cost.food || 0);
      game.wood -= (cost.wood || 0);
      game.flour -= (cost.flour || 0);
      game.plank -= (cost.plank || 0);
      game.bread -= (cost.bread || 0);
      game.furniture -= (cost.furniture || 0);
      game.stone = (game.stone || 0) - (cost.stone || 0);
      game.iron = (game.iron || 0) - (cost.iron || 0);

      tile.state = "OWNED";
      game.ownedCount += 1;
      game.purchasedTilesCount += 1;
      game.statTotalConquered += 1;

      const pos = hexToPixel(tile.q, tile.r);
      triggerShockwave(pos.x, pos.y, "#38bdf8");
      triggerScreenShake(6.0, 0.25);
      audio.playExpand();
      game.recalculateVisibility();
      updateQuestProgress("conquer_tile", 1);
      updateQuestProgress("own_tiles", game.ownedCount);
      saveGame();
      updateUI();
      showToast(`🚩 Yeni Karo Fethedildi! (+1 Toprak, Toplam: ${game.ownedCount})`);
    } else {
      audio.playError();
      showToast("⚠️ Yetersiz Kaynak! Bu karoyu fethetmek için gereken malzemeler ambarlarda yok.", true);
    }
  } else if (tile.state === "OWNED") {
    if (tile.hasRuins) {
      openRuinsModal(tile);
    } else if (tile.building) {
      openBuildingMenu(tile);
    } else {
      openBuildMenu(tile);
    }
  }
}

// =============================================================================
// 9. UI MENÜLERİ & BUTONLAR
// =============================================================================

const topBar = document.getElementById("top-bar");
const foodLabel = document.getElementById("food-label");
const woodLabel = document.getElementById("wood-label");
const crownLabel = document.getElementById("crown-label");
const landLabel = document.getElementById("land-label");
const flourLabel = document.getElementById("flour-label");
const plankLabel = document.getElementById("plank-label");
const breadLabel = document.getElementById("bread-label");
const furnitureLabel = document.getElementById("furniture-label");
const stoneLabel = document.getElementById("stone-label");
const ironLabel = document.getElementById("iron-label");
const obsidianLabel = document.getElementById("obsidian-label");
const mithrilLabel = document.getElementById("mithril-label");
const hintLabel = document.getElementById("hint-label");
const drawerRow = document.getElementById("drawer-row");
const btnToggleDrawer = document.getElementById("btn-toggle-drawer");
const btnSettings = document.getElementById("btn-settings");
const btnFrenzy = document.getElementById("btn-frenzy");

const bottomMenu = document.getElementById("bottom-menu");
const menuTitle = document.getElementById("menu-title");
const menuContent = document.getElementById("menu-content");
const btnCloseMenu = document.getElementById("btn-close-menu");

const modalBackdrop = document.getElementById("modal-backdrop");
const settingsModal = document.getElementById("settings-modal");
const prestigeConfirmModal = document.getElementById("prestige-confirm-modal");
const offlineModal = document.getElementById("offline-modal");

function formatCompact(val) {
  if (val === undefined || val === null) return "0";
  if (val < 0) return "-" + formatCompact(-val);
  if (val < 1000) return val % 1 === 0 ? val.toString() : val.toFixed(1);
  if (val < 1000000) return (val / 1000).toFixed(1) + "K";
  if (val < 1000000000) return (val / 1000000).toFixed(1) + "M";
  if (val < 1000000000000) return (val / 1000000000).toFixed(1) + "B";
  return (val / 1000000000000).toFixed(1) + "T";
}

function updateUI() {
  if (foodLabel) foodLabel.textContent = `${t("food")}: ${formatCompact(game.food)}`;
  if (woodLabel) woodLabel.textContent = `${t("wood")}: ${formatCompact(game.wood)}`;
  if (flourLabel) flourLabel.textContent = `${t("flour")}: ${formatCompact(game.flour)}`;
  if (plankLabel) plankLabel.textContent = `${t("plank")}: ${formatCompact(game.plank)}`;
  if (breadLabel) breadLabel.textContent = `${t("bread")}: ${formatCompact(game.bread)}`;
  if (furnitureLabel) furnitureLabel.textContent = `${t("furniture")}: ${formatCompact(game.furniture)}`;
  if (stoneLabel) stoneLabel.textContent = `${t("stone")}: ${formatCompact(game.stone || 0)}`;
  if (ironLabel) ironLabel.textContent = `${t("iron")}: ${formatCompact(game.iron || 0)}`;
  if (crownLabel) crownLabel.textContent = `${formatCompact(game.crowns)}`;
  if (landLabel) landLabel.textContent = `${formatCompact(game.ownedCount)}`;

  if (btnFrenzy) {
    btnFrenzy.textContent = game.frenzyTimer > 0 ? `⚡ 10x (${Math.ceil(game.frenzyTimer)}s)` : "⚡";
  }

  if (hintLabel) {
    if (game.frenzyTimer > 0) hintLabel.textContent = `⚡ 10x MEGA ÇILGINLIK AKTİF! (${Math.ceil(game.frenzyTimer)}s kaldı)`;
    else if (game.castleLevel === 1) hintLabel.textContent = t("hint_castle_1");
    else if (game.castleLevel === 2) hintLabel.textContent = t("hint_castle_2");
    else if (game.food < 1.0) hintLabel.textContent = t("hint_no_food");
    else hintLabel.textContent = t("hint_expand");
  }
}

function openBuildMenu(tile) {
  audio.playClick();
  const isMeadow = (tile.biome === BIOMES.MEADOW);
  const isForest = (tile.biome === BIOMES.FOREST);
  const isSea = (tile.biome === BIOMES.SEA);
  const isMountain = (tile.biome === BIOMES.MOUNTAIN);

  if (isMeadow) menuTitle.textContent = t("build_title_meadow");
  else if (isForest) menuTitle.textContent = t("build_title_forest");
  else if (isSea) menuTitle.textContent = t("build_title_sea");
  else if (isMountain) menuTitle.textContent = t("build_title_mountain") || "⛰️ Dağ İnşaat Menüsü";

  let html = "";
  if (isMeadow) {
    // 1. Mısır Tarlası Kartı
    const cornCount = Object.values(game.tiles).filter(t => t.building && t.building.type === "corn").length;
    const cornCost = cornCount === 0 ? 0 : 2;
    const canCorn = game.food >= cornCost;
    html += `
      <div class="build-card">
        <div class="build-card-info">
          <span class="build-card-icon">🌽</span>
          <div class="build-card-text">
            <h4>${t("corn_name")}</h4>
            <p>${t("corn_desc")}</p>
          </div>
        </div>
        <div class="build-card-action">
          <span class="cost-tag ${canCorn ? '' : 'cant-afford'}">${cornCost === 0 ? t("free") : cornCost + " 🥡"}</span>
          <button class="btn-primary" onclick="buildOnSelected('corn', ${cornCost})">${t("build_btn")}</button>
        </div>
      </div>
    `;

    // 2. Değirmen Kartı (Tier 2)
    const isLvl3 = game.castleLevel >= 3;
    const canMill = isLvl3 && game.food >= 5 && game.wood >= 3;
    html += `
      <div class="build-card">
        <div class="build-card-info">
          <span class="build-card-icon">🌾</span>
          <div class="build-card-text">
            <h4>${t("windmill_name")}</h4>
            <p>${t("windmill_desc")}</p>
          </div>
        </div>
        <div class="build-card-action">
          <span class="cost-tag ${canMill ? '' : 'cant-afford'}">${isLvl3 ? '5 🥡 + 3 🪵' : t('locked_castle_3')}</span>
          <button class="btn-primary" ${isLvl3 ? '' : 'disabled'} onclick="buildOnSelected('windmill', 5, 3)">${t("build_btn")}</button>
        </div>
      </div>
    `;

    // 3. Taş Fırın Kartı (Tier 3)
    const isLvl4 = game.castleLevel >= 4;
    const canBakery = isLvl4 && game.food >= 10 && game.flour >= 8;
    html += `
      <div class="build-card">
        <div class="build-card-info">
          <span class="build-card-icon">🍞</span>
          <div class="build-card-text">
            <h4>${t("bakery_name")}</h4>
            <p>${t("bakery_desc")}</p>
          </div>
        </div>
        <div class="build-card-action">
          <span class="cost-tag ${canBakery ? '' : 'cant-afford'}">${isLvl4 ? '10 🥡 + 8 🌾' : t('locked_castle_4')}</span>
          <button class="btn-primary" ${isLvl4 ? '' : 'disabled'} onclick="buildOnSelected('bakery', 10, 0, 8, 0)">${t("build_btn")}</button>
        </div>
      </div>
    `;

    // 4. Gözcü Kulesi (Savunma)
    const canTower = (game.wood >= 20 && (game.stone || 0) >= 15);
    html += `
      <div class="build-card">
        <div class="build-card-info">
          <span class="build-card-icon">🏹</span>
          <div class="build-card-text">
            <h4>${t("watchtower_name")}</h4>
            <p>${t("watchtower_desc")}</p>
          </div>
        </div>
        <div class="build-card-action">
          <span class="cost-tag ${canTower ? '' : 'cant-afford'}">20 🪵 + 15 🪨</span>
          <button class="btn-primary" onclick="buildOnSelected('watchtower', 0, 20, 0, 0, 0, 0, 15, 0)">${t("build_btn")}</button>
        </div>
      </div>
    `;
  } else if (isForest) {
    // 1. Oduncu Kulübesi
    const lumberCount = Object.values(game.tiles).filter(t => t.building && t.building.type === "lumberjack").length;
    const lumberCost = lumberCount === 0 ? 2 : 2 + lumberCount * 2;
    const canLumber = game.food >= lumberCost;
    html += `
      <div class="build-card">
        <div class="build-card-info">
          <span class="build-card-icon">🪓</span>
          <div class="build-card-text">
            <h4>${t("lumberjack_name")}</h4>
            <p>${t("lumberjack_desc")}</p>
          </div>
        </div>
        <div class="build-card-action">
          <span class="cost-tag ${canLumber ? '' : 'cant-afford'}">${lumberCost} 🥡</span>
          <button class="btn-primary" onclick="buildOnSelected('lumberjack', ${lumberCost})">${t("build_btn")}</button>
        </div>
      </div>
    `;

    // 2. Kereste Fabrikası (Tier 2)
    const isLvl3 = game.castleLevel >= 3;
    const canSaw = isLvl3 && game.food >= 4 && game.wood >= 5;
    html += `
      <div class="build-card">
        <div class="build-card-info">
          <span class="build-card-icon">🪵</span>
          <div class="build-card-text">
            <h4>${t("sawmill_name")}</h4>
            <p>${t("sawmill_desc")}</p>
          </div>
        </div>
        <div class="build-card-action">
          <span class="cost-tag ${canSaw ? '' : 'cant-afford'}">${isLvl3 ? '4 🥡 + 5 🪵' : t('locked_castle_3')}</span>
          <button class="btn-primary" ${isLvl3 ? '' : 'disabled'} onclick="buildOnSelected('sawmill', 4, 5)">${t("build_btn")}</button>
        </div>
      </div>
    `;

    // 3. Mobilyacı Kartı (Tier 3)
    const isLvl4 = game.castleLevel >= 4;
    const canFurn = isLvl4 && game.wood >= 12 && game.plank >= 6;
    html += `
      <div class="build-card">
        <div class="build-card-info">
          <span class="build-card-icon">🪑</span>
          <div class="build-card-text">
            <h4>${t("furniture_name")}</h4>
            <p>${t("furniture_desc")}</p>
          </div>
        </div>
        <div class="build-card-action">
          <span class="cost-tag ${canFurn ? '' : 'cant-afford'}">${isLvl4 ? '12 🪵 + 6 🪵 Kereste' : t('locked_castle_4')}</span>
          <button class="btn-primary" ${isLvl4 ? '' : 'disabled'} onclick="buildOnSelected('furniture', 0, 12, 0, 6)">${t("build_btn")}</button>
        </div>
      </div>
    `;
  } else if (isMountain) {
    // 1. Taş Ocağı
    const canQuarry = game.wood >= 40 && game.plank >= 20;
    html += `
      <div class="build-card">
        <div class="build-card-info">
          <span class="build-card-icon">🪨</span>
          <div class="build-card-text">
            <h4>${t("quarry_name")}</h4>
            <p>${t("quarry_desc")}</p>
          </div>
        </div>
        <div class="build-card-action">
          <span class="cost-tag ${canQuarry ? '' : 'cant-afford'}">40 🪵 + 20 🪵 Kereste</span>
          <button class="btn-primary" onclick="buildOnSelected('quarry', 0, 40, 0, 20)">${t("build_btn")}</button>
        </div>
      </div>
    `;

    // 2. Demir Madeni (Tier 3 - Şato Seviye 4)
    const isLvl4 = game.castleLevel >= 4;
    const canMine = isLvl4 && game.wood >= 60 && (game.stone || 0) >= 30;
    html += `
      <div class="build-card">
        <div class="build-card-info">
          <span class="build-card-icon">⛏️</span>
          <div class="build-card-text">
            <h4>${t("mine_name")}</h4>
            <p>${t("mine_desc")}</p>
          </div>
        </div>
        <div class="build-card-action">
          <span class="cost-tag ${canMine ? '' : 'cant-afford'}">${isLvl4 ? '60 🪵 + 30 🪨' : t('locked_castle_4')}</span>
          <button class="btn-primary" ${isLvl4 ? '' : 'disabled'} onclick="buildOnSelected('mine', 0, 60, 0, 0, 0, 0, 30)">${t("build_btn")}</button>
        </div>
      </div>
    `;

    // 3. Dağ Gözcü Kulesi (Savunma)
    const canTowerMtn = (game.wood >= 20 && (game.stone || 0) >= 15);
    html += `
      <div class="build-card">
        <div class="build-card-info">
          <span class="build-card-icon">🏹</span>
          <div class="build-card-text">
            <h4>${t("watchtower_name")}</h4>
            <p>${t("watchtower_desc")}</p>
          </div>
        </div>
        <div class="build-card-action">
          <span class="cost-tag ${canTowerMtn ? '' : 'cant-afford'}">20 🪵 + 15 🪨</span>
          <button class="btn-primary" onclick="buildOnSelected('watchtower', 0, 20, 0, 0, 0, 0, 15, 0)">${t("build_btn")}</button>
        </div>
      </div>
    `;
  } else if (isSea) {
    // 1. Ahşap Köprü Kartı (Deniz Üzerine)
    const canBridge = game.wood >= 4;
    html += `
      <div class="build-card">
        <div class="build-card-info">
          <span class="build-card-icon">🌉</span>
          <div class="build-card-text">
            <h4>${t("bridge_name")}</h4>
            <p>${t("bridge_desc")}</p>
          </div>
        </div>
        <div class="build-card-action">
          <span class="cost-tag ${canBridge ? '' : 'cant-afford'}">4 🪵</span>
          <button class="btn-primary" onclick="buildOnSelected('bridge', 0, 4)">${t("build_btn")}</button>
        </div>
      </div>
    `;
  }

  // 3. İşçi Kulübesi Kartı (Deniz hariç her yerde yapılabilir)
  if (!isSea) {
    const workerCount = Object.values(game.tiles).filter(t => t.building && t.building.type === "worker").length;
    const workerCost = workerCount === 0 ? 0 : 3;
    const canWorker = game.food >= workerCost;
    html += `
      <div class="build-card">
        <div class="build-card-info">
          <span class="build-card-icon">🛖</span>
          <div class="build-card-text">
            <h4>${t("worker_name")}</h4>
            <p>${t("worker_desc")}</p>
          </div>
        </div>
        <div class="build-card-action">
          <span class="cost-tag ${canWorker ? '' : 'cant-afford'}">${workerCost === 0 ? t("free") : workerCost + " 🥡"}</span>
          <button class="btn-primary" onclick="buildOnSelected('worker', ${workerCost})">${t("build_btn")}</button>
        </div>
      </div>
    `;
  }

  menuContent.innerHTML = html;

  // ORMAN hexinde Ormansızlaştır butonu ekle
  if (tile.biome && tile.biome.name === 'FOREST') {
    menuContent.innerHTML += `
      <hr style="border-color:rgba(80,200,100,0.3);margin:6px 0">
      <button class="btn-upgrade" style="background:rgba(40,160,80,0.18);color:#55dd88;width:100%;border:1px solid rgba(80,200,100,0.35)" onclick="deforestTile()">
        🌿 Ağaçları Kurut (Orman → Çayır) &nbsp;<small>(Ücretsiz)</small>
      </button>
    `;
  }

  bottomMenu.classList.remove("hidden");
}

window.buildOnSelected = function(bType, foodCost = 0, woodCost = 0, flourCost = 0, plankCost = 0, breadCost = 0, furnitureCost = 0, stoneCost = 0, ironCost = 0) {
  if (!game.selectedTile) return;
  if (game.food < foodCost || game.wood < woodCost || game.flour < flourCost || game.plank < plankCost || game.bread < breadCost || game.furniture < furnitureCost || (game.stone || 0) < stoneCost || (game.iron || 0) < ironCost) {
    audio.playError();
    showToast(t("toast_insufficient_res"), true);
    return;
  }

  game.food -= foodCost;
  game.wood -= woodCost;
  game.flour -= flourCost;
  game.plank -= plankCost;
  game.bread -= breadCost;
  game.furniture -= furnitureCost;
  game.stone = (game.stone || 0) - stoneCost;
  game.iron = (game.iron || 0) - ironCost;

  game.selectedTile.building = {
    type: bType,
    level: 1,
    accumulated: 0.0
  };

  audio.playBuild();
  closeBottomMenu();
  
  // Görev İlerlemesi
  updateQuestProgress("build_building", 1);
  updateQuestProgress("build_" + bType, 1);

  saveGame();
  renderMap();

  if (bType === 'corn') showToast(t("toast_built_corn"));
  else if (bType === 'windmill') showToast(t("toast_built_windmill"));
  else if (bType === 'bakery') showToast(t("toast_built_bakery"));
  else if (bType === 'lumberjack') showToast(t("toast_built_lumberjack"));
  else if (bType === 'sawmill') showToast(t("toast_built_sawmill"));
  else if (bType === 'furniture') showToast(t("toast_built_furniture"));
  else if (bType === 'quarry') showToast(t("toast_built_quarry") || "🪨 Taş Ocağı kuruldu!");
  else if (bType === 'mine') showToast(t("toast_built_mine") || "⛏️ Demir Madeni açıldı!");
  else if (bType === 'worker') showToast(t("toast_built_worker"));
  else if (bType === 'watchtower') showToast(t("toast_built_watchtower") || "🏹 Gözcü Kulesi kuruldu! Gece savunması aktif.");
  else if (bType === 'bridge') showToast(t("toast_built_bridge"));
};

function openBuildingMenu(tile) {
  audio.playClick();
  const b = tile.building;

  if (b.type === "castle") {
    menuTitle.textContent = `${CASTLE_TITLES[game.castleLevel - 1]} (${t("level")} ${game.castleLevel})`;
    const bonusPct = Math.round((game.getGlobalMultiplier() - 1.0) * 100);
    const upData = CASTLE_UPGRADES[game.castleLevel];

    let btnHtml = "";
    if (game.castleLevel >= 10) {
      btnHtml = `<button class="btn-upgrade" disabled>${t("max_level")}</button>`;
    } else {
      const costStr = upData.costWood === 0 ? `${upData.costFood} 🥡` : `${upData.costFood} 🥡 + ${upData.costWood} 🪵`;
      const canAfford = game.food >= upData.costFood && game.wood >= upData.costWood;
      btnHtml = `
        <button class="btn-upgrade" onclick="upgradeCastle()" ${canAfford ? '' : 'style="opacity:0.6"'}>
          <span>${t("upgrade")} (${costStr})</span>
          <small>${upData.nextTitle} (+%25)</small>
        </button>
      `;
    }

    menuContent.innerHTML = `
      <div class="prod-flow-row">
        <div class="prod-icon-box">👑</div>
        <div style="flex:1">
          <p style="color:var(--green);font-weight:700;font-size:0.9rem">${t("global_bonus")}: +%${bonusPct}</p>
          <p style="color:var(--gold);font-size:0.76rem">${upData ? t("next_unlock") + ': ' + upData.unlock : t("max_power_active")}</p>
        </div>
        ${btnHtml}
      </div>
    `;
  } else if (b.type === "corn") {
    menuTitle.textContent = `🌽 ${t("corn_name")} (${t("level")} ${b.level})`;
    const rate = (0.42 * Math.pow(1.5, b.level - 1)) * game.getGlobalMultiplier();
    const upCost = Math.round(2 * Math.pow(1.8, b.level - 1));
    const accum = b.accumulated || 0;
    const cornRefund = Math.max(0, game.purchasedMeadowCount * 0.5).toFixed(1);

    menuContent.innerHTML = `
      <div class="prod-flow-row">
        <div class="prod-icon-box">🌽</div>
        <div class="prod-rate-box">
          <span>${rate.toFixed(2)} ${t("per_sec")}</span>
          <span class="arrow">──▶</span>
        </div>
        <button class="btn-collect" onclick="collectCorn()">
          <span>${accum.toFixed(2)}x1 🌽</span>
          <small>${accum.toFixed(2)} 🥡 ${t("collect")}</small>
        </button>
        <button class="btn-upgrade" onclick="upgradeBuilding('corn', ${upCost})">
          <span>⬆️ ${t("upgrade")} (${upCost} 🥡)</span>
          <small>+${(rate * 0.5).toFixed(2)} ${t("per_sec")}</small>
        </button>
      </div>
      <hr style="border-color:rgba(255,100,80,0.3);margin:6px 0">
      <button class="btn-upgrade" style="background:rgba(200,60,50,0.18);color:#ff6655;width:100%;border:1px solid rgba(200,60,50,0.35)" onclick="demolishBuilding('corn', ${cornRefund}, 0)">
        🔨 Yapıyı Yık &nbsp;<small>(%50 iade: ${cornRefund} 🥡)</small>
      </button>
    `;
  } else if (b.type === "windmill") {
    menuTitle.textContent = `🌾 ${t("windmill_name")} (${t("level")} ${b.level})`;
    const rate = (0.25 * Math.pow(1.5, b.level - 1)) * game.getGlobalMultiplier();
    const upFood = Math.round(5 * Math.pow(1.6, b.level - 1));
    const upWood = Math.round(4 * Math.pow(1.6, b.level - 1));
    const accum = b.accumulated || 0;

    menuContent.innerHTML = `
      <div class="prod-flow-row">
        <div class="prod-icon-box">🌾</div>
        <div class="prod-rate-box">
          <span>${rate.toFixed(2)} ${t("flour")}${t("per_sec")}</span>
          <small style="font-size:0.65rem">${b.isAdjacent ? t("supply_neighbor") : t("supply_global")}</small>
        </div>
        <button class="btn-collect" onclick="collectFlour()">
          <span>${accum.toFixed(2)} 🌾</span>
          <small>${t("collect")}</small>
        </button>
        <button class="btn-upgrade" onclick="upgradeBuildingMulti('windmill', ${upFood}, ${upWood})">
          <span>⬆️ (${upFood} 🥡+${upWood} 🪵)</span>
          <small>+${(rate * 0.5).toFixed(2)}/sn</small>
        </button>
      </div>
      <hr style="border-color:rgba(255,100,80,0.3);margin:6px 0">
      <button class="btn-upgrade" style="background:rgba(200,60,50,0.18);color:#ff6655;width:100%;border:1px solid rgba(200,60,50,0.35)" onclick="demolishBuilding('windmill', 2.5, 1.5)">
        🔨 Yapıyı Yık &nbsp;<small>(%50 iade: 2.5 🥡 + 1.5 🪵)</small>
      </button>
    `;
  } else if (b.type === "bakery") {
    menuTitle.textContent = `🍞 ${t("bakery_name")} (${t("level")} ${b.level})`;
    const rate = (0.25 * Math.pow(1.5, b.level - 1)) * game.getGlobalMultiplier();
    const upFood = Math.round(10 * Math.pow(1.35, b.level - 1));
    const upFlour = Math.round(8 * Math.pow(1.35, b.level - 1));
    const accum = b.accumulated || 0;

    menuContent.innerHTML = `
      <div class="prod-flow-row">
        <div class="prod-icon-box">🍞</div>
        <div class="prod-rate-box">
          <span>${rate.toFixed(2)} ${t("bread")}${t("per_sec")}</span>
          <small style="font-size:0.65rem">${b.isAdjacent ? t("supply_neighbor_flour") : t("supply_global")}</small>
        </div>
        <button class="btn-collect" onclick="collectBread()">
          <span>${accum.toFixed(2)} 🍞</span>
          <small>${t("collect")}</small>
        </button>
        <button class="btn-upgrade" onclick="upgradeBuildingMulti('bakery', ${upFood}, 0, ${upFlour}, 0)">
          <span>⬆️ (${upFood} 🥡+${upFlour} 🌾)</span>
          <small>+${(rate * 0.5).toFixed(2)}/sn</small>
        </button>
      </div>
    `;
  } else if (b.type === "lumberjack") {
    menuTitle.textContent = `🪓 ${t("lumberjack_name")} (${t("level")} ${b.level})`;
    const rate = (0.35 * Math.pow(1.5, b.level - 1)) * game.getGlobalMultiplier();
    const upCost = Math.round(2 * Math.pow(1.8, b.level - 1));
    const accum = b.accumulated || 0;

    menuContent.innerHTML = `
      <div class="prod-flow-row">
        <div class="prod-icon-box">🪓</div>
        <div class="prod-rate-box">
          <span>${rate.toFixed(2)} ${t("per_sec")}</span>
          <span class="arrow">──▶</span>
        </div>
        <button class="btn-collect" onclick="collectWood()">
          <span>${accum.toFixed(2)}x1 🪵</span>
          <small>${accum.toFixed(2)} 🪵 ${t("collect")}</small>
        </button>
        <button class="btn-upgrade" onclick="upgradeBuilding('lumberjack', ${upCost})">
          <span>⬆️ ${t("upgrade")} (${upCost} 🥡)</span>
          <small>+${(rate * 0.5).toFixed(2)} ${t("per_sec")}</small>
        </button>
      </div>
      <hr style="border-color:rgba(255,100,80,0.3);margin:6px 0">
      <button class="btn-upgrade" style="background:rgba(200,60,50,0.18);color:#ff6655;width:100%;border:1px solid rgba(200,60,50,0.35)" onclick="demolishBuilding('lumberjack', ${Math.floor(upCost * 0.5)}, 0)">
        🔨 Yapıyı Yık &nbsp;<small>(%50 iade: ${Math.floor(upCost * 0.5)} 🥡)</small>
      </button>
    `;
  } else if (b.type === "sawmill") {
    menuTitle.textContent = `🪵 ${t("sawmill_name")} (${t("level")} ${b.level})`;
    const rate = (0.20 * Math.pow(1.5, b.level - 1)) * game.getGlobalMultiplier();
    const upFood = Math.round(4 * Math.pow(1.6, b.level - 1));
    const upWood = Math.round(6 * Math.pow(1.6, b.level - 1));
    const accum = b.accumulated || 0;

    menuContent.innerHTML = `
      <div class="prod-flow-row">
        <div class="prod-icon-box">🪵</div>
        <div class="prod-rate-box">
          <span>${rate.toFixed(2)} ${t("plank")}${t("per_sec")}</span>
          <small style="font-size:0.65rem">${b.isAdjacent ? t("supply_neighbor_wood") : t("supply_global")}</small>
        </div>
        <button class="btn-collect" onclick="collectPlank()">
          <span>${accum.toFixed(2)} 🪵</span>
          <small>${t("collect")}</small>
        </button>
        <button class="btn-upgrade" onclick="upgradeBuildingMulti('sawmill', ${upFood}, ${upWood})">
          <span>⬆️ (${upFood} 🥡+${upWood} 🪵)</span>
          <small>+${(rate * 0.5).toFixed(2)}/sn</small>
        </button>
      </div>
    `;
  } else if (b.type === "furniture") {
    menuTitle.textContent = `🪑 ${t("furniture_name")} (${t("level")} ${b.level})`;
    const rate = (0.20 * Math.pow(1.5, b.level - 1)) * game.getGlobalMultiplier();
    const upWood = Math.round(12 * Math.pow(1.35, b.level - 1));
    const upPlank = Math.round(8 * Math.pow(1.35, b.level - 1));
    const accum = b.accumulated || 0;

    menuContent.innerHTML = `
      <div class="prod-flow-row">
        <div class="prod-icon-box">🪑</div>
        <div class="prod-rate-box">
          <span>${rate.toFixed(2)} ${t("furniture")}${t("per_sec")}</span>
          <small style="font-size:0.65rem">${b.isAdjacent ? t("supply_neighbor_plank") : t("supply_global")}</small>
        </div>
        <button class="btn-collect" onclick="collectFurniture()">
          <span>${accum.toFixed(2)} 🪑</span>
          <small>${t("collect")}</small>
        </button>
        <button class="btn-upgrade" onclick="upgradeBuildingMulti('furniture', 0, ${upWood}, 0, ${upPlank})">
          <span>⬆️ (${upWood} 🪵+${upPlank} 🪵 Kereste)</span>
          <small>+${(rate * 0.5).toFixed(2)}/sn</small>
        </button>
      </div>
    `;
  } else if (b.type === "worker") {
    menuTitle.textContent = `🛖 ${t("worker_name")} (${t("level")} ${b.level})`;
    const rate = (0.80 * Math.pow(1.5, b.level - 1)) * game.getGlobalMultiplier();
    const upCost = Math.round(3 * Math.pow(1.7, b.level - 1));
    const gathered = b.totalGathered || 0;

    menuContent.innerHTML = `
      <div class="prod-flow-row">
        <div class="prod-icon-box">🛖</div>
        <div style="flex:1">
          <p style="color:var(--green);font-weight:700;font-size:0.85rem">${t("auto_carry")}: ${rate.toFixed(2)} ${t("per_sec")}</p>
          <p style="color:var(--text-muted);font-size:0.75rem">${t("total_transferred")}: ${gathered.toFixed(1)}</p>
        </div>
        <button class="btn-upgrade" onclick="upgradeBuilding('worker', ${upCost})">
          <span>⬆️ ${t("upgrade")} (${upCost} 🥡)</span>
          <small>+${(rate * 0.5).toFixed(2)} ${t("per_sec")}</small>
        </button>
      </div>
    `;
  } else if (b.type === "quarry") {
    menuTitle.textContent = `🪨 ${t("quarry_name")} (${t("level")} ${b.level})`;
    const rate = (0.35 * Math.pow(1.5, b.level - 1)) * game.getGlobalMultiplier();
    const upWood = Math.round(15 * Math.pow(1.4, b.level - 1));
    const upPlank = Math.round(8 * Math.pow(1.4, b.level - 1));
    const accum = b.accumulated || 0;

    menuContent.innerHTML = `
      <div class="prod-flow-row">
        <div class="prod-icon-box">🪨</div>
        <div class="prod-rate-box">
          <span>${rate.toFixed(2)} ${t("stone")}${t("per_sec")}</span>
          <small style="font-size:0.65rem">${b.isAdjacent ? t("supply_neighbor_plank") : t("supply_global")}</small>
        </div>
        <button class="btn-collect" onclick="collectStone()">
          <span>${accum.toFixed(2)} 🪨</span>
          <small>${t("collect")}</small>
        </button>
        <button class="btn-upgrade" onclick="upgradeBuildingMulti('quarry', 0, ${upWood}, 0, ${upPlank})">
          <span>⬆️ (${upWood} 🪵+${upPlank} 🪵 Kereste)</span>
          <small>+${(rate * 0.5).toFixed(2)}/sn</small>
        </button>
      </div>
    `;
  } else if (b.type === "mine") {
    menuTitle.textContent = `⛏️ ${t("mine_name")} (${t("level")} ${b.level})`;
    const rate = (0.25 * Math.pow(1.5, b.level - 1)) * game.getGlobalMultiplier();
    const upWood = Math.round(25 * Math.pow(1.4, b.level - 1));
    const upStone = Math.round(15 * Math.pow(1.4, b.level - 1));
    const accum = b.accumulated || 0;

    menuContent.innerHTML = `
      <div class="prod-flow-row">
        <div class="prod-icon-box">⛏️</div>
        <div class="prod-rate-box">
          <span>${rate.toFixed(2)} ${t("iron")}${t("per_sec")}</span>
          <small style="font-size:0.65rem">${b.isAdjacent ? t("supply_neighbor") : t("supply_global")}</small>
        </div>
        <button class="btn-collect" onclick="collectIron()">
          <span>${accum.toFixed(2)} ⛏️</span>
          <small>${t("collect")}</small>
        </button>
        <button class="btn-upgrade" onclick="upgradeBuildingMulti('mine', 0, ${upWood}, 0, 0, 0, 0, ${upStone})">
          <span>⬆️ (${upWood} 🪵+${upStone} 🪨)</span>
          <small>+${(rate * 0.5).toFixed(2)}/sn</small>
        </button>
      </div>
    `;
  } else if (b.type === "watchtower") {
    menuTitle.textContent = `🏹 ${t("watchtower_name")} (${t("level")} ${b.level})`;
    const costWood = Math.round(15 * Math.pow(1.4, b.level - 1));
    const costStone = Math.round(10 * Math.pow(1.4, b.level - 1));

    menuContent.innerHTML = `
      <div class="prod-flow-row">
        <div class="prod-icon-box">🛡️</div>
        <div style="flex:1;text-align:left">
          <p style="color:#38bdf8;font-weight:700;font-size:0.85rem">Savunma Gücü: ${b.level * 25} Güç</p>
          <small style="color:var(--text-muted);font-size:0.75rem">Gece akıncılarını püskürtür ve ambarları korur.</small>
        </div>
        <button class="btn-upgrade" onclick="upgradeBuildingMulti('watchtower', 0, ${costWood}, 0, 0, 0, 0, ${costStone})">
          <span>⬆️ (${costWood} 🪵 + ${costStone} 🪨)</span>
          <small>Savunma +25</small>
        </button>
      </div>
      <hr style="border-color:rgba(255,100,80,0.3);margin:6px 0">
      <button class="btn-upgrade" style="background:rgba(200,60,50,0.18);color:#ff6655;width:100%;border:1px solid rgba(200,60,50,0.35)" onclick="demolishBuilding('watchtower', 0, 10, 0, 0, 0, 0, 7.5)">
        🔨 Yapıyı Yık &nbsp;<small>(%50 iade: 10 🪵 + 7.5 🪨)</small>
      </button>
    `;
  }

  if (b.type !== "castle") {
    if (tile.isWarmed) {
      menuContent.innerHTML += `
        <div style="background:rgba(249,115,22,0.15);border:1px solid #f97316;border-radius:8px;padding:6px 10px;margin-top:6px;font-size:0.75rem;color:#fdba74;text-align:center;font-weight:600">
          🔥 Tarla Isıtıldı! (+%50 Hız & Donma Koruması Aktif)
        </div>
      `;
    } else {
      const canAfford = (game.wood || 0) >= 5;
      menuContent.innerHTML += `
        <button class="btn-warm-tile" style="margin-top:6px;width:100%" onclick="warmTile()" ${canAfford ? '' : 'style="opacity:0.6"'}>
          🔥 Ateş Yak & Tarlayı Isıt (5 🪵 Odun) <small>— +%50 Hız</small>
        </button>
      `;
    }
  }

  bottomMenu.classList.remove("hidden");
}

function updateOpenMenuLive() {
  if (bottomMenu.classList.contains("hidden") || !game.selectedTile) return;
  const b = game.selectedTile.building;
  if (!b) return;
}

function closeBottomMenu() {
  bottomMenu.classList.add("hidden");
  game.selectedTile = null;
}

// === YAPI YIKMA & ORMANLAŞTIRMA ===
window.demolishBuilding = function(type, refundFood, refundWood) {
  if (!game.selectedTile || !game.selectedTile.building) return;
  const b = game.selectedTile.building;
  const accum = b.accumulated || 0;
  // Birikmiş kaynakları topla
  if (type === 'corn') { game.food += accum; game.statTotalFood = (game.statTotalFood || 0) + accum; }
  else if (type === 'windmill') { game.flour += accum; }
  else if (type === 'lumberjack') { game.wood += accum; game.statTotalWood = (game.statTotalWood || 0) + accum; }
  else if (type === 'sawmill') { game.plank += accum; }
  // Kaynak iadesi
  game.food += parseFloat(refundFood) || 0;
  game.wood += parseFloat(refundWood) || 0;
  // Binayı kaldır
  game.selectedTile.building = null;
  closeBottomMenu();
  audio.playBuild();
  showToast('🔨 Yapı yıkıldı! Kaynaklarınız iade edildi.');
  saveGame();
  renderMap();
  updateUI();
};

window.deforestTile = function() {
  if (!game.selectedTile) return;
  const tile = game.selectedTile;
  if (!tile.biome || tile.biome.name !== 'FOREST') return;
  // Orman binası varsa birikimi topla
  if (tile.building && tile.building.accumulated > 0) {
    game.wood += tile.building.accumulated;
  }
  // Binayı kaldır
  tile.building = null;
  // Biyomu MEADOW yap
  tile.biome = BIOMES.MEADOW;
  closeBottomMenu();
  audio.playBuild();
  showToast('🌿 Ağaçlar kurutuldu! Hex çayıra dönüştü.');
  saveGame();
  renderMap();
  updateUI();
};

// Koleksiyon İşlemleri (Kritik Hasat / Bereketli Hasat Destekli)
function processLuckyHarvest(val, icon, resColor, toastKey) {
  const isCrit = Math.random() < 0.15;
  const mult = isCrit ? 3.0 : 1.0;
  const finalVal = val * mult;
  const p = hexToPixel(game.selectedTile.q, game.selectedTile.r);
  
  triggerTileBounce(game.selectedTile.q, game.selectedTile.r);
  triggerFlyingResource(p.x, p.y, icon, resColor);
  triggerFloatingText(p.x, p.y - 25, `+${formatCompact(finalVal)}`, isCrit ? "#f59e0b" : resColor);
  triggerScreenShake(isCrit ? 6.0 : 2.5, isCrit ? 0.22 : 0.12);

  if (isCrit) {
    if (audio.playCritHarvest) audio.playCritHarvest();
    else audio.playCollect();
    triggerShockwave(p.x, p.y, "#f59e0b");
    showToast(`✨ BEREKETLİ HASAT! +${formatCompact(finalVal)} ${icon} (3x Kritik)`);
  } else {
    audio.playCollect();
    if (toastKey) showToast(t(toastKey, [formatCompact(finalVal)]));
  }
  
  checkTitlesAndAchievements();
  return finalVal;
}

window.collectCorn = function() {
  if (!game.selectedTile || !game.selectedTile.building) return;
  const b = game.selectedTile.building;
  const val = b.accumulated || 0;
  if (val > 0.001) {
    b.accumulated = 0;
    const gained = processLuckyHarvest(val, "🌽", "#eab308", "toast_collected_food");
    game.food += gained;
    game.statTotalFood += gained;
    updateQuestProgress("collect_food", gained);
    openBuildingMenu(game.selectedTile);
  }
};

window.collectWood = function() {
  if (!game.selectedTile || !game.selectedTile.building) return;
  const b = game.selectedTile.building;
  const val = b.accumulated || 0;
  if (val > 0.001) {
    b.accumulated = 0;
    const gained = processLuckyHarvest(val, "🪵", "#d4a373", "toast_collected_wood");
    game.wood += gained;
    game.statTotalWood += gained;
    updateQuestProgress("collect_wood", gained);
    openBuildingMenu(game.selectedTile);
  }
};

window.collectFlour = function() {
  if (!game.selectedTile || !game.selectedTile.building) return;
  const b = game.selectedTile.building;
  const val = b.accumulated || 0;
  if (val > 0.001) {
    b.accumulated = 0;
    const gained = processLuckyHarvest(val, "🌾", "#fef08a", "toast_collected_flour");
    game.flour += gained;
    game.statTotalFlour += gained;
    openBuildingMenu(game.selectedTile);
  }
};

window.collectPlank = function() {
  if (!game.selectedTile || !game.selectedTile.building) return;
  const b = game.selectedTile.building;
  const val = b.accumulated || 0;
  if (val > 0.001) {
    b.accumulated = 0;
    const gained = processLuckyHarvest(val, "🪵", "#fbcfe8", "toast_collected_plank");
    game.plank += gained;
    game.statTotalPlank += gained;
    openBuildingMenu(game.selectedTile);
  }
};

window.collectBread = function() {
  if (!game.selectedTile || !game.selectedTile.building) return;
  const b = game.selectedTile.building;
  const val = b.accumulated || 0;
  if (val > 0.001) {
    b.accumulated = 0;
    const gained = processLuckyHarvest(val, "🍞", "#fdba74", "toast_collected_bread");
    game.bread += gained;
    game.statTotalBread += gained;
    openBuildingMenu(game.selectedTile);
  }
};

window.collectFurniture = function() {
  if (!game.selectedTile || !game.selectedTile.building) return;
  const b = game.selectedTile.building;
  const val = b.accumulated || 0;
  if (val > 0.001) {
    b.accumulated = 0;
    const gained = processLuckyHarvest(val, "🪑", "#93c5fd", "toast_collected_furniture");
    game.furniture += gained;
    game.statTotalFurniture += gained;
    openBuildingMenu(game.selectedTile);
  }
};

window.collectStone = function() {
  if (!game.selectedTile || !game.selectedTile.building) return;
  const b = game.selectedTile.building;
  const val = b.accumulated || 0;
  if (val > 0.001) {
    b.accumulated = 0;
    const gained = processLuckyHarvest(val, "🪨", "#cbd5e1", "toast_collected_stone");
    game.stone = (game.stone || 0) + gained;
    game.statTotalStone = (game.statTotalStone || 0) + gained;
    updateQuestProgress("collect_stone", gained);
    openBuildingMenu(game.selectedTile);
  }
};

window.collectIron = function() {
  if (!game.selectedTile || !game.selectedTile.building) return;
  const b = game.selectedTile.building;
  const val = b.accumulated || 0;
  if (val > 0.001) {
    b.accumulated = 0;
    const gained = processLuckyHarvest(val, "⛏️", "#38bdf8", "toast_collected_iron");
    game.iron = (game.iron || 0) + gained;
    game.statTotalIron = (game.statTotalIron || 0) + gained;
    openBuildingMenu(game.selectedTile);
  }
};

// =============================================================================
// ZUD FELAKETİ ISINMA & TARLA KURTARMA MEKANİĞİ
// =============================================================================

window.warmTile = function() {
  if (!game.selectedTile) return;
  const tile = game.selectedTile;
  const WOOD_COST = 5;

  if ((game.wood || 0) < WOOD_COST) {
    audio.playError();
    showToast("⚠️ Tarlayı ısıtmak için en az 5 🪵 Odun gerekli!", true);
    return;
  }

  game.wood -= WOOD_COST;
  tile.isWarmed = true;
  tile.warmTimer = 60.0; // 60 saniye boyunca koruma & +%50 hız
  game.warmedTilesCount = (game.warmedTilesCount || 0) + 1;

  if (audio.playFireBurn) audio.playFireBurn();
  else audio.playUpgrade();

  const p = hexToPixel(tile.q, tile.r);
  triggerShockwave(p.x, p.y, "#f97316");
  triggerFloatingText(p.x, p.y - 30, "🔥 +%50 ISINMA!", "#f97316");
  showToast("🔥 Tarla ısıtıldı! Buzlar eridi ve 60 saniye boyunca +%50 üretim hızı kazandı!");

  checkTitlesAndAchievements();
  saveGame();
  openBuildingMenu(tile);
};

// =============================================================================
// İPEK YOLU PAZAR YERİ TAKAS FONKSİYONU
// =============================================================================

window.tradeMarket = function(recipeKey) {
  const merchantBonus = (game.titles && game.titles.merchant) ? 1.20 : 1.0;

  if (recipeKey === "flour_to_stone") {
    if ((game.flour || 0) < 15) {
      audio.playError();
      showToast("⚠️ Yetersiz Un! (15 🌾 Un gerekli)", true);
      return;
    }
    game.flour -= 15;
    const gain = Math.round(8 * merchantBonus);
    game.stone = (game.stone || 0) + gain;
    game.statTotalStone = (game.statTotalStone || 0) + gain;
    audio.playTradeSuccess();
    showToast(`⚖️ Takas Başarılı! 15 Un verildi, +${gain} 🪨 Taş alındı.`);
  } else if (recipeKey === "bread_to_iron") {
    if ((game.bread || 0) < 10) {
      audio.playError();
      showToast("⚠️ Yetersiz Ekmek! (10 🍞 Ekmek gerekli)", true);
      return;
    }
    game.bread -= 10;
    const gain = Math.round(5 * merchantBonus);
    game.iron = (game.iron || 0) + gain;
    game.statTotalIron = (game.statTotalIron || 0) + gain;
    audio.playTradeSuccess();
    showToast(`⚖️ Takas Başarılı! 10 Ekmek verildi, +${gain} ⛏️ Demir alındı.`);
  } else if (recipeKey === "furniture_to_stone") {
    if ((game.furniture || 0) < 10) {
      audio.playError();
      showToast("⚠️ Yetersiz Mobilya! (10 🪑 Mobilya gerekli)", true);
      return;
    }
    game.furniture -= 10;
    const gain = Math.round(15 * merchantBonus);
    game.stone = (game.stone || 0) + gain;
    game.statTotalStone = (game.statTotalStone || 0) + gain;
    audio.playTradeSuccess();
    showToast(`⚖️ Takas Başarılı! 10 Mobilya verildi, +${gain} 🪨 Taş alındı.`);
  } else if (recipeKey === "iron_stone_to_crown") {
    if ((game.iron || 0) < 25 || (game.stone || 0) < 25) {
      audio.playError();
      showToast("⚠️ Yetersiz Maden! (25 ⛏️ Demir + 25 🪨 Taş gerekli)", true);
      return;
    }
    game.iron -= 25;
    game.stone -= 25;
    game.crowns = (game.crowns || 0) + 1;
    audio.playTradeSuccess();
    showToast(`👑 Kraliyet Satışı Tamamlandı! +1 👑 Kraliyet Tacı kazanıldı!`);
  } else if (recipeKey === "obsidian_to_tamga") {
    if ((game.obsidian || 0) < 15) {
      audio.playError();
      showToast("⚠️ Yetersiz Obsidiyen! (15 🔮 Obsidiyen gerekli)", true);
      return;
    }
    game.obsidian -= 15;
    game.tamgas = (game.tamgas || 0) + 1;
    audio.playTradeSuccess();
    showToast(`𐰋 Ata Kutsaması! 15 Obsidiyen verildi, +1 𐰋 Göktürk Damgası kazanıldı!`);
  }

  game.marketTradesCount = (game.marketTradesCount || 0) + 1;
  checkTitlesAndAchievements();
  saveGame();
  updateUI();
};

// =============================================================================
// 8 KADEMELİ BOZKIR UNVANLARI & BAŞARIMLARI (TITLES & ACHIEVEMENTS)
// =============================================================================

const TITLES_CONFIG = [
  { key: "farmer", name: "🌾 Bozkır Çiftçisi", desc: "Toplam 500 Gıda üret.", perk: "Gıda üretimi kalıcı +%5", check: () => (game.statTotalFood || 0) >= 500 },
  { key: "lumberjack", name: "🪓 Ulu Oduncu", desc: "Toplam 500 Odun üret.", perk: "Odun üretimi kalıcı +%5", check: () => (game.statTotalWood || 0) >= 500 },
  { key: "conqueror", name: "🏰 Toprak Fatihi", desc: "En az 10 arsa fethet.", perk: "Arsa maliyetleri -%10", check: () => (game.ownedCount || 1) >= 10 },
  { key: "khagan", name: "👑 Bozkır Hakanı", desc: "Şatoyu 5. Seviyeye yükselt.", perk: "Küresel hız kalıcı +%15", check: () => (game.castleLevel || 1) >= 5 },
  { key: "nomad", name: "🐎 Kutlu Göçer", desc: "En az 1 kez Büyük Bozkır Göçü yap.", perk: "Göç başlangıcı +50 Gıda, +50 Odun", check: () => (game.totalMigrations || 0) >= 1 },
  { key: "zudMaster", name: "❄️ Zud Fatihi", desc: "Zud felaketinde donan en az 3 tarlayı ısıt.", perk: "Kışın felaket kaybı -%50 azalır", check: () => (game.warmedTilesCount || 0) >= 3 },
  { key: "ergenekonLord", name: "🌋 Ergenekon Efendisi", desc: "Yeraltı dünyasında 50 Obsidiyen üret.", perk: "Yeraltı madenlerine +%20 hız", check: () => (game.statTotalObsidian || 0) >= 50 },
  { key: "merchant", name: "⚖️ İpek Yolu Taciri", desc: "Pazar yerinde en az 5 takas yap.", perk: "Pazar takaslarında +%20 ek kazanç", check: () => (game.marketTradesCount || 0) >= 5 }
];

function checkTitlesAndAchievements() {
  if (!game.titles) game.titles = {};
  TITLES_CONFIG.forEach(cfg => {
    if (!game.titles[cfg.key] && cfg.check()) {
      game.titles[cfg.key] = true;
      if (audio.playQuestComplete) audio.playQuestComplete();
      showToast(`🏆 YENİ UNVAN KAZANILDI: ${cfg.name}! (${cfg.perk})`);
      triggerShockwave(0, 0, "#f59e0b");
      updateTitlesUI();
    }
  });
}

function updateTitlesUI() {
  const container = document.getElementById("titles-grid");
  if (!container) return;
  container.innerHTML = "";

  TITLES_CONFIG.forEach(cfg => {
    const isUnlocked = !!(game.titles && game.titles[cfg.key]);
    const card = document.createElement("div");
    card.className = `title-card ${isUnlocked ? "unlocked" : "locked"}`;
    card.innerHTML = `
      <div class="title-icon">${cfg.name.split(" ")[0]}</div>
      <div class="title-info">
        <div class="title-name">${cfg.name} ${isUnlocked ? "✅" : "🔒"}</div>
        <div class="title-desc">${cfg.desc}</div>
        <div class="title-perk">${cfg.perk}</div>
      </div>
    `;
    container.appendChild(card);
  });
}

window.buyTalent = function(key) {
  if (!game.talents) game.talents = { workerSpeed: 0, boostAll: 0, treasureHunter: 0, conquestMaster: 0 };
  const currentLvl = game.talents[key] || 0;
  const cost = Math.round(1 + currentLvl * 2);

  if ((game.crowns || 0) < cost) {
    audio.playError();
    showToast(t("toast_insufficient_res") || "⚠️ Yetersiz Taç!", true);
    return;
  }

  game.crowns -= cost;
  game.talents[key] = currentLvl + 1;

  audio.playPrestige();
  triggerScreenShake(5.0, 0.2);
  saveGame();
  updateTalentsUI();
  updateUI();
  showToast(`🌟 Yetenek Yükseltildi! (Seviye ${game.talents[key]})`);
};

window.upgradeBuilding = function(type, cost) {
  if (game.food < cost) {
    audio.playError();
    showToast(t("toast_insufficient_res"), true);
    return;
  }
  game.food -= cost;
  game.selectedTile.building.level += 1;
  audio.playUpgrade();
  updateQuestProgress("upgrade_building", 1);
  updateQuestProgress("upgrade_" + type, 1);
  saveGame();
  showToast(t("toast_upgraded", [t(type + "_name"), game.selectedTile.building.level]));
  openBuildingMenu(game.selectedTile);
};

window.upgradeBuildingMulti = function(type, foodCost = 0, woodCost = 0, flourCost = 0, plankCost = 0, breadCost = 0, furnitureCost = 0, stoneCost = 0, ironCost = 0) {
  if (game.food < foodCost || game.wood < woodCost || game.flour < flourCost || game.plank < plankCost || game.bread < breadCost || game.furniture < furnitureCost || (game.stone || 0) < stoneCost || (game.iron || 0) < ironCost) {
    audio.playError();
    showToast(t("toast_insufficient_res"), true);
    return;
  }
  game.food -= foodCost;
  game.wood -= woodCost;
  game.flour -= flourCost;
  game.plank -= plankCost;
  game.bread -= breadCost;
  game.furniture -= furnitureCost;
  game.stone = (game.stone || 0) - stoneCost;
  game.iron = (game.iron || 0) - ironCost;

  game.selectedTile.building.level += 1;
  audio.playUpgrade();
  updateQuestProgress("upgrade_building", 1);
  updateQuestProgress("upgrade_" + type, 1);
  saveGame();
  showToast(t("toast_upgraded", [t(type + "_name"), game.selectedTile.building.level]));
  openBuildingMenu(game.selectedTile);
};

window.upgradeCastle = function() {
  if (game.castleLevel >= 10) return;
  const upData = CASTLE_UPGRADES[game.castleLevel];
  if (game.food >= upData.costFood && game.wood >= upData.costWood) {
    game.food -= upData.costFood;
    game.wood -= upData.costWood;
    game.castleLevel += 1;

    triggerShockwave(0, 0, "#f8c83e");
    triggerFloatingText(0, -35, `👑 SV. ${game.castleLevel}`, "#f8c83e");
    triggerScreenShake(10.0, 0.35);

    audio.playCastleUpgrade();
    updateQuestProgress("castle_level", game.castleLevel);
    saveGame();
    showToast(t("toast_castle_upgraded", [CASTLE_TITLES[game.castleLevel - 1]]));
    openBuildingMenu(game.selectedTile);
  } else {
    audio.playError();
    showToast(t("toast_insufficient_res"), true);
  }
};

// =============================================================================
// 10. AYARLAR, İSTATİSTİKLER, PRESTİJ & ÇEVRİMDISI GELİR MODALI
// =============================================================================

function setupModalHandlers() {
  btnToggleDrawer.addEventListener("click", () => {
    audio.playClick();
    drawerRow.classList.toggle("hidden");
    btnToggleDrawer.textContent = drawerRow.classList.contains("hidden") ? "▼" : "▲";
  });

  if (btnFrenzy) {
    btnFrenzy.addEventListener("click", () => {
      audio.playPrestige();
      game.frenzyTimer = 300.0; // 5 dk 10x
      // Anında 10 dk üretim
      const baseMult = game.getCastleMultiplier() * game.getPrestigeMultiplier();
      const instantFood = 20.0 * baseMult;
      const instantWood = 15.0 * baseMult;
      const instantFlour = 10.0 * baseMult;
      const instantPlank = 10.0 * baseMult;
      const instantBread = 5.0 * baseMult;
      const instantFurniture = 5.0 * baseMult;

      game.food += instantFood;
      game.wood += instantWood;
      game.flour += instantFlour;
      game.plank += instantPlank;
      game.bread += instantBread;
      game.furniture += instantFurniture;

      game.statTotalFood += instantFood;
      game.statTotalWood += instantWood;
      game.statTotalFlour += instantFlour;
      game.statTotalPlank += instantPlank;
      game.statTotalBread += instantBread;
      game.statTotalFurniture += instantFurniture;

      updateUI();
      saveGame();
      showToast("⚡ 10x ÇILGINLIK BAŞLADI! (5 Dk 10x Hız + Anında 10 Dk Kaynak Yüklendi!)");
    });
  }

  btnSettings.addEventListener("click", () => {
    audio.playClick();
    openSettingsModal();
  });

  btnCloseMenu.addEventListener("click", closeBottomMenu);
  document.getElementById("btn-close-settings").addEventListener("click", closeModals);

  // Tab Geçişleri
  const tabBtnGen = document.getElementById("tab-btn-general");
  const tabBtnStat = document.getElementById("tab-btn-stats");
  const tabBtnPres = document.getElementById("tab-btn-prestige");
  const tabBtnTal = document.getElementById("tab-btn-talents");
  const tabGen = document.getElementById("tab-general");
  const tabStat = document.getElementById("tab-stats");
  const tabPres = document.getElementById("tab-prestige");
  const tabTal = document.getElementById("tab-talents");

  function switchTab(idx) {
    audio.playClick();
    if (tabBtnGen) tabBtnGen.classList.toggle("active", idx === 0);
    if (tabBtnStat) tabBtnStat.classList.toggle("active", idx === 1);
    if (tabBtnPres) tabBtnPres.classList.toggle("active", idx === 2);
    if (tabBtnTal) tabBtnTal.classList.toggle("active", idx === 3);

    if (tabGen) tabGen.classList.toggle("hidden", idx !== 0);
    if (tabStat) tabStat.classList.toggle("hidden", idx !== 1);
    if (tabPres) tabPres.classList.toggle("hidden", idx !== 2);
    if (tabTal) tabTal.classList.toggle("hidden", idx !== 3);

    if (idx === 1) updateStatsModal();
    if (idx === 2) updatePrestigeModal();
    if (idx === 3) updateTalentsUI();
  }

  if (tabBtnGen) tabBtnGen.addEventListener("click", () => switchTab(0));
  if (tabBtnStat) tabBtnStat.addEventListener("click", () => switchTab(1));
  if (tabBtnPres) tabBtnPres.addEventListener("click", () => switchTab(2));
  if (tabBtnTal) tabBtnTal.addEventListener("click", () => switchTab(3));

  // Dil Değiştirme Butonları
  document.querySelectorAll(".btn-lang").forEach(btn => {
    btn.addEventListener("click", () => {
      audio.playClick();
      currentLang = btn.getAttribute("data-lang");
      updateLanguageUI();
      saveGame();
    });
  });

  // Ses Slider & Mute
  const volumeSlider = document.getElementById("volume-slider");
  const btnMute = document.getElementById("btn-mute-toggle");

  if (volumeSlider) {
    volumeSlider.addEventListener("input", e => {
      audio.volume = parseFloat(e.target.value);
    });
  }

  if (btnMute) {
    btnMute.addEventListener("click", () => {
      audio.isMuted = !audio.isMuted;
      btnMute.textContent = audio.isMuted ? "🔇 " + t("mute") : "🔊 " + t("unmute");
      audio.playClick();
    });
  }

  // Prestij Butonları
  const btnDoPrestige = document.getElementById("btn-do-prestige");
  if (btnDoPrestige) {
    btnDoPrestige.addEventListener("click", () => {
      const earned = game.calculateEarnedCrowns();
      if (earned <= 0) {
        audio.playError();
        showToast(t("rebirth_need_more"), true);
        return;
      }
      audio.playClick();
      settingsModal.classList.add("hidden");
      const nextBonus = Math.round(((1.0 + (game.crowns + earned) * 0.05) - 1.0) * 100);
      document.getElementById("lbl-prestige-confirm-desc").textContent = t("prestige_confirm_desc", [earned, nextBonus]);
      prestigeConfirmModal.classList.remove("hidden");
    });
  }

  const btnConfirmRebirth = document.getElementById("btn-confirm-rebirth");
  if (btnConfirmRebirth) {
    btnConfirmRebirth.addEventListener("click", () => {
      const earned = game.calculateEarnedCrowns();
      if (earned <= 0) return;

      game.crowns += earned;
      game.totalRebirths += 1;

      // Sıfırlama
      game.food = 1.0;
      game.wood = 1.0;
      game.flour = 0.0;
      game.plank = 0.0;
      game.bread = 0.0;
      game.furniture = 0.0;
      game.stone = 0.0;
      game.iron = 0.0;
      game.castleLevel = 1;
      game.initFreshMap();

      closeModals();
      audio.playPrestige();
      saveGame();
      showToast(t("toast_prestige_success", [earned, Math.round((game.getPrestigeMultiplier() - 1.0) * 100)]));
    });
  }

  const btnCancelRebirth = document.getElementById("btn-cancel-rebirth");
  if (btnCancelRebirth) {
    btnCancelRebirth.addEventListener("click", () => {
      prestigeConfirmModal.classList.add("hidden");
      settingsModal.classList.remove("hidden");
    });
  }

  // Çevrimdışı Gelir Butonları
  const btnClaimOffline = document.getElementById("btn-claim-offline");
  if (btnClaimOffline) {
    btnClaimOffline.addEventListener("click", () => {
      claimOfflineGains(1);
    });
  }
  const btnClaim3x = document.getElementById("btn-claim-3x");
  if (btnClaim3x) {
    btnClaim3x.addEventListener("click", () => {
      claimOfflineGains(3);
    });
  }

  // Yetenek Yükseltme Butonları
  ["workerSpeed", "boostAll", "treasureHunter", "conquestMaster"].forEach(key => {
    const btn = document.getElementById(`btn-talent-${key}`);
    if (btn) {
      btn.addEventListener("click", () => {
        buyTalent(key);
      });
    }
  });

  // Görevler Modalı Butonları
  const btnQuests = document.getElementById("btn-quests");
  if (btnQuests) btnQuests.addEventListener("click", openQuestsModal);

  const btnCloseQuests = document.getElementById("btn-close-quests");
  if (btnCloseQuests) btnCloseQuests.addEventListener("click", closeModals);

  const btnClaimFast = document.getElementById("btn-claim-fast");
  if (btnClaimFast) btnClaimFast.addEventListener("click", () => claimQuest("fast"));

  const btnClaimStrat = document.getElementById("btn-claim-strat");
  if (btnClaimStrat) btnClaimStrat.addEventListener("click", () => claimQuest("strat"));

  const btnClaimEpic = document.getElementById("btn-claim-epic");
  if (btnClaimEpic) btnClaimEpic.addEventListener("click", () => claimQuest("epic"));

  // Kadim Eserler Modalı Butonları
  const btnRelics = document.getElementById("btn-relics");
  if (btnRelics) btnRelics.addEventListener("click", openRelicsModal);

  const btnCloseRelics = document.getElementById("btn-close-relics");
  if (btnCloseRelics) btnCloseRelics.addEventListener("click", closeModals);

  // Kervan & Şaman Olay Modalı Butonları
  const btnAcceptEnc = document.getElementById("btn-accept-encounter");
  if (btnAcceptEnc) btnAcceptEnc.addEventListener("click", acceptEncounter);

  const btnDeclineEnc = document.getElementById("btn-decline-encounter");
  if (btnDeclineEnc) btnDeclineEnc.addEventListener("click", declineEncounter);

  // Hakan Otağı (Kingdom Hub) Butonu
  const btnOtag = document.getElementById("btn-otag");
  if (btnOtag) btnOtag.addEventListener("click", () => openOtagModal("migration"));

  const btnCloseOtag = document.getElementById("btn-close-otag");
  if (btnCloseOtag) btnCloseOtag.addEventListener("click", closeModals);

  // Otağ Sekme Butonları
  ["migration", "quests", "relics", "market", "layer", "titles"].forEach(tabName => {
    const btn = document.getElementById(`tab-btn-${tabName}`);
    if (btn) {
      btn.addEventListener("click", () => switchOtagTab(tabName));
    }
  });

  // Zindan Keşif Modalı Butonları
  const btnRuinsSafe = document.getElementById("btn-ruins-safe");
  if (btnRuinsSafe) btnRuinsSafe.addEventListener("click", exploreRuinsSafe);

  const btnRuinsGamble = document.getElementById("btn-ruins-gamble");
  if (btnRuinsGamble) btnRuinsGamble.addEventListener("click", exploreRuinsGamble);

  // Büyük Bozkır Göçü & Töre Ağacı Butonları
  const btnMigration = document.getElementById("btn-migration");
  if (btnMigration) btnMigration.addEventListener("click", () => openOtagModal("migration"));

  const btnCloseMigration = document.getElementById("btn-close-migration");
  if (btnCloseMigration) btnCloseMigration.addEventListener("click", closeModals);

  const btnExecMigration = document.getElementById("btn-execute-migration");
  if (btnExecMigration) btnExecMigration.addEventListener("click", executeMigration);

  // Töre Ağacı Yetenek Butonları
  const toreKeys = [
    { branch: "gokTengri", key: "rainBlessing" },
    { branch: "gokTengri", key: "shamanAura" },
    { branch: "kulTigin", key: "braveHeart" },
    { branch: "kulTigin", key: "steelKorgan" },
    { branch: "tonyukuk", key: "silkNetwork" },
    { branch: "tonyukuk", key: "pavedRoads" }
  ];
  toreKeys.forEach(tk => {
    const btn = document.getElementById(`btn-tore-${tk.key}`);
    if (btn) {
      btn.addEventListener("click", () => {
        buyToreTalent(tk.branch, tk.key);
      });
    }
  });

  // Katman Geçiş Butonu (Bozkır vs Ergenekon Yeraltı)
  const btnLayer = document.getElementById("btn-layer");
  if (btnLayer) btnLayer.addEventListener("click", toggleActiveLayer);
}

window.openOtagModal = function(tabName = "migration") {
  audio.playClick();
  updateMigrationUI();
  updateQuestsUI();
  updateRelicsUI();
  updateTitlesUI();

  const layerLbl = document.getElementById("lbl-active-layer-status");
  if (layerLbl) {
    layerLbl.textContent = (game.activeLayer === "SURFACE") ? "🌍 Yeryüzü Krallığı" : "🌋 Ergenekon Yeraltı Dünyası";
  }

  modalBackdrop.classList.remove("hidden");
  const otag = document.getElementById("otag-modal");
  if (otag) otag.classList.remove("hidden");

  switchOtagTab(tabName);
};

window.switchOtagTab = function(tabName) {
  audio.playClick();
  const tabs = ["migration", "quests", "relics", "market", "layer", "titles"];
  tabs.forEach(tName => {
    const btn = document.getElementById(`tab-btn-${tName}`);
    const pane = document.getElementById(`pane-${tName}`);
    if (btn) btn.classList.toggle("active", tName === tabName);
    if (pane) pane.classList.toggle("hidden", tName !== tabName);
  });
};

function openMigrationModal() {
  openOtagModal("migration");
}

function openQuestsModal() {
  openOtagModal("quests");
}

function openRelicsModal() {
  openOtagModal("relics");
}

function updateMigrationUI() {
  const earned = game.calculateEarnedTamgas();
  const tamgaValEl = document.getElementById("val-earn-tamgas");
  if (tamgaValEl) tamgaValEl.textContent = `+${earned} 𐰋`;

  const currTamgaEl = document.getElementById("val-curr-tamgas");
  if (currTamgaEl) currTamgaEl.textContent = `${game.tamgas || 0} 𐰋`;

  const currTamgaChip = document.getElementById("tamga-label");
  if (currTamgaChip) currTamgaChip.textContent = `${game.tamgas || 0}`;

  if (!game.toreTalents) {
    game.toreTalents = {
      gokTengri: { rainBlessing: 0, shamanAura: 0 },
      kulTigin: { braveHeart: 0, steelKorgan: 0 },
      tonyukuk: { silkNetwork: 0, pavedRoads: 0 }
    };
  }

  const branches = ["gokTengri", "kulTigin", "tonyukuk"];
  branches.forEach(br => {
    Object.keys(game.toreTalents[br] || {}).forEach(k => {
      const lvl = (game.toreTalents[br] && game.toreTalents[br][k]) ? game.toreTalents[br][k] : 0;
      const cost = Math.round(1 + lvl * 2);
      const lvlEl = document.getElementById(`lvl-tore-${k}`);
      if (lvlEl) lvlEl.textContent = `${lvl}`;

      const costEl = document.getElementById(`cost-tore-${k}`);
      if (costEl) costEl.textContent = `${cost}`;
    });
  });
}

function buyToreTalent(branch, key) {
  if (!game.toreTalents) {
    game.toreTalents = {
      gokTengri: { rainBlessing: 0, shamanAura: 0 },
      kulTigin: { braveHeart: 0, steelKorgan: 0 },
      tonyukuk: { silkNetwork: 0, pavedRoads: 0 }
    };
  }
  const currentLvl = (game.toreTalents[branch] && game.toreTalents[branch][key]) ? game.toreTalents[branch][key] : 0;
  if (currentLvl >= 5) return;
  const cost = Math.round(1 + currentLvl * 2);
  if ((game.tamgas || 0) < cost) {
    audio.playError();
    showToast("⚠️ Yetersiz Kutlu Damga (𐰋)!", true);
    return;
  }
  game.tamgas -= cost;
  if (!game.toreTalents[branch]) game.toreTalents[branch] = {};
  game.toreTalents[branch][key] = currentLvl + 1;
  audio.playUpgrade();
  saveGame();
  updateMigrationUI();
  updateUI();
  showToast(`𐰋 Kadim Töre Güçlendirildi! (${key}: Sv. ${game.toreTalents[branch][key]})`);
}

function executeMigration() {
  const earned = game.calculateEarnedTamgas();
  if (earned <= 0) return;

  game.tamgas = (game.tamgas || 0) + earned;
  game.totalMigrations = (game.totalMigrations || 0) + 1;

  // Sıfırlama ve Bozkır Göçü
  game.food = (game.titles && game.titles.nomad) ? 50.0 : 1.0;
  game.wood = (game.titles && game.titles.nomad) ? 50.0 : 1.0;
  game.flour = 0.0;
  game.plank = 0.0;
  game.bread = 0.0;
  game.furniture = 0.0;
  game.stone = 0.0;
  game.iron = 0.0;
  game.obsidian = 0.0;
  game.mithril = 0.0;
  game.castleLevel = 1;
  game.initFreshMap();

  closeModals();
  audio.playPrestige();
  triggerScreenShake(12.0, 0.4);
  checkTitlesAndAchievements();
  saveGame();
  showToast(`🐎 BÜYÜK BOZKIR GÖÇÜ TAMAMLANDI! (+${earned} 𐰋 Damga Kazanıldı)`);
}

function toggleActiveLayer() {
  audio.playClick();
  game.activeLayer = (game.activeLayer === "SURFACE") ? "UNDERGROUND" : "SURFACE";
  const btn = document.getElementById("btn-layer");
  if (btn) {
    btn.textContent = (game.activeLayer === "SURFACE") ? "🌍" : "🌋";
  }
  const layerLbl = document.getElementById("lbl-active-layer-status");
  if (layerLbl) {
    layerLbl.textContent = (game.activeLayer === "SURFACE") ? "🌍 Yeryüzü Krallığı" : "🌋 Ergenekon Yeraltı Dünyası";
  }
  showToast((game.activeLayer === "SURFACE") ? "☀️ Bozkır Dünyasına Geçildi" : "🌋 Ergenekon Yeraltı Mağarasına İnildi");
}

function openSettingsModal() {
  updateLanguageUI();
  updateStatsModal();
  updatePrestigeModal();
  updateTalentsUI();
  modalBackdrop.classList.remove("hidden");
  settingsModal.classList.remove("hidden");
  prestigeConfirmModal.classList.add("hidden");
  offlineModal.classList.add("hidden");
}

function closeModals() {
  modalBackdrop.classList.add("hidden");
  settingsModal.classList.add("hidden");
  prestigeConfirmModal.classList.add("hidden");
  offlineModal.classList.add("hidden");

  const otagModal = document.getElementById("otag-modal");
  if (otagModal) otagModal.classList.add("hidden");

  const qModal = document.getElementById("quest-modal");
  if (qModal) qModal.classList.add("hidden");

  const rModal = document.getElementById("relics-modal");
  if (rModal) rModal.classList.add("hidden");

  const eModal = document.getElementById("encounter-modal");
  if (eModal) eModal.classList.add("hidden");

  const ruModal = document.getElementById("ruins-modal");
  if (ruModal) ruModal.classList.add("hidden");

  const mModal = document.getElementById("migration-modal");
  if (mModal) mModal.classList.add("hidden");
}

function buyTalent(key) {
  if (!game.talents) game.talents = { workerSpeed: 0, boostAll: 0, treasureHunter: 0, conquestMaster: 0 };
  const currentLvl = game.talents[key] || 0;
  if (currentLvl >= 10) return;
  const cost = Math.round(1 + currentLvl * 2);
  if ((game.crowns || 0) < cost) {
    audio.playError();
    showToast("⚠️ Yetersiz Kraliyet Tacı!", true);
    return;
  }
  game.crowns -= cost;
  game.talents[key] = currentLvl + 1;
  audio.playUpgrade();
  saveGame();
  updateTalentsUI();
  updateUI();
  showToast(`✨ Yetenek Yükseltildi! (${key}: Sv. ${game.talents[key]})`);
}

function updateTalentsUI() {
  if (!game.talents) game.talents = { workerSpeed: 0, boostAll: 0, treasureHunter: 0, conquestMaster: 0 };
  const crownEl = document.getElementById("talent-crowns-val");
  if (crownEl) crownEl.textContent = `${game.crowns || 0} 👑`;

  const talents = [
    { key: "workerSpeed", max: 10 },
    { key: "boostAll", max: 10 },
    { key: "treasureHunter", max: 10 },
    { key: "conquestMaster", max: 10 }
  ];

  talents.forEach(tDef => {
    const lvl = game.talents[tDef.key] || 0;
    const cost = Math.round(1 + lvl * 2);
    const lvlEl = document.getElementById(`talent-${tDef.key}-lvl`);
    if (lvlEl) lvlEl.textContent = `${lvl}/${tDef.max}`;

    const btnEl = document.getElementById(`btn-talent-${tDef.key}`);
    if (btnEl) {
      if (lvl >= tDef.max) {
        btnEl.textContent = t("max_level") || "Maksimum";
        btnEl.disabled = true;
      } else {
        btnEl.textContent = `${cost} 👑`;
        btnEl.disabled = ((game.crowns || 0) < cost);
      }
    }
  });
}

function updateLanguageUI() {
  document.querySelectorAll(".btn-lang").forEach(btn => {
    btn.classList.toggle("active", btn.getAttribute("data-lang") === currentLang);
  });

  const setEl = (id, text) => {
    const el = document.getElementById(id);
    if (el && text) el.textContent = text;
  };

  setEl("settings-title", t("settings_title"));
  setEl("tab-btn-general", t("tab_general"));
  setEl("tab-btn-stats", t("tab_stats"));
  setEl("tab-btn-prestige", t("tab_prestige"));
  setEl("tab-btn-talents", t("tab_talents") || "🌟 Yetenekler");
  setEl("lbl-lang-select", t("language_select"));
  setEl("lbl-audio-sfx", t("sfx_volume"));
  setEl("lbl-prestige-desc", t("prestige_desc"));
  setEl("btn-do-prestige", t("rebirth_btn"));

  setEl("lbl-stat-playtime", t("stat_playtime"));
  setEl("lbl-stat-conquered", t("stat_conquered"));
  setEl("lbl-stat-food", t("stat_total_food"));
  setEl("lbl-stat-wood", t("stat_total_wood"));
  setEl("lbl-stat-flour", t("stat_total_flour"));
  setEl("lbl-stat-plank", t("stat_total_plank"));
  setEl("lbl-stat-bread", t("stat_total_bread"));
  setEl("lbl-stat-furniture", t("stat_total_furniture"));
  setEl("lbl-stat-stone", t("stat_total_stone") || "Toplam Taş");
  setEl("lbl-stat-iron", t("stat_total_iron") || "Toplam Demir");
  setEl("lbl-stat-rebirths", t("stat_rebirths"));

  setEl("lbl-curr-crowns", t("current_crowns"));
  setEl("lbl-earn-crowns", t("earned_crowns"));
  setEl("lbl-prestige-confirm-title", t("prestige_confirm_title"));
  setEl("btn-confirm-rebirth", t("confirm"));
  setEl("btn-cancel-rebirth", t("cancel"));

  updateUI();
}

function updateStatsModal() {
  const mins = Math.floor(game.statPlaytime / 60);
  const secs = Math.floor(game.statPlaytime % 60);
  const setVal = (id, val) => {
    const el = document.getElementById(id);
    if (el) el.textContent = val;
  };
  setVal("val-stat-playtime", `${mins} dk ${secs} sn`);
  setVal("val-stat-conquered", `${game.statTotalConquered}`);
  setVal("val-stat-food", `${(game.statTotalFood || 0).toFixed(1)}`);
  setVal("val-stat-wood", `${(game.statTotalWood || 0).toFixed(1)}`);
  setVal("val-stat-flour", `${(game.statTotalFlour || 0).toFixed(1)}`);
  setVal("val-stat-plank", `${(game.statTotalPlank || 0).toFixed(1)}`);
  setVal("val-stat-bread", `${(game.statTotalBread || 0).toFixed(1)}`);
  setVal("val-stat-furniture", `${(game.statTotalFurniture || 0).toFixed(1)}`);
  setVal("val-stat-stone", `${(game.statTotalStone || 0).toFixed(1)}`);
  setVal("val-stat-iron", `${(game.statTotalIron || 0).toFixed(1)}`);
  setVal("val-stat-rebirths", `${game.totalRebirths}`);
}

function updatePrestigeModal() {
  const bonusPct = Math.round((game.getPrestigeMultiplier() - 1.0) * 100);
  const earned = game.calculateEarnedCrowns();
  const currEl = document.getElementById("val-curr-crowns");
  if (currEl) currEl.textContent = `${game.crowns} 👑 (+%${bonusPct})`;
  const earnEl = document.getElementById("val-earn-crowns");
  if (earnEl) earnEl.textContent = `+${earned} 👑`;
}

// Çevrimdışı Gelir
let pendingOffline = { food: 0, wood: 0, flour: 0, plank: 0, bread: 0, furniture: 0, stone: 0, iron: 0 };

function checkOfflineGains(lastTimestamp) {
  if (!lastTimestamp) return;
  const now = Math.floor(Date.now() / 1000);
  const elapsed = Math.max(0, now - lastTimestamp);
  if (elapsed < 15) return;

  const cappedSeconds = Math.min(8 * 3600, elapsed);
  const globalMult = game.getGlobalMultiplier();

  let f = 0, w = 0, fl = 0, p = 0, br = 0, fu = 0, st = 0, ir = 0;
  const hasWorkers = Object.values(game.tiles).some(t => t.building && t.building.type === "worker");

  Object.values(game.tiles).forEach(t => {
    if (t.state !== "OWNED" || !t.building) return;
    const b = t.building;
    if (b.type === "corn") {
      const rate = (0.42 * Math.pow(1.5, b.level - 1)) * globalMult;
      f += hasWorkers ? rate * cappedSeconds : Math.min(rate * 30.0, rate * cappedSeconds);
    } else if (b.type === "lumberjack") {
      const rate = (0.35 * Math.pow(1.5, b.level - 1)) * globalMult;
      w += hasWorkers ? rate * cappedSeconds : Math.min(rate * 30.0, rate * cappedSeconds);
    } else if (b.type === "windmill") {
      const rate = (0.25 * Math.pow(1.5, b.level - 1)) * globalMult;
      fl += hasWorkers ? rate * cappedSeconds : Math.min(rate * 30.0, rate * cappedSeconds);
    } else if (b.type === "sawmill") {
      const rate = (0.20 * Math.pow(1.5, b.level - 1)) * globalMult;
      p += hasWorkers ? rate * cappedSeconds : Math.min(rate * 30.0, rate * cappedSeconds);
    } else if (b.type === "bakery") {
      const rate = (0.25 * Math.pow(1.5, b.level - 1)) * globalMult;
      br += hasWorkers ? rate * cappedSeconds : Math.min(rate * 40.0, rate * cappedSeconds);
    } else if (b.type === "furniture") {
      const rate = (0.20 * Math.pow(1.5, b.level - 1)) * globalMult;
      fu += hasWorkers ? rate * cappedSeconds : Math.min(rate * 40.0, rate * cappedSeconds);
    } else if (b.type === "quarry") {
      const rate = (0.35 * Math.pow(1.5, b.level - 1)) * globalMult;
      st += hasWorkers ? rate * cappedSeconds : Math.min(rate * 30.0, rate * cappedSeconds);
    } else if (b.type === "mine") {
      const rate = (0.25 * Math.pow(1.5, b.level - 1)) * globalMult;
      ir += hasWorkers ? rate * cappedSeconds : Math.min(rate * 30.0, rate * cappedSeconds);
    }
  });

  if (f > 0.1 || w > 0.1 || fl > 0.1 || p > 0.1 || br > 0.1 || fu > 0.1 || st > 0.1 || ir > 0.1) {
    pendingOffline = { food: f, wood: w, flour: fl, plank: p, bread: br, furniture: fu, stone: st, iron: ir };
    const mins = Math.floor(cappedSeconds / 60);
    const timeStr = mins >= 60 ? `${Math.floor(mins / 60)} sa ${mins % 60} dk` : `${mins} dk`;

    const setGain = (id, text) => {
      const el = document.getElementById(id);
      if (el) el.textContent = text;
    };

    setGain("lbl-offline-title", t("offline_welcome"));
    setGain("lbl-offline-desc", t("offline_desc", [timeStr]));
    setGain("gain-food", `+${f.toFixed(1)} 🥡 ${t("food")}`);
    setGain("gain-wood", `+${w.toFixed(1)} 🪵 ${t("wood")}`);
    setGain("gain-flour", `+${fl.toFixed(1)} 🌾 ${t("flour")}`);
    setGain("gain-plank", `+${p.toFixed(1)} 🪵 ${t("plank")}`);
    setGain("gain-bread", `+${br.toFixed(1)} 🍞 ${t("bread")}`);
    setGain("gain-furniture", `+${fu.toFixed(1)} 🪑 ${t("furniture")}`);
    setGain("gain-stone", `+${st.toFixed(1)} 🪨 ${t("stone")}`);
    setGain("gain-iron", `+${ir.toFixed(1)} ⛏️ ${t("iron")}`);

    const claimBtn = document.getElementById("btn-claim-offline");
    if (claimBtn) claimBtn.textContent = t("offline_claim");
    const claim3xBtn = document.getElementById("btn-claim-3x");
    if (claim3xBtn) claim3xBtn.textContent = t("offline_claim_3x");

    modalBackdrop.classList.remove("hidden");
    offlineModal.classList.remove("hidden");
    audio.playCollect();
  }
}

function claimOfflineGains(multiplier = 1) {
  game.food += (pendingOffline.food || 0) * multiplier;
  game.wood += (pendingOffline.wood || 0) * multiplier;
  game.flour += (pendingOffline.flour || 0) * multiplier;
  game.plank += (pendingOffline.plank || 0) * multiplier;
  game.bread += (pendingOffline.bread || 0) * multiplier;
  game.furniture += (pendingOffline.furniture || 0) * multiplier;
  game.stone = (game.stone || 0) + (pendingOffline.stone || 0) * multiplier;
  game.iron = (game.iron || 0) + (pendingOffline.iron || 0) * multiplier;

  game.statTotalFood += (pendingOffline.food || 0) * multiplier;
  game.statTotalWood += (pendingOffline.wood || 0) * multiplier;
  game.statTotalFlour += (pendingOffline.flour || 0) * multiplier;
  game.statTotalPlank += (pendingOffline.plank || 0) * multiplier;
  game.statTotalBread += (pendingOffline.bread || 0) * multiplier;
  game.statTotalFurniture += (pendingOffline.furniture || 0) * multiplier;
  game.statTotalStone = (game.statTotalStone || 0) + (pendingOffline.stone || 0) * multiplier;
  game.statTotalIron = (game.statTotalIron || 0) + (pendingOffline.iron || 0) * multiplier;

  closeModals();
  audio.playPrestige();
  saveGame();
  if (multiplier > 1) {
    showToast("🌟 3x Çevrimdışı Ödülü Ambarlara Eklendi!");
  }
}

// Toast
let toastTimeout = null;
function showToast(msg, isWarning = false) {
  const container = document.getElementById("toast-container");
  const msgEl = document.getElementById("toast-message");
  if (!container || !msgEl) return;
  msgEl.textContent = msg;

  container.classList.remove("hidden");
  container.classList.toggle("toast-warning", isWarning);
  container.style.opacity = "1";
  container.style.transform = "translateX(-50%) translateY(0)";

  if (toastTimeout) clearTimeout(toastTimeout);
  toastTimeout = setTimeout(() => {
    container.style.opacity = "0";
    container.style.transform = "translateX(-50%) translateY(-10px)";
    setTimeout(() => container.classList.add("hidden"), 250);
  }, 2200);
}

// =============================================================================
// 11. KAYIT & YÜKLEME (LOCALSTORAGE)
// =============================================================================

const SAVE_KEY = "idle_kingdom_clicker_save_v1";

function saveGame() {
  const data = {
    timestamp: Math.floor(Date.now() / 1000),
    lang: currentLang,
    food: game.food,
    wood: game.wood,
    flour: game.flour,
    plank: game.plank,
    bread: game.bread,
    furniture: game.furniture,
    stone: game.stone || 0,
    iron: game.iron || 0,
    obsidian: game.obsidian || 0,
    mithril: game.mithril || 0,
    tamgas: game.tamgas || 0,
    totalMigrations: game.totalMigrations || 0,
    toreTalents: game.toreTalents || {},
    season: game.season || "SPRING",
    seasonTimer: game.seasonTimer || 0,
    seasonYear: game.seasonYear || 1,
    isZud: !!game.isZud,
    activeLayer: game.activeLayer || "SURFACE",
    undergroundUnlocked: !!game.undergroundUnlocked,
    talents: game.talents || {},
    titles: game.titles || {},
    marketTradesCount: game.marketTradesCount || 0,
    warmedTilesCount: game.warmedTilesCount || 0,
    crowns: game.crowns,
    totalRebirths: game.totalRebirths,
    ownedCount: game.ownedCount,
    purchasedTilesCount: game.purchasedTilesCount,
    purchasedMeadowCount: game.purchasedMeadowCount,
    purchasedForestCount: game.purchasedForestCount,
    purchasedSeaCount: game.purchasedSeaCount,
    purchasedMountainCount: game.purchasedMountainCount,
    castleLevel: game.castleLevel,
    relics: game.relics || { axe: false, cornucopia: false, standard: false, shield: false },
    quests: game.quests || null,
    shamanBoostTimer: game.shamanBoostTimer || 0,
    lastRaidNight: game.lastRaidNight !== undefined ? game.lastRaidNight : -1,
    stats: {
      totalFood: game.statTotalFood,
      totalWood: game.statTotalWood,
      totalFlour: game.statTotalFlour,
      totalPlank: game.statTotalPlank,
      totalBread: game.statTotalBread,
      totalFurniture: game.statTotalFurniture,
      totalStone: game.statTotalStone || 0,
      totalIron: game.statTotalIron || 0,
      totalObsidian: game.statTotalObsidian || 0,
      totalMithril: game.statTotalMithril || 0,
      totalConquered: game.statTotalConquered,
      playtime: game.statPlaytime
    },
    tiles: Object.values(game.tiles || {}).map(t => ({
      q: t.q, r: t.r,
      state: t.state,
      biomeId: (t.biome && t.biome.id !== undefined) ? t.biome.id : 1,
      hasRuins: !!t.hasRuins,
      isWarmed: !!t.isWarmed,
      warmTimer: t.warmTimer || 0,
      building: t.building ? {
        type: t.building.type,
        level: t.building.level,
        accumulated: t.building.accumulated || 0,
        totalGathered: t.building.totalGathered || 0
      } : null
    })),
    undergroundTiles: Object.values(game.undergroundTiles || {}).map(t => ({
      q: t.q, r: t.r,
      state: t.state,
      biomeId: (t.biome && t.biome.id !== undefined) ? t.biome.id : 10,
      hasRuins: !!t.hasRuins,
      isWarmed: !!t.isWarmed,
      warmTimer: t.warmTimer || 0,
      building: t.building ? {
        type: t.building.type,
        level: t.building.level,
        accumulated: t.building.accumulated || 0,
        totalGathered: t.building.totalGathered || 0
      } : null
    }))
  };

  try {
    localStorage.setItem(SAVE_KEY, JSON.stringify(data));
  } catch (e) {
    console.error("Save error:", e);
  }
}

function loadGame() {
  try {
    const raw = localStorage.getItem(SAVE_KEY);
    if (!raw) {
      game.initFreshMap();
      return;
    }

    const data = JSON.parse(raw);
    if (!data || !data.tiles || data.tiles.length === 0) {
      game.initFreshMap();
      return;
    }

    currentLang = data.lang || "tr";
    game.food = (data.food !== undefined) ? data.food : 1.0;
    game.wood = (data.wood !== undefined) ? data.wood : 1.0;
    game.flour = data.flour || 0.0;
    game.plank = data.plank || 0.0;
    game.bread = data.bread || 0.0;
    game.furniture = data.furniture || 0.0;
    game.stone = data.stone || 0.0;
    game.iron = data.iron || 0.0;
    game.obsidian = data.obsidian || 0.0;
    game.mithril = data.mithril || 0.0;
    game.tamgas = data.tamgas || 0;
    game.totalMigrations = data.totalMigrations || 0;
    game.toreTalents = data.toreTalents || {
      gokTengri: { rainBlessing: 0, shamanAura: 0 },
      kulTigin: { braveHeart: 0, steelKorgan: 0 },
      tonyukuk: { silkNetwork: 0, pavedRoads: 0 }
    };
    game.season = data.season || "SPRING";
    game.seasonTimer = data.seasonTimer || 0.0;
    game.seasonYear = data.seasonYear || 1;
    game.isZud = !!data.isZud;
    game.activeLayer = data.activeLayer || "SURFACE";
    game.undergroundUnlocked = !!data.undergroundUnlocked;
    game.talents = data.talents || { workerSpeed: 0, boostAll: 0, treasureHunter: 0, conquestMaster: 0 };
    game.titles = data.titles || {};
    game.marketTradesCount = data.marketTradesCount || 0;
    game.warmedTilesCount = data.warmedTilesCount || 0;
    game.crowns = data.crowns || 0;
    game.totalRebirths = data.totalRebirths || 0;
    game.ownedCount = data.ownedCount || 1;
    game.purchasedTilesCount = data.purchasedTilesCount || 0;
    game.purchasedMeadowCount = data.purchasedMeadowCount || 0;
    game.purchasedForestCount = data.purchasedForestCount || 0;
    game.purchasedSeaCount = data.purchasedSeaCount || 0;
    game.purchasedMountainCount = data.purchasedMountainCount || 0;
    game.castleLevel = data.castleLevel || 1;
    game.relics = data.relics || { axe: false, cornucopia: false, standard: false, shield: false };
    game.quests = data.quests || null;
    game.shamanBoostTimer = data.shamanBoostTimer || 0;
    game.lastRaidNight = data.lastRaidNight !== undefined ? data.lastRaidNight : -1;
    initQuests();

    if (data.stats) {
      game.statTotalFood = data.stats.totalFood || 0;
      game.statTotalWood = data.stats.totalWood || 0;
      game.statTotalFlour = data.stats.totalFlour || 0;
      game.statTotalPlank = data.stats.totalPlank || 0;
      game.statTotalBread = data.stats.totalBread || 0;
      game.statTotalFurniture = data.stats.totalFurniture || 0;
      game.statTotalStone = data.stats.totalStone || 0;
      game.statTotalIron = data.stats.totalIron || 0;
      game.statTotalObsidian = data.stats.totalObsidian || 0;
      game.statTotalMithril = data.stats.totalMithril || 0;
      game.statTotalConquered = data.stats.totalConquered || 1;
      game.statPlaytime = data.stats.playtime || 0;
    }

    // Karoları Yükle
    game.tiles = {};
    const biomeMap = {
      0: BIOMES.SEA,
      1: BIOMES.MEADOW,
      2: BIOMES.FOREST,
      3: BIOMES.MOUNTAIN,
      4: BIOMES.SNOW_PEAK,
      5: BIOMES.DESERT_OASIS,
      6: BIOMES.WONDER,
      10: BIOMES.CAVERN,
      11: BIOMES.MAGMA,
      12: BIOMES.CRYSTAL
    };

    data.tiles.forEach(td => {
      const key = `${td.q},${td.r}`;
      game.tiles[key] = {
        q: td.q, r: td.r,
        state: td.state,
        biome: biomeMap[td.biomeId] || BIOMES.MEADOW,
        building: td.building,
        hasRuins: !!td.hasRuins
      };
    });

    // Yeraltı Karolarını Yükle
    if (data.undergroundTiles && data.undergroundTiles.length > 0) {
      game.undergroundTiles = {};
      data.undergroundTiles.forEach(td => {
        const key = `${td.q},${td.r}`;
        game.undergroundTiles[key] = {
          q: td.q, r: td.r,
          state: td.state,
          biome: biomeMap[td.biomeId] || BIOMES.CAVERN,
          building: td.building,
          hasRuins: !!td.hasRuins
        };
      });
    } else {
      game.initUndergroundMap();
    }

    // Çevrimdışı Gelir Kontrolü
    checkOfflineGains(data.timestamp);
  } catch (e) {
    console.error("Load error:", e);
    game.initFreshMap();
  }
}

// =============================================================================
// 12. BAŞLATMA (INIT)
// =============================================================================

window.addEventListener("DOMContentLoaded", () => {
  loadGame();
  setupInputHandlers();
  setupModalHandlers();
  updateLanguageUI();
  requestAnimationFrame(gameLoop);
});
