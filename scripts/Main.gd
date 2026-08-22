class_name Main
extends Node2D

@onready var hex_grid: HexGrid = $HexGrid


# Üst Envanter Barı (TopBar)
@onready var food_label: Label = $UI/TopBar/MarginContainer/VBoxContainer/TopRow/FoodChip/HBox/FoodLabel
@onready var wood_label: Label = $UI/TopBar/MarginContainer/VBoxContainer/TopRow/WoodChip/HBox/WoodLabel
@onready var crown_label: Label = $UI/TopBar/MarginContainer/VBoxContainer/TopRow/CrownChip/HBox/CrownLabel
@onready var tile_count_label: Label = $UI/TopBar/MarginContainer/VBoxContainer/TopRow/TileChip/HBox/TileCountLabel
@onready var btn_toggle_drawer: Button = $UI/TopBar/MarginContainer/VBoxContainer/TopRow/DrawerButton
@onready var btn_settings: Button = $UI/TopBar/MarginContainer/VBoxContainer/TopRow/SettingsButton
@onready var drawer_row: HBoxContainer = $UI/TopBar/MarginContainer/VBoxContainer/DrawerRow
@onready var flour_label: Label = $UI/TopBar/MarginContainer/VBoxContainer/DrawerRow/FlourChip/HBox/FlourLabel
@onready var plank_label: Label = $UI/TopBar/MarginContainer/VBoxContainer/DrawerRow/PlankChip/HBox/PlankLabel
@onready var hint_label: Label = $UI/TopBar/MarginContainer/VBoxContainer/HintLabel

# Dinamik İnşaat Menüsü (Build Menu)
@onready var build_menu: PanelContainer = $UI/BuildMenu
@onready var build_menu_title: Label = $UI/BuildMenu/MarginContainer/VBoxContainer/HeaderRow/TitleLabel
@onready var btn_close_build_menu: Button = $UI/BuildMenu/MarginContainer/VBoxContainer/HeaderRow/CloseButton

@onready var corn_card: PanelContainer = $UI/BuildMenu/MarginContainer/VBoxContainer/CornCard
@onready var corn_name_label: Label = $UI/BuildMenu/MarginContainer/VBoxContainer/CornCard/HBoxContainer/InfoVBox/NameLabel
@onready var corn_desc_label: Label = $UI/BuildMenu/MarginContainer/VBoxContainer/CornCard/HBoxContainer/InfoVBox/DescLabel
@onready var corn_cost_badge: Label = $UI/BuildMenu/MarginContainer/VBoxContainer/CornCard/HBoxContainer/CostBadge
@onready var btn_build_corn: Button = $UI/BuildMenu/MarginContainer/VBoxContainer/CornCard/HBoxContainer/BuildButton

@onready var windmill_card: PanelContainer = $UI/BuildMenu/MarginContainer/VBoxContainer/WindmillCard
@onready var windmill_name_label: Label = $UI/BuildMenu/MarginContainer/VBoxContainer/WindmillCard/HBoxContainer/InfoVBox/NameLabel
@onready var windmill_desc_label: Label = $UI/BuildMenu/MarginContainer/VBoxContainer/WindmillCard/HBoxContainer/InfoVBox/DescLabel
@onready var windmill_cost_badge: Label = $UI/BuildMenu/MarginContainer/VBoxContainer/WindmillCard/HBoxContainer/CostBadge
@onready var btn_build_windmill: Button = $UI/BuildMenu/MarginContainer/VBoxContainer/WindmillCard/HBoxContainer/BuildButton

@onready var lumberjack_card: PanelContainer = $UI/BuildMenu/MarginContainer/VBoxContainer/LumberjackCard
@onready var lumberjack_name_label: Label = $UI/BuildMenu/MarginContainer/VBoxContainer/LumberjackCard/HBoxContainer/InfoVBox/NameLabel
@onready var lumberjack_desc_label: Label = $UI/BuildMenu/MarginContainer/VBoxContainer/LumberjackCard/HBoxContainer/InfoVBox/DescLabel
@onready var lumberjack_cost_badge: Label = $UI/BuildMenu/MarginContainer/VBoxContainer/LumberjackCard/HBoxContainer/CostBadge
@onready var btn_build_lumberjack: Button = $UI/BuildMenu/MarginContainer/VBoxContainer/LumberjackCard/HBoxContainer/BuildButton

@onready var sawmill_card: PanelContainer = $UI/BuildMenu/MarginContainer/VBoxContainer/SawmillCard
@onready var sawmill_name_label: Label = $UI/BuildMenu/MarginContainer/VBoxContainer/SawmillCard/HBoxContainer/InfoVBox/NameLabel
@onready var sawmill_desc_label: Label = $UI/BuildMenu/MarginContainer/VBoxContainer/SawmillCard/HBoxContainer/InfoVBox/DescLabel
@onready var sawmill_cost_badge: Label = $UI/BuildMenu/MarginContainer/VBoxContainer/SawmillCard/HBoxContainer/CostBadge
@onready var btn_build_sawmill: Button = $UI/BuildMenu/MarginContainer/VBoxContainer/SawmillCard/HBoxContainer/BuildButton

@onready var worker_card: PanelContainer = $UI/BuildMenu/MarginContainer/VBoxContainer/WorkerCard
@onready var worker_name_label: Label = $UI/BuildMenu/MarginContainer/VBoxContainer/WorkerCard/HBoxContainer/InfoVBox/NameLabel
@onready var worker_desc_label: Label = $UI/BuildMenu/MarginContainer/VBoxContainer/WorkerCard/HBoxContainer/InfoVBox/DescLabel
@onready var worker_cost_badge: Label = $UI/BuildMenu/MarginContainer/VBoxContainer/WorkerCard/HBoxContainer/CostBadge
@onready var btn_build_worker: Button = $UI/BuildMenu/MarginContainer/VBoxContainer/WorkerCard/HBoxContainer/BuildButton

# Köprü İnşaat Kartı
@onready var bridge_card: PanelContainer = $UI/BuildMenu/MarginContainer/VBoxContainer/BridgeCard
@onready var bridge_name_label: Label = $UI/BuildMenu/MarginContainer/VBoxContainer/BridgeCard/HBoxContainer/InfoVBox/NameLabel
@onready var bridge_desc_label: Label = $UI/BuildMenu/MarginContainer/VBoxContainer/BridgeCard/HBoxContainer/InfoVBox/DescLabel
@onready var bridge_cost_badge: Label = $UI/BuildMenu/MarginContainer/VBoxContainer/BridgeCard/HBoxContainer/CostBadge
@onready var btn_build_bridge: Button = $UI/BuildMenu/MarginContainer/VBoxContainer/BridgeCard/HBoxContainer/BuildButton

# Şato Krallık Yönetim Menüsü (Castle Menu)
@onready var castle_menu: PanelContainer = $UI/CastleMenu
@onready var castle_title_label: Label = $UI/CastleMenu/MarginContainer/VBoxContainer/HeaderRow/TitleLabel
@onready var btn_close_castle_menu: Button = $UI/CastleMenu/MarginContainer/VBoxContainer/HeaderRow/CloseButton
@onready var castle_bonus_label: Label = $UI/CastleMenu/MarginContainer/VBoxContainer/FlowRow/InfoVBox/BonusLabel
@onready var castle_unlock_label: Label = $UI/CastleMenu/MarginContainer/VBoxContainer/FlowRow/InfoVBox/UnlockLabel
@onready var castle_upgrade_cost_label: Label = $UI/CastleMenu/MarginContainer/VBoxContainer/FlowRow/UpgradeCastleButton/VBox/CostLabel
@onready var castle_upgrade_info_label: Label = $UI/CastleMenu/MarginContainer/VBoxContainer/FlowRow/UpgradeCastleButton/VBox/InfoLabel
@onready var btn_upgrade_castle: Button = $UI/CastleMenu/MarginContainer/VBoxContainer/FlowRow/UpgradeCastleButton

# Mısır Tarlası Üretim Menüsü
@onready var production_menu: PanelContainer = $UI/ProductionMenu
@onready var prod_title_label: Label = $UI/ProductionMenu/MarginContainer/VBoxContainer/HeaderRow/TitleLabel
@onready var btn_close_prod_menu: Button = $UI/ProductionMenu/MarginContainer/VBoxContainer/HeaderRow/CloseButton
@onready var prod_rate_label: Label = $UI/ProductionMenu/MarginContainer/VBoxContainer/FlowRow/ArrowContainer/RateLabel
@onready var corn_accum_label: Label = $UI/ProductionMenu/MarginContainer/VBoxContainer/FlowRow/CollectButton/VBox/CornLabel
@onready var food_accum_label: Label = $UI/ProductionMenu/MarginContainer/VBoxContainer/FlowRow/CollectButton/VBox/FoodLabel
@onready var btn_collect: Button = $UI/ProductionMenu/MarginContainer/VBoxContainer/FlowRow/CollectButton
@onready var btn_upgrade: Button = $UI/ProductionMenu/MarginContainer/VBoxContainer/FlowRow/UpgradeButton
@onready var upgrade_cost_label: Label = $UI/ProductionMenu/MarginContainer/VBoxContainer/FlowRow/UpgradeButton/VBox/CostLabel
@onready var upgrade_info_label: Label = $UI/ProductionMenu/MarginContainer/VBoxContainer/FlowRow/UpgradeButton/VBox/InfoLabel

# Değirmen Üretim Menüsü (Flour Menu)
@onready var flour_menu: PanelContainer = $UI/FlourMenu
@onready var flour_title_label: Label = $UI/FlourMenu/MarginContainer/VBoxContainer/HeaderRow/TitleLabel
@onready var btn_close_flour_menu: Button = $UI/FlourMenu/MarginContainer/VBoxContainer/HeaderRow/CloseButton
@onready var flour_rate_label: Label = $UI/FlourMenu/MarginContainer/VBoxContainer/FlowRow/ArrowContainer/RateLabel
@onready var flour_supply_label: Label = $UI/FlourMenu/MarginContainer/VBoxContainer/FlowRow/ArrowContainer/SupplyLabel
@onready var flour_accum_label: Label = $UI/FlourMenu/MarginContainer/VBoxContainer/FlowRow/CollectFlourButton/VBox/FlourLabel
@onready var btn_collect_flour: Button = $UI/FlourMenu/MarginContainer/VBoxContainer/FlowRow/CollectFlourButton
@onready var btn_upgrade_flour: Button = $UI/FlourMenu/MarginContainer/VBoxContainer/FlowRow/UpgradeFlourButton
@onready var flour_upgrade_cost_label: Label = $UI/FlourMenu/MarginContainer/VBoxContainer/FlowRow/UpgradeFlourButton/VBox/CostLabel
@onready var flour_upgrade_info_label: Label = $UI/FlourMenu/MarginContainer/VBoxContainer/FlowRow/UpgradeFlourButton/VBox/InfoLabel

