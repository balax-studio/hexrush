class_name RelicManager
extends RefCounted

## Kadim Bozkır & Göktürk Eserleri Yöneticisi

const RELIC_DEFINITIONS = {
	"axe": {
		"name": "Göktürk Baltası",
		"icon": "🪓",
		"perk": "Odun ve Kereste üretimine kalıcı +%25 verim.",
		"flavor": "Bozkırın kadim demircileri tarafından çifte su verilmiş kutsal balta."
	},
	"cornucopia": {
		"name": "Bereket Boynuzu",
		"icon": "🏺",
		"perk": "Mısır ve Fırınlara kalıcı +%25 üretim hızı.",
		"flavor": "Toprağın sonsuz bereketini çağıran efsanevi tören kabı."
	},
	"standard": {
		"name": "Kurt Başlı Tuğ",
		"icon": "⚔️",
		"perk": "Toprak fetih maliyetlerinde %15 kalıcı indirim.",
		"flavor": "Orduların ve kağanların önünde dalgalanan dokuz kollu savaş sancağı."
	},
	"shield": {
		"name": "Demir Dağ Kalkanı",
		"icon": "🛡️",
		"perk": "Taş/Demir madenlerine +%30 hız ve Gece Savunması gücü.",
		"flavor": "Ergenekon Dağı'ndan çıkarılan ilk cevherle dövülmüş aşılmaz kalkan."
	}
}

static func get_wood_multiplier(relics: Dictionary) -> float:
	return 1.25 if relics.get("axe", false) else 1.0

static func get_food_multiplier(relics: Dictionary) -> float:
	return 1.25 if relics.get("cornucopia", false) else 1.0

static func get_expansion_multiplier(relics: Dictionary) -> float:
	return 0.85 if relics.get("standard", false) else 1.0

static func get_mine_multiplier(relics: Dictionary) -> float:
	return 1.30 if relics.get("shield", false) else 1.0
