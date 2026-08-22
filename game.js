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
    supply_global: "🟡 Ana Ambardan (%50)",
    
    // Biyomlar & Yapılar
    corn_name: "Mısır Tarlası",
    corn_desc: "Temel gıda üretimi.",
    windmill_name: "Değirmen (Tier 2)",
    windmill_desc: "Gıdayı Un'a çevirir.",
    lumberjack_name: "Oduncu Kulübesi",
    lumberjack_desc: "Temel odun üretimi.",
    sawmill_name: "Kereste Fabrikası (Tier 2)",
    sawmill_desc: "Odunu Kalas'a çevirir.",
    worker_name: "İşçi Kulübesi",
    worker_desc: "Komşulardan otomatik hammadde taşır.",
    castle_title: "🏰 Krallık Şatosu",
    global_bonus: "Küresel Üretim & Taşıma Bonusu",
    next_unlock: "Sonraki Kilit",
    max_level: "MAKSİMUM SEVİYE",
    max_power_active: "👑 Krallık Maksimum Gücüne Ulaştı!",
    
    // Menü Başlıkları
    build_title_meadow: "🌾 Çayır İnşaat Menüsü",
    build_title_forest: "🌲 Orman İnşaat Menüsü",
    build_title_sea: "🌊 Deniz İnşaat Menüsü",
    settings_title: "⚙️ Ayarlar & Krallık Yönetimi",
    tab_general: "🌐 Genel & Ses",
    tab_stats: "📊 İstatistikler",
    tab_prestige: "👑 Prestij",
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
    toast_mountain_conquered: "🏔️ Dağ Fethedildi! Arkasındaki 1 birim sınırındaki tüm araziler açığa çıkarıldı.",
    toast_mountain_info: "🏔️ Fethedilmiş Dağ Zirvesi. Çevredeki tüm topraklar görüş alanında.",
    toast_no_food_tile: "⚠️ Yetersiz Gıda! Yeni altıgen açmak için {0} 🥡 Gıda gerekli.",
    toast_need_bridge: "⚠️ Açık Deniz Engeli! Denizden geçiş için önce bu deniz karosuna köprü inşa etmelisin.",
    toast_bridge_need_land: "⚠️ Köprü inşa etmek için en az 1 komşu kara parçası gereklidir.",
    toast_forest_locked: "🔒 Orman Kilitli! Odunculuk için Şatoyu Seviye 2'ye yükselt.",
    toast_no_build_biome: "ℹ️ Bu biyomda henüz inşa edilebilir yapı bulunmuyor.",
    toast_built_corn: "🌽 Mısır Tarlası inşa edildi!",
    toast_built_windmill: "🌾 Değirmen kuruldu! Un üretimi başladı.",
    toast_built_lumberjack: "🪓 Oduncu Kulübesi kuruldu! Odun üretimi başladı.",
    toast_built_sawmill: "🪵 Kereste Fabrikası kuruldu! Kalas üretimi başladı.",
    toast_built_worker: "🛖 İşçi Kulübesi kuruldu! Otomatik taşıma başladı.",
    toast_built_bridge: "🌉 Köprü inşa edildi! Deniz ötesi kara fethine açıldı.",
    toast_collected_food: "🥡 +{0} Gıda ambarına eklendi!",
    toast_collected_wood: "🪵 +{0} Odun kereste ambarına eklendi!",
    toast_collected_flour: "🌾 +{0} Un ambarına eklendi!",
    toast_collected_plank: "🪵 +{0} Kereste/Kalas ambarına eklendi!",
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
    supply_global: "🟡 Global Silo (50%)",
    
    corn_name: "Corn Field",
    corn_desc: "Basic food production.",
    windmill_name: "Windmill (Tier 2)",
    windmill_desc: "Processes food into flour.",
    lumberjack_name: "Lumberjack Hut",
    lumberjack_desc: "Basic wood production.",
    sawmill_name: "Sawmill (Tier 2)",
    sawmill_desc: "Processes wood into planks.",
    worker_name: "Worker Hut",
    worker_desc: "Auto-gathers resources from neighbors.",
    castle_title: "🏰 Kingdom Castle",
    global_bonus: "Global Production & Transport Bonus",
    next_unlock: "Next Unlock",
    max_level: "MAX LEVEL",
    max_power_active: "👑 Kingdom Reached Max Power!",
    
    build_title_meadow: "🌾 Meadow Build Menu",
    build_title_forest: "🌲 Forest Build Menu",
    settings_title: "⚙️ Settings & Kingdom Management",
    tab_general: "🌐 General & Audio",
    tab_stats: "📊 Statistics",
    tab_prestige: "👑 Prestige",
    language_select: "Language Selection:",
    sfx_volume: "Sound Effects (SFX):",
    mute: "Muted",
    unmute: "Sound On",
    
    hint_castle_1: "Upgrade Castle to Level 2 to unlock Lumberjack! (Cost: 6 🥡)",
    hint_castle_2: "Upgrade Castle to Level 3 to unlock Windmill & Sawmill! (18 🥡 + 10 🪵)",
    hint_expand: "Conquer new lands: 1 🥡 Food | Refine goods with factories!",
    hint_no_food: "Out of food! Harvest corn fields or build a worker hut.",
    
    toast_free_tile: "✨ First land conquered for FREE! (+1 Land)",
    toast_buy_tile: "🏰 Land conquered for 1 🥡 Food! (+1 Land)",
    toast_mountain_conquered: "🏔️ Mountain Conquered! All lands within 1-unit boundary revealed.",
    toast_mountain_info: "🏔️ Conquered Mountain Peak. Surrounding lands in line of sight.",
    toast_no_food_tile: "⚠️ Not enough food! 1 🥡 Food required.",
    toast_forest_locked: "🔒 Forest Locked! Upgrade Castle to Level 2 first.",
    toast_no_build_biome: "ℹ️ No constructible buildings for this biome yet.",
    toast_built_corn: "🌽 Corn Field constructed!",
    toast_built_windmill: "🌾 Windmill built! Flour production started.",
    toast_built_lumberjack: "🪓 Lumberjack Hut built! Wood production started.",
    toast_built_sawmill: "🪵 Sawmill built! Plank production started.",
    toast_built_worker: "🛖 Worker Hut built! Auto-transport active.",
    toast_collected_food: "🥡 +{0} Food added to storage!",
    toast_collected_wood: "🪵 +{0} Wood added to storage!",
    toast_collected_flour: "🌾 +{0} Flour added to storage!",
    toast_collected_plank: "🪵 +{0} Planks added to storage!",
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
    supply_global: "🟡 Almacén Global (50%)",
    
    corn_name: "Campo de Maíz",
    corn_desc: "Producción básica de comida.",
    windmill_name: "Molino (Nivel 2)",
    windmill_desc: "Transforma comida en harina.",
    lumberjack_name: "Cabaña de Leñador",
    lumberjack_desc: "Producción básica de madera.",
    sawmill_name: "Aserradero (Nivel 2)",
    sawmill_desc: "Transforma madera en tablones.",
    worker_name: "Cabaña de Obreros",
    worker_desc: "Transporta recursos de vecinos.",
    castle_title: "🏰 Castillo del Reino",
    global_bonus: "Bono Global de Producción",
    next_unlock: "Próximo Desbloqueo",
    max_level: "NIVEL MÁXIMO",
    max_power_active: "👑 ¡Poder Legendario Alcanzado!",
    
    build_title_meadow: "🌾 Menú de Pradera",
    build_title_forest: "🌲 Menú de Bosque",
    settings_title: "⚙️ Ajustes y Gestión del Reino",
    tab_general: "🌐 General y Sonido",
    tab_stats: "📊 Estadísticas",
    tab_prestige: "👑 Prestigio",
    language_select: "Seleccionar Idioma:",
    sfx_volume: "Efectos de Sonido (SFX):",
    mute: "Silenciado",
    unmute: "Sonido Activo",
    
    hint_castle_1: "¡Mejora el castillo a Nivel 2 para desbloquear Leñador! (Costo: 6 🥡)",
    hint_castle_2: "¡Mejora a Nivel 3 para Molino y Aserradero! (18 🥡 + 10 🪵)",
    hint_expand: "Conquista tierras: 1 🥡 Comida | ¡Procesa materias primas!",
    hint_no_food: "¡Sin comida! Cosecha maíz o construye una cabaña de obreros.",
    
    toast_free_tile: "✨ ¡Primera tierra conquistada GRATIS! (+1 Tierra)",
    toast_buy_tile: "🏰 ¡Tierra conquistada por 1 🥡 Comida! (+1 Tierra)",
    toast_mountain_conquered: "🏔️ ¡Montaña Conquistada! Todas las tierras cercanas reveladas.",
    toast_mountain_info: "🏔️ Pico Conquistado. Tierras circundantes a la vista.",
    toast_no_food_tile: "⚠️ ¡Comida insuficiente! 1 🥡 requerida.",
    toast_forest_locked: "🔒 ¡Bosque bloqueado! Mejora el castillo a Nivel 2 primero.",
    toast_no_build_biome: "ℹ️ Sin edificios para este bioma.",
    toast_built_corn: "🌽 ¡Campo de Maíz construido!",
    toast_built_windmill: "🌾 ¡Molino construido!",
    toast_built_lumberjack: "🪓 ¡Cabaña de Leñador construida!",
    toast_built_sawmill: "🪵 ¡Aserradero construido!",
    toast_built_worker: "🛖 ¡Cabaña de Obreros construida!",
    toast_collected_food: "🥡 ¡+{0} Comida recolectada!",
    toast_collected_wood: "🪵 ¡+{0} Madera recolectada!",
    toast_collected_flour: "🌾 ¡+{0} Harina recolectada!",
    toast_collected_plank: "🪵 ¡+{0} Tablones recolectados!",
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
    supply_global: "🟡 Hauptlager (50%)",
    
    corn_name: "Maisfeld",
    corn_desc: "Grundlegende Nahrungsproduktion.",
    windmill_name: "Windmühle (Stufe 2)",
    windmill_desc: "Verarbeitet Nahrung zu Mehl.",
    lumberjack_name: "Holzfällerhütte",
    lumberjack_desc: "Grundlegende Holzproduktion.",
    sawmill_name: "Sägewerk (Stufe 2)",
    sawmill_desc: "Verarbeitet Holz zu Brettern.",
    worker_name: "Arbeiterhütte",
    worker_desc: "Transportiert Waren von Nachbarn.",
    castle_title: "🏰 Königsburg",
    global_bonus: "Globaler Produktionsbonus",
    next_unlock: "Nächste Freischaltung",
    max_level: "MAXIMALE STUFE",
    max_power_active: "👑 Maximale Macht erreicht!",
    
    build_title_meadow: "🌾 Wiesen-Baumenü",
    build_title_forest: "🌲 Wald-Baumenü",
    settings_title: "⚙️ Einstellungen & Verwaltung",
    tab_general: "🌐 Allgemein & Audio",
    tab_stats: "📊 Statistiken",
    tab_prestige: "👑 Prestige",
    language_select: "Sprachauswahl:",
    sfx_volume: "Soundeffekte (SFX):",
    mute: "Stumm",
    unmute: "Ton Ein",
    
    hint_castle_1: "Burg auf Stufe 2 für Holzfäller verbessern! (6 🥡)",
    hint_castle_2: "Burg auf Stufe 3 für Mühle & Sägewerk! (18 🥡 + 10 🪵)",
    hint_expand: "Land erobern: 1 🥡 Nahrung | Fabriken bauen!",
    hint_no_food: "Keine Nahrung! Mais ernten oder Arbeiter bauen.",
    
    toast_free_tile: "✨ Erstes Land KOSTENLOS erobert! (+1 Land)",
    toast_buy_tile: "🏰 Land für 1 🥡 Nahrung erobert! (+1 Land)",
    toast_mountain_conquered: "🏔️ Berg erobert! Umliegende Ländereien aufgedeckt.",
    toast_mountain_info: "🏔️ Eroberter Berggipfel. Ländereien im Sichtfeld.",
    toast_no_food_tile: "⚠️ Zu wenig Nahrung! 1 🥡 erforderlich.",
    toast_forest_locked: "🔒 Wald gesperrt! Burg zuerst auf Stufe 2 bringen.",
    toast_no_build_biome: "ℹ️ Keine Gebäude für dieses Biom verfügbar.",
    toast_built_corn: "🌽 Maisfeld errichtet!",
    toast_built_windmill: "🌾 Windmühle errichtet!",
    toast_built_lumberjack: "🪓 Holzfällerhütte errichtet!",
    toast_built_sawmill: "🪵 Sägewerk errichtet!",
    toast_built_worker: "🛖 Arbeiterhütte errichtet!",
    toast_collected_food: "🥡 +{0} Nahrung gesammelt!",
    toast_collected_wood: "🪵 +{0} Holz gesammelt!",
    toast_collected_flour: "🌾 +{0} Mehl gesammelt!",
    toast_collected_plank: "🪵 +{0} Bretter gesammelt!",
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
  playUpgrade() { this.playTones([440, 554.37, 659.25, 880], 0.22, 'triangle'); }
  playCastleUpgrade() { this.playTones([523.25, 659.25, 783.99, 1046.5], 0.35, 'triangle'); }
  playPrestige() { this.playTones([523.25, 659.25, 783.99, 1046.5, 1318.51, 1567.98], 0.55, 'triangle'); }
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
  SEA: { id: 0, name: "Sea", baseColor: "#2e82de", borderColor: "#1f5f9e" },
  MEADOW: { id: 1, name: "Meadow", baseColor: "#61c75c", borderColor: "#3e8c38" },
  FOREST: { id: 2, name: "Forest", baseColor: "#1e702e", borderColor: "#12471c" },
  MOUNTAIN: { id: 3, name: "Mountain", baseColor: "#846142", borderColor: "#573b24" }
};