# Oduncu Kulübesi Üretim Menüsü
@onready var wood_menu: PanelContainer = $UI/WoodMenu
@onready var wood_title_label: Label = $UI/WoodMenu/MarginContainer/VBoxContainer/HeaderRow/TitleLabel
@onready var btn_close_wood_menu: Button = $UI/WoodMenu/MarginContainer/VBoxContainer/HeaderRow/CloseButton
@onready var wood_rate_label: Label = $UI/WoodMenu/MarginContainer/VBoxContainer/FlowRow/ArrowContainer/RateLabel
@onready var wood_raw_accum_label: Label = $UI/WoodMenu/MarginContainer/VBoxContainer/FlowRow/CollectWoodButton/VBox/RawWoodLabel
@onready var wood_collect_label: Label = $UI/WoodMenu/MarginContainer/VBoxContainer/FlowRow/CollectWoodButton/VBox/WoodLabel
@onready var btn_collect_wood: Button = $UI/WoodMenu/MarginContainer/VBoxContainer/FlowRow/CollectWoodButton
@onready var btn_upgrade_wood: Button = $UI/WoodMenu/MarginContainer/VBoxContainer/FlowRow/UpgradeWoodButton
@onready var wood_upgrade_cost_label: Label = $UI/WoodMenu/MarginContainer/VBoxContainer/FlowRow/UpgradeWoodButton/VBox/CostLabel
@onready var wood_upgrade_info_label: Label = $UI/WoodMenu/MarginContainer/VBoxContainer/FlowRow/UpgradeWoodButton/VBox/InfoLabel

# Kereste Fabrikası Üretim Menüsü (Plank Menu)
@onready var plank_menu: PanelContainer = $UI/PlankMenu
@onready var plank_title_label: Label = $UI/PlankMenu/MarginContainer/VBoxContainer/HeaderRow/TitleLabel
@onready var btn_close_plank_menu: Button = $UI/PlankMenu/MarginContainer/VBoxContainer/HeaderRow/CloseButton
@onready var plank_rate_label: Label = $UI/PlankMenu/MarginContainer/VBoxContainer/FlowRow/ArrowContainer/RateLabel
@onready var plank_supply_label: Label = $UI/PlankMenu/MarginContainer/VBoxContainer/FlowRow/ArrowContainer/SupplyLabel
@onready var plank_accum_label: Label = $UI/PlankMenu/MarginContainer/VBoxContainer/FlowRow/CollectPlankButton/VBox/PlankLabel
@onready var btn_collect_plank: Button = $UI/PlankMenu/MarginContainer/VBoxContainer/FlowRow/CollectPlankButton
@onready var btn_upgrade_plank: Button = $UI/PlankMenu/MarginContainer/VBoxContainer/FlowRow/UpgradePlankButton
@onready var plank_upgrade_cost_label: Label = $UI/PlankMenu/MarginContainer/VBoxContainer/FlowRow/UpgradePlankButton/VBox/CostLabel
@onready var plank_upgrade_info_label: Label = $UI/PlankMenu/MarginContainer/VBoxContainer/FlowRow/UpgradePlankButton/VBox/InfoLabel

# İşçi Kulübesi Menüsü
@onready var worker_menu: PanelContainer = $UI/WorkerMenu
@onready var worker_title_label: Label = $UI/WorkerMenu/MarginContainer/VBoxContainer/HeaderRow/TitleLabel
@onready var btn_close_worker_menu: Button = $UI/WorkerMenu/MarginContainer/VBoxContainer/HeaderRow/CloseButton
@onready var worker_rate_label: Label = $UI/WorkerMenu/MarginContainer/VBoxContainer/FlowRow/InfoVBox/RateLabel
@onready var worker_neighbors_label: Label = $UI/WorkerMenu/MarginContainer/VBoxContainer/FlowRow/InfoVBox/NeighborsLabel
@onready var worker_upgrade_cost_label: Label = $UI/WorkerMenu/MarginContainer/VBoxContainer/FlowRow/UpgradeWorkerButton/VBox/CostLabel
@onready var worker_upgrade_info_label: Label = $UI/WorkerMenu/MarginContainer/VBoxContainer/FlowRow/UpgradeWorkerButton/VBox/InfoLabel
@onready var btn_upgrade_worker: Button = $UI/WorkerMenu/MarginContainer/VBoxContainer/FlowRow/UpgradeWorkerButton

# Toast Bildirim Paneli
@onready var toast_panel: PanelContainer = $UI/ToastNotification
@onready var toast_label: Label = $UI/ToastNotification/MarginContainer/ToastLabel

# Ayarlar & İstatistikler & Prestij Modalı
@onready var settings_modal: PanelContainer = $UI/SettingsModal
@onready var settings_title_label: Label = $UI/SettingsModal/MarginContainer/VBoxContainer/HeaderRow/SettingsTitleLabel
@onready var btn_close_settings: Button = $UI/SettingsModal/MarginContainer/VBoxContainer/HeaderRow/BtnCloseSettings
@onready var btn_tab_general: Button = $UI/SettingsModal/MarginContainer/VBoxContainer/TabButtonsRow/BtnTabGeneral
@onready var btn_tab_stats: Button = $UI/SettingsModal/MarginContainer/VBoxContainer/TabButtonsRow/BtnTabStats
@onready var btn_tab_prestige: Button = $UI/SettingsModal/MarginContainer/VBoxContainer/TabButtonsRow/BtnTabPrestige

@onready var tab_general: VBoxContainer = $UI/SettingsModal/MarginContainer/VBoxContainer/TabGeneral
@onready var lang_label: Label = $UI/SettingsModal/MarginContainer/VBoxContainer/TabGeneral/LangLabel
@onready var btn_lang_tr: Button = $UI/SettingsModal/MarginContainer/VBoxContainer/TabGeneral/LangRow/BtnLangTR
@onready var btn_lang_en: Button = $UI/SettingsModal/MarginContainer/VBoxContainer/TabGeneral/LangRow/BtnLangEN
@onready var btn_lang_es: Button = $UI/SettingsModal/MarginContainer/VBoxContainer/TabGeneral/LangRow/BtnLangES
@onready var btn_lang_de: Button = $UI/SettingsModal/MarginContainer/VBoxContainer/TabGeneral/LangRow/BtnLangDE
@onready var audio_label: Label = $UI/SettingsModal/MarginContainer/VBoxContainer/TabGeneral/AudioLabel
@onready var volume_slider: HSlider = $UI/SettingsModal/MarginContainer/VBoxContainer/TabGeneral/AudioRow/VolumeSlider
@onready var btn_mute: Button = $UI/SettingsModal/MarginContainer/VBoxContainer/TabGeneral/AudioRow/BtnMute

@onready var tab_stats: VBoxContainer = $UI/SettingsModal/MarginContainer/VBoxContainer/TabStats
@onready var stat_playtime_label: Label = $UI/SettingsModal/MarginContainer/VBoxContainer/TabStats/StatPlaytime
@onready var stat_lands_label: Label = $UI/SettingsModal/MarginContainer/VBoxContainer/TabStats/StatLands
@onready var stat_food_label: Label = $UI/SettingsModal/MarginContainer/VBoxContainer/TabStats/StatFood
@onready var stat_wood_label: Label = $UI/SettingsModal/MarginContainer/VBoxContainer/TabStats/StatWood
@onready var stat_flour_label: Label = $UI/SettingsModal/MarginContainer/VBoxContainer/TabStats/StatFlour
@onready var stat_plank_label: Label = $UI/SettingsModal/MarginContainer/VBoxContainer/TabStats/StatPlank
@onready var stat_rebirths_label: Label = $UI/SettingsModal/MarginContainer/VBoxContainer/TabStats/StatRebirths

@onready var tab_prestige: VBoxContainer = $UI/SettingsModal/MarginContainer/VBoxContainer/TabPrestige
@onready var prestige_desc_label: Label = $UI/SettingsModal/MarginContainer/VBoxContainer/TabPrestige/PrestigeDesc
@onready var current_crowns_label: Label = $UI/SettingsModal/MarginContainer/VBoxContainer/TabPrestige/CurrentCrownsLabel
@onready var earned_crowns_label: Label = $UI/SettingsModal/MarginContainer/VBoxContainer/TabPrestige/EarnedCrownsLabel
@onready var btn_do_prestige: Button = $UI/SettingsModal/MarginContainer/VBoxContainer/TabPrestige/BtnDoPrestige

# Prestij Onay Modalı
@onready var prestige_confirm_modal: PanelContainer = $UI/PrestigeConfirmModal
@onready var prestige_confirm_title: Label = $UI/PrestigeConfirmModal/MarginContainer/VBoxContainer/Title
@onready var prestige_confirm_desc: Label = $UI/PrestigeConfirmModal/MarginContainer/VBoxContainer/Desc
@onready var btn_confirm_prestige: Button = $UI/PrestigeConfirmModal/MarginContainer/VBoxContainer/ButtonRow/BtnConfirmPrestige
@onready var btn_cancel_prestige: Button = $UI/PrestigeConfirmModal/MarginContainer/VBoxContainer/ButtonRow/BtnCancelPrestige

# Çevrimdışı Gelir Modalı
@onready var offline_modal: PanelContainer = $UI/OfflineGainsModal
@onready var offline_title_label: Label = $UI/OfflineGainsModal/MarginContainer/VBoxContainer/OfflineTitle
@onready var offline_desc_label: Label = $UI/OfflineGainsModal/MarginContainer/VBoxContainer/OfflineDesc
@onready var gain_food_label: Label = $UI/OfflineGainsModal/MarginContainer/VBoxContainer/GainsGrid/GainFood
@onready var gain_wood_label: Label = $UI/OfflineGainsModal/MarginContainer/VBoxContainer/GainsGrid/GainWood
@onready var gain_flour_label: Label = $UI/OfflineGainsModal/MarginContainer/VBoxContainer/GainsGrid/GainFlour
@onready var gain_plank_label: Label = $UI/OfflineGainsModal/MarginContainer/VBoxContainer/GainsGrid/GainPlank
@onready var btn_claim_all: Button = $UI/OfflineGainsModal/MarginContainer/VBoxContainer/ButtonRow/BtnClaimAll
@onready var btn_claim_3x: Button = $UI/OfflineGainsModal/MarginContainer/VBoxContainer/ButtonRow/BtnClaim3x

# Sahne Ön Yüklemeleri
@export var corn_field_scene: PackedScene = preload("res://scenes/CornField.tscn")
@export var windmill_scene: PackedScene = preload("res://scenes/Windmill.tscn")
@export var lumberjack_hut_scene: PackedScene = preload("res://scenes/LumberjackHut.tscn")
@export var sawmill_scene: PackedScene = preload("res://scenes/Sawmill.tscn")
@export var worker_hut_scene: PackedScene = preload("res://scenes/WorkerHut.tscn")
@export var castle_scene: PackedScene = preload("res://scenes/Castle.tscn")
@export var bridge_scene: PackedScene = preload("res://scenes/Bridge.tscn")

# 10 Kademeli Şato Yükseltme Tablosu
const CASTLE_UPGRADES = {
	1: {"cost_food": 6,   "cost_wood": 0,   "next_title": "🛡️ Derebeylik (Sv. 2)", "unlock": "🪓 Odunculuk & Orman Yapıları Kilidi Açılır!"},
	2: {"cost_food": 18,  "cost_wood": 10,  "next_title": "🏰 Kontluk (Sv. 3)",    "unlock": "🌾 Değirmen & 🪵 Kereste Fabrikası Kilidi Açılır!"},
	3: {"cost_food": 35,  "cost_wood": 25,  "next_title": "⚔️ Düklük (Sv. 4)",     "unlock": "🪙 Pazar Yeri & Ticaret Kilidi (+%75 Hız)"},
	4: {"cost_food": 65,  "cost_wood": 45,  "next_title": "👑 Büyük Düklük (Sv. 5)", "unlock": "✨ 2x Kat Küresel Üretim & Taşıma Hızı"},
	5: {"cost_food": 110, "cost_wood": 80,  "next_title": "🦅 Prens Emareti (Sv. 6)", "unlock": "🦅 Kraliyet Lojistik Ağı (+%125 Hız)"},
	6: {"cost_food": 180, "cost_wood": 130, "next_title": "⚜️ Krallık (Sv. 7)",    "unlock": "⚜️ Krallık Vergi Dairesi (+%150 Hız)"},
	7: {"cost_food": 290, "cost_wood": 210, "next_title": "🦁 Büyük Krallık (Sv. 8)", "unlock": "🦁 Başkent Koruması (+%175 Hız)"},
	8: {"cost_food": 450, "cost_wood": 330, "next_title": "🌟 Baş İmparatorluk (Sv. 9)", "unlock": "🌟 3x Kat Küresel Üretim & Taşıma Hızı"},
	9: {"cost_food": 700, "cost_wood": 500, "next_title": "⚡ Efsanevi Hükümdarlık (Sv. 10)", "unlock": "⚡ Efsanevi Hükümdar Zirvesi (+%225 Hız)"}
}

