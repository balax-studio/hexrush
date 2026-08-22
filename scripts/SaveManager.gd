class_name SaveManager
extends RefCounted

## Oyun Verilerini JSON Formatında Kaydeden, Yükleyen ve Çevrimdışı Geliri Hesaplayan Sistem.

const SAVE_PATH = "user://idle_kingdom_save.json"
const MAX_OFFLINE_SECONDS = 8 * 3600 # Maksimum 8 saatlik çevrimdışı üretim tavanı

static func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

static func delete_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)

## Oyunun tüm durumunu dosyaya kaydeder
static func save_game(main_node: Node) -> bool:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if not file:
		printerr("SaveManager: Dosya açılamadı! ", SAVE_PATH)
		return false
		
	var hex_grid: HexGrid = main_node.get("hex_grid")
	if not hex_grid:
		return false
		
	var tiles_data: Array = []
	for coord in hex_grid.tiles:
		var t: HexTile = hex_grid.tiles[coord]
		var b_type = ""
		var b_lvl = 1
		var b_accum = 0.0
		
		if t.has_building():
			var b = t.building
			if b is CornField or "accumulated_food" in b:
				b_type = "corn"
				b_lvl = b.get("level") if "level" in b else 1
				b_accum = b.get("accumulated_food") if "accumulated_food" in b else 0.0
			elif b is Windmill or "accumulated_flour" in b:
				b_type = "windmill"
				b_lvl = b.get("level") if "level" in b else 1
				b_accum = b.get("accumulated_flour") if "accumulated_flour" in b else 0.0
			elif b is Bakery or "accumulated_bread" in b:
				b_type = "bakery"
				b_lvl = b.get("level") if "level" in b else 1
				b_accum = b.get("accumulated_bread") if "accumulated_bread" in b else 0.0
			elif b is LumberjackHut or "accumulated_wood" in b:
				b_type = "lumberjack"
				b_lvl = b.get("level") if "level" in b else 1
				b_accum = b.get("accumulated_wood") if "accumulated_wood" in b else 0.0
			elif b is Sawmill or "accumulated_plank" in b:
				b_type = "sawmill"
				b_lvl = b.get("level") if "level" in b else 1
				b_accum = b.get("accumulated_plank") if "accumulated_plank" in b else 0.0
			elif b is FurnitureMaker or "accumulated_furniture" in b:
				b_type = "furniture"
				b_lvl = b.get("level") if "level" in b else 1
				b_accum = b.get("accumulated_furniture") if "accumulated_furniture" in b else 0.0
			elif b is WorkerHut or "carry_rate" in b:
				b_type = "worker"
				b_lvl = b.get("level") if "level" in b else 1
				b_accum = b.get("total_gathered") if "total_gathered" in b else 0.0
			elif b is Watchtower or "defense_power" in b:
				b_type = "watchtower"
				b_lvl = b.get("level") if "level" in b else 1
				b_accum = 0.0
			elif b is MountainMine or "accumulated_resource" in b:
				b_type = "mine"
				b_lvl = b.get("level") if "level" in b else 1
				b_accum = b.get("accumulated_resource") if "accumulated_resource" in b else 0.0
			elif "bridge" in b.name.to_lower() or (b.get_script() != null and "bridge" in b.get_script().resource_path.to_lower()):
				b_type = "bridge"
				b_lvl = 1
				b_accum = 0.0
			else:
				b_type = "castle"
				b_lvl = main_node.get("castle_level")
				
		var is_warmed: bool = t.get("is_warmed") if "is_warmed" in t else false
		var warm_timer: float = t.get("warm_timer") if "warm_timer" in t else 0.0
				
		tiles_data.append({
			"x": coord.x,
			"y": coord.y,
			"state": int(t.state),
			"type": int(t.tile_type),
			"building_type": b_type,
			"building_level": b_lvl,
			"building_accum": b_accum,
			"is_warmed": is_warmed,
			"warm_timer": warm_timer
		})
		
	var sound_mgr = main_node.get("sound_manager")
	var sfx_vol = sound_mgr.sfx_volume if sound_mgr else 0.8
	var sfx_muted = sound_mgr.is_muted if sound_mgr else false
	
	var data = {
		"version": 2,
		"timestamp": int(Time.get_unix_time_from_system()),
		"resources": {
			"food": main_node.get("food"),
			"wood": main_node.get("wood"),
			"flour": main_node.get("flour"),
			"plank": main_node.get("plank"),
			"bread": main_node.get("bread"),
			"furniture": main_node.get("furniture"),
			"stone": main_node.get("stone") if "stone" in main_node else 0.0,
			"iron": main_node.get("iron") if "iron" in main_node else 0.0,
			"obsidian": main_node.get("obsidian") if "obsidian" in main_node else 0.0,
			"mithril": main_node.get("mithril") if "mithril" in main_node else 0.0,
			"tamgas": main_node.get("tamgas") if "tamgas" in main_node else 0
		},
		"progression": {
			"owned_count": main_node.get("owned_count"),
			"purchased_meadow_count": main_node.get("purchased_meadow_count"),
			"purchased_forest_count": main_node.get("purchased_forest_count"),
			"purchased_sea_count": main_node.get("purchased_sea_count"),
			"purchased_mountain_count": main_node.get("purchased_mountain_count"),
			"castle_level": main_node.get("castle_level"),
			"total_migrations": main_node.get("total_migrations") if "total_migrations" in main_node else 0
		},
		"prestige": {
			"crowns": main_node.get("crowns"),
			"total_rebirths": main_node.get("total_rebirths")
		},
		"tore": {
			"tore_talents": main_node.get("tore_talents") if "tore_talents" in main_node else {}
		},
		"titles": {
			"unlocked": main_node.get("titles") if "titles" in main_node else {},
			"market_trades_count": main_node.get("market_trades_count") if "market_trades_count" in main_node else 0,
			"warmed_tiles_count": main_node.get("warmed_tiles_count") if "warmed_tiles_count" in main_node else 0
		},
		"season": {
			"current": main_node.get("season") if "season" in main_node else "SPRING",
			"timer": main_node.get("season_timer") if "season_timer" in main_node else 0.0,
			"year": main_node.get("season_year") if "season_year" in main_node else 1,
			"is_zud": main_node.get("is_zud") if "is_zud" in main_node else false
		},
		"stats": {
			"total_food_produced": main_node.get("stat_total_food"),
			"total_wood_produced": main_node.get("stat_total_wood"),
			"total_flour_produced": main_node.get("stat_total_flour"),
			"total_plank_produced": main_node.get("stat_total_plank"),
			"total_bread_produced": main_node.get("stat_total_bread"),
			"total_furniture_produced": main_node.get("stat_total_furniture"),
			"total_stone_produced": main_node.get("stat_total_stone") if "stat_total_stone" in main_node else 0.0,
			"total_iron_produced": main_node.get("stat_total_iron") if "stat_total_iron" in main_node else 0.0,
			"total_obsidian_produced": main_node.get("stat_total_obsidian") if "stat_total_obsidian" in main_node else 0.0,
			"total_tiles_conquered": main_node.get("stat_total_conquered"),
			"playtime_seconds": main_node.get("stat_playtime")
		},
		"settings": {
			"language": Localization.current_lang,
			"sfx_volume": sfx_vol,
			"sfx_muted": sfx_muted
		},
		"tiles": tiles_data
	}
	
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	return true