class GameState {
  constructor() {
    this.food = 1.0;
    this.wood = 0.0;
    this.flour = 0.0;
    this.plank = 0.0;

    this.crowns = 0;
    this.totalRebirths = 0;
    this.ownedCount = 1;
    this.purchasedTilesCount = 0;
    this.castleLevel = 1;

    // Kariyer İstatistikleri
    this.statTotalFood = 0.0;
    this.statTotalWood = 0.0;
    this.statTotalFlour = 0.0;
    this.statTotalPlank = 0.0;
    this.statTotalConquered = 1;
    this.statPlaytime = 0.0;

    // Altıgen Karolar: key = "q,r" -> Tile Object
    this.tiles = {};
    
    this.selectedTile = null;
    this.autoSaveTimer = 0.0;
  }

  getCastleMultiplier() {
    return 1.0 + (this.castleLevel - 1) * 0.25;
  }

  getPrestigeMultiplier() {
    return 1.0 + this.crowns * 0.05;
  }

  getGlobalMultiplier() {
    return this.getCastleMultiplier() * this.getPrestigeMultiplier();
  }

  getLandExpansionCost() {
    if (this.purchasedTilesCount === 0) return 0;
    return Math.max(1, Math.floor(1.0 * Math.pow(1.18, this.purchasedTilesCount - 1)));
  }

  getCareerTotalResources() {
    return this.statTotalFood + this.statTotalWood + this.statTotalFlour + this.statTotalPlank;
  }

  calculateEarnedCrowns() {
    const totalRes = this.getCareerTotalResources();
    const baseCrowns = Math.floor(Math.sqrt(totalRes / 1000.0));
    return baseCrowns * this.castleLevel;
  }