# Ses Sentetizörü
var sound_manager: SoundManager

# Oyun Durumu (Game State)
var food: float = 1.0
var wood: float = 0.0
var flour: float = 0.0
var plank: float = 0.0

var crowns: int = 0
var total_rebirths: int = 0
var owned_count: int = 1
var purchased_tiles_count: int = 0
var corn_fields_count: int = 0
var windmills_count: int = 0
var lumberjack_huts_count: int = 0
var sawmills_count: int = 0
var worker_huts_count: int = 0

var castle_level: int = 1
var center_castle: Node2D = null

# Kariyer İstatistikleri
var stat_total_food: float = 0.0
var stat_total_wood: float = 0.0
var stat_total_flour: float = 0.0
var stat_total_plank: float = 0.0
var stat_total_conquered: int = 1
var stat_playtime: float = 0.0

# Çevrimdışı Gelir Geçici Değişkenleri
var _pending_offline_gains = {"food": 0.0, "wood": 0.0, "flour": 0.0, "plank": 0.0}

var selected_tile: HexTile = null
var active_corn_field: Node2D = null
var active_windmill: Node2D = null
var active_lumberjack_hut: Node2D = null
var active_sawmill: Node2D = null
var active_worker_hut: Node2D = null

var worker_huts: Array[Node2D] = []
var windmills: Array[Node2D] = []
var sawmills: Array[Node2D] = []

var _drawer_open: bool = false
var _toast_tween: Tween = null
var _menu_tween: Tween = null
var _auto_save_timer: float = 0.0

func _ready() -> void:
	# Ses Yöneticisini Başlat
	sound_manager = SoundManager.new()
	add_child(sound_manager)
	
	# Sinyal Bağlantıları
	hex_grid.tile_clicked_discovered.connect(_on_tile_clicked_discovered)
	hex_grid.tile_clicked_owned.connect(_on_tile_clicked_owned)
	
	btn_toggle_drawer.pressed.connect(_toggle_inventory_drawer)
	btn_settings.pressed.connect(open_settings_modal)
	
	# İnşaat menüsü butonları
	btn_build_corn.pressed.connect(_on_build_corn_pressed)
	btn_build_windmill.pressed.connect(_on_build_windmill_pressed)
	btn_build_lumberjack.pressed.connect(_on_build_lumberjack_pressed)
	btn_build_sawmill.pressed.connect(_on_build_sawmill_pressed)
	btn_build_worker.pressed.connect(_on_build_worker_pressed)
	btn_build_bridge.pressed.connect(_on_build_bridge_pressed)
	btn_close_build_menu.pressed.connect(close_build_menu)
	
	# Şato menüsü butonları
	btn_close_castle_menu.pressed.connect(close_castle_menu)
	btn_upgrade_castle.pressed.connect(_on_upgrade_castle_pressed)
	
	# Mısır üretim menüsü butonları
	btn_close_prod_menu.pressed.connect(close_production_menu)
	btn_collect.pressed.connect(_on_collect_pressed)
	btn_upgrade.pressed.connect(_on_upgrade_pressed)
	
	# Değirmen üretim menüsü butonları
	btn_close_flour_menu.pressed.connect(close_flour_menu)
	btn_collect_flour.pressed.connect(_on_collect_flour_pressed)
	btn_upgrade_flour.pressed.connect(_on_upgrade_flour_pressed)
	
	# Odun üretim menüsü butonları
	btn_close_wood_menu.pressed.connect(close_wood_menu)
	btn_collect_wood.pressed.connect(_on_collect_wood_pressed)
	btn_upgrade_wood.pressed.connect(_on_upgrade_wood_pressed)
	
	# Kereste fabrikası üretim menüsü butonları
	btn_close_plank_menu.pressed.connect(close_plank_menu)
	btn_collect_plank.pressed.connect(_on_collect_plank_pressed)
	btn_upgrade_plank.pressed.connect(_on_upgrade_plank_pressed)
	
	# İşçi kulübesi menüsü butonları
	btn_close_worker_menu.pressed.connect(close_worker_menu)
	btn_upgrade_worker.pressed.connect(_on_upgrade_worker_pressed)
	
	# Ayarlar & Prestij Modalı Butonları
	btn_close_settings.pressed.connect(close_settings_modal)
	btn_tab_general.pressed.connect(func(): _switch_settings_tab(0))
	btn_tab_stats.pressed.connect(func(): _switch_settings_tab(1))
	btn_tab_prestige.pressed.connect(func(): _switch_settings_tab(2))
	
	btn_lang_tr.pressed.connect(func(): _change_language("tr"))
	btn_lang_en.pressed.connect(func(): _change_language("en"))
	btn_lang_es.pressed.connect(func(): _change_language("es"))
	btn_lang_de.pressed.connect(func(): _change_language("de"))
	
	volume_slider.value_changed.connect(_on_volume_changed)
	btn_mute.pressed.connect(_on_mute_toggle)
	
	btn_do_prestige.pressed.connect(_on_prestige_button_pressed)
	btn_confirm_prestige.pressed.connect(_execute_prestige)
	btn_cancel_prestige.pressed.connect(func(): prestige_confirm_modal.visible = false)
	
	# Çevrimdışı Gelir Butonları
	btn_claim_all.pressed.connect(_claim_offline_normal)
	btn_claim_3x.pressed.connect(_claim_offline_3x)
	
	# Başlangıçta panelleri gizle
	close_all_menus()
	settings_modal.visible = false
	prestige_confirm_modal.visible = false
	offline_modal.visible = false
	toast_panel.modulate.a = 0.0
	toast_panel.visible = false
	drawer_row.visible = false
	
	# Kayıtlı oyun kontrolü
	_initialize_game_state()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_APPLICATION_PAUSED:
		SaveManager.save_game(self)

func _unhandled_input(event: InputEvent) -> void:
	if settings_modal.visible or prestige_confirm_modal.visible or offline_modal.visible:
		return
		
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var mouse_world = get_global_mouse_position()
		var coord = HexMath.pixel_to_hex(mouse_world.x, mouse_world.y, hex_grid.hex_size, hex_grid.y_scale)
		if hex_grid.tiles.has(coord):
			var tile: HexTile = hex_grid.tiles[coord]
			if tile.state == HexTile.TileState.DISCOVERED:
				_on_tile_clicked_discovered(coord, tile)
			elif tile.state == HexTile.TileState.OWNED:
				_on_tile_clicked_owned(coord, tile)


## Kayıtlı veriyi yükler veya sıfırdan harita başlatır
func _initialize_game_state() -> void:
	var loaded = false
	if SaveManager.has_save():
		var save_data = SaveManager.load_saved_data()
		if save_data.size() > 0 and save_data.has("tiles") and save_data["tiles"].size() > 0:
			_load_from_dict(save_data)
			if hex_grid.tiles.size() > 0 and hex_grid.tiles.has(Vector2i.ZERO):
				loaded = true
				var offline = SaveManager.calculate_offline_gains(save_data)
				if offline["seconds"] > 15 and (offline["food"] > 0.01 or offline["wood"] > 0.01 or offline["flour"] > 0.01 or offline["plank"] > 0.01):
					_show_offline_modal(offline)
					
	if not loaded:
		# Sıfırdan Yeni Oyun
		hex_grid.initialize_map()
		if hex_grid.tiles.has(Vector2i.ZERO):
			var ct: HexTile = hex_grid.tiles[Vector2i.ZERO]
			if ct.has_building():
				center_castle = ct.building
				
	update_ui()


## Kayıt sözlüğünden verileri aktarır
func _load_from_dict(d: Dictionary) -> void:
	if d.has("resources"):
		var r = d["resources"]
		food = float(r.get("food", 1.0))
		wood = float(r.get("wood", 0.0))
		flour = float(r.get("flour", 0.0))
		plank = float(r.get("plank", 0.0))
		
	if d.has("progression"):
		var p = d["progression"]
		owned_count = int(p.get("owned_count", 1))
		purchased_tiles_count = int(p.get("purchased_tiles_count", 0))
		castle_level = int(p.get("castle_level", 1))
		
	if d.has("prestige"):
		var pr = d["prestige"]
		crowns = int(pr.get("crowns", 0))
		total_rebirths = int(pr.get("total_rebirths", 0))
		
	if d.has("stats"):
		var st = d["stats"]
		stat_total_food = float(st.get("total_food_produced", 0.0))
		stat_total_wood = float(st.get("total_wood_produced", 0.0))
		stat_total_flour = float(st.get("total_flour_produced", 0.0))
		stat_total_plank = float(st.get("total_plank_produced", 0.0))
		stat_total_conquered = int(st.get("total_tiles_conquered", 1))
		stat_playtime = float(st.get("playtime_seconds", 0.0))
		
	if d.has("settings"):
		var s = d["settings"]
		Localization.set_language(s.get("language", "tr"))
		sound_manager.set_volume(float(s.get("sfx_volume", 0.8)))
		sound_manager.set_muted(bool(s.get("sfx_muted", false)))
		volume_slider.value = sound_manager.sfx_volume
		btn_mute.text = "🔇 Kapalı" if sound_manager.is_muted else "🔊 Açık"
		
	var scenes_dict = {
		"castle": castle_scene,
		"corn": corn_field_scene,
		"windmill": windmill_scene,
		"lumberjack": lumberjack_hut_scene,
		"sawmill": sawmill_scene,
		"worker": worker_hut_scene
	}
	
	if d.has("tiles"):
		var refs = hex_grid.load_from_saved_tiles(d["tiles"], scenes_dict)
		center_castle = refs["castle"]
		windmills.clear()
		for wm in refs["windmills"]:
			windmills.append(wm)
		sawmills.clear()
		for sm in refs["sawmills"]:
			sawmills.append(sm)
		worker_huts.clear()
		for wh in refs["worker_huts"]:
			worker_huts.append(wh)
		corn_fields_count = refs["corn_fields"].size()
		windmills_count = windmills.size()
		sawmills_count = sawmills.size()
		worker_huts_count = worker_huts.size()

# =============================================================================
# ÇARPANLAR & MATEMATİK
# =============================================================================

func get_castle_multiplier() -> float:
	return 1.0 + float(castle_level - 1) * 0.25

func get_prestige_multiplier() -> float:
	return 1.0 + float(crowns) * 0.05

func get_global_multiplier() -> float:
	return get_castle_multiplier() * get_prestige_multiplier()

func get_career_total_resources() -> float:
	return stat_total_food + stat_total_wood + stat_total_flour + stat_total_plank

