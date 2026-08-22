class_name EconomyManager
extends RefCounted

## Modüler Krallık Ekonomisi, Töre Ağacı & Yetenek Hesaplayıcı (Godot 4 Paritesi)

static func get_global_multiplier(castle_level: int, crowns: int, talents: Dictionary, tore_talents: Dictionary = {}, titles: Dictionary = {}) -> float:
	var castle_mult: float = 1.0 + float(castle_level - 1) * 0.25
	var prestige_bonus: float = float(crowns) * 0.05
	
	# Yetenek Ağacı Çarpanları
	var talent_boost: float = float(talents.get("boostAll", 0)) * 0.05
	
	# Töre Ağacı Çarpanları (Tonyukuk & Gök Tengri)
	var tore_boost: float = 0.0
	if tore_talents.has("gokTengri"):
		var rain: int = int(tore_talents["gokTengri"].get("rainBlessing", 0))
		tore_boost += float(rain) * 0.05
	if tore_talents.has("tonyukuk"):
		var silk: int = int(tore_talents["tonyukuk"].get("silkNetwork", 0))
		tore_boost += float(silk) * 0.04
		
	# Unvan Bonusları (Bozkır Hakanı unvanı +%15 küresel hız)
	var title_boost: float = 0.0
	if titles.get("khagan", false):
		title_boost += 0.15
		
	var prestige_mult: float = 1.0 + prestige_bonus + talent_boost + tore_boost + title_boost
	return castle_mult * prestige_mult

static func get_worker_transfer_multiplier(talents: Dictionary, tore_talents: Dictionary = {}) -> float:
	var speed_lvl: int = talents.get("workerSpeed", 0)
	var road_lvl: int = 0
	if tore_talents.has("tonyukuk"):
		road_lvl = int(tore_talents["tonyukuk"].get("pavedRoads", 0))
	return 1.0 + float(speed_lvl) * 0.10 + float(road_lvl) * 0.08

static func get_expansion_discount(talents: Dictionary, tore_talents: Dictionary = {}, titles: Dictionary = {}) -> float:
	var conquest_lvl: int = talents.get("conquestMaster", 0)
	var discount: float = float(conquest_lvl) * 0.03
	if tore_talents.has("kulTigin"):
		discount += float(tore_talents["kulTigin"].get("braveHeart", 0)) * 0.05
	if titles.get("conqueror", false):
		discount += 0.10
	return minf(0.60, discount)

static func get_season_production_multiplier(season: String, is_zud: bool, is_tile_warmed: bool, titles: Dictionary = {}) -> float:
	if is_tile_warmed:
		return 1.50 # Isıtılmış karo +%50 hız
	
	if season == "SPRING":
		return 1.25 # Bahar bereketi
	elif season == "SUMMER":
		return 1.10 # Yaz güneşi
	elif season == "AUTUMN":
		return 1.00 # Normal hasat
	elif season == "WINTER":
		var loss_penalty: float = 0.60 if is_zud else 0.80
		if titles.get("zudMaster", false):
			loss_penalty = minf(1.0, loss_penalty + 0.20)
		return loss_penalty
	return 1.0

static func calculate_market_trade(recipe_key: String, resources: Dictionary, titles: Dictionary = {}) -> Dictionary:
	var merchant_bonus: float = 1.20 if titles.get("merchant", false) else 1.0
	var result = { "success": false, "consumed": {}, "gained": {} }
	
	if recipe_key == "flour_to_stone":
		if float(resources.get("flour", 0.0)) >= 15.0:
			result["success"] = true
			result["consumed"] = { "flour": 15.0 }
			result["gained"] = { "stone": roundf(8.0 * merchant_bonus) }
	elif recipe_key == "bread_to_iron":
		if float(resources.get("bread", 0.0)) >= 10.0:
			result["success"] = true
			result["consumed"] = { "bread": 10.0 }
			result["gained"] = { "iron": roundf(5.0 * merchant_bonus) }
	elif recipe_key == "furniture_to_stone":
		if float(resources.get("furniture", 0.0)) >= 10.0:
			result["success"] = true
			result["consumed"] = { "furniture": 10.0 }
			result["gained"] = { "stone": roundf(15.0 * merchant_bonus) }
	elif recipe_key == "iron_stone_to_crown":
		if float(resources.get("iron", 0.0)) >= 25.0 and float(resources.get("stone", 0.0)) >= 25.0:
			result["success"] = true
			result["consumed"] = { "iron": 25.0, "stone": 25.0 }
			result["gained"] = { "crowns": 1 }
	elif recipe_key == "obsidian_to_tamga":
		if float(resources.get("obsidian", 0.0)) >= 15.0:
			result["success"] = true
			result["consumed"] = { "obsidian": 15.0 }
			result["gained"] = { "tamgas": 1 }
			
	return result

static func calculate_offline_production(buildings: Array, elapsed_seconds: float, global_mult: float, has_workers: bool) -> Dictionary:
	var capped_time: float = minf(8.0 * 3600.0, elapsed_seconds)
	var gains = {
		"food": 0.0,
		"wood": 0.0,
		"flour": 0.0,
		"plank": 0.0,
		"bread": 0.0,
		"furniture": 0.0,
		"stone": 0.0,
		"iron": 0.0
	}
	
	for b in buildings:
		var type: String = b.get("type", "")
		var lvl: int = b.get("level", 1)
		var rate: float = 0.20 * pow(1.5, lvl - 1) * global_mult
		
		if type == "corn":
			rate = 0.42 * pow(1.5, lvl - 1) * global_mult
			gains["food"] += rate * capped_time if has_workers else minf(rate * 30.0, rate * capped_time)
		elif type == "lumberjack":
			rate = 0.35 * pow(1.5, lvl - 1) * global_mult
			gains["wood"] += rate * capped_time if has_workers else minf(rate * 30.0, rate * capped_time)
		elif type == "quarry":
			rate = 0.35 * pow(1.5, lvl - 1) * global_mult
			gains["stone"] += rate * capped_time if has_workers else minf(rate * 30.0, rate * capped_time)
		elif type == "mine":
			rate = 0.25 * pow(1.5, lvl - 1) * global_mult
			gains["iron"] += rate * capped_time if has_workers else minf(rate * 30.0, rate * capped_time)
			
	return gains
