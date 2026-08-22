class_name QuestSystem
extends RefCounted

## 3-Katmanlı Görev ve Ferman Sistemi (Hızlı, Krallık, Epik)

signal quest_completed(tier: String, quest_data: Dictionary)

enum QuestTier { FAST, STRATEGIC, EPIC }

static func generate_quest(tier: String, current_castle_lvl: int = 1) -> Dictionary:
	if tier == "fast":
		var types = ["collect_wood", "collect_food", "collect_stone", "click_tile"]
		var selected = types[randi() % types.size()]
		if selected == "collect_wood":
			return { "type": selected, "desc": "25 Odun Topla", "current": 0, "target": 25, "reward": { "food": 30 } }
		elif selected == "collect_food":
			return { "type": selected, "desc": "35 Gıda Hasat Et", "current": 0, "target": 35, "reward": { "wood": 25 } }
		elif selected == "collect_stone":
			return { "type": selected, "desc": "15 Taş Çıkar", "current": 0, "target": 15, "reward": { "food": 25, "iron": 5 } }
		else:
			return { "type": selected, "desc": "15 Kez Karoya Tıkla", "current": 0, "target": 15, "reward": { "food": 20, "wood": 20 } }
			
	elif tier == "strat":
		var types = ["upgrade_quarry", "build_worker", "conquer_forest", "build_watchtower"]
		var selected = types[randi() % types.size()]
		if selected == "upgrade_quarry":
			return { "type": selected, "desc": "Bir Taş Ocağını 2. Seviyeye Yükselt", "current": 0, "target": 1, "reward": { "stone": 35, "crowns": 1 } }
		elif selected == "build_worker":
			return { "type": selected, "desc": "2 İşçi Kulübesi Kur", "current": 0, "target": 2, "reward": { "food": 40, "wood": 40, "crowns": 1 } }
		elif selected == "conquer_forest":
			return { "type": selected, "desc": "2 Orman Karosu Fethet", "current": 0, "target": 2, "reward": { "wood": 50, "crowns": 1 } }
		else:
			return { "type": selected, "desc": "1 Gözcü Kulesi İnşa Et", "current": 0, "target": 1, "reward": { "wood": 30, "stone": 20, "crowns": 1 } }
			
	else: # epic
		var types = ["castle_level", "conquer_total", "defend_raids"]
		var selected = types[randi() % types.size()]
		if selected == "castle_level":
			var target_lvl = current_castle_lvl + 1
			return { "type": selected, "desc": "Şatoyu " + str(target_lvl) + ". Seviyeye Yükselt", "current": current_castle_lvl, "target": target_lvl, "reward": { "crowns": 3, "relic": true } }
		elif selected == "conquer_total":
			return { "type": selected, "desc": "Toplam 10 Toprak Fethet", "current": 0, "target": 10, "reward": { "crowns": 4, "relic": true } }
		else:
			return { "type": selected, "desc": "2 Gece Baskınını Savuştur", "current": 0, "target": 2, "reward": { "crowns": 3, "relic": true } }