func calculate_earned_crowns() -> int:
	var total_res = get_career_total_resources()
	var base_crowns = int(floor(sqrt(total_res / 1000.0)))
	return base_crowns * castle_level

# =============================================================================
# ANA DÖNGÜ (PROCESS)
# =============================================================================

func _process(delta: float) -> void:
	stat_playtime += delta
	_auto_save_timer += delta
	if _auto_save_timer >= 60.0:
		_auto_save_timer = 0.0
		SaveManager.save_game(self)
		
	# 1. Tier 2 Fabrikalarının Üretimi
	_process_tier2_factories(delta)

	# 2. İşçi Kulübelerinin Taşıması
	_process_worker_auto_gather(delta)

	# 3. Açık olan menülerin canlı bilgi güncellemesi
	if production_menu.visible and active_corn_field and is_instance_valid(active_corn_field):
		_update_production_menu_live()
	elif flour_menu.visible and active_windmill and is_instance_valid(active_windmill):
		_update_flour_menu_live()
	elif wood_menu.visible and active_lumberjack_hut and is_instance_valid(active_lumberjack_hut):
		_update_wood_menu_live()
	elif plank_menu.visible and active_sawmill and is_instance_valid(active_sawmill):
		_update_plank_menu_live()
	elif worker_menu.visible and active_worker_hut and is_instance_valid(active_worker_hut):
		_update_worker_menu_live()
	elif castle_menu.visible:
		_update_castle_menu_live()
	elif settings_modal.visible and tab_stats.visible:
		_update_stats_tab_live()
	elif settings_modal.visible and tab_prestige.visible:
		_update_prestige_tab_live()

## Tier 2 Fabrikalarının Hibrit Uzamsal Üretim Döngüsü (Değirmen & Kereste Fabrikası)
func _process_tier2_factories(delta: float) -> void:
	var global_mult = get_global_multiplier()
	
	# Değirmenler (Gıda ➔ Un)
	for mill in windmills:
		if not is_instance_valid(mill) or mill.is_full():
			continue
			
		var coord = mill.get("grid_coord")
		var rate = mill.get("base_rate") * global_mult
		var max_cap = mill.get("max_capacity")
		
		var neighbor_farms: Array[Node2D] = []
		if coord != null:
			var neighbors = hex_grid.get_neighbor_buildings(coord)
			for n in neighbors:
				if is_instance_valid(n) and "accumulated_food" in n and n.accumulated_food > 0.001:
					neighbor_farms.append(n)
					
		if neighbor_farms.size() > 0:
			mill.is_adjacent_to_farm = true
			var needed = rate * delta
			var take_per_farm = needed / float(neighbor_farms.size())
			var actually_got = 0.0
			for farm in neighbor_farms:
				var available = farm.accumulated_food
				var take = min(available, take_per_farm)
				farm.accumulated_food -= take
				actually_got += take
			mill.accumulated_flour = min(max_cap, mill.accumulated_flour + actually_got)
			stat_total_flour += actually_got
		else:
			mill.is_adjacent_to_farm = false
			var needed = (rate * 0.5) * delta
			if food >= needed:
				food -= needed
				mill.accumulated_flour = min(max_cap, mill.accumulated_flour + needed)
				stat_total_flour += needed
				update_ui()
				
	# Kereste Fabrikaları (Odun ➔ Kereste/Kalas)
	for saw in sawmills:
		if not is_instance_valid(saw) or saw.is_full():
			continue
			
		var coord = saw.get("grid_coord")
		var rate = saw.get("base_rate") * global_mult
		var max_cap = saw.get("max_capacity")
		
		var neighbor_huts: Array[Node2D] = []
		if coord != null:
			var neighbors = hex_grid.get_neighbor_buildings(coord)
			for n in neighbors:
				if is_instance_valid(n) and "accumulated_wood" in n and n.accumulated_wood > 0.001:
					neighbor_huts.append(n)
					
		if neighbor_huts.size() > 0:
			saw.is_adjacent_to_lumberjack = true
			var needed = rate * delta
			var take_per_hut = needed / float(neighbor_huts.size())
			var actually_got = 0.0
			for hut in neighbor_huts:
				var available = hut.accumulated_wood
				var take = min(available, take_per_hut)
				hut.accumulated_wood -= take
				actually_got += take
			saw.accumulated_plank = min(max_cap, saw.accumulated_plank + actually_got)
			stat_total_plank += actually_got
		else:
			saw.is_adjacent_to_lumberjack = false
			var needed = (rate * 0.5) * delta
			if wood >= needed:
				wood -= needed
				saw.accumulated_plank = min(max_cap, saw.accumulated_plank + needed)
				stat_total_plank += needed
				update_ui()

## İşçi kulübelerinin tüm kaynakları otomatik toplama mekaniği
func _process_worker_auto_gather(delta: float) -> void:
	var global_mult = get_global_multiplier()
	for hut in worker_huts:
		if not is_instance_valid(hut):
			continue
		
		var coord = hut.get("grid_coord")
		if coord == null:
			continue
			
		var neighbors = hex_grid.get_neighbor_buildings(coord)
		var valid_targets: Array[Node2D] = []
		for n in neighbors:
			if not is_instance_valid(n):
				continue
			if ("accumulated_food" in n and n.accumulated_food > 0.001) or \
			   ("accumulated_wood" in n and n.accumulated_wood > 0.001) or \
			   ("accumulated_flour" in n and n.accumulated_flour > 0.001) or \
			   ("accumulated_plank" in n and n.accumulated_plank > 0.001):
				valid_targets.append(n)
				
		if valid_targets.size() > 0:
			var max_transfer = hut.get("carry_rate") * global_mult * delta
			var transfer_per_target = max_transfer / float(valid_targets.size())
			
			for target in valid_targets:
				if "accumulated_food" in target:
					var available = target.accumulated_food
					var actual_take = min(available, transfer_per_target)
					target.accumulated_food -= actual_take
					food += actual_take
					stat_total_food += actual_take
					if "total_gathered" in hut: hut.total_gathered += actual_take
				elif "accumulated_wood" in target:
					var available = target.accumulated_wood
					var actual_take = min(available, transfer_per_target)
					target.accumulated_wood -= actual_take
					wood += actual_take
					stat_total_wood += actual_take
					if "total_gathered" in hut: hut.total_gathered += actual_take
				elif "accumulated_flour" in target:
					var available = target.accumulated_flour
					var actual_take = min(available, transfer_per_target)
					target.accumulated_flour -= actual_take
					flour += actual_take
					if "total_gathered" in hut: hut.total_gathered += actual_take
				elif "accumulated_plank" in target:
					var available = target.accumulated_plank
					var actual_take = min(available, transfer_per_target)
					target.accumulated_plank -= actual_take
					plank += actual_take
					if "total_gathered" in hut: hut.total_gathered += actual_take
			
			update_ui()

## UI metinlerini ve envanter durumunu günceller
func update_ui() -> void:
	if food_label:
		food_label.text = "%s: %d" % [Localization.tr_t("food"), int(food)] if food == floor(food) else "%s: %.1f" % [Localization.tr_t("food"), food]
	if wood_label:
		wood_label.text = "%s: %d" % [Localization.tr_t("wood"), int(wood)] if wood == floor(wood) else "%s: %.1f" % [Localization.tr_t("wood"), wood]
	if flour_label:
		flour_label.text = "%s: %d" % [Localization.tr_t("flour"), int(flour)] if flour == floor(flour) else "%s: %.1f" % [Localization.tr_t("flour"), flour]
	if plank_label:
		plank_label.text = "%s: %d" % [Localization.tr_t("plank"), int(plank)] if plank == floor(plank) else "%s: %.1f" % [Localization.tr_t("plank"), plank]
	if crown_label:
		crown_label.text = "%d" % crowns
	if tile_count_label:
		tile_count_label.text = "%d" % owned_count
		
	if hint_label:
		if castle_level == 1:
			hint_label.text = Localization.tr_t("hint_castle_1")
		elif castle_level == 2:
			hint_label.text = Localization.tr_t("hint_castle_2")
		elif food < 1.0:
			hint_label.text = Localization.tr_t("hint_no_food")
		else:
			hint_label.text = Localization.tr_t("hint_expand")

func _toggle_inventory_drawer() -> void:
	sound_manager.play_click()
	_drawer_open = !_drawer_open
	if drawer_row:
		drawer_row.visible = _drawer_open
	if btn_toggle_drawer:
		btn_toggle_drawer.text = "▲" if _drawer_open else "▼"

# =============================================================================
# ETKİLEŞİM & ARSA TIKLAMA
# =============================================================================

func get_land_expansion_cost() -> int:
	if purchased_tiles_count == 0:
		return 0
	return int(max(1.0, floor(1.0 * pow(1.18, float(purchased_tiles_count - 1)))))

func _on_tile_clicked_discovered(coord: Vector2i, tile: HexTile) -> void:
	close_all_menus()
	
	# Deniz ve Köprü Geçiş Kontrolü:
	# Karoya doğrudan bir kara arsasından veya köprü inşa edilmiş bir deniz arsasından ulaşılmalıdır.
	var neighbors = HexMath.get_neighbors(coord)
	var has_valid_access = false
	var blocked_by_unbridged_sea = false
	
	for n_coord in neighbors:
		if hex_grid.tiles.has(n_coord):
			var n_tile: HexTile = hex_grid.tiles[n_coord]
			if n_tile.state == HexTile.TileState.OWNED:
				if n_tile.tile_type != HexTile.TileType.SEA:
					# Normal bir kara karosuna (Çayır, Orman, Dağ) bağlı -> Geçiş serbest
					has_valid_access = true
					break
				else:
					# Bir deniz karosuna bağlı -> Üzerinde köprü var mı?
					if n_tile.has_building() and (n_tile.building is Bridge or "bridge" in n_tile.building.name.to_lower()):
						has_valid_access = true
						break
					else:
						blocked_by_unbridged_sea = true
						
	if not has_valid_access:
		sound_manager.play_error()
		if blocked_by_unbridged_sea:
			show_toast(Localization.tr_t("toast_need_bridge"), true)
		else:
			show_toast(Localization.tr_t("toast_adjacent_required"), true)
		return
		
	var cost: int = get_land_expansion_cost()
	
	if food >= cost:
		food -= cost
		purchased_tiles_count += 1
		owned_count += 1
		stat_total_conquered += 1
		
		sound_manager.play_tile_unlock()
		hex_grid.unlock_tile(tile)
		update_ui()
		SaveManager.save_game(self)
		
		if tile.tile_type == HexTile.TileType.MOUNTAIN:
			show_toast(Localization.tr_t("toast_mountain_conquered"))
		elif cost == 0:
			show_toast(Localization.tr_t("toast_free_tile"))
		else:
			show_toast(Localization.tr_t("toast_buy_tile", [cost]))
	else:
		sound_manager.play_error()
		show_toast(Localization.tr_t("toast_no_food_tile", [cost]), true)

