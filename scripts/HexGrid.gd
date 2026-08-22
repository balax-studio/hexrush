class_name HexGrid
extends Node2D

## Altıgen haritayı, biyom oluşturma ve komşuluk genişleme mekaniğini yöneten sistem.

signal tile_purchased(coord: Vector2i, tile: HexTile)
signal tile_clicked_discovered(coord: Vector2i, tile: HexTile)
signal tile_clicked_owned(coord: Vector2i, tile: HexTile)

@export var hex_tile_scene: PackedScene = preload("res://scenes/HexTile.tscn")
@export var castle_scene: PackedScene = preload("res://scenes/Castle.tscn")
@export var hex_size: float = 75.0
@export var y_scale: float = 0.85

# Koordinat (Vector2i) -> HexTile referansı
var tiles: Dictionary = {}

func _ready() -> void:
	randomize()
	initialize_map()

## Haritayı sıfırlar ve 3 birim yarıçapındaki altıgenleri kurar
func initialize_map() -> void:
	# Varsa eski arsaları temizle
	for child in get_children():
		child.queue_free()
	tiles.clear()

	# 1. 3 birim yarıçapındaki (toplam 37 karo) tüm altıgenleri başlat
	var radius = 3
	for q in range(-radius, radius + 1):
		var r1 = max(-radius, -q - radius)
		var r2 = min(radius, -q + radius)
		for r in range(r1, r2 + 1):
			var coord = Vector2i(q, r)
			var tile = spawn_tile(coord)
			if coord == Vector2i.ZERO:
				tile.set_tile_type(HexTile.TileType.MEADOW)
				tile.set_state(HexTile.TileState.OWNED, false)
			else:
				var random_type: HexTile.TileType = randi() % HexTile.TileType.size() as HexTile.TileType
				tile.set_tile_type(random_type)
				tile.set_state(HexTile.TileState.HIDDEN, false)

	# Merkez Şatoyu inşa et
	var center_tile: HexTile = tiles[Vector2i.ZERO]
	var castle_instance = castle_scene.instantiate()
	if castle_instance and "y_scale" in castle_instance:
		castle_instance.y_scale = y_scale
	center_tile.set_building(castle_instance)

	# 2. Merkezden bakışla görüş hattını ve dağ arkası gölgelerini hesapla
	recalculate_visibility(false)

## Merkezden (veya fethedilmiş topraklardan) bakarak görüş hattını (Line of Sight) hesaplar.
## Fethedilmemiş dağların arkasında kalan tüm cepheler gizli (HIDDEN) kalır.
func recalculate_visibility(animate: bool = true) -> void:
	for coord in tiles:
		var tile: HexTile = tiles[coord]
		if tile.state == HexTile.TileState.OWNED:
			continue # Sahipli topraklar her zaman tam görünür

		var dist = HexMath.hex_distance(Vector2i.ZERO, coord)
		if dist > 3:
			tile.set_state(HexTile.TileState.HIDDEN, animate)
			continue

		# Merkezden (0,0) bu karoya giden ışını (ray) al
		var line = HexMath.hex_line(Vector2i.ZERO, coord)
		var is_blocked = false

		# Merkez ve hedef arasındaki tüm ara karoları kontrol et
		for i in range(1, line.size() - 1):
			var mid_coord = line[i]
			if tiles.has(mid_coord):
				var mid_tile: HexTile = tiles[mid_coord]
				# Eğer aradaki karo fethedilmemiş bir DAĞ ise arkasındaki görüşü tamamen keser!
				if mid_tile.tile_type == HexTile.TileType.MOUNTAIN and mid_tile.state != HexTile.TileState.OWNED:
					is_blocked = true
					break

		if is_blocked:
			tile.set_state(HexTile.TileState.HIDDEN, animate)
		else:
			if tile.state == HexTile.TileState.HIDDEN:
				tile.set_state(HexTile.TileState.DISCOVERED, animate)

## Belirtilen koordinatta bir HexTile oluşturur veya mevcut olanı döndürür
func spawn_tile(coord: Vector2i) -> HexTile:
	if tiles.has(coord):
		return tiles[coord]

	var tile_instance = hex_tile_scene.instantiate() as HexTile
	tile_instance.hex_size = hex_size
	tile_instance.y_scale = y_scale
	tile_instance.grid_coord = coord
	tile_instance.position = HexMath.hex_to_pixel(coord.x, coord.y, hex_size, y_scale)
	
	tile_instance.z_index = int(tile_instance.position.y)
	tile_instance.tile_clicked.connect(_on_tile_clicked)
	add_child(tile_instance)
	tiles[coord] = tile_instance
	
	return tile_instance

