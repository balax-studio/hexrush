class_name EconomyManager
extends RefCounted

## Modüler Krallık Ekonomisi & Yetenek Hesaplayıcı

static func get_global_multiplier(castle_level: int, crowns: int, talents: Dictionary) -> float:
	var castle_mult: float = 1.0 + float(castle_level - 1) * 0.25
	var prestige_bonus: float = float(crowns) * 0.05
	
	# Yetenek Ağacı Çarpanları
	var talent_boost: float = float(talents.get("boostAll", 0)) * 0.05
	var prestige_mult: float = 1.0 + prestige_bonus + talent_boost
	
	return castle_mult * prestige_mult

static func get_worker_transfer_multiplier(talents: Dictionary) -> float:
	var speed_lvl: int = talents.get("workerSpeed", 0)
	return 1.0 + float(speed_lvl) * 0.10

static func get_expansion_discount(talents: Dictionary) -> float:
	var conquest_lvl: int = talents.get("conquestMaster", 0)
	return float(conquest_lvl) * 0.03

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