func _on_tile_clicked_owned(_coord: Vector2i, tile: HexTile) -> void:
	if not tile.has_building():
		if tile.tile_type == HexTile.TileType.MEADOW:
			close_all_menus()
			selected_tile = tile
			open_build_menu()
		elif tile.tile_type == HexTile.TileType.FOREST:
			if castle_level < 2:
				sound_manager.play_error()
				show_toast(Localization.tr_t("toast_forest_locked"), true)
			else:
				close_all_menus()
				selected_tile = tile
				open_build_menu()
		elif tile.tile_type == HexTile.TileType.SEA:
			# Deniz karosuna köprü inşa edebilmek için en az 1 komşu kara karosu olmalı
			var neighbors = HexMath.get_neighbors(tile.grid_coord)
			var has_adjacent_land = false
			for n_coord in neighbors:
				if hex_grid.tiles.has(n_coord):
					var n_tile: HexTile = hex_grid.tiles[n_coord]
					if n_tile.tile_type != HexTile.TileType.SEA:
						has_adjacent_land = true
						break
			if has_adjacent_land:
				close_all_menus()
				selected_tile = tile
				open_build_menu()
			else:
				sound_manager.play_error()
				show_toast(Localization.tr_t("toast_bridge_need_land"), true)
		elif tile.tile_type == HexTile.TileType.MOUNTAIN:
			show_toast(Localization.tr_t("toast_mountain_info"))
		else:
			show_toast(Localization.tr_t("toast_no_build_biome"))
	else:
		var b = tile.building
		if b and ("accumulated_food" in b):
			close_all_menus()
			selected_tile = tile
			active_corn_field = b
			open_production_menu()
		elif b and ("accumulated_flour" in b):
			close_all_menus()
			selected_tile = tile
			active_windmill = b
			open_flour_menu()
		elif b and ("accumulated_wood" in b):
			close_all_menus()
			selected_tile = tile
			active_lumberjack_hut = b
			open_wood_menu()
		elif b and ("accumulated_plank" in b):
			close_all_menus()
			selected_tile = tile
			active_sawmill = b
			open_plank_menu()
		elif b and ("carry_rate" in b):
			close_all_menus()
			selected_tile = tile
			active_worker_hut = b
			open_worker_menu()
		else:
			close_all_menus()
			selected_tile = tile
			center_castle = b
			open_castle_menu()

func close_all_menus_instant(except_menu: PanelContainer = null) -> void:
	if _menu_tween and _menu_tween.is_running():
		_menu_tween.kill()
	var all_panels = [build_menu, castle_menu, production_menu, flour_menu, wood_menu, plank_menu, worker_menu, settings_modal, prestige_confirm_modal]
	for m in all_panels:
		if m and is_instance_valid(m) and m != except_menu:
			m.visible = false
			m.modulate.a = 1.0

func close_all_menus() -> void:
	close_all_menus_instant(null)
	selected_tile = null
	active_corn_field = null
	active_windmill = null
	active_lumberjack_hut = null
	active_sawmill = null
	active_worker_hut = null

# =============================================================================
# DİNAMİK İNŞAAT MENÜSÜ
# =============================================================================

func open_build_menu() -> void:
	if not selected_tile or not is_instance_valid(selected_tile):
		return
		
	sound_manager.play_click()
	close_all_menus_instant(build_menu)
		
	var is_meadow = (selected_tile.tile_type == HexTile.TileType.MEADOW)
	var is_forest = (selected_tile.tile_type == HexTile.TileType.FOREST)
	
	if is_meadow:
		build_menu_title.text = Localization.tr_t("build_title_meadow")
		corn_card.visible = true
		windmill_card.visible = true
		lumberjack_card.visible = false
		sawmill_card.visible = false
		bridge_card.visible = false
		worker_card.visible = true
		
		corn_name_label.text = Localization.tr_t("corn_name")
		corn_desc_label.text = Localization.tr_t("corn_desc")
		btn_build_corn.text = Localization.tr_t("build_btn")
		
		windmill_name_label.text = Localization.tr_t("windmill_name")
		windmill_desc_label.text = Localization.tr_t("windmill_desc")
		btn_build_windmill.text = Localization.tr_t("build_btn")
		
		if castle_level < 3:
			windmill_cost_badge.text = Localization.tr_t("locked_castle_3")
			windmill_cost_badge.add_theme_color_override("font_color", Color(1.0, 0.45, 0.45))
			btn_build_windmill.disabled = true
		else:
			windmill_cost_badge.text = "5 🥡 + 3 🪵"
			var can_afford_wm = (food >= 5 and wood >= 3)
			windmill_cost_badge.add_theme_color_override("font_color", Color(0.4, 0.95, 0.45) if can_afford_wm else Color(1.0, 0.45, 0.45))
			btn_build_windmill.disabled = false
	elif is_forest:
		build_menu_title.text = Localization.tr_t("build_title_forest")
		corn_card.visible = false
		windmill_card.visible = false
		lumberjack_card.visible = true
		sawmill_card.visible = true
		bridge_card.visible = false
		worker_card.visible = true
		
		lumberjack_name_label.text = Localization.tr_t("lumberjack_name")
		lumberjack_desc_label.text = Localization.tr_t("lumberjack_desc")
		btn_build_lumberjack.text = Localization.tr_t("build_btn")
		
		sawmill_name_label.text = Localization.tr_t("sawmill_name")
		sawmill_desc_label.text = Localization.tr_t("sawmill_desc")
		btn_build_sawmill.text = Localization.tr_t("build_btn")
		
		if castle_level < 3:
			sawmill_cost_badge.text = Localization.tr_t("locked_castle_3")
			sawmill_cost_badge.add_theme_color_override("font_color", Color(1.0, 0.45, 0.45))
			btn_build_sawmill.disabled = true
		else:
			sawmill_cost_badge.text = "4 🥡 + 5 🪵"
			var can_afford_sm = (food >= 4 and wood >= 5)
			sawmill_cost_badge.add_theme_color_override("font_color", Color(0.4, 0.95, 0.45) if can_afford_sm else Color(1.0, 0.45, 0.45))
			btn_build_sawmill.disabled = false
	elif selected_tile.tile_type == HexTile.TileType.SEA:
		build_menu_title.text = Localization.tr_t("build_title_sea")
		corn_card.visible = false
		windmill_card.visible = false
		lumberjack_card.visible = false
		sawmill_card.visible = false
		worker_card.visible = false
		bridge_card.visible = true
		
		bridge_name_label.text = Localization.tr_t("bridge_name")
		bridge_desc_label.text = Localization.tr_t("bridge_desc")
		btn_build_bridge.text = Localization.tr_t("build_btn")
		bridge_cost_badge.text = "4 🪵"
		var can_afford_bridge = (wood >= 4)
		bridge_cost_badge.add_theme_color_override("font_color", Color(0.4, 0.95, 0.45) if can_afford_bridge else Color(1.0, 0.45, 0.45))
		btn_build_bridge.disabled = false
	else:
		return
		
	if worker_card.visible:
		worker_name_label.text = Localization.tr_t("worker_name")
		worker_desc_label.text = Localization.tr_t("worker_desc")
		btn_build_worker.text = Localization.tr_t("build_btn")
	
	var corn_cost = 0 if corn_fields_count == 0 else 2
	var wood_cost = 2 if lumberjack_huts_count == 0 else 2 + (lumberjack_huts_count * 2)
	var worker_cost = 0 if worker_huts_count == 0 else 3
	
	if corn_cost_badge:
		corn_cost_badge.text = Localization.tr_t("free") if corn_cost == 0 else "%d 🥡" % corn_cost
		corn_cost_badge.add_theme_color_override("font_color", Color(1.0, 0.45, 0.45) if (corn_cost > 0 and food < corn_cost) else Color(0.4, 0.95, 0.45))
		
	if lumberjack_cost_badge:
		lumberjack_cost_badge.text = "%d 🥡" % wood_cost
		lumberjack_cost_badge.add_theme_color_override("font_color", Color(1.0, 0.45, 0.45) if food < wood_cost else Color(0.4, 0.95, 0.45))
		
	if worker_cost_badge:
		worker_cost_badge.text = Localization.tr_t("free") if worker_cost == 0 else "%d 🥡" % worker_cost
		worker_cost_badge.add_theme_color_override("font_color", Color(1.0, 0.45, 0.45) if (worker_cost > 0 and food < worker_cost) else Color(0.4, 0.95, 0.45))
	
	build_menu.visible = true
	build_menu.modulate.a = 0.0
	if _menu_tween and _menu_tween.is_running(): _menu_tween.kill()
	_menu_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_menu_tween.tween_property(build_menu, "modulate:a", 1.0, 0.2)

func close_build_menu() -> void:
	if not build_menu or not build_menu.visible: return
	if _menu_tween and _menu_tween.is_running(): _menu_tween.kill()
	_menu_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_menu_tween.tween_property(build_menu, "modulate:a", 0.0, 0.15)
	_menu_tween.tween_callback(func(): build_menu.visible = false; selected_tile = null)

func _on_build_bridge_pressed() -> void:
	if not selected_tile or not is_instance_valid(selected_tile): return
	var bridge_wood_cost = 4
	if wood < bridge_wood_cost:
		sound_manager.play_error()
		show_toast(Localization.tr_t("toast_insufficient_res"), true)
		return
	wood -= bridge_wood_cost
	var instance = bridge_scene.instantiate()
	if instance and "y_scale" in instance: instance.y_scale = hex_grid.y_scale
	if instance and "grid_coord" in instance: instance.grid_coord = selected_tile.grid_coord
	selected_tile.set_building(instance)
	sound_manager.play_build()
	close_build_menu()
	update_ui()
	SaveManager.save_game(self)
	show_toast(Localization.tr_t("toast_built_bridge"))

func _on_build_corn_pressed() -> void:
	if not selected_tile or not is_instance_valid(selected_tile): return
	var cost = 0 if corn_fields_count == 0 else 2
	if cost > 0 and food < cost:
		sound_manager.play_error()
		show_toast(Localization.tr_t("toast_insufficient_res"), true)
		return
	food -= cost
	var instance = corn_field_scene.instantiate()
	if instance and "y_scale" in instance: instance.y_scale = hex_grid.y_scale
	selected_tile.set_building(instance)
	corn_fields_count += 1
	sound_manager.play_build()
	close_build_menu()
	update_ui()
	SaveManager.save_game(self)
	show_toast(Localization.tr_t("toast_built_corn"))

func _on_build_windmill_pressed() -> void:
	if not selected_tile or not is_instance_valid(selected_tile): return
	if food < 5 or wood < 3:
		sound_manager.play_error()
		show_toast(Localization.tr_t("toast_insufficient_res"), true)
		return
	food -= 5
	wood -= 3
	var instance = windmill_scene.instantiate()
	if instance and "y_scale" in instance: instance.y_scale = hex_grid.y_scale
	if instance and "grid_coord" in instance: instance.grid_coord = selected_tile.grid_coord
	selected_tile.set_building(instance)
	windmills.append(instance)
	windmills_count += 1
	sound_manager.play_build()
	close_build_menu()
	update_ui()
	SaveManager.save_game(self)
	show_toast(Localization.tr_t("toast_built_windmill"))

func _on_build_lumberjack_pressed() -> void:
	if not selected_tile or not is_instance_valid(selected_tile): return
	var cost = 2 if lumberjack_huts_count == 0 else 2 + (lumberjack_huts_count * 2)
	if food < cost:
		sound_manager.play_error()
		show_toast(Localization.tr_t("toast_insufficient_res"), true)
		return
	food -= cost
	var instance = lumberjack_hut_scene.instantiate()
	if instance and "y_scale" in instance: instance.y_scale = hex_grid.y_scale
	selected_tile.set_building(instance)
	lumberjack_huts_count += 1
	sound_manager.play_build()
	close_build_menu()
	update_ui()
	SaveManager.save_game(self)
	show_toast(Localization.tr_t("toast_built_lumberjack"))

