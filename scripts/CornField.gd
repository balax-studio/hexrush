class_name CornField
extends Node2D

## Altıgen ızgaranın izometrik perspektifinde (y_scale = 0.85) çizilen
## 3 Boyutlu, karıklı, çitli ve korkuluklu sevimli Mısır Tarlası yapısı.

@export var field_scale: float = 1.0
@export var y_scale: float = 0.85

# Üretim ve Seviye Durumu (Production & Level State)
const FILL_DURATION: float = 30.0     # Tarlanın sıfırdan tam dolma süresi (30 saniye)

var level: int = 1
var production_rate: float = 0.42     # Saniyede üretilen miktar (0.42/sn)
var max_capacity: float = 12.60       # 30 sn x 0.42 = 12.60 birim kapasite tavanı
var accumulated_food: float = 0.0    # Tarlada hasat edilmeyi bekleyen gıda
var upgrade_cost: int = 2            # Bir sonraki seviyeye yükseltme bedeli (Gıda)

var _time: float = 0.0

# Renk Paleti
const SOIL_BASE = Color(0.42, 0.28, 0.16)       # Sürülmüş ıslak tarla toprağı
const SOIL_RIDGE = Color(0.56, 0.38, 0.22)      # Güneş vuran toprak karık tepeleri
const SOIL_SHADE = Color(0.30, 0.19, 0.10)      # Karık çukuru gölgeleri

const STALK_BASE = Color(0.28, 0.62, 0.22)      # Mısır sapı yeşili
const STALK_LIGHT = Color(0.45, 0.78, 0.28)     # Yaprak aydınlık yeşili
const CORN_GOLD = Color(0.98, 0.82, 0.18)       # Olgun altın sarısı mısır koçanı
const CORN_TASSEL = Color(0.85, 0.65, 0.30)     # Mısır püskülü

const FENCE_WOOD = Color(0.58, 0.40, 0.25)      # Ahşap tarla çiti
const FENCE_SHADE = Color(0.40, 0.26, 0.15)
const STRAW_COLOR = Color(0.90, 0.80, 0.45)     # Korkuluk samanı
const CLOTH_BLUE = Color(0.25, 0.48, 0.82)      # Korkuluk gömleği
const HAT_COLOR = Color(0.68, 0.45, 0.25)       # Saman şapka

func _ready() -> void:
	# Başlangıç kapasitesini 30 saniyelik üretime eşitle
	max_capacity = snapped(production_rate * FILL_DURATION, 0.1)
	
	# Açılışta topraktan fışkırma / elastik pop-in animasyonu
	scale = Vector2.ZERO
	var tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2.ONE * field_scale, 0.65)

func _process(delta: float) -> void:
	_time += delta * 3.5
	# Pasif gıda üretimi (30 saniyede dolacak şekilde max_capacity ile sınırlı)
	accumulated_food = min(max_capacity, accumulated_food + (production_rate * delta))
	# Rüzgarda yaprak ve püskül salınımı için
	queue_redraw()

## Tarlanın kapasitesinin dolup dolmadığını döndürür
func is_full() -> bool:
	return accumulated_food >= (max_capacity - 0.01)

## Biriken mısırı hasat eder ve miktarını döndürür
func collect_food() -> float:
	var collected = accumulated_food
	accumulated_food = 0.0
	
	# Hasat pop animasyonu
	var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2.ONE * (field_scale * 1.08), 0.1)
	tween.tween_property(self, "scale", Vector2.ONE * field_scale, 0.2)
	
	return collected

## Tarlayı bir üst seviyeye geliştirir (Hız ve kapasite birlikte artar, 30 sn'de dolar)
func upgrade() -> void:
	level += 1
	production_rate = snapped(production_rate * 1.5, 0.01)
	# Geliştirme yapıldıkça kapasite de hızla orantılı olarak büyür
	max_capacity = snapped(production_rate * FILL_DURATION, 0.1)
	upgrade_cost = int(round(upgrade_cost * 1.8)) + 1
	
	# Geliştirme animasyonu
	var tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2.ONE * (field_scale * 1.18), 0.15)
	tween.tween_property(self, "scale", Vector2.ONE * field_scale, 0.3)

func iso(x: float, z: float, h: float = 0.0) -> Vector2:
	return Vector2(x, z * y_scale - h)