  initFreshMap() {
    this.tiles = {};
    this.ownedCount = 1;
    this.purchasedTilesCount = 0;

    const radius = 3;
    const biomeKeys = Object.keys(BIOMES);

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
            building: { type: "castle", level: this.castleLevel }
          };
        } else {
          const randB = BIOMES[biomeKeys[Math.floor(Math.random() * biomeKeys.length)]];
          this.tiles[key] = {
            q, r,
            state: "HIDDEN",
            biome: randB,
            building: null
          };
        }
      }
    }

    this.recalculateVisibility();
  }

  recalculateVisibility() {
    const origin = { q: 0, r: 0 };

    Object.values(this.tiles).forEach(tile => {
      if (tile.state === "OWNED") return;

      const dist = hexDistance(origin, tile);
      if (dist > 3) {
        tile.state = "HIDDEN";
        return;
      }

      const line = hexLine(origin, tile);
      let isBlocked = false;

      for (let i = 1; i < line.length - 1; i++) {
        const midKey = `${line[i].q},${line[i].r}`;
        const midTile = this.tiles[midKey];
        if (midTile && midTile.biome === BIOMES.MOUNTAIN && midTile.state !== "OWNED") {
          isBlocked = true;
          break;
        }
      }

      if (isBlocked) {
        tile.state = "HIDDEN";
      } else {
        tile.state = "DISCOVERED";
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

function resizeCanvas() {
  const dpr = window.devicePixelRatio || 1;
  canvas.width = window.innerWidth * dpr;
  canvas.height = window.innerHeight * dpr;
  ctx.scale(dpr, dpr);
}
window.addEventListener("resize", resizeCanvas);
resizeCanvas();

function draw() {
  ctx.save();
  ctx.clearRect(0, 0, window.innerWidth, window.innerHeight);

  // Arka plan koyu gradyanı
  const bgGrad = ctx.createRadialGradient(
    window.innerWidth / 2, window.innerHeight / 2, 50,
    window.innerWidth / 2, window.innerHeight / 2, Math.max(window.innerWidth, window.innerHeight)
  );
  bgGrad.addColorStop(0, "#101726");
  bgGrad.addColorStop(1, "#070a10");
  ctx.fillStyle = bgGrad;
  ctx.fillRect(0, 0, window.innerWidth, window.innerHeight);

  // Kamera Dönüşümü
  ctx.translate(window.innerWidth / 2 + camera.x, window.innerHeight / 2 + camera.y);
  ctx.scale(camera.zoom, camera.zoom);

  // Karoları Y-Sort derinliğine göre sırala
  const tileList = Object.values(game.tiles).filter(t => t.state !== "HIDDEN");
  tileList.sort((a, b) => {
    const posA = hexToPixel(a.q, a.r);
    const posB = hexToPixel(b.q, b.r);
    return posA.y - posB.y;
  });

  // 1. Karoları Çiz
  tileList.forEach(tile => {
    drawHexTile(tile);
  });

  ctx.restore();
}

function drawHexTile(tile) {
  const pos = hexToPixel(tile.q, tile.r);
  const corners = getHexCorners(HEX_SIZE, Y_SCALE);
  const isDiscovered = (tile.state === "DISCOVERED");

  ctx.save();
  ctx.translate(pos.x, pos.y);

  if (isDiscovered) {
    ctx.globalAlpha = 0.52;
  }

  // 1. 3D Taban Kalınlığı (Side Extrusion)
  const depth = 18.0 * Y_SCALE;
  const sideColor1 = "#182a1b";
  const sideColor2 = "#0e1c10";

  ctx.fillStyle = sideColor1;
  ctx.beginPath();
  ctx.moveTo(corners[2].x, corners[2].y);
  ctx.lineTo(corners[3].x, corners[3].y);
  ctx.lineTo(corners[3].x, corners[3].y + depth);
  ctx.lineTo(corners[2].x, corners[2].y + depth);
  ctx.closePath();
  ctx.fill();

  ctx.fillStyle = sideColor2;
  ctx.beginPath();
  ctx.moveTo(corners[3].x, corners[3].y);
  ctx.lineTo(corners[4].x, corners[4].y);
  ctx.lineTo(corners[4].x, corners[4].y + depth);
  ctx.lineTo(corners[3].x, corners[3].y + depth);
  ctx.closePath();
  ctx.fill();

  // 2. Üst Yüzey Poligonu
  ctx.fillStyle = tile.biome.baseColor;
  ctx.beginPath();
  ctx.moveTo(corners[0].x, corners[0].y);
  for (let i = 1; i < 6; i++) {
    ctx.lineTo(corners[i].x, corners[i].y);
  }
  ctx.closePath();
  ctx.fill();

  // 3. Kenarlık Çizgisi
  ctx.strokeStyle = isDiscovered ? "#7dd3fc" : tile.biome.borderColor;
  ctx.lineWidth = isDiscovered ? 2.8 : 2.0;
  ctx.stroke();

  // 4. Biyom Detayları (Bina yoksa)
  if (!tile.building) {
    if (tile.biome === BIOMES.FOREST) {
      drawIsometricForest(animWindTime);
    } else if (tile.biome === BIOMES.MOUNTAIN) {
      drawIsometricMountain();
    } else if (tile.biome === BIOMES.MEADOW) {
      drawIsometricMeadow(animWindTime);
    } else if (tile.biome === BIOMES.SEA) {
      drawIsometricSea(animWindTime);
    }
  } else {
    // 5. Bina Görselleri & 3D Animasyonları
    drawBuilding(tile.building, animWindTime);
  }

  // 6. Keşif Bekleyen Artı Sembolü
  if (isDiscovered) {
    ctx.strokeStyle = "#ffffff";
    ctx.lineWidth = 3.0;
    const cSize = 9.0;
    ctx.beginPath();
    ctx.moveTo(-cSize, 0);
    ctx.lineTo(cSize, 0);
    ctx.moveTo(0, -cSize * Y_SCALE);
    ctx.lineTo(0, cSize * Y_SCALE);
    ctx.stroke();
  }

  ctx.restore();
}

// 🌲 3D İzometrik Orman ve Çam Ağaçları
function drawIsometricForest(time) {
  const trees = [
    { x: -24, y: -16 * Y_SCALE, sc: 0.85 },
    { x: 20,  y: -22 * Y_SCALE, sc: 0.95 },
    { x: 0,   y: -30 * Y_SCALE, sc: 0.80 },
    { x: -10, y: -2 * Y_SCALE,  sc: 1.15 },
    { x: 22,  y: 6 * Y_SCALE,   sc: 1.05 },
    { x: -26, y: 14 * Y_SCALE,  sc: 0.88 },
    { x: 6,   y: 18 * Y_SCALE,  sc: 1.10 }
  ];
  trees.sort((a, b) => a.y - b.y);

  trees.forEach(tr => {
    const sway = Math.sin(time * 2.5 + tr.x * 0.1 + tr.y * 0.2) * (1.8 * tr.sc);

    // Zemin Gölgesi
    ctx.fillStyle = "rgba(0, 0, 0, 0.35)";
    ctx.beginPath();
    ctx.ellipse(tr.x + 2, tr.y + 2, 10 * tr.sc, 5 * tr.sc * Y_SCALE, 0, 0, Math.PI * 2);
    ctx.fill();

    // Ahşap Gövde
    const tw = 4 * tr.sc;
    const th = 9 * tr.sc * Y_SCALE;
    ctx.fillStyle = "#5c3d22";
    ctx.fillRect(tr.x - tw / 2, tr.y - th, tw, th);

    // 3 Kademeli Hacimli Çam Konileri (Işık/Gölge Yüzeyli)
    const tiers = [
      { y: tr.y - 6 * tr.sc * Y_SCALE, w: 16 * tr.sc, h: 14 * tr.sc * Y_SCALE, sw: sway * 0.3 },
      { y: tr.y - 14 * tr.sc * Y_SCALE, w: 12 * tr.sc, h: 13 * tr.sc * Y_SCALE, sw: sway * 0.6 },
      { y: tr.y - 22 * tr.sc * Y_SCALE, w: 8 * tr.sc,  h: 12 * tr.sc * Y_SCALE, sw: sway * 1.0 }
    ];

    tiers.forEach(t => {
      // Sol Gölge Yüzeyi
      ctx.fillStyle = "#0c4217";
      ctx.beginPath();
      ctx.moveTo(tr.x - t.w / 2, t.y);
      ctx.lineTo(tr.x, t.y + t.w * 0.15 * Y_SCALE);
      ctx.lineTo(tr.x + t.sw, t.y - t.h);
      ctx.closePath();
      ctx.fill();

      // Sağ Güneş Yüzeyi
      ctx.fillStyle = "#228b3b";
      ctx.beginPath();
      ctx.moveTo(tr.x, t.y + t.w * 0.15 * Y_SCALE);
      ctx.lineTo(tr.x + t.w / 2, t.y);
      ctx.lineTo(tr.x + t.sw, t.y - t.h);
      ctx.closePath();
      ctx.fill();
    });
  });
}

// 🏔️ 3D Karlı Dağ Zirveleri
function drawIsometricMountain() {
  const peaks = [
    { x: -14, y: 6 * Y_SCALE,  w: 28, h: 32 * Y_SCALE },
    { x: 16,  y: -6 * Y_SCALE, w: 32, h: 38 * Y_SCALE },
    { x: -2,  y: -18 * Y_SCALE,w: 24, h: 26 * Y_SCALE }
  ];
  peaks.sort((a, b) => a.y - b.y);

  peaks.forEach(p => {
    // Sol Yüzey
    ctx.fillStyle = "#4a3525";
    ctx.beginPath();
    ctx.moveTo(p.x - p.w / 2, p.y);
    ctx.lineTo(p.x, p.y + p.w * 0.15 * Y_SCALE);
    ctx.lineTo(p.x, p.y - p.h);
    ctx.closePath();
    ctx.fill();

    // Sağ Yüzey
    ctx.fillStyle = "#7a5c43";
    ctx.beginPath();
    ctx.moveTo(p.x, p.y + p.w * 0.15 * Y_SCALE);
    ctx.lineTo(p.x + p.w / 2, p.y);
    ctx.lineTo(p.x, p.y - p.h);
    ctx.closePath();
    ctx.fill();

    // Karlı Şapka (Snow Cap)
    const sH = p.h * 0.35;
    ctx.fillStyle = "#e2e8f0";
    ctx.beginPath();
    ctx.moveTo(p.x - p.w * 0.18, p.y - p.h + sH);
    ctx.lineTo(p.x, p.y - p.h + sH);
    ctx.lineTo(p.x, p.y - p.h);
    ctx.closePath();
    ctx.fill();

    ctx.fillStyle = "#ffffff";
    ctx.beginPath();
    ctx.moveTo(p.x, p.y - p.h + sH);
    ctx.lineTo(p.x + p.w * 0.18, p.y - p.h + sH);
    ctx.lineTo(p.x, p.y - p.h);
    ctx.closePath();
    ctx.fill();
  });
}

// 🌸 Çayır Çiçekleri & Çimen
function drawIsometricMeadow(time) {
  const spots = [
    { x: -18, y: -12 * Y_SCALE },
    { x: 16,  y: -14 * Y_SCALE },
    { x: -10, y: 14 * Y_SCALE },
    { x: 20,  y: 10 * Y_SCALE }
  ];
  spots.forEach(sp => {
    const sway = Math.sin(time * 2.5 + sp.x) * 1.5;
    ctx.strokeStyle = "#38a169";
    ctx.lineWidth = 1.6;
    ctx.beginPath();
    ctx.moveTo(sp.x, sp.y);
    ctx.lineTo(sp.x - 2 + sway, sp.y - 7 * Y_SCALE);
    ctx.moveTo(sp.x, sp.y);
    ctx.lineTo(sp.x + 2 + sway, sp.y - 8 * Y_SCALE);
    ctx.stroke();

    ctx.fillStyle = "#fef08a";
    ctx.beginPath();
    ctx.arc(sp.x + sway, sp.y - 9 * Y_SCALE, 1.8, 0, Math.PI * 2);
    ctx.fill();
  });
}

// 🌊 Deniz Dalgaları
function drawIsometricSea(time) {
  const offset = Math.sin(time * 2.0) * 3.0;
  ctx.strokeStyle = "rgba(147, 197, 253, 0.6)";
  ctx.lineWidth = 1.8;
  ctx.beginPath();
  ctx.arc(-14 + offset, -8 * Y_SCALE, 8.0, 0.2, 2.8);
  ctx.stroke();
  ctx.beginPath();
  ctx.arc(12 - offset, 6 * Y_SCALE, 10.0, 0.2, 2.8);
  ctx.stroke();
}

// 🏗️ 3D İZOMETRİK BİNA VE YAPILAR (GODOT İLE %100 BİREBİR DERİNLİK VE ANİMASYON)

function drawBuilding(b, time) {
  if (b.type === "castle") {
    drawIsometricCastle(b.level || game.castleLevel, time);
  } else if (b.type === "corn") {
    drawIsometricCornField(b, time);
  } else if (b.type === "windmill") {
    drawIsometricWindmill(b, time);
  } else if (b.type === "lumberjack") {
    drawIsometricLumberjack(b, time);
  } else if (b.type === "sawmill") {
    drawIsometricSawmill(b, time);
  } else if (b.type === "worker") {
    drawIsometricWorkerHut(b, time);
  } else if (b.type === "bridge") {
    drawIsometricBridge(b, time);
  }
}

// 🌉 3D Ahşap Kazıklı ve Korkuluklu Köprü
function drawIsometricBridge(b, time) {
  // Su Üzerindeki Gölge
  ctx.fillStyle = "rgba(8, 28, 44, 0.45)";
  ctx.beginPath();
  ctx.ellipse(2, 3 * Y_SCALE, 26, 16 * Y_SCALE, 0, 0, Math.PI * 2);
  ctx.fill();

  // Suya Çakılı 4 Ahşap Kazık
  const pillars = [
    { x: -22, y: -10 * Y_SCALE },
    { x: 22,  y: -10 * Y_SCALE },
    { x: -22, y: 10 * Y_SCALE },
    { x: 22,  y: 10 * Y_SCALE }
  ];
  pillars.forEach(p => {
    ctx.fillStyle = "#5c3d22";
    ctx.fillRect(p.x - 2.5, p.y - 6 * Y_SCALE, 5, 12 * Y_SCALE);
    // Su Halka Dalgası
    ctx.strokeStyle = "rgba(147, 197, 253, 0.5)";
    ctx.lineWidth = 1.0;
    ctx.beginPath();
    ctx.arc(p.x, p.y + 6 * Y_SCALE, 3, 0, Math.PI * 2);
    ctx.stroke();
  });

  // Ana Ahşap Kalaslar Platformu
  const numPlanks = 7;
  const bridgeW = 46;
  const bridgeH = 24 * Y_SCALE;

  for (let i = 0; i < numPlanks; i++) {
    const t = i / (numPlanks - 1);
    const xPos = -bridgeW * 0.5 + bridgeW * t;
    ctx.fillStyle = (i % 2 === 0) ? "#d4a373" : "#b07d4b";
    ctx.fillRect(xPos - 2.5, -bridgeH * 0.5, 4.5, bridgeH);
    ctx.strokeStyle = "#5c3d22";
    ctx.lineWidth = 0.8;
    ctx.strokeRect(xPos - 2.5, -bridgeH * 0.5, 4.5, bridgeH);
  }

  // Yan Güvenlik Korkulukları
  ctx.strokeStyle = "#5c3d22";
  ctx.lineWidth = 2.4;
  // Üst Korkuluk
  ctx.beginPath();
  ctx.moveTo(-bridgeW * 0.5, -bridgeH * 0.5 - 4 * Y_SCALE);
  ctx.lineTo(bridgeW * 0.5, -bridgeH * 0.5 - 4 * Y_SCALE);
  ctx.stroke();
  // Alt Korkuluk
  ctx.beginPath();
  ctx.moveTo(-bridgeW * 0.5, bridgeH * 0.5 - 1 * Y_SCALE);
  ctx.lineTo(bridgeW * 0.5, bridgeH * 0.5 - 1 * Y_SCALE);
  ctx.stroke();

  // Korkuluk Dikmeleri
  for (let i = 0; i < 4; i++) {
    const t = i / 3;
    const xPos = -bridgeW * 0.45 + bridgeW * 0.9 * t;
    ctx.strokeStyle = "#d4a373";
    ctx.lineWidth = 1.8;
    ctx.beginPath();
    ctx.moveTo(xPos, -bridgeH * 0.5);
    ctx.lineTo(xPos, -bridgeH * 0.5 - 6 * Y_SCALE);
    ctx.moveTo(xPos, bridgeH * 0.5 - 3 * Y_SCALE);
    ctx.lineTo(xPos, bridgeH * 0.5 + 2 * Y_SCALE);
    ctx.stroke();
  }
}

// 🏰 3D Krallık Şatosu (Hisar, Çift Kuleler, Kiremit Çatılar, Meşaleler ve Dalgalanan Kraliyet Bayrağı)
function drawIsometricCastle(level, time) {
  // 1. Zemin Gölgesi
  ctx.fillStyle = "rgba(0, 0, 0, 0.4)";
  ctx.beginPath();
  ctx.ellipse(3, 4 * Y_SCALE, 44, 26 * Y_SCALE, 0, 0, Math.PI * 2);
  ctx.fill();

  // 2. Ana Şato Gövdesi (Taş Duvarlar)
  const gw = 38;
  const gh = 26 * Y_SCALE;
  ctx.fillStyle = "#64748b"; // Sol aydınlık cephe
  ctx.fillRect(-gw / 2, -gh, gw / 2, gh);
  ctx.fillStyle = "#475569"; // Sağ gölge cephe
  ctx.fillRect(0, -gh, gw / 2, gh);

  // Taş derz çizgileri
  ctx.strokeStyle = "#334155";
  ctx.lineWidth = 1.0;
  ctx.strokeRect(-gw / 2, -gh, gw, gh);

  // 3. Ahşap & Demir Parmaklıklı Şato Kapısı
  ctx.fillStyle = "#1e293b";
  ctx.beginPath();
  ctx.arc(0, -10 * Y_SCALE, 7, Math.PI, 0);
  ctx.lineTo(7, 0);
  ctx.lineTo(-7, 0);
  ctx.closePath();
  ctx.fill();

  ctx.fillStyle = "#78350f";
  ctx.fillRect(-5, -9 * Y_SCALE, 10, 9 * Y_SCALE);
  ctx.strokeStyle = "#0f172a";
  ctx.lineWidth = 1.2;
  ctx.strokeRect(-5, -9 * Y_SCALE, 10, 9 * Y_SCALE);

  // 4. Yan Savunma Kuleleri (Sol ve Sağ)
  const towers = [
    { x: -22, y: -4 * Y_SCALE, w: 14, h: 32 * Y_SCALE },
    { x: 22,  y: -4 * Y_SCALE, w: 14, h: 32 * Y_SCALE }
  ];

  towers.forEach(tw => {
    // Sol aydınlık
    ctx.fillStyle = "#94a3b8";
    ctx.fillRect(tw.x - tw.w / 2, tw.y - tw.h, tw.w / 2, tw.h);
    // Sağ gölge
    ctx.fillStyle = "#64748b";
    ctx.fillRect(tw.x, tw.y - tw.h, tw.w / 2, tw.h);

    // Kule Burçları
    ctx.fillStyle = "#475569";
    ctx.fillRect(tw.x - tw.w / 2 - 2, tw.y - tw.h - 4 * Y_SCALE, tw.w + 4, 4 * Y_SCALE);

    // Konik Burgonya Kiremit Çatı
    const roofH = 18 * Y_SCALE;
    // Sol Kiremit Yüzeyi
    ctx.fillStyle = "#ef4444";
    ctx.beginPath();
    ctx.moveTo(tw.x - tw.w / 2 - 2, tw.y - tw.h - 4 * Y_SCALE);
    ctx.lineTo(tw.x, tw.y - tw.h - 4 * Y_SCALE + 2);
    ctx.lineTo(tw.x, tw.y - tw.h - 4 * Y_SCALE - roofH);
    ctx.closePath();
    ctx.fill();

    // Sağ Kiremit Yüzeyi
    ctx.fillStyle = "#b91c1c";
    ctx.beginPath();
    ctx.moveTo(tw.x, tw.y - tw.h - 4 * Y_SCALE + 2);
    ctx.lineTo(tw.x + tw.w / 2 + 2, tw.y - tw.h - 4 * Y_SCALE);
    ctx.lineTo(tw.x, tw.y - tw.h - 4 * Y_SCALE - roofH);
    ctx.closePath();
    ctx.fill();

    // Altın Çatı Tepeliği
    ctx.fillStyle = "#f59e0b";
    ctx.beginPath();
    ctx.arc(tw.x, tw.y - tw.h - 4 * Y_SCALE - roofH, 2.5, 0, Math.PI * 2);
    ctx.fill();

    // Kule Ok Pencereleri (Işıklı)
    ctx.fillStyle = "#fef08a";
    ctx.fillRect(tw.x - 1.5, tw.y - tw.h + 8 * Y_SCALE, 3, 5 * Y_SCALE);
  });

  // 5. Merkez Yüksek Başkule (Donjon)
  const mw = 22;
  const mh = 42 * Y_SCALE;
  ctx.fillStyle = "#cbd5e1";
  ctx.fillRect(-mw / 2, -mh, mw / 2, mh - gh);
  ctx.fillStyle = "#94a3b8";
  ctx.fillRect(0, -mh, mw / 2, mh - gh);

  // Başkule Burç Çıkıntıları (Kreneller)
  ctx.fillStyle = "#475569";
  for (let i = -mw / 2; i < mw / 2; i += 6) {
    ctx.fillRect(i, -mh - 4 * Y_SCALE, 4, 4 * Y_SCALE);
  }

  // Başkule Pencereleri (Sıcak Meşale Parıltısı)
  ctx.fillStyle = "#fde047";
  ctx.fillRect(-5, -mh + 6 * Y_SCALE, 3.5, 6 * Y_SCALE);
  ctx.fillRect(2, -mh + 6 * Y_SCALE, 3.5, 6 * Y_SCALE);

  // 6. Dalgalanan Altın Kraliyet Bayrağı & Flama
  const flagPoleX = 0;
  const flagPoleY = -mh - 4 * Y_SCALE;
  const poleH = 22 * Y_SCALE;

  // Bayrak Direği
  ctx.strokeStyle = "#e2e8f0";
  ctx.lineWidth = 1.8;
  ctx.beginPath();
  ctx.moveTo(flagPoleX, flagPoleY);
  ctx.lineTo(flagPoleX, flagPoleY - poleH);
  ctx.stroke();

  // Direk Ucu Altın Küre
  ctx.fillStyle = "#f59e0b";
  ctx.beginPath();
  ctx.arc(flagPoleX, flagPoleY - poleH, 2.8, 0, Math.PI * 2);
  ctx.fill();

  // Canlı Dalgalanan Kırlangıç Flama
  const wave1 = Math.sin(time * 4.5) * 3.5;
  const wave2 = Math.sin(time * 4.5 + 1.2) * 4.0;
  const flagTop = flagPoleY - poleH + 2;

  ctx.fillStyle = "#f59e0b";
  ctx.beginPath();
  ctx.moveTo(flagPoleX, flagTop);
  ctx.quadraticCurveTo(flagPoleX + 10, flagTop + wave1, flagPoleX + 22, flagTop + wave2);
  ctx.lineTo(flagPoleX + 16, flagTop + 7 + wave2 * 0.8);
  ctx.lineTo(flagPoleX + 22, flagTop + 14 + wave2);
  ctx.quadraticCurveTo(flagPoleX + 10, flagTop + 12 + wave1, flagPoleX, flagTop + 12);
  ctx.closePath();
  ctx.fill();

  // Flama Üzerinde Kraliyet Arması Kırmızısı
  ctx.fillStyle = "#dc2626";
  ctx.beginPath();
  ctx.arc(flagPoleX + 7, flagTop + 6 + wave1 * 0.5, 2.2, 0, Math.PI * 2);
  ctx.fill();

  // İleri Kademe Şato Süsleri (Level 4+)
  if (level >= 4) {
    ctx.fillStyle = "#f59e0b";
    ctx.font = "bold 13px Outfit, sans-serif";
    ctx.textAlign = "center";
    ctx.fillText("👑", 0, -mh - 26 * Y_SCALE);
  }
}

// 🌽 3D Karıklı, Çitli ve Rüzgarda Salınan Mısır Tarlası
function drawIsometricCornField(b, time) {
  // 1. Zemin Gölgesi ve Sürülmüş Toprak Tabanı
  ctx.fillStyle = "rgba(0, 0, 0, 0.25)";
  ctx.beginPath();
  ctx.ellipse(0, 0, 42, 26 * Y_SCALE, 0, 0, Math.PI * 2);
  ctx.fill();

  // 2. Sürülmüş Tarla Karıkları (Plowed Soil Furrows)
  const ridges = 5;
  const rWidth = 46;
  const rDepth = 32 * Y_SCALE;

  for (let i = 0; i < ridges; i++) {
    const t = i / (ridges - 1);
    const zOffset = (-rDepth * 0.5) + (rDepth * t);

    // Çukur Gölgesi
    ctx.strokeStyle = "#3e2723";
    ctx.lineWidth = 4.5 * Y_SCALE;
    ctx.beginPath();
    ctx.moveTo(-rWidth * 0.48, zOffset);
    ctx.lineTo(rWidth * 0.48, zOffset);
    ctx.stroke();

    // Güneş Vuran Toprak Tepesi
    ctx.strokeStyle = "#795548";
    ctx.lineWidth = 2.2 * Y_SCALE;
    ctx.beginPath();
    ctx.moveTo(-rWidth * 0.46, zOffset - 1.5 * Y_SCALE);
    ctx.lineTo(rWidth * 0.46, zOffset - 1.5 * Y_SCALE);
    ctx.stroke();
  }

  // 3. Ahşap Köşe Çitleri
  const posts = [
    { x: -32, y: -14 * Y_SCALE },
    { x: 32,  y: -14 * Y_SCALE },
    { x: -34, y: 12 * Y_SCALE },
    { x: 34,  y: 12 * Y_SCALE }
  ];

  posts.forEach(p => {
    ctx.fillStyle = "#8d6e63";
    ctx.fillRect(p.x - 1.8, p.y - 8 * Y_SCALE, 3.6, 8 * Y_SCALE);
    ctx.fillStyle = "#d7ccc8";
    ctx.fillRect(p.x - 1.8, p.y - 9 * Y_SCALE, 3.6, 1.5 * Y_SCALE);
  });

  // Çit Yatay Tahtaları
  ctx.strokeStyle = "#6d4c41";
  ctx.lineWidth = 1.5;
  ctx.beginPath();
  ctx.moveTo(-32, -18 * Y_SCALE);
  ctx.lineTo(32, -18 * Y_SCALE);
  ctx.stroke();

  // 4. Canlı Rüzgarda Salınan Mısır Sapları & Koçanları
  const stalks = [
    { x: -20, y: -10 * Y_SCALE, sc: 0.90 },
    { x: 0,   y: -14 * Y_SCALE, sc: 0.95 },
    { x: 20,  y: -11 * Y_SCALE, sc: 0.92 },
    { x: -14, y: 0,             sc: 1.08 },
    { x: 12,  y: -2 * Y_SCALE,  sc: 1.05 },
    { x: -22, y: 10 * Y_SCALE,  sc: 0.95 },
    { x: -2,  y: 12 * Y_SCALE,  sc: 1.12 },
    { x: 18,  y: 9 * Y_SCALE,   sc: 1.02 }
  ];
  stalks.sort((a, b) => a.y - b.y);

  stalks.forEach((st, idx) => {
    const sway = Math.sin(time * 3.2 + idx * 0.85) * (2.8 * st.sc);
    const stalkH = 22 * st.sc * Y_SCALE;

    // Yeşil Sap
    ctx.strokeStyle = "#16a34a";
    ctx.lineWidth = 2.4 * st.sc;
    ctx.beginPath();
    ctx.moveTo(st.x, st.y);
    ctx.quadraticCurveTo(st.x + sway * 0.5, st.y - stalkH * 0.5, st.x + sway, st.y - stalkH);
    ctx.stroke();

    // Açılan Mısır Yaprakları
    ctx.strokeStyle = "#4ade80";
    ctx.lineWidth = 1.8 * st.sc;
    // Sol Yaprak
    ctx.beginPath();
    ctx.moveTo(st.x + sway * 0.3, st.y - stalkH * 0.35);
    ctx.quadraticCurveTo(st.x - 7 * st.sc, st.y - stalkH * 0.45, st.x - 9 * st.sc + sway, st.y - stalkH * 0.2);
    ctx.stroke();
    // Sağ Yaprak
    ctx.beginPath();
    ctx.moveTo(st.x + sway * 0.6, st.y - stalkH * 0.65);
    ctx.quadraticCurveTo(st.x + 8 * st.sc, st.y - stalkH * 0.75, st.x + 10 * st.sc + sway, st.y - stalkH * 0.5);
    ctx.stroke();

    // 🌽 Olgun Altın Sarısı Mısır Koçanı
    const cobX = st.x + sway * 0.55 + 2 * st.sc;
    const cobY = st.y - stalkH * 0.55;
    ctx.fillStyle = "#eab308";
    ctx.beginPath();
    ctx.ellipse(cobX, cobY, 3.2 * st.sc, 6.5 * st.sc * Y_SCALE, Math.PI / 8, 0, Math.PI * 2);
    ctx.fill();

    // Mısır Püskülü (Tassel)
    ctx.strokeStyle = "#ca8a04";
    ctx.lineWidth = 1.2 * st.sc;
    ctx.beginPath();
    ctx.moveTo(st.x + sway, st.y - stalkH);
    ctx.lineTo(st.x + sway - 2 * st.sc, st.y - stalkH - 4 * Y_SCALE);
    ctx.moveTo(st.x + sway, st.y - stalkH);
    ctx.lineTo(st.x + sway + 2 * st.sc, st.y - stalkH - 4.5 * Y_SCALE);
    ctx.stroke();
  });

  // 5. Sevimli Tarla Korkuluğu (Scarecrow)
  const scX = 26;
  const scY = 2 * Y_SCALE;
  // Direk
  ctx.strokeStyle = "#5d4037";
  ctx.lineWidth = 2.0;
  ctx.beginPath();
  ctx.moveTo(scX, scY);
  ctx.lineTo(scX, scY - 18 * Y_SCALE);
  ctx.moveTo(scX - 6, scY - 12 * Y_SCALE);
  ctx.lineTo(scX + 6, scY - 12 * Y_SCALE);
  ctx.stroke();
  // Mavi Gömlek
  ctx.fillStyle = "#2563eb";
  ctx.fillRect(scX - 3.5, scY - 14 * Y_SCALE, 7, 7 * Y_SCALE);
  // Saman Baş ve Şapka
  ctx.fillStyle = "#fef08a";
  ctx.beginPath();
  ctx.arc(scX, scY - 16 * Y_SCALE, 2.5, 0, Math.PI * 2);
  ctx.fill();
  ctx.fillStyle = "#b45309";
  ctx.fillRect(scX - 4.5, scY - 19 * Y_SCALE, 9, 2.5 * Y_SCALE);
  ctx.fillRect(scX - 2.5, scY - 22 * Y_SCALE, 5, 3.5 * Y_SCALE);

  // 6. Hasat Bekleyen Doluluk Göstergesi (Floating Harvest Glow)
  const accum = b.accumulated || 0;
  if (accum > 0.5) {
    const floatOffset = Math.sin(time * 3.0) * 3.0;
    ctx.fillStyle = "rgba(234, 179, 8, 0.92)";
    ctx.beginPath();
    ctx.arc(0, -32 * Y_SCALE + floatOffset, 11, 0, Math.PI * 2);
    ctx.fill();
    ctx.strokeStyle = "#ffffff";
    ctx.lineWidth = 1.5;
    ctx.stroke();

    ctx.fillStyle = "#000000";
    ctx.font = "bold 11px Outfit, sans-serif";
    ctx.textAlign = "center";
    ctx.fillText("🌽", 0, -28 * Y_SCALE + floatOffset);
  }
}

// 🌾 3D Dönen Değirmen (Taş Gövde, Ahşap Çatı ve Kanatlar)
function drawIsometricWindmill(b, time) {
  // Zemin Gölgesi
  ctx.fillStyle = "rgba(0, 0, 0, 0.35)";
  ctx.beginPath();
  ctx.ellipse(2, 2 * Y_SCALE, 26, 16 * Y_SCALE, 0, 0, Math.PI * 2);
  ctx.fill();

  // Taş Gövde (Sol Aydınlık, Sağ Gölge)
  ctx.fillStyle = "#cbd5e1";
  ctx.beginPath();
  ctx.moveTo(-12, 0);
  ctx.lineTo(0, 2 * Y_SCALE);
  ctx.lineTo(0, -32 * Y_SCALE);
  ctx.lineTo(-8, -32 * Y_SCALE);
  ctx.closePath();
  ctx.fill();

  ctx.fillStyle = "#94a3b8";
  ctx.beginPath();
  ctx.moveTo(0, 2 * Y_SCALE);
  ctx.lineTo(12, 0);
  ctx.lineTo(8, -32 * Y_SCALE);
  ctx.lineTo(0, -32 * Y_SCALE);
  ctx.closePath();
  ctx.fill();

  // Kapı
  ctx.fillStyle = "#78350f";
  ctx.fillRect(-3, -8 * Y_SCALE, 6, 8 * Y_SCALE);

  // Konik Ahşap Çatı
  ctx.fillStyle = "#b45309";
  ctx.beginPath();
  ctx.moveTo(-11, -32 * Y_SCALE);
  ctx.lineTo(11, -32 * Y_SCALE);
  ctx.lineTo(0, -46 * Y_SCALE);
  ctx.closePath();
  ctx.fill();

  // Dönen 4 Yelken Kanadı
  const bladeAngle = time * 3.2;
  const hubY = -34 * Y_SCALE;

  ctx.save();
  ctx.translate(0, hubY);
  ctx.rotate(bladeAngle);

  for (let i = 0; i < 4; i++) {
    ctx.rotate(Math.PI / 2);
    // Ahşap Kol
    ctx.strokeStyle = "#5c3d22";
    ctx.lineWidth = 2.2;
    ctx.beginPath();
    ctx.moveTo(0, 0);
    ctx.lineTo(0, -22);
    ctx.stroke();

    // Beyaz Keten Yelken Bezi
    ctx.fillStyle = "rgba(254, 240, 138, 0.9)";
    ctx.fillRect(2, -21, 7, 14);
    ctx.strokeStyle = "#ca8a04";
    ctx.lineWidth = 0.8;
    ctx.strokeRect(2, -21, 7, 14);
  }

  // Merkez Göbek
  ctx.fillStyle = "#1e293b";
  ctx.beginPath();
  ctx.arc(0, 0, 3.5, 0, Math.PI * 2);
  ctx.fill();
  ctx.restore();
}

// 🪓 3D Oduncu Kulübesi (Kütük Ev, Odun Yığınları ve Baltalı Kütük)
function drawIsometricLumberjack(b, time) {
  // Zemin Gölgesi
  ctx.fillStyle = "rgba(0, 0, 0, 0.35)";
  ctx.beginPath();
  ctx.ellipse(0, 0, 32, 18 * Y_SCALE, 0, 0, Math.PI * 2);
  ctx.fill();

  // Kütük Duvarlar
  ctx.fillStyle = "#854d0e";
  ctx.fillRect(-18, -18 * Y_SCALE, 18, 18 * Y_SCALE);
  ctx.fillStyle = "#713f12";
  ctx.fillRect(0, -18 * Y_SCALE, 18, 18 * Y_SCALE);

  // Üçgen Kiremit Çatı
  ctx.fillStyle = "#a16207";
  ctx.beginPath();
  ctx.moveTo(-22, -18 * Y_SCALE);
  ctx.lineTo(22, -18 * Y_SCALE);
  ctx.lineTo(0, -32 * Y_SCALE);
  ctx.closePath();
  ctx.fill();

  // Taş Baca & Duman
  ctx.fillStyle = "#64748b";
  ctx.fillRect(10, -30 * Y_SCALE, 5, 12 * Y_SCALE);
  const smoke = Math.sin(time * 3.0) * 3.0;
  ctx.fillStyle = "rgba(226, 232, 240, 0.6)";
  ctx.beginPath();
  ctx.arc(12 + smoke, -34 * Y_SCALE, 3, 0, Math.PI * 2);
  ctx.arc(14 + smoke * 1.5, -39 * Y_SCALE, 4, 0, Math.PI * 2);
  ctx.fill();

  // Baltalı Ağaç Kütüğü
  ctx.fillStyle = "#d97706";
  ctx.fillRect(-22, -4 * Y_SCALE, 8, 5 * Y_SCALE);
  ctx.strokeStyle = "#e2e8f0";
  ctx.lineWidth = 2.0;
  ctx.beginPath();
  ctx.moveTo(-18, -4 * Y_SCALE);
  ctx.lineTo(-14, -11 * Y_SCALE);
  ctx.stroke();

  // Odun Yığınları
  ctx.fillStyle = "#b45309";
  ctx.beginPath();
  ctx.arc(18, -2 * Y_SCALE, 3.5, 0, Math.PI * 2);
  ctx.arc(24, -2 * Y_SCALE, 3.5, 0, Math.PI * 2);
  ctx.arc(21, -6 * Y_SCALE, 3.5, 0, Math.PI * 2);
  ctx.fill();
}

// 🪵 3D Kereste Fabrikası (Hızar Testeresi & Kalas Yığınları)
function drawIsometricSawmill(b, time) {
  // Zemin Gölgesi
  ctx.fillStyle = "rgba(0, 0, 0, 0.35)";
  ctx.beginPath();
  ctx.ellipse(0, 0, 34, 20 * Y_SCALE, 0, 0, Math.PI * 2);
  ctx.fill();

  // Atölye Ahşap İskeleti
  ctx.fillStyle = "#78350f";
  ctx.fillRect(-18, -14 * Y_SCALE, 36, 14 * Y_SCALE);
  ctx.fillStyle = "#92400e";
  ctx.fillRect(-22, -26 * Y_SCALE, 44, 12 * Y_SCALE);

  // Dönen Çelik Hızar Testeresi
  const sawSpin = time * 12.0;
  ctx.save();
  ctx.translate(-2, -6 * Y_SCALE);
  ctx.rotate(sawSpin);
  ctx.fillStyle = "#e2e8f0";
  ctx.beginPath();
  ctx.arc(0, 0, 7, 0, Math.PI * 2);
  ctx.fill();
  ctx.strokeStyle = "#94a3b8";
  ctx.lineWidth = 1.5;
  ctx.stroke();
  ctx.restore();

  // Kesilmiş Kereste Kalas Yığınları
  ctx.fillStyle = "#fde68a";
  ctx.fillRect(12, -4 * Y_SCALE, 14, 3 * Y_SCALE);
  ctx.fillRect(14, -8 * Y_SCALE, 12, 3 * Y_SCALE);
  ctx.fillRect(13, -12 * Y_SCALE, 13, 3 * Y_SCALE);
  ctx.strokeStyle = "#d97706";
  ctx.lineWidth = 0.8;
  ctx.strokeRect(12, -4 * Y_SCALE, 14, 3 * Y_SCALE);
  ctx.strokeRect(14, -8 * Y_SCALE, 12, 3 * Y_SCALE);
}

// 🛖 3D İşçi Kulübesi (Saman Çatılı Kulübe, Taş Baca ve El Arabası)
function drawIsometricWorkerHut(b, time) {
  // Zemin Gölgesi
  ctx.fillStyle = "rgba(0, 0, 0, 0.3)";
  ctx.beginPath();
  ctx.ellipse(0, 0, 30, 18 * Y_SCALE, 0, 0, Math.PI * 2);
  ctx.fill();

  // Kil/Taş Duvarlar
  ctx.fillStyle = "#e2e8f0";
  ctx.fillRect(-15, -16 * Y_SCALE, 30, 16 * Y_SCALE);

  // Sarı Saman Çatı
  ctx.fillStyle = "#eab308";
  ctx.beginPath();
  ctx.moveTo(-19, -16 * Y_SCALE);
  ctx.lineTo(19, -16 * Y_SCALE);
  ctx.lineTo(0, -30 * Y_SCALE);
  ctx.closePath();
  ctx.fill();

  // Kapı & Pencere
  ctx.fillStyle = "#78350f";
  ctx.fillRect(-4, -8 * Y_SCALE, 8, 8 * Y_SCALE);
  ctx.fillStyle = "#fde047";
  ctx.fillRect(7, -12 * Y_SCALE, 4, 4 * Y_SCALE);

  // Tüten Baca Dumanı
  const smoke = Math.sin(time * 3.5) * 3.0;
  ctx.fillStyle = "rgba(203, 213, 225, 0.7)";
  ctx.beginPath();
  ctx.arc(-8 + smoke, -32 * Y_SCALE, 3, 0, Math.PI * 2);
  ctx.arc(-10 + smoke * 1.5, -37 * Y_SCALE, 4.5, 0, Math.PI * 2);
  ctx.fill();
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

  if (game.autoSaveTimer >= 30.0) {
    game.autoSaveTimer = 0.0;
    saveGame();
  }

  // 1. Üretim Döngüsü (Mısır, Oduncu, Değirmen, Kereste, İşçi)
  processProduction(delta);

  // 2. Çizim
  draw();

  // 3. UI Canlı Güncelleme
  updateUI();
  updateOpenMenuLive();

  requestAnimationFrame(gameLoop);
}

function processProduction(delta) {
  const globalMult = game.getGlobalMultiplier();

  Object.values(game.tiles).forEach(tile => {
    if (tile.state !== "OWNED" || !tile.building) return;
    const b = tile.building;

    if (b.type === "corn") {
      const rate = (0.42 * Math.pow(1.5, b.level - 1)) * globalMult;
      const maxCap = rate * 30.0;
      b.accumulated = Math.min(maxCap, (b.accumulated || 0) + rate * delta);
    } else if (b.type === "lumberjack") {
      const rate = (0.35 * Math.pow(1.5, b.level - 1)) * globalMult;
      const maxCap = rate * 30.0;
      b.accumulated = Math.min(maxCap, (b.accumulated || 0) + rate * delta);
    } else if (b.type === "windmill") {
      const rate = (0.25 * Math.pow(1.5, b.level - 1)) * globalMult;
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
      const rate = (0.20 * Math.pow(1.5, b.level - 1)) * globalMult;
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
          lumberHuts.forEach(h => {
            const take = Math.min(h.accumulated, takePerHut);
            h.accumulated -= take;
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
    } else if (b.type === "worker") {
      const rate = (0.80 * Math.pow(1.5, b.level - 1)) * globalMult;
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
          } else if (tgt.type === "sawmill") {
            game.plank += take;
          }
        });
      }
    }
  });
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
    const tile = game.tiles[key];

    if (tile) {
      handleTileClick(tile);
    }
  });
}