func _on_build_sawmill_pressed() -> void:
	if not selected_tile or not is_instance_valid(selected_tile): return
	if food < 4 or wood < 5:
		sound_manager.play_error()
		show_toast(Localization.tr_t("toast_insufficient_res"), true)
		return
	food -= 4
	wood -= 5
	var instance = sawmill_scene.instantiate()
	if instance and "y_scale" in instance: instance.y_scale = hex_grid.y_scale
	if instance and "grid_coord" in instance: instance.grid_coord = selected_tile.grid_coord
	selected_tile.set_building(instance)
	sawmills.append(instance)
	sawmills_count += 1
	sound_manager.play_build()
	close_build_menu()
	update_ui()
	SaveManager.save_game(self)
	show_toast(Localization.tr_t("toast_built_sawmill"))

func _on_build_worker_pressed() -> void:
	if not selected_tile or not is_instance_valid(selected_tile): return
	var cost = 0 if worker_huts_count == 0 else 3
	if cost > 0 and food < cost:
		sound_manager.play_error()
		show_toast(Localization.tr_t("toast_insufficient_res"), true)
		return
	food -= cost
	var instance = worker_hut_scene.instantiate()
	if instance and "y_scale" in instance: instance.y_scale = hex_grid.y_scale
	if instance and "grid_coord" in instance: instance.grid_coord = selected_tile.grid_coord
	selected_tile.set_building(instance)
	worker_huts.append(instance)
	worker_huts_count += 1
	sound_manager.play_build()
	close_build_menu()
	update_ui()
	SaveManager.save_game(self)
	show_toast(Localization.tr_t("toast_built_worker"))

# =============================================================================
# ŞATO KRALLIK YÖNETİM MENÜSÜ
# =============================================================================

func open_castle_menu() -> void:
	sound_manager.play_click()
	close_all_menus_instant(castle_menu)
	_update_castle_menu_live()
	castle_menu.visible = true
	castle_menu.modulate.a = 0.0
	if _menu_tween and _menu_tween.is_running(): _menu_tween.kill()
	_menu_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_menu_tween.tween_property(castle_menu, "modulate:a", 1.0, 0.2)

func close_castle_menu() -> void:
	if not castle_menu or not castle_menu.visible: return
	if _menu_tween and _menu_tween.is_running(): _menu_tween.kill()
	_menu_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_menu_tween.tween_property(castle_menu, "modulate:a", 0.0, 0.15)
	_menu_tween.tween_callback(func(): castle_menu.visible = false)

func _update_castle_menu_live() -> void:
	var cur_mult = get_global_multiplier()
	var bonus_pct = int((cur_mult - 1.0) * 100.0)
	var title_str = center_castle.get_title() if (center_castle and center_castle.has_method("get_title")) else Localization.tr_t("castle_title")
	
	if castle_title_label: castle_title_label.text = "%s (%s %d)" % [title_str, Localization.tr_t("level"), castle_level]
	if castle_bonus_label: castle_bonus_label.text = "%s: +%%%d" % [Localization.tr_t("global_bonus"), bonus_pct]
	
	if castle_level >= 10:
		if castle_unlock_label: castle_unlock_label.text = Localization.tr_t("max_power_active")
		if castle_upgrade_cost_label:
			castle_upgrade_cost_label.text = Localization.tr_t("max_level")
			castle_upgrade_cost_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
		btn_upgrade_castle.disabled = true
	else:
		var up_data = CASTLE_UPGRADES.get(castle_level, {"cost_food": 10, "cost_wood": 5, "next_title": "İleri Kademe", "unlock": "+%25 Hız"})
		var req_food = up_data["cost_food"]
		var req_wood = up_data["cost_wood"]
		
		if castle_unlock_label: castle_unlock_label.text = "%s: %s" % [Localization.tr_t("next_unlock"), up_data["unlock"]]
		var cost_str = "%s (%d 🥡)" % [Localization.tr_t("upgrade"), req_food] if req_wood == 0 else "%s (%d 🥡 + %d 🪵)" % [Localization.tr_t("upgrade"), req_food, req_wood]
		var can_afford = (food >= req_food and wood >= req_wood)
		
		if castle_upgrade_cost_label:
			castle_upgrade_cost_label.text = cost_str
			castle_upgrade_cost_label.add_theme_color_override("font_color", Color(0.4, 0.95, 0.45) if can_afford else Color(1.0, 0.45, 0.45))
		if castle_upgrade_info_label:
			castle_upgrade_info_label.text = "➔ %s (+%%25)" % up_data["next_title"]
		btn_upgrade_castle.disabled = false

func _on_upgrade_castle_pressed() -> void:
	if castle_level >= 10: return
	var up_data = CASTLE_UPGRADES.get(castle_level, {"cost_food": 10, "cost_wood": 5, "next_title": "", "unlock": ""})
	var req_food = up_data["cost_food"]
	var req_wood = up_data["cost_wood"]
	
	if food >= req_food and wood >= req_wood:
		food -= req_food
		wood -= req_wood
		castle_level += 1
		if center_castle and center_castle.has_method("upgrade_castle"): center_castle.upgrade_castle()
		sound_manager.play_castle_upgrade()
		update_ui()
		_update_castle_menu_live()
		SaveManager.save_game(self)
		show_toast(Localization.tr_t("toast_castle_upgraded", [center_castle.get_title() if center_castle else ""]))
	else:
		sound_manager.play_error()
		show_toast(Localization.tr_t("toast_insufficient_res"), true)

# =============================================================================
# ÜRETİM & HASAT MENÜLERİ
# =============================================================================

# --- MISIR ---
func open_production_menu() -> void:
	if not active_corn_field or not is_instance_valid(active_corn_field): return
	sound_manager.play_click()
	close_all_menus_instant(production_menu)
	_update_production_menu_live()
	production_menu.visible = true
	production_menu.modulate.a = 0.0
	if _menu_tween and _menu_tween.is_running(): _menu_tween.kill()
	_menu_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_menu_tween.tween_property(production_menu, "modulate:a", 1.0, 0.2)

func close_production_menu() -> void:
	if not production_menu or not production_menu.visible: return
	if _menu_tween and _menu_tween.is_running(): _menu_tween.kill()
	_menu_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_menu_tween.tween_property(production_menu, "modulate:a", 0.0, 0.15)
	_menu_tween.tween_callback(func(): production_menu.visible = false; active_corn_field = null)

func _update_production_menu_live() -> void:
	if not active_corn_field or not is_instance_valid(active_corn_field): return
	var global_mult = get_global_multiplier()
	var lvl = active_corn_field.get("level")
	var rate = active_corn_field.get("production_rate") * global_mult
	var accum = active_corn_field.get("accumulated_food")
	var up_cost = active_corn_field.get("upgrade_cost")
	var is_cap_full = (active_corn_field.has_method("is_full") and active_corn_field.is_full())
	
	if prod_title_label: prod_title_label.text = "🌽 %s (%s %d)" % [Localization.tr_t("corn_name"), Localization.tr_t("level"), lvl]
	if prod_rate_label: prod_rate_label.text = "%.2f %s" % [rate, Localization.tr_t("per_sec")]
	if corn_accum_label: corn_accum_label.text = "%.2fx1 🌽" % accum
	if food_accum_label:
		food_accum_label.text = "%.2f 🥡 [%s]" % [accum, Localization.tr_t("full")] if is_cap_full else "%.2f 🥡 %s" % [accum, Localization.tr_t("collect")]
	if upgrade_cost_label:
		upgrade_cost_label.text = "⬆️ %s (%d 🥡)" % [Localization.tr_t("upgrade"), up_cost]
		upgrade_cost_label.add_theme_color_override("font_color", Color(0.4, 0.95, 0.45) if food >= up_cost else Color(1.0, 0.45, 0.45))
	if upgrade_info_label:
		upgrade_info_label.text = "+%.2f%s | %s: %.1f 🥡" % [rate * 0.5, Localization.tr_t("per_sec"), Localization.tr_t("capacity"), (rate * 1.5) * 30.0]

func _on_collect_pressed() -> void:
	if not active_corn_field or not is_instance_valid(active_corn_field): return
	var collected: float = active_corn_field.collect_food()
	if collected > 0.001:
		food += collected
		stat_total_food += collected
		sound_manager.play_collect()
		update_ui()
		_update_production_menu_live()
		show_toast(Localization.tr_t("toast_collected_food", [collected]))

func _on_upgrade_pressed() -> void:
	if not active_corn_field or not is_instance_valid(active_corn_field): return
	var up_cost: int = active_corn_field.get("upgrade_cost")
	if food >= up_cost:
		food -= up_cost
		active_corn_field.upgrade()
		sound_manager.play_upgrade()
		update_ui()
		_update_production_menu_live()
		SaveManager.save_game(self)
		show_toast(Localization.tr_t("toast_upgraded", [Localization.tr_t("corn_name"), active_corn_field.level]))
	else:
		sound_manager.play_error()
		show_toast(Localization.tr_t("toast_insufficient_res"), true)

# --- DEĞİRMEN (FLOUR) ---
func open_flour_menu() -> void:
	if not active_windmill or not is_instance_valid(active_windmill): return
	sound_manager.play_click()
	close_all_menus_instant(flour_menu)
	_update_flour_menu_live()
	flour_menu.visible = true
	flour_menu.modulate.a = 0.0
	if _menu_tween and _menu_tween.is_running(): _menu_tween.kill()
	_menu_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_menu_tween.tween_property(flour_menu, "modulate:a", 1.0, 0.2)

func close_flour_menu() -> void:
	if not flour_menu or not flour_menu.visible: return
	if _menu_tween and _menu_tween.is_running(): _menu_tween.kill()
	_menu_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_menu_tween.tween_property(flour_menu, "modulate:a", 0.0, 0.15)
	_menu_tween.tween_callback(func(): flour_menu.visible = false; active_windmill = null)

func _update_flour_menu_live() -> void:
	if not active_windmill or not is_instance_valid(active_windmill): return
	var global_mult = get_global_multiplier()
	var lvl = active_windmill.get("level")
	var rate = active_windmill.get("base_rate") * global_mult
	var accum = active_windmill.get("accumulated_flour")
	var is_adj = active_windmill.get("is_adjacent_to_farm")
	var up_food = active_windmill.get("upgrade_cost_food")
	var up_wood = active_windmill.get("upgrade_cost_wood")
	var is_cap_full = (active_windmill.has_method("is_full") and active_windmill.is_full())
	
	if flour_title_label: flour_title_label.text = "🌾 %s (%s %d)" % [Localization.tr_t("windmill_name"), Localization.tr_t("level"), lvl]
	if flour_rate_label: flour_rate_label.text = "%.2f %s%s" % [(rate if is_adj else rate * 0.5), Localization.tr_t("flour"), Localization.tr_t("per_sec")]
	if flour_supply_label:
		flour_supply_label.text = Localization.tr_t("supply_neighbor") if is_adj else Localization.tr_t("supply_global")
	if flour_accum_label:
		flour_accum_label.text = "%.2f 🌾 [%s]" % [accum, Localization.tr_t("full")] if is_cap_full else "%.2f 🌾 %s %s" % [accum, Localization.tr_t("flour"), Localization.tr_t("collect")]
	if flour_upgrade_cost_label:
		var can_afford = (food >= up_food and wood >= up_wood)
		flour_upgrade_cost_label.text = "⬆️ %s (%d 🥡 + %d 🪵)" % [Localization.tr_t("upgrade"), up_food, up_wood]
		flour_upgrade_cost_label.add_theme_color_override("font_color", Color(0.4, 0.95, 0.45) if can_afford else Color(1.0, 0.45, 0.45))
	if flour_upgrade_info_label:
		flour_upgrade_info_label.text = "+%.2f%s | %s: %.1f 🌾" % [rate * 0.5, Localization.tr_t("per_sec"), Localization.tr_t("capacity"), (rate * 1.5) * 30.0]