## Kayıtlı verileri dosyadan okur
static func load_saved_data() -> Dictionary:
	if not has_save():
		return {}
		
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return {}
		
	var content = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var err = json.parse(content)
	if err != OK:
		printerr("SaveManager: JSON okuma hatası!")
		return {}
		
	if json.data is Dictionary:
		return json.data
	return {}

## Çevrimdışı sürede kazanılan gelirleri simüle eder
static func calculate_offline_gains(save_data: Dictionary) -> Dictionary:
	if not save_data.has("timestamp"):
		return {"seconds": 0, "food": 0.0, "wood": 0.0, "flour": 0.0, "plank": 0.0}
		
	var last_time = int(save_data["timestamp"])
	var current_time = int(Time.get_unix_time_from_system())
	var elapsed_seconds = max(0, current_time - last_time)
	
	# Minimum 15 saniye çevrimdışı kalınmışsa hesapla
	if elapsed_seconds < 15:
		return {"seconds": 0, "food": 0.0, "wood": 0.0, "flour": 0.0, "plank": 0.0}
		
	var capped_seconds = min(elapsed_seconds, MAX_OFFLINE_SECONDS)
	
	# Küresel çarpanı ve prestij çarpanını hesapla
	var c_lvl = 1
	if save_data.has("progression") and save_data["progression"].has("castle_level"):
		c_lvl = int(save_data["progression"]["castle_level"])
		
	var crowns = 0
	if save_data.has("prestige") and save_data["prestige"].has("crowns"):
		crowns = int(save_data["prestige"]["crowns"])
		
	var global_mult = (1.0 + float(c_lvl - 1) * 0.25) * (1.0 + float(crowns) * 0.05)
	
	var gained_food = 0.0
	var gained_wood = 0.0
	var gained_flour = 0.0
	var gained_plank = 0.0
	var gained_bread = 0.0
	var gained_furniture = 0.0
	
	if save_data.has("tiles"):
		var tiles_arr: Array = save_data["tiles"]
		var has_workers = false
		for t in tiles_arr:
			if t.get("building_type") == "worker":
				has_workers = true
				break
				
		for t in tiles_arr:
			var b_type = t.get("building_type", "")
			var b_lvl = t.get("building_level", 1)
			
			if b_type == "corn":
				var rate = (0.42 * pow(1.5, b_lvl - 1)) * global_mult
				var max_cap = (rate * 30.0)
				if has_workers:
					gained_food += rate * capped_seconds
				else:
					gained_food += min(max_cap, rate * capped_seconds)
					
			elif b_type == "lumberjack":
				var rate = (0.35 * pow(1.5, b_lvl - 1)) * global_mult
				var max_cap = (rate * 30.0)
				if has_workers:
					gained_wood += rate * capped_seconds
				else:
					gained_wood += min(max_cap, rate * capped_seconds)
					
			elif b_type == "windmill":
				var rate = (0.25 * pow(1.5, b_lvl - 1)) * global_mult
				var max_cap = (rate * 30.0)
				if has_workers:
					gained_flour += rate * capped_seconds
				else:
					gained_flour += min(max_cap, rate * capped_seconds)
					
			elif b_type == "sawmill":
				var rate = (0.20 * pow(1.5, b_lvl - 1)) * global_mult
				var max_cap = (rate * 30.0)
				if has_workers:
					gained_plank += rate * capped_seconds
				else:
					gained_plank += min(max_cap, rate * capped_seconds)
					
			elif b_type == "bakery":
				var rate = (0.25 * pow(1.5, b_lvl - 1)) * global_mult
				var max_cap = (rate * 30.0)
				if has_workers:
					gained_bread += rate * capped_seconds
				else:
					gained_bread += min(max_cap, rate * capped_seconds)
					
			elif b_type == "furniture":
				var rate = (0.20 * pow(1.5, b_lvl - 1)) * global_mult
				var max_cap = (rate * 30.0)
				if has_workers:
					gained_furniture += rate * capped_seconds
				else:
					gained_furniture += min(max_cap, rate * capped_seconds)
					
	return {
		"seconds": capped_seconds,
		"food": gained_food,
		"wood": gained_wood,
		"flour": gained_flour,
		"plank": gained_plank,
		"bread": gained_bread,
		"furniture": gained_furniture
	}