## Bir arsayı resmen açar ve görüş hattını günceller
func unlock_tile(tile: HexTile) -> void:
	tile.set_state(HexTile.TileState.OWNED, true)
	tile_purchased.emit(tile.grid_coord, tile)
	recalculate_visibility(true)

## Bir arsanın komşularını açar
func reveal_neighbors_of(_origin_coord: Vector2i, _animate: bool = true) -> void:
	recalculate_visibility(_animate)


## Bir arsaya tıklandığında çalışan fonksiyon
func _on_tile_clicked(tile: HexTile) -> void:
	if tile.state == HexTile.TileState.DISCOVERED:
		tile_clicked_discovered.emit(tile.grid_coord, tile)
	elif tile.state == HexTile.TileState.OWNED:
		_on_owned_tile_interact(tile)
		tile_clicked_owned.emit(tile.grid_coord, tile)

func _on_owned_tile_interact(tile: HexTile) -> void:
	# Sahipli arsaya tıklandığında ufak bir geri bildirim animasyonu
	var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(tile, "scale", Vector2.ONE * 1.05, 0.08)
	tween.tween_property(tile, "scale", Vector2.ONE, 0.12)

## Verilen koordinatın 6 komşusundaki binaları (CornField, WorkerHut vb.) döndürür
func get_neighbor_buildings(coord: Vector2i) -> Array[Node2D]:
	var neighbor_buildings: Array[Node2D] = []
	var neighbors = HexMath.get_neighbors(coord)
	for n_coord in neighbors:
		if tiles.has(n_coord):
			var t: HexTile = tiles[n_coord]
			if t.state == HexTile.TileState.OWNED and t.has_building():
				neighbor_buildings.append(t.building)
	return neighbor_buildings

## Kaydedilmiş harita verisini yükler ve binaları ayağa kaldırır
func load_from_saved_tiles(tiles_data: Array, scenes_dict: Dictionary) -> Dictionary:
	for child in get_children():
		child.queue_free()
	tiles.clear()
	
	var building_refs = {
		"castle": null,
		"windmills": [] as Array[Node2D],
		"sawmills": [] as Array[Node2D],
		"worker_huts": [] as Array[Node2D],
		"corn_fields": [] as Array[Node2D]
	}
	
	for td in tiles_data:
		var coord = Vector2i(int(td["x"]), int(td["y"]))
		var tile = spawn_tile(coord)
		tile.set_tile_type(int(td["type"]) as HexTile.TileType)
		tile.set_state(int(td["state"]) as HexTile.TileState, false)
		
		var b_type = td.get("building_type", "")
		if b_type != "" and scenes_dict.has(b_type) and scenes_dict[b_type] != null:
			var b_scene: PackedScene = scenes_dict[b_type]
			var b_inst = b_scene.instantiate()
			if "y_scale" in b_inst: b_inst.y_scale = y_scale
			if "grid_coord" in b_inst: b_inst.grid_coord = coord
			
			var lvl = int(td.get("building_level", 1))
			if "level" in b_inst: b_inst.level = lvl
			
			var accum = float(td.get("building_accum", 0.0))
			if "accumulated_food" in b_inst: b_inst.accumulated_food = accum
			elif "accumulated_wood" in b_inst: b_inst.accumulated_wood = accum
			elif "accumulated_flour" in b_inst: b_inst.accumulated_flour = accum
			elif "accumulated_plank" in b_inst: b_inst.accumulated_plank = accum
			elif "total_gathered" in b_inst: b_inst.total_gathered = accum
			
			tile.set_building(b_inst)
			
			if b_type == "castle": building_refs["castle"] = b_inst
			elif b_type == "windmill": building_refs["windmills"].append(b_inst)
			elif b_type == "sawmill": building_refs["sawmills"].append(b_inst)
			elif b_type == "worker": building_refs["worker_huts"].append(b_inst)
			elif b_type == "corn": building_refs["corn_fields"].append(b_inst)
			
	return building_refs