func _on_collect_flour_pressed() -> void:
	if not active_windmill or not is_instance_valid(active_windmill): return
	var collected: float = active_windmill.collect_flour()
	if collected > 0.001:
		flour += collected
		stat_total_flour += collected
		sound_manager.play_collect()
		update_ui()
		_update_flour_menu_live()
		show_toast(Localization.tr_t("toast_collected_flour", [collected]))

func _on_upgrade_flour_pressed() -> void:
	if not active_windmill or not is_instance_valid(active_windmill): return
	var up_food: int = active_windmill.get("upgrade_cost_food")
	var up_wood: int = active_windmill.get("upgrade_cost_wood")
	if food >= up_food and wood >= up_wood:
		food -= up_food
		wood -= up_wood
		active_windmill.upgrade()
		sound_manager.play_upgrade()
		update_ui()
		_update_flour_menu_live()
		SaveManager.save_game(self)
		show_toast(Localization.tr_t("toast_upgraded", [Localization.tr_t("windmill_name"), active_windmill.level]))
	else:
		sound_manager.play_error()
		show_toast(Localization.tr_t("toast_insufficient_res"), true)

# --- ODUNCU (WOOD) ---
func open_wood_menu() -> void:
	if not active_lumberjack_hut or not is_instance_valid(active_lumberjack_hut): return
	sound_manager.play_click()
	close_all_menus_instant(wood_menu)
	_update_wood_menu_live()
	wood_menu.visible = true
	wood_menu.modulate.a = 0.0
	if _menu_tween and _menu_tween.is_running(): _menu_tween.kill()
	_menu_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_menu_tween.tween_property(wood_menu, "modulate:a", 1.0, 0.2)

func close_wood_menu() -> void:
	if not wood_menu or not wood_menu.visible: return
	if _menu_tween and _menu_tween.is_running(): _menu_tween.kill()
	_menu_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_menu_tween.tween_property(wood_menu, "modulate:a", 0.0, 0.15)
	_menu_tween.tween_callback(func(): wood_menu.visible = false; active_lumberjack_hut = null)

func _update_wood_menu_live() -> void:
	if not active_lumberjack_hut or not is_instance_valid(active_lumberjack_hut): return
	var global_mult = get_global_multiplier()
	var lvl = active_lumberjack_hut.get("level")
	var rate = active_lumberjack_hut.get("production_rate") * global_mult
	var accum = active_lumberjack_hut.get("accumulated_wood")
	var up_cost = active_lumberjack_hut.get("upgrade_cost")
	var is_cap_full = (active_lumberjack_hut.has_method("is_full") and active_lumberjack_hut.is_full())
	
	if wood_title_label: wood_title_label.text = "🪓 %s (%s %d)" % [Localization.tr_t("lumberjack_name"), Localization.tr_t("level"), lvl]
	if wood_rate_label: wood_rate_label.text = "%.2f %s" % [rate, Localization.tr_t("per_sec")]
	if wood_raw_accum_label: wood_raw_accum_label.text = "%.2fx1 🪵" % accum
	if wood_collect_label:
		wood_collect_label.text = "%.2f 🪵 [%s]" % [accum, Localization.tr_t("full")] if is_cap_full else "%.2f 🪵 %s" % [accum, Localization.tr_t("collect")]
	if wood_upgrade_cost_label:
		wood_upgrade_cost_label.text = "⬆️ %s (%d 🥡)" % [Localization.tr_t("upgrade"), up_cost]
		wood_upgrade_cost_label.add_theme_color_override("font_color", Color(0.4, 0.95, 0.45) if food >= up_cost else Color(1.0, 0.45, 0.45))
	if wood_upgrade_info_label:
		wood_upgrade_info_label.text = "+%.2f%s | %s: %.1f 🪵" % [rate * 0.5, Localization.tr_t("per_sec"), Localization.tr_t("capacity"), (rate * 1.5) * 30.0]

func _on_collect_wood_pressed() -> void:
	if not active_lumberjack_hut or not is_instance_valid(active_lumberjack_hut): return
	var collected: float = active_lumberjack_hut.collect_wood()
	if collected > 0.001:
		wood += collected
		stat_total_wood += collected
		sound_manager.play_collect()
		update_ui()
		_update_wood_menu_live()
		show_toast(Localization.tr_t("toast_collected_wood", [collected]))

func _on_upgrade_wood_pressed() -> void:
	if not active_lumberjack_hut or not is_instance_valid(active_lumberjack_hut): return
	var up_cost: int = active_lumberjack_hut.get("upgrade_cost")
	if food >= up_cost:
		food -= up_cost
		active_lumberjack_hut.upgrade()
		sound_manager.play_upgrade()
		update_ui()
		_update_wood_menu_live()
		SaveManager.save_game(self)
		show_toast(Localization.tr_t("toast_upgraded", [Localization.tr_t("lumberjack_name"), active_lumberjack_hut.level]))
	else:
		sound_manager.play_error()
		show_toast(Localization.tr_t("toast_insufficient_res"), true)

# --- KERESTE FABRİKASI (PLANK) ---
func open_plank_menu() -> void:
	if not active_sawmill or not is_instance_valid(active_sawmill): return
	sound_manager.play_click()
	close_all_menus_instant(plank_menu)
	_update_plank_menu_live()
	plank_menu.visible = true
	plank_menu.modulate.a = 0.0
	if _menu_tween and _menu_tween.is_running(): _menu_tween.kill()
	_menu_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_menu_tween.tween_property(plank_menu, "modulate:a", 1.0, 0.2)

func close_plank_menu() -> void:
	if not plank_menu or not plank_menu.visible: return
	if _menu_tween and _menu_tween.is_running(): _menu_tween.kill()
	_menu_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_menu_tween.tween_property(plank_menu, "modulate:a", 0.0, 0.15)
	_menu_tween.tween_callback(func(): plank_menu.visible = false; active_sawmill = null)

func _update_plank_menu_live() -> void:
	if not active_sawmill or not is_instance_valid(active_sawmill): return
	var global_mult = get_global_multiplier()
	var lvl = active_sawmill.get("level")
	var rate = active_sawmill.get("base_rate") * global_mult
	var accum = active_sawmill.get("accumulated_plank")
	var is_adj = active_sawmill.get("is_adjacent_to_lumberjack")
	var up_food = active_sawmill.get("upgrade_cost_food")
	var up_wood = active_sawmill.get("upgrade_cost_wood")
	var is_cap_full = (active_sawmill.has_method("is_full") and active_sawmill.is_full())
	
	if plank_title_label: plank_title_label.text = "🪵 %s (%s %d)" % [Localization.tr_t("sawmill_name"), Localization.tr_t("level"), lvl]
	if plank_rate_label: plank_rate_label.text = "%.2f %s%s" % [(rate if is_adj else rate * 0.5), Localization.tr_t("plank"), Localization.tr_t("per_sec")]
	if plank_supply_label:
		plank_supply_label.text = Localization.tr_t("supply_neighbor_wood") if is_adj else Localization.tr_t("supply_global")
	if plank_accum_label:
		plank_accum_label.text = "%.2f 🪵 [%s]" % [accum, Localization.tr_t("full")] if is_cap_full else "%.2f 🪵 %s %s" % [accum, Localization.tr_t("plank"), Localization.tr_t("collect")]
	if plank_upgrade_cost_label:
		var can_afford = (food >= up_food and wood >= up_wood)
		plank_upgrade_cost_label.text = "⬆️ %s (%d 🥡 + %d 🪵)" % [Localization.tr_t("upgrade"), up_food, up_wood]
		plank_upgrade_cost_label.add_theme_color_override("font_color", Color(0.4, 0.95, 0.45) if can_afford else Color(1.0, 0.45, 0.45))
	if plank_upgrade_info_label:
		plank_upgrade_info_label.text = "+%.2f%s | %s: %.1f 🪵" % [rate * 0.5, Localization.tr_t("per_sec"), Localization.tr_t("capacity"), (rate * 1.5) * 30.0]

func _on_collect_plank_pressed() -> void:
	if not active_sawmill or not is_instance_valid(active_sawmill): return
	var collected: float = active_sawmill.collect_plank()
	if collected > 0.001:
		plank += collected
		stat_total_plank += collected
		sound_manager.play_collect()
		update_ui()
		_update_plank_menu_live()
		show_toast(Localization.tr_t("toast_collected_plank", [collected]))

func _on_upgrade_plank_pressed() -> void:
	if not active_sawmill or not is_instance_valid(active_sawmill): return
	var up_food: int = active_sawmill.get("upgrade_cost_food")
	var up_wood: int = active_sawmill.get("upgrade_cost_wood")
	if food >= up_food and wood >= up_wood:
		food -= up_food
		wood -= up_wood
		active_sawmill.upgrade()
		sound_manager.play_upgrade()
		update_ui()
		_update_plank_menu_live()
		SaveManager.save_game(self)
		show_toast(Localization.tr_t("toast_upgraded", [Localization.tr_t("sawmill_name"), active_sawmill.level]))
	else:
		sound_manager.play_error()
		show_toast(Localization.tr_t("toast_insufficient_res"), true)

# --- İŞÇİ KULÜBESİ ---
func open_worker_menu() -> void:
	if not active_worker_hut or not is_instance_valid(active_worker_hut): return
	sound_manager.play_click()
	close_all_menus_instant(worker_menu)
	_update_worker_menu_live()
	worker_menu.visible = true
	worker_menu.modulate.a = 0.0
	if _menu_tween and _menu_tween.is_running(): _menu_tween.kill()
	_menu_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_menu_tween.tween_property(worker_menu, "modulate:a", 1.0, 0.2)

func close_worker_menu() -> void:
	if not worker_menu or not worker_menu.visible: return
	if _menu_tween and _menu_tween.is_running(): _menu_tween.kill()
	_menu_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_menu_tween.tween_property(worker_menu, "modulate:a", 0.0, 0.15)
	_menu_tween.tween_callback(func(): worker_menu.visible = false; active_worker_hut = null)


func _update_worker_menu_live() -> void:
	if not active_worker_hut or not is_instance_valid(active_worker_hut): return
	var global_mult = get_global_multiplier()
	var lvl = active_worker_hut.get("level")
	var rate = active_worker_hut.get("carry_rate") * global_mult
	var up_cost = active_worker_hut.get("upgrade_cost")
	var coord = active_worker_hut.get("grid_coord")
	var gathered = active_worker_hut.get("total_gathered")
	
	var neighbors_count = 0
	if coord != null:
		var n_b = hex_grid.get_neighbor_buildings(coord)
		for b in n_b:
			if ("accumulated_food" in b) or ("accumulated_wood" in b) or ("accumulated_flour" in b) or ("accumulated_plank" in b):
				neighbors_count += 1
				
	if worker_title_label: worker_title_label.text = "🛖 %s (%s %d)" % [Localization.tr_t("worker_name"), Localization.tr_t("level"), lvl]
	if worker_rate_label: worker_rate_label.text = "%s: %.2f %s" % [Localization.tr_t("auto_carry"), rate, Localization.tr_t("per_sec")]
	if worker_neighbors_label:
		worker_neighbors_label.text = "%s: %d | %s: %.1f" % [Localization.tr_t("connected_facilities"), neighbors_count, Localization.tr_t("total_transferred"), gathered]
	if worker_upgrade_cost_label:
		worker_upgrade_cost_label.text = "⬆️ %s (%d 🥡)" % [Localization.tr_t("upgrade"), up_cost]
		worker_upgrade_cost_label.add_theme_color_override("font_color", Color(0.4, 0.95, 0.45) if food >= up_cost else Color(1.0, 0.45, 0.45))
	if worker_upgrade_info_label:
		worker_upgrade_info_label.text = "+%.2f %s" % [active_worker_hut.get("carry_rate") * 0.5, Localization.tr_t("per_sec")]