function handleTileClick(tile) {
  if (tile.state === "DISCOVERED") {
    // Deniz ve Köprü Geçiş Kontrolü:
    const neighbors = NEIGHBOR_DIRS.map(d => `${tile.q + d.q},${tile.r + d.r}`);
    let hasValidAccess = false;
    let blockedByUnbridgedSea = false;

    for (const nKey of neighbors) {
      const nTile = game.tiles[nKey];
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
      showToast(t("toast_need_bridge"), true);
      return;
    }

    // Arsa Satın Alma / Fethetme (Üstel Artan Maliyet)
    const cost = game.getLandExpansionCost();
    if (game.food >= cost) {
      game.food -= cost;
      game.purchasedTilesCount += 1;
      game.ownedCount += 1;
      game.statTotalConquered += 1;
      tile.state = "OWNED";

      audio.playTileUnlock();
      game.revealNeighbors(tile.q, tile.r);
      saveGame();

      if (tile.biome === BIOMES.MOUNTAIN) {
        showToast(t("toast_mountain_conquered"));
      } else if (cost === 0) {
        showToast(t("toast_free_tile"));
      } else {
        showToast(t("toast_buy_tile").replace("%d", cost).replace("1", cost));
      }
    } else {
      audio.playError();
      showToast(t("toast_no_food_tile").replace("%d", cost).replace("1", cost), true);
    }
  } else if (tile.state === "OWNED") {
    // Sahipli arsa etkileşimi
    game.selectedTile = tile;
    if (!tile.building) {
      if (tile.biome === BIOMES.MEADOW) {
        openBuildMenu(tile);
      } else if (tile.biome === BIOMES.FOREST) {
        if (game.castleLevel < 2) {
          audio.playError();
          showToast(t("toast_forest_locked"), true);
        } else {
          openBuildMenu(tile);
        }
      } else if (tile.biome === BIOMES.SEA) {
        // Deniz karosuna köprü inşa edebilmek için en az 1 komşu kara parçası olmalı
        const neighbors = NEIGHBOR_DIRS.map(d => `${tile.q + d.q},${tile.r + d.r}`);
        const hasAdjacentLand = neighbors.some(nKey => {
          const nTile = game.tiles[nKey];
          return nTile && nTile.biome !== BIOMES.SEA;
        });
        if (hasAdjacentLand) {
          openBuildMenu(tile);
        } else {
          audio.playError();
          showToast(t("toast_bridge_need_land"), true);
        }
      } else if (tile.biome === BIOMES.MOUNTAIN) {
        showToast(t("toast_mountain_info"));
      } else {
        showToast(t("toast_no_build_biome"));
      }
    } else {
      if (tile.building.type === "bridge") {
        showToast("🌉 Ahşap Köprü. Açık deniz geçişi ve kara bağlantısı aktif.");
      } else {
        openBuildingMenu(tile);
      }
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
const hintLabel = document.getElementById("hint-label");
const drawerRow = document.getElementById("drawer-row");
const btnToggleDrawer = document.getElementById("btn-toggle-drawer");
const btnSettings = document.getElementById("btn-settings");

const bottomMenu = document.getElementById("bottom-menu");
const menuTitle = document.getElementById("menu-title");
const menuContent = document.getElementById("menu-content");
const btnCloseMenu = document.getElementById("btn-close-menu");

const modalBackdrop = document.getElementById("modal-backdrop");
const settingsModal = document.getElementById("settings-modal");
const prestigeConfirmModal = document.getElementById("prestige-confirm-modal");
const offlineModal = document.getElementById("offline-modal");

function updateUI() {
  foodLabel.textContent = `${t("food")}: ${game.food % 1 === 0 ? game.food : game.food.toFixed(1)}`;
  woodLabel.textContent = `${t("wood")}: ${game.wood % 1 === 0 ? game.wood : game.wood.toFixed(1)}`;
  flourLabel.textContent = `${t("flour")}: ${game.flour % 1 === 0 ? game.flour : game.flour.toFixed(1)}`;
  plankLabel.textContent = `${t("plank")}: ${game.plank % 1 === 0 ? game.plank : game.plank.toFixed(1)}`;
  crownLabel.textContent = `${game.crowns}`;
  landLabel.textContent = `${game.ownedCount}`;

  if (game.castleLevel === 1) hintLabel.textContent = t("hint_castle_1");
  else if (game.castleLevel === 2) hintLabel.textContent = t("hint_castle_2");
  else if (game.food < 1.0) hintLabel.textContent = t("hint_no_food");
  else hintLabel.textContent = t("hint_expand");
}

function openBuildMenu(tile) {
  audio.playClick();
  const isMeadow = (tile.biome === BIOMES.MEADOW);
  const isForest = (tile.biome === BIOMES.FOREST);
  const isSea = (tile.biome === BIOMES.SEA);

  if (isMeadow) menuTitle.textContent = t("build_title_meadow");
  else if (isForest) menuTitle.textContent = t("build_title_forest");
  else if (isSea) menuTitle.textContent = t("build_title_sea");

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
          <span class="cost-tag ${canMill ? '' : 'cant-afford'}">${isLvl3 ? '5 🥡 + 3 🪵' : '🔒 ŞATO SV. 3'}</span>
          <button class="btn-primary" ${isLvl3 ? '' : 'disabled'} onclick="buildOnSelected('windmill', 5, 3)">${t("build_btn")}</button>
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
          <span class="cost-tag ${canSaw ? '' : 'cant-afford'}">${isLvl3 ? '4 🥡 + 5 🪵' : '🔒 ŞATO SV. 3'}</span>
          <button class="btn-primary" ${isLvl3 ? '' : 'disabled'} onclick="buildOnSelected('sawmill', 4, 5)">${t("build_btn")}</button>
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

  // 3. İşçi Kulübesi Kartı (Çayır ve Ormanda yapılabilir)
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
  bottomMenu.classList.remove("hidden");
}

window.buildOnSelected = function(bType, foodCost = 0, woodCost = 0) {
  if (!game.selectedTile) return;
  if (game.food < foodCost || game.wood < woodCost) {
    audio.playError();
    showToast(t("toast_insufficient_res"), true);
    return;
  }

  game.food -= foodCost;
  game.wood -= woodCost;
  game.selectedTile.building = {
    type: bType,
    level: 1,
    accumulated: 0.0
  };

  audio.playBuild();
  closeBottomMenu();
  saveGame();

  if (bType === 'corn') showToast(t("toast_built_corn"));
  else if (bType === 'windmill') showToast(t("toast_built_windmill"));
  else if (bType === 'lumberjack') showToast(t("toast_built_lumberjack"));
  else if (bType === 'sawmill') showToast(t("toast_built_sawmill"));
  else if (bType === 'worker') showToast(t("toast_built_worker"));
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
  }

  bottomMenu.classList.remove("hidden");
}

function updateOpenMenuLive() {
  if (bottomMenu.classList.contains("hidden") || !game.selectedTile) return;
  // Canlı değer güncellemesi
  const b = game.selectedTile.building;
  if (!b) return;
  // Güncel metinleri tazele
}

function closeBottomMenu() {
  bottomMenu.classList.add("hidden");
  game.selectedTile = null;
}

// Koleksiyon İşlemleri
window.collectCorn = function() {
  if (!game.selectedTile || !game.selectedTile.building) return;
  const b = game.selectedTile.building;
  const val = b.accumulated || 0;
  if (val > 0.001) {
    game.food += val;
    game.statTotalFood += val;
    b.accumulated = 0;
    audio.playCollect();
    showToast(t("toast_collected_food", [val]));
    openBuildingMenu(game.selectedTile);
  }
};

window.collectWood = function() {
  if (!game.selectedTile || !game.selectedTile.building) return;
  const b = game.selectedTile.building;
  const val = b.accumulated || 0;
  if (val > 0.001) {
    game.wood += val;
    game.statTotalWood += val;
    b.accumulated = 0;
    audio.playCollect();
    showToast(t("toast_collected_wood", [val]));
    openBuildingMenu(game.selectedTile);
  }
};

window.collectFlour = function() {
  if (!game.selectedTile || !game.selectedTile.building) return;
  const b = game.selectedTile.building;
  const val = b.accumulated || 0;
  if (val > 0.001) {
    game.flour += val;
    b.accumulated = 0;
    audio.playCollect();
    showToast(t("toast_collected_flour", [val]));
    openBuildingMenu(game.selectedTile);
  }
};

window.collectPlank = function() {
  if (!game.selectedTile || !game.selectedTile.building) return;
  const b = game.selectedTile.building;
  const val = b.accumulated || 0;
  if (val > 0.001) {
    game.plank += val;
    b.accumulated = 0;
    audio.playCollect();
    showToast(t("toast_collected_plank", [val]));
    openBuildingMenu(game.selectedTile);
  }
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
  saveGame();
  showToast(t("toast_upgraded", [t(type + "_name"), game.selectedTile.building.level]));
  openBuildingMenu(game.selectedTile);
};

window.upgradeBuildingMulti = function(type, foodCost, woodCost) {
  if (game.food < foodCost || game.wood < woodCost) {
    audio.playError();
    showToast(t("toast_insufficient_res"), true);
    return;
  }
  game.food -= foodCost;
  game.wood -= woodCost;
  game.selectedTile.building.level += 1;
  audio.playUpgrade();
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
    audio.playCastleUpgrade();
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
  const tabGen = document.getElementById("tab-general");
  const tabStat = document.getElementById("tab-stats");
  const tabPres = document.getElementById("tab-prestige");

  function switchTab(idx) {
    audio.playClick();
    tabBtnGen.classList.toggle("active", idx === 0);
    tabBtnStat.classList.toggle("active", idx === 1);
    tabBtnPres.classList.toggle("active", idx === 2);

    tabGen.classList.toggle("hidden", idx !== 0);
    tabStat.classList.toggle("hidden", idx !== 1);
    tabPres.classList.toggle("hidden", idx !== 2);

    if (idx === 1) updateStatsModal();
    if (idx === 2) updatePrestigeModal();
  }

  tabBtnGen.addEventListener("click", () => switchTab(0));
  tabBtnStat.addEventListener("click", () => switchTab(1));
  tabBtnPres.addEventListener("click", () => switchTab(2));

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

  volumeSlider.addEventListener("input", e => {
    audio.volume = parseFloat(e.target.value);
  });

  btnMute.addEventListener("click", () => {
    audio.isMuted = !audio.isMuted;
    btnMute.textContent = audio.isMuted ? "🔇 " + t("mute") : "🔊 " + t("unmute");
    audio.playClick();
  });

  // Prestij Butonları
  document.getElementById("btn-do-prestige").addEventListener("click", () => {
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

  document.getElementById("btn-confirm-rebirth").addEventListener("click", () => {
    const earned = game.calculateEarnedCrowns();
    if (earned <= 0) return;

    game.crowns += earned;
    game.totalRebirths += 1;

    // Sıfırlama
    game.food = 1.0;
    game.wood = 0.0;
    game.flour = 0.0;
    game.plank = 0.0;
    game.castleLevel = 1;
    game.initFreshMap();

    closeModals();
    audio.playPrestige();
    saveGame();
    showToast(t("toast_prestige_success", [earned, Math.round((game.getPrestigeMultiplier() - 1.0) * 100)]));
  });

  document.getElementById("btn-cancel-rebirth").addEventListener("click", () => {
    prestigeConfirmModal.classList.add("hidden");
    settingsModal.classList.remove("hidden");
  });

  // Çevrimdışı Gelir Butonları
  document.getElementById("btn-claim-offline").addEventListener("click", () => {
    claimOfflineGains(1);
  });
  document.getElementById("btn-claim-3x").addEventListener("click", () => {
    claimOfflineGains(3);
  });
}

function openSettingsModal() {
  updateLanguageUI();
  updateStatsModal();
  updatePrestigeModal();
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
}

function updateLanguageUI() {
  document.querySelectorAll(".btn-lang").forEach(btn => {
    btn.classList.toggle("active", btn.getAttribute("data-lang") === currentLang);
  });

  document.getElementById("settings-title").textContent = t("settings_title");
  document.getElementById("tab-btn-general").textContent = t("tab_general");
  document.getElementById("tab-btn-stats").textContent = t("tab_stats");
  document.getElementById("tab-btn-prestige").textContent = t("tab_prestige");
  document.getElementById("lbl-lang-select").textContent = t("language_select");
  document.getElementById("lbl-audio-sfx").textContent = t("sfx_volume");
  document.getElementById("lbl-prestige-desc").textContent = t("prestige_desc");
  document.getElementById("btn-do-prestige").textContent = t("rebirth_btn");

  updateUI();
}

function updateStatsModal() {
  const mins = Math.floor(game.statPlaytime / 60);
  const secs = Math.floor(game.statPlaytime % 60);
  document.getElementById("val-stat-playtime").textContent = `${mins} dk ${secs} sn`;
  document.getElementById("val-stat-conquered").textContent = `${game.statTotalConquered}`;
  document.getElementById("val-stat-food").textContent = `${game.statTotalFood.toFixed(1)}`;
  document.getElementById("val-stat-wood").textContent = `${game.statTotalWood.toFixed(1)}`;
  document.getElementById("val-stat-flour").textContent = `${game.statTotalFlour.toFixed(1)}`;
  document.getElementById("val-stat-plank").textContent = `${game.statTotalPlank.toFixed(1)}`;
  document.getElementById("val-stat-rebirths").textContent = `${game.totalRebirths}`;
}

function updatePrestigeModal() {
  const bonusPct = Math.round((game.getPrestigeMultiplier() - 1.0) * 100);
  const earned = game.calculateEarnedCrowns();
  document.getElementById("val-curr-crowns").textContent = `${game.crowns} 👑 (+%${bonusPct})`;
  document.getElementById("val-earn-crowns").textContent = `+${earned} 👑`;
}

// Çevrimdışı Gelir
let pendingOffline = { food: 0, wood: 0, flour: 0, plank: 0 };

function checkOfflineGains(lastTimestamp) {
  if (!lastTimestamp) return;
  const now = Math.floor(Date.now() / 1000);
  const elapsed = Math.max(0, now - lastTimestamp);
  if (elapsed < 15) return;

  const cappedSeconds = Math.min(8 * 3600, elapsed);
  const globalMult = game.getGlobalMultiplier();

  let f = 0, w = 0, fl = 0, p = 0;
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
    }
  });

  if (f > 0.1 || w > 0.1 || fl > 0.1 || p > 0.1) {
    pendingOffline = { food: f, wood: w, flour: fl, plank: p };
    const mins = Math.floor(cappedSeconds / 60);
    const timeStr = mins >= 60 ? `${Math.floor(mins / 60)} sa ${mins % 60} dk` : `${mins} dk`;

    document.getElementById("lbl-offline-title").textContent = t("offline_welcome");
    document.getElementById("lbl-offline-desc").textContent = t("offline_desc", [timeStr]);
    document.getElementById("gain-food").textContent = `+${f.toFixed(1)} 🥡 ${t("food")}`;
    document.getElementById("gain-wood").textContent = `+${w.toFixed(1)} 🪵 ${t("wood")}`;
    document.getElementById("gain-flour").textContent = `+${fl.toFixed(1)} 🌾 ${t("flour")}`;
    document.getElementById("gain-plank").textContent = `+${p.toFixed(1)} 🪵 ${t("plank")}`;
    document.getElementById("btn-claim-offline").textContent = t("offline_claim");
    document.getElementById("btn-claim-3x").textContent = t("offline_claim_3x");

    modalBackdrop.classList.remove("hidden");
    offlineModal.classList.remove("hidden");
    audio.playCollect();
  }
}

function claimOfflineGains(multiplier = 1) {
  game.food += pendingOffline.food * multiplier;
  game.wood += pendingOffline.wood * multiplier;
  game.flour += pendingOffline.flour * multiplier;
  game.plank += pendingOffline.plank * multiplier;

  game.statTotalFood += pendingOffline.food * multiplier;
  game.statTotalWood += pendingOffline.wood * multiplier;
  game.statTotalFlour += pendingOffline.flour * multiplier;
  game.statTotalPlank += pendingOffline.plank * multiplier;

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
    crowns: game.crowns,
    totalRebirths: game.totalRebirths,
    ownedCount: game.ownedCount,
    purchasedTilesCount: game.purchasedTilesCount,
    castleLevel: game.castleLevel,
    stats: {
      totalFood: game.statTotalFood,
      totalWood: game.statTotalWood,
      totalFlour: game.statTotalFlour,
      totalPlank: game.statTotalPlank,
      totalConquered: game.statTotalConquered,
      playtime: game.statPlaytime
    },
    tiles: Object.values(game.tiles).map(t => ({
      q: t.q, r: t.r,
      state: t.state,
      biomeId: t.biome.id,
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
    game.food = data.food || 1.0;
    game.wood = data.wood || 0.0;
    game.flour = data.flour || 0.0;
    game.plank = data.plank || 0.0;
    game.crowns = data.crowns || 0;
    game.totalRebirths = data.totalRebirths || 0;
    game.ownedCount = data.ownedCount || 1;
    game.purchasedTilesCount = data.purchasedTilesCount || 0;
    game.castleLevel = data.castleLevel || 1;

    if (data.stats) {
      game.statTotalFood = data.stats.totalFood || 0;
      game.statTotalWood = data.stats.totalWood || 0;
      game.statTotalFlour = data.stats.totalFlour || 0;
      game.statTotalPlank = data.stats.totalPlank || 0;
      game.statTotalConquered = data.stats.totalConquered || 1;
      game.statPlaytime = data.stats.playtime || 0;
    }

    // Karoları Yükle
    game.tiles = {};
    const biomeMap = [BIOMES.SEA, BIOMES.MEADOW, BIOMES.FOREST, BIOMES.MOUNTAIN];
    data.tiles.forEach(td => {
      const key = `${td.q},${td.r}`;
      game.tiles[key] = {
        q: td.q, r: td.r,
        state: td.state,
        biome: biomeMap[td.biomeId] || BIOMES.MEADOW,
        building: td.building
      };
    });

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