func _draw() -> void:
	# 1. Sürülmüş tarla karıkları
	var ridges = 5
	var r_width = 44.0
	var r_depth = 34.0
	
	for i in range(ridges):
		var t = float(i) / float(ridges - 1)
		var z_offset = lerp(-r_depth * 0.5, r_depth * 0.5, t)
		
		var p1 = iso(-r_width * 0.5, z_offset, 0.0)
		var p2 = iso(r_width * 0.5, z_offset, 0.0)
		var p1_top = iso(-r_width * 0.5, z_offset, 2.5)
		var p2_top = iso(r_width * 0.5, z_offset, 2.5)
		
		draw_line(p1, p2, SOIL_SHADE, 5.0)
		draw_line(p1_top, p2_top, SOIL_RIDGE, 3.0)

	# 2. Mısır Sapları ve Altın Koçanlar
	var stalk_cols = 4
	var stalk_rows = 3
	for r in range(stalk_rows):
		for c in range(stalk_cols):
			var rx = (float(c) - (stalk_cols - 1) * 0.5) * 10.0 + sin(_time + r) * 1.2
			var rz = (float(r) - (stalk_rows - 1) * 0.5) * 11.0
			_draw_corn_stalk(rx, rz, (r * stalk_cols + c))

	# 3. Ahşap Tarla Çiti
	_draw_fence()

	# 4. Korkuluk
	_draw_scarecrow()

func _draw_corn_stalk(x: float, z: float, seed_idx: int) -> void:
	var h_base = 0.0
	var stalk_h = 16.0 + sin(float(seed_idx) * 2.1) * 3.0
	var sway = sin(_time * 2.0 + float(seed_idx)) * 2.5
	
	var bot = iso(x, z, h_base)
	var mid = iso(x + sway * 0.5, z, h_base + stalk_h * 0.5)
	var top = iso(x + sway, z, h_base + stalk_h)
	
	draw_line(bot, mid, STALK_BASE, 2.2)
	draw_line(mid, top, STALK_LIGHT, 1.8)
	
	var leaf_sway = cos(_time * 2.5 + float(seed_idx)) * 1.5
	var leaf_l = iso(x - 5.0 + leaf_sway, z - 2.0, h_base + stalk_h * 0.45)
	var leaf_r = iso(x + 5.0 + leaf_sway, z + 2.0, h_base + stalk_h * 0.55)
	draw_line(mid, leaf_l, STALK_LIGHT, 1.5)
	draw_line(mid, leaf_r, STALK_LIGHT, 1.5)
	
	var cob_pos = iso(x + 2.0 + sway * 0.7, z + 1.0, h_base + stalk_h * 0.6)
	draw_circle(cob_pos, 2.5, CORN_GOLD)
	draw_circle(cob_pos + Vector2(0, -1), 1.5, CORN_TASSEL)

func _draw_fence() -> void:
	var post_z = 20.0
	var post_xs = [-22.0, -8.0, 8.0, 22.0]
	var h_post = 9.0
	
	for i in range(post_xs.size() - 1):
		var p1 = iso(post_xs[i], post_z, 5.0)
		var p2 = iso(post_xs[i+1], post_z, 5.0)
		draw_line(p1, p2, FENCE_WOOD, 2.0)
		draw_line(p1 + Vector2(0, -3), p2 + Vector2(0, -3), FENCE_WOOD, 1.5)
		
	for px in post_xs:
		var b = iso(px, post_z, 0.0)
		var t = iso(px, post_z, h_post)
		draw_line(b, t, FENCE_SHADE, 3.0)
		draw_line(b, t, FENCE_WOOD, 1.8)

func _draw_scarecrow() -> void:
	var sc_x = -15.0
	var sc_z = -4.0
	var sc_h = 24.0
	
	var bot = iso(sc_x, sc_z, 0.0)
	var waist = iso(sc_x, sc_z, sc_h * 0.45)
	var shoulder = iso(sc_x, sc_z, sc_h * 0.75)
	var head = iso(sc_x, sc_z, sc_h * 0.9)
	var hat_top = iso(sc_x, sc_z, sc_h + 3.0)
	
	draw_line(bot, shoulder, FENCE_SHADE, 2.5)
	
	var arm_l = iso(sc_x - 7.0, sc_z, sc_h * 0.7)
	var arm_r = iso(sc_x + 7.0, sc_z, sc_h * 0.7)
	draw_line(arm_l, arm_r, FENCE_SHADE, 2.0)
	draw_line(arm_l, arm_r + Vector2(0, 1), STRAW_COLOR, 1.2)
	
	var body_poly = PackedVector2Array([
		waist + Vector2(-3, 0),
		waist + Vector2(3, 0),
		shoulder + Vector2(4, 0),
		shoulder + Vector2(-4, 0)
	])
	draw_colored_polygon(body_poly, CLOTH_BLUE)
	draw_circle(head, 3.5, STRAW_COLOR)
	
	var hat_poly = PackedVector2Array([
		head + Vector2(-6, -1),
		head + Vector2(6, -1),
		hat_top + Vector2(0, -2)
	])
	draw_colored_polygon(hat_poly, HAT_COLOR)
	draw_line(head + Vector2(-7, 0), head + Vector2(7, 0), HAT_COLOR.darkened(0.2), 1.5)