func _on_upgrade_worker_pressed() -> void:
	if not active_worker_hut or not is_instance_valid(active_worker_hut): return
	var up_cost: int = active_worker_hut.get("upgrade_cost")
	if food >= up_cost:
		food -= up_cost
		active_worker_hut.upgrade()
		sound_manager.play_upgrade()
		update_ui()
		_update_worker_menu_live()
		SaveManager.save_game(self)
		show_toast(Localization.tr_t("toast_upgraded", [Localization.tr_t("worker_name"), active_worker_hut.level]))
	else:
		sound_manager.play_error()
		show_toast(Localization.tr_t("toast_insufficient_res"), true)

# =============================================================================
# AYARLAR, İSTATİSTİKLER & PRESTİJ MODALI
# =============================================================================

func open_settings_modal() -> void:
	sound_manager.play_click()
	close_all_menus()
	_refresh_settings_localized_texts()
	_switch_settings_tab(0)
	settings_modal.visible = true
	settings_modal.scale = Vector2.ONE * 0.85
	var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(settings_modal, "scale", Vector2.ONE, 0.25)

func close_settings_modal() -> void:
	sound_manager.play_click()
	settings_modal.visible = false
	SaveManager.save_game(self)

func _switch_settings_tab(tab_idx: int) -> void:
	sound_manager.play_click()
	tab_general.visible = (tab_idx == 0)
	tab_stats.visible = (tab_idx == 1)
	tab_prestige.visible = (tab_idx == 2)
	
	btn_tab_general.modulate = Color(1.0, 1.0, 1.0, 1.0 if tab_idx == 0 else 0.6)
	btn_tab_stats.modulate = Color(1.0, 1.0, 1.0, 1.0 if tab_idx == 1 else 0.6)
	btn_tab_prestige.modulate = Color(1.0, 1.0, 1.0, 1.0 if tab_idx == 2 else 0.6)
	
	if tab_idx == 1:
		_update_stats_tab_live()
	elif tab_idx == 2:
		_update_prestige_tab_live()

func _change_language(lang_code: String) -> void:
	Localization.set_language(lang_code)
	sound_manager.play_click()
	_refresh_settings_localized_texts()
	update_ui()
	SaveManager.save_game(self)

func _refresh_settings_localized_texts() -> void:
	if settings_title_label: settings_title_label.text = Localization.tr_t("settings_title")
	if btn_tab_general: btn_tab_general.text = Localization.tr_t("tab_general")
	if btn_tab_stats: btn_tab_stats.text = Localization.tr_t("tab_stats")
	if btn_tab_prestige: btn_tab_prestige.text = Localization.tr_t("tab_prestige")
	if lang_label: lang_label.text = Localization.tr_t("language_select")
	if audio_label: audio_label.text = Localization.tr_t("sfx_volume")
	if prestige_desc_label: prestige_desc_label.text = Localization.tr_t("prestige_desc")
	if btn_do_prestige: btn_do_prestige.text = Localization.tr_t("rebirth_btn")

func _on_volume_changed(val: float) -> void:
	sound_manager.set_volume(val)

func _on_mute_toggle() -> void:
	sound_manager.set_muted(!sound_manager.is_muted)
	btn_mute.text = "🔇 %s" % Localization.tr_t("mute") if sound_manager.is_muted else "🔊 Açık"
	sound_manager.play_click()

func _update_stats_tab_live() -> void:
	var mins = int(stat_playtime / 60.0)
	var secs = int(fmod(stat_playtime, 60.0))
	if stat_playtime_label: stat_playtime_label.text = "%s: %d dk %d sn" % [Localization.tr_t("stat_playtime"), mins, secs]
	if stat_lands_label: stat_lands_label.text = "%s: %d" % [Localization.tr_t("stat_conquered"), stat_total_conquered]
	if stat_food_label: stat_food_label.text = "%s: %.1f" % [Localization.tr_t("stat_total_food"), stat_total_food]
	if stat_wood_label: stat_wood_label.text = "%s: %.1f" % [Localization.tr_t("stat_total_wood"), stat_total_wood]
	if stat_flour_label: stat_flour_label.text = "%s: %.1f" % [Localization.tr_t("stat_total_flour"), stat_total_flour]
	if stat_plank_label: stat_plank_label.text = "%s: %.1f" % [Localization.tr_t("stat_total_plank"), stat_total_plank]
	if stat_rebirths_label: stat_rebirths_label.text = "%s: %d" % [Localization.tr_t("stat_rebirths"), total_rebirths]

func get_castle_multiplier() -> float:
	return 1.0 + float(castle_level - 1) * 0.25

func get_prestige_multiplier() -> float:
	return 1.0 + float(crowns) * 0.05

func get_global_multiplier() -> float:
	return get_castle_multiplier() * get_prestige_multiplier()

func get_career_total_resources() -> float:
	return stat_total_food + stat_total_wood + stat_total_flour + stat_total_plank

func calculate_earned_crowns() -> int:
	var total_res = get_career_total_resources()
	var base_crowns = int(floor(sqrt(total_res / 20.0)))
	return max(1, base_crowns * castle_level)

func _update_prestige_tab_live() -> void:
	var cur_bonus = int((get_prestige_multiplier() - 1.0) * 100.0)
	var earned = calculate_earned_crowns()
	if current_crowns_label: current_crowns_label.text = "%s: %d 👑 (+%%%d %s)" % [Localization.tr_t("current_crowns"), crowns, cur_bonus, Localization.tr_t("capacity")]
	if earned_crowns_label: earned_crowns_label.text = "%s: +%d 👑" % [Localization.tr_t("earned_crowns"), earned]

func _on_prestige_button_pressed() -> void:
	var earned = calculate_earned_crowns()
	sound_manager.play_click()
	prestige_confirm_title.text = Localization.tr_t("prestige_confirm_title")
	prestige_confirm_desc.text = Localization.tr_t("prestige_confirm_desc", [earned, int(((1.0 + float(crowns + earned) * 0.05) - 1.0) * 100.0)])
	btn_confirm_prestige.text = Localization.tr_t("confirm")
	btn_cancel_prestige.text = Localization.tr_t("cancel")
	prestige_confirm_modal.visible = true

func _execute_prestige() -> void:
	var earned = calculate_earned_crowns()
	if earned <= 0:
		prestige_confirm_modal.visible = false
		return
		
	crowns += earned
	total_rebirths += 1
	
	# Sıfırlama
	food = 1.0
	wood = 0.0
	flour = 0.0
	plank = 0.0
	purchased_tiles_count = 0
	owned_count = 1
	castle_level = 1
	corn_fields_count = 0
	windmills_count = 0
	lumberjack_huts_count = 0
	sawmills_count = 0
	worker_huts_count = 0
	
	windmills.clear()
	sawmills.clear()
	worker_huts.clear()
	
	hex_grid.initialize_map()
	if hex_grid.tiles.has(Vector2i.ZERO):
		var ct: HexTile = hex_grid.tiles[Vector2i.ZERO]
		if ct.has_building():
			center_castle = ct.building
			
	prestige_confirm_modal.visible = false
	settings_modal.visible = false
	close_all_menus()
	
	sound_manager.play_prestige()
	update_ui()
	SaveManager.save_game(self)
	
	show_toast(Localization.tr_t("toast_prestige_success", [earned, int((get_prestige_multiplier() - 1.0) * 100.0)]))

# =============================================================================
# ÇEVRİMDIŞI GELİR MODALI
# =============================================================================

func _show_offline_modal(gains: Dictionary) -> void:
	_pending_offline_gains = gains
	var total_mins = int(gains["seconds"] / 60.0)
	var time_str = "%d saat %d dk" % [int(total_mins / 60), int(fmod(total_mins, 60))] if total_mins >= 60 else "%d dk" % total_mins
	
	offline_title_label.text = Localization.tr_t("offline_welcome")
	offline_desc_label.text = Localization.tr_t("offline_desc", [time_str])
	gain_food_label.text = "+%.1f 🥡 %s" % [gains["food"], Localization.tr_t("food")]
	gain_wood_label.text = "+%.1f 🪵 %s" % [gains["wood"], Localization.tr_t("wood")]
	gain_flour_label.text = "+%.1f 🌾 %s" % [gains["flour"], Localization.tr_t("flour")]
	gain_plank_label.text = "+%.1f 🪵 %s" % [gains["plank"], Localization.tr_t("plank")]
	
	btn_claim_all.text = Localization.tr_t("offline_claim")
	btn_claim_3x.text = Localization.tr_t("offline_claim_3x")
	
	offline_modal.visible = true
	sound_manager.play_collect()

func _claim_offline_normal() -> void:
	food += _pending_offline_gains["food"]
	wood += _pending_offline_gains["wood"]
	flour += _pending_offline_gains["flour"]
	plank += _pending_offline_gains["plank"]
	
	stat_total_food += _pending_offline_gains["food"]
	stat_total_wood += _pending_offline_gains["wood"]
	stat_total_flour += _pending_offline_gains["flour"]
	stat_total_plank += _pending_offline_gains["plank"]
	
	offline_modal.visible = false
	sound_manager.play_collect()
	update_ui()
	SaveManager.save_game(self)

func _claim_offline_3x() -> void:
	var f = _pending_offline_gains["food"] * 3.0
	var w = _pending_offline_gains["wood"] * 3.0
	var fl = _pending_offline_gains["flour"] * 3.0
	var p = _pending_offline_gains["plank"] * 3.0
	
	food += f
	wood += w
	flour += fl
	plank += p
	
	stat_total_food += f
	stat_total_wood += w
	stat_total_flour += fl
	stat_total_plank += p
	
	offline_modal.visible = false
	sound_manager.play_prestige()
	update_ui()
	SaveManager.save_game(self)
	show_toast("🌟 3x Çevrimdışı Ödülü Ambarlara Eklendi!")

# =============================================================================
# BİLDİRİM / TOAST
# =============================================================================

func show_toast(message: String, is_warning: bool = false) -> void:
	if not toast_panel or not toast_label: return
	toast_label.text = message
	toast_label.add_theme_color_override("font_color", Color(1.0, 0.45, 0.45) if is_warning else Color(0.95, 0.95, 0.95))
	toast_panel.visible = true
	if _toast_tween and _toast_tween.is_running(): _toast_tween.kill()
	_toast_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_toast_tween.tween_property(toast_panel, "modulate:a", 1.0, 0.2)
	_toast_tween.tween_interval(2.2)
	_toast_tween.tween_property(toast_panel, "modulate:a", 0.0, 0.4)
	_toast_tween.tween_callback(func(): toast_panel.visible = false)
