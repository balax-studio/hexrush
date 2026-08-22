class_name Castle
extends Node2D

## Altıgen ızgaranın izometrik perspektifi (y_scale = 0.85, 30° aksonometri) ile
## %100 uyumlu, derinlikli, çok kuleli ve detaylı 3 Boyutlu Şato / Hisar yapısı.

@export var castle_scale: float = 1.0
@export var y_scale: float = 0.85

# Canlı rüzgar ve bayrak dalgalanma efekti için zaman değişkeni
var _time: float = 0.0

# Renk Paleti (Doğal taş tonları, kraliyet kırmızısı çatı ve altın flama)
const COLOR_SHADOW = Color(0.05, 0.08, 0.12, 0.32)

# Taş Duvar Renkleri (Güneş sol-üstten vurur: Aydınlık, Yan, Gölge)
const STONE_TOP = Color(0.92, 0.93, 0.95)       # Yatay üst yüzeyler (en parlak)
const STONE_LIGHT = Color(0.82, 0.84, 0.88)     # Sol cephe (direkt ışık)
const STONE_MID = Color(0.68, 0.71, 0.77)       # Ön-sağ cephe (hafif gölge)
const STONE_DARK = Color(0.52, 0.55, 0.62)      # Sağ-arka cephe (derin gölge)
const STONE_STROKE = Color(0.38, 0.41, 0.48, 0.85) # Derz ve kenar çizgisi

# Kiremit ve Çatı Renkleri (Görkemli Burgonya Kırmızısı)
const ROOF_LIGHT = Color(0.90, 0.28, 0.28)
const ROOF_MID = Color(0.74, 0.18, 0.20)
const ROOF_DARK = Color(0.55, 0.12, 0.14)
const ROOF_RIM = Color(0.98, 0.82, 0.42)        # Çatı ucu altın süs

# Ahşap & Demir & Detaylar
const WOOD_LIGHT = Color(0.55, 0.36, 0.22)
const WOOD_DARK = Color(0.36, 0.22, 0.12)
const IRON_COLOR = Color(0.18, 0.19, 0.22)
const WINDOW_DARK = Color(0.12, 0.15, 0.22)
const WINDOW_GLOW = Color(1.0, 0.85, 0.45, 0.75) # Pencerelerdeki sıcak meşale ışığı
const FLAG_GOLD = Color(0.98, 0.82, 0.18)
const FLAG_GOLD_SHADOW = Color(0.80, 0.62, 0.12)
const FLAG_EMBLEM = Color(0.85, 0.22, 0.22)

# 10 Kademeli Krallık Seviyesi ve Unvanları
const TITLES = [
	"🛖 Köy Yerleşimi",
	"🛡️ Derebeylik (Barony)",
	"🏰 Kontluk (County)",
	"⚔️ Düklük (Duchy)",
	"👑 Büyük Düklük (Grand Duchy)",
	"🦅 Prens Emareti (Principality)",
	"⚜️ Krallık (Kingdom)",
	"🦁 Büyük Krallık (High Kingdom)",
	"🌟 Baş İmparatorluk (Empire)",
	"⚡ Efsanevi Hükümdarlık (Mythic Sovereign)"
]

var castle_level: int = 1

func get_title() -> String:
	return TITLES[clamp(castle_level - 1, 0, TITLES.size() - 1)]

func get_global_multiplier() -> float:
	return 1.0 + float(castle_level - 1) * 0.25

func upgrade_castle() -> void:
	if castle_level < 10:
		castle_level += 1
		var tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "scale", Vector2.ONE * (castle_scale * 1.2), 0.15)
		tween.tween_property(self, "scale", Vector2.ONE * castle_scale, 0.35)

func _ready() -> void:
	# Açılışta şatonun tatmin edici bir elastik "pop-in" animasyonuyla yükselmesi
	scale = Vector2.ZERO
	var tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2.ONE * castle_scale, 0.7)

func _process(delta: float) -> void:
	_time += delta * 4.0
	# Bayrak dalgalanmasını güncellemek için periyodik yeniden çizim
	queue_redraw()

## 3D Uzay noktasını (x, z, h) izometrik ekran koordinatına çevirir
func iso(x: float, z: float, h: float = 0.0) -> Vector2:
	return Vector2(x, z * y_scale - h)

func _draw() -> void:
	# -------------------------------------------------------------
	# 0. ZEMİN GÖLGESİ (Altıgen perspektifine uygun elips izdüşümü)
	# -------------------------------------------------------------
	var ground_shadow_pts = PackedVector2Array()
	var shadow_segments = 16
	var shadow_radius_x = 48.0
	var shadow_radius_z = 32.0
	var shadow_offset_x = 6.0
	var shadow_offset_z = 8.0
	for i in range(shadow_segments):
		var angle = (TAU / shadow_segments) * i
		var sx = shadow_offset_x + cos(angle) * shadow_radius_x
		var sz = shadow_offset_z + sin(angle) * shadow_radius_z
		ground_shadow_pts.append(iso(sx, sz, 0.0))
	draw_colored_polygon(ground_shadow_pts, COLOR_SHADOW)

	# -------------------------------------------------------------
	# 1. TAŞ KAİDE / TEMEL PLATFORMU (Raised Hexagonal Stone Base)
	# -------------------------------------------------------------
	_draw_iso_hex_platform(0.0, 0.0, 38.0, 0.0, 7.0)

	# Giriş Merdivenleri (Öne doğru uzanan basamaklar)
	_draw_iso_stairs(0.0, 30.0, 16.0, 12.0, 7.0)

	# -------------------------------------------------------------
	# 2. ARKA KULELER VE ARKA SUR (Back-to-Front Y-Sorting: Z < 0)
	# -------------------------------------------------------------
	# Sol Arka Kule
	_draw_iso_tower(-24.0, -18.0, 8.5, 7.0, 36.0, true, 16.0)
	# Sağ Arka Kule
	_draw_iso_tower(24.0, -18.0, 8.5, 7.0, 36.0, true, 16.0)
	
	# Arka ve Yan Sur Duvarları
	_draw_iso_curtain_wall(Vector2(-24, -18), Vector2(24, -18), 7.0, 20.0)
	_draw_iso_curtain_wall(Vector2(-24, -18), Vector2(-28, 10), 7.0, 20.0)
	_draw_iso_curtain_wall(Vector2(24, -18), Vector2(28, 10), 7.0, 20.0)

	# -------------------------------------------------------------
	# 3. İÇ AVLUS VE MERKEZ BÜYÜK BAŞKULE (Grand Keep / Donjon)
	# -------------------------------------------------------------
	# Avlu zemini (Kaldırım taşları)
	var courtyard = PackedVector2Array([
		iso(-20, -14, 7), iso(20, -14, 7),
		iso(22, 10, 7), iso(0, 18, 7), iso(-22, 10, 7)
	])
	draw_colored_polygon(courtyard, STONE_DARK.darkened(0.2))

	# Ana Başkule (Merkezde yükselen 2 katlı devasa kule)
	_draw_central_keep(0.0, -2.0)

	# -------------------------------------------------------------
	# 4. ÖN SUR VE TAÇ KAPI (Barbican & Front Gate)
	# -------------------------------------------------------------
	_draw_iso_curtain_wall(Vector2(-28, 10), Vector2(-8, 22), 7.0, 22.0)
	_draw_iso_curtain_wall(Vector2(8, 22), Vector2(28, 10), 7.0, 22.0)
	_draw_gatehouse(0.0, 21.0, 16.0, 7.0, 24.0)

	# -------------------------------------------------------------
	# 5. ÖN KÖŞE BURÇLARI (Front Bastion Towers)
	# -------------------------------------------------------------
	# Sol Ön Kule
	_draw_iso_tower(-28.0, 10.0, 9.5, 7.0, 32.0, true, 18.0)
	# Sağ Ön Kule
	_draw_iso_tower(28.0, 10.0, 9.5, 7.0, 32.0, true, 18.0)

	# -------------------------------------------------------------
	# 6. KRALİYET BAYRAĞI VE FLAMA ANİMASYONU (Pinnacle Mast & Banner)
	# -------------------------------------------------------------
	_draw_royal_banner(0.0, -2.0, 78.0)


# =============================================================================
# YARDIMCI ÇİZİM FONKSİYONLARI (İzometrik 3D Geometri)
# =============================================================================

## Altıgen yükseltilmiş taş temel platformu çizer
func _draw_iso_hex_platform(cx: float, cz: float, radius: float, base_h: float, height: float) -> void:
	var corners_bot: Array[Vector2] = []
	var corners_top: Array[Vector2] = []
	
	for i in range(6):
		var angle_deg = 60.0 * i - 30.0
		var rad = deg_to_rad(angle_deg)
		var x = cx + radius * cos(rad)
		var z = cz + radius * sin(rad)
		corners_bot.append(iso(x, z, base_h))
		corners_top.append(iso(x, z, base_h + height))

	# Ön alt 3 yüzeyi çiz (i=0..1, 1..2, 2..3)
	# i=0: Sağ-Alt (Mid shade), i=1: En Ön-Alt (Light), i=2: Sol-Alt (Light)
	var face_colors = [STONE_DARK, STONE_MID, STONE_LIGHT]
	for idx in range(3):
		var i0 = (idx) % 6
		var i1 = (idx + 1) % 6
		var face = PackedVector2Array([
			corners_bot[i0], corners_bot[i1],
			corners_top[i1], corners_top[i0]
		])
		draw_colored_polygon(face, face_colors[idx])
		draw_polyline(PackedVector2Array([corners_top[i0], corners_top[i1], corners_bot[i1]]), STONE_STROKE, 1.0)

	# Üst kaplama yüzeyi
	draw_colored_polygon(PackedVector2Array(corners_top), STONE_TOP)
	var outline = PackedVector2Array(corners_top)
	outline.append(corners_top[0])
	draw_polyline(outline, STONE_STROKE, 1.5)


## Basamaklı giriş merdiveni çizer
func _draw_iso_stairs(cx: float, cz: float, width: float, length: float, total_h: float) -> void:
	var steps = 3
	var step_len = length / steps
	var step_h = total_h / steps
	
	for s in range(steps):
		var z_start = cz - length * 0.5 + (s * step_len)
		var h = total_h - (s * step_h)
		var w2 = width * 0.5
		
		var p_tl = iso(cx - w2, z_start, h)
		var p_tr = iso(cx + w2, z_start, h)
		var p_br = iso(cx + w2, z_start + step_len, h)
		var p_bl = iso(cx - w2, z_start + step_len, h)
		
		# Basamak üst yüzeyi
		draw_colored_polygon(PackedVector2Array([p_tl, p_tr, p_br, p_bl]), STONE_TOP.darkened(0.08))
		# Basamak dikey alnı
		var p_b_bot_l = iso(cx - w2, z_start + step_len, h - step_h)
		var p_b_bot_r = iso(cx + w2, z_start + step_len, h - step_h)
		draw_colored_polygon(PackedVector2Array([p_bl, p_br, p_b_bot_r, p_b_bot_l]), STONE_MID)


## İzometrik Sur Duvarı ve Mazgallarını Çizer
func _draw_iso_curtain_wall(p1: Vector2, p2: Vector2, base_h: float, height: float) -> void:
	var wall_top_l = iso(p1.x, p1.y, base_h + height)
	var wall_top_r = iso(p2.x, p2.y, base_h + height)
	var wall_bot_r = iso(p2.x, p2.y, base_h)
	var wall_bot_l = iso(p1.x, p1.y, base_h)
	
	# Duvarın duruş açısına göre gölgelendirme
	var is_right_facing = (p2.x - p1.x) > 0
	var wall_color = STONE_LIGHT if not is_right_facing else STONE_MID
	if abs(p2.y - p1.y) > abs(p2.x - p1.x) and p2.x > 0:
		wall_color = STONE_DARK
		
	draw_colored_polygon(PackedVector2Array([wall_bot_l, wall_bot_r, wall_top_r, wall_top_l]), wall_color)
	
	# Taş derz çizgileri
	var mid_h = base_h + height * 0.5
	var line_l = iso(p1.x, p1.y, mid_h)
	var line_r = iso(p2.x, p2.y, mid_h)
	draw_line(line_l, line_r, STONE_STROKE.darkened(0.2), 1.0)
	
	# Sur üstü yürüyüş yolu kornişi
	draw_line(wall_top_l, wall_top_r, STONE_TOP, 2.0)
	
	# Sur Mazgalları (Crenellations)
	var cren_count = 3
	var cren_h = 4.0
	for c in range(cren_count):
		var t0 = float(c * 2) / (cren_count * 2)
		var t1 = float(c * 2 + 1) / (cren_count * 2)
		var c_p0 = p1.lerp(p2, t0)
		var c_p1 = p1.lerp(p2, t1)
		
		var c_bl = iso(c_p0.x, c_p0.y, base_h + height)
		var c_br = iso(c_p1.x, c_p1.y, base_h + height)
		var c_tr = iso(c_p1.x, c_p1.y, base_h + height + cren_h)
		var c_tl = iso(c_p0.x, c_p0.y, base_h + height + cren_h)
		
		draw_colored_polygon(PackedVector2Array([c_bl, c_br, c_tr, c_tl]), wall_color.lightened(0.08))
		draw_polyline(PackedVector2Array([c_bl, c_tl, c_tr, c_br]), STONE_STROKE, 1.0)


## 6/8 Kenarlı İzometrik Silindirik Kule Çizer (Gövde + Konsol + Mazgal + Konik Çatı)
func _draw_iso_tower(cx: float, cz: float, radius: float, base_h: float, height: float, has_roof: bool = true, roof_h: float = 16.0) -> void:
	var sides = 8
	var bot_pts: Array[Vector2] = []
	var top_pts: Array[Vector2] = []
	
	for i in range(sides):
		var angle = (TAU / sides) * i + (PI / 8.0)
		var tx = cx + radius * cos(angle)
		var tz = cz + radius * sin(angle)
		bot_pts.append(iso(tx, tz, base_h))
		top_pts.append(iso(tx, tz, base_h + height))

	# Ön tarafa bakan yüzeyleri gölgelerine göre çiz (i=0, 1, 2, 3)
	var colors = [STONE_DARK, STONE_DARK.lightened(0.15), STONE_MID, STONE_LIGHT, STONE_TOP]
	for i in range(sides / 2 + 1):
		var i0 = (i + 6) % sides
		var i1 = (i + 7) % sides
		var face = PackedVector2Array([
			bot_pts[i0], bot_pts[i1],
			top_pts[i1], top_pts[i0]
		])
		var col = colors[min(i, colors.size() - 1)]
		draw_colored_polygon(face, col)
		draw_line(top_pts[i0], bot_pts[i0], STONE_STROKE, 1.0)

	# Mazgal Altı Konsol Çıkıntısı (Cornice / Machicolations)
	var corbel_h = 3.0
	var corbel_rad = radius + 2.0
	var corbel_top_pts: Array[Vector2] = []
	for i in range(sides):
		var angle = (TAU / sides) * i + (PI / 8.0)
		var tx = cx + corbel_rad * cos(angle)
		var tz = cz + corbel_rad * sin(angle)
		corbel_top_pts.append(iso(tx, tz, base_h + height + corbel_h))

	for i in range(sides / 2 + 1):
		var i0 = (i + 6) % sides
		var i1 = (i + 7) % sides
		var c_face = PackedVector2Array([
			top_pts[i0], top_pts[i1],
			corbel_top_pts[i1], corbel_top_pts[i0]
		])
		draw_colored_polygon(c_face, colors[min(i, colors.size() - 1)].lightened(0.06))

	# Okçu Mazgal Penceresi (Slit Window)
	var win_center = iso(cx, cz + radius * 0.9, base_h + height * 0.5)
	draw_rect(Rect2(win_center.x - 1.5, win_center.y - 4.0, 3.0, 8.0), WINDOW_DARK)
	draw_rect(Rect2(win_center.x - 0.5, win_center.y - 2.0, 1.0, 4.0), WINDOW_GLOW)

	# Kule Üstü Konik Çatı
	if has_roof:
		var apex = iso(cx, cz, base_h + height + corbel_h + roof_h)
		var roof_base_h = base_h + height + corbel_h
		
		# Çatı fasetleri
		for i in range(sides / 2 + 1):
			var i0 = (i + 6) % sides
			var i1 = (i + 7) % sides
			var p0 = corbel_top_pts[i0]
			var p1 = corbel_top_pts[i1]
			
			var tri = PackedVector2Array([p0, p1, apex])
			var r_col = ROOF_MID
			if i <= 1:
				r_col = ROOF_DARK
			elif i >= 3:
				r_col = ROOF_LIGHT
				
			draw_colored_polygon(tri, r_col)
			draw_line(p0, apex, ROOF_DARK.darkened(0.3), 1.0)

		# Çatı Zirve Altın Başlığı (Finial)
		draw_circle(apex + Vector2(0, -1), 2.5, ROOF_RIM)
		draw_circle(apex + Vector2(0, -1), 1.2, Color.WHITE)


## Merkez Büyük Hisar / Donjon Çizer (Kare-Prizma Katmanlı Görkemli Kule)
func _draw_central_keep(cx: float, cz: float) -> void:
	var w = 15.0
	var d = 15.0
	var base_h = 7.0
	var h1 = 38.0
	
	# Kat 1: Ana Gövde Köşeleri
	var p_f = iso(cx, cz + d, base_h)         # Ön köşe
	var p_l = iso(cx - w, cz, base_h)         # Sol köşe
	var p_r = iso(cx + w, cz, base_h)         # Sağ köşe
	var p_b = iso(cx, cz - d, base_h)         # Arka köşe
	
	var p_f_top = iso(cx, cz + d, base_h + h1)
	var p_l_top = iso(cx - w, cz, base_h + h1)
	var p_r_top = iso(cx + w, cz, base_h + h1)
	var p_b_top = iso(cx, cz - d, base_h + h1)
	
	# Sol Işıklı Yüzey
	draw_colored_polygon(PackedVector2Array([p_l, p_f, p_f_top, p_l_top]), STONE_LIGHT)
	# Sağ Gölgeli Yüzey
	draw_colored_polygon(PackedVector2Array([p_f, p_r, p_r_top, p_f_top]), STONE_MID)
	
	# Köşe ayrım çizgisi
	draw_line(p_f, p_f_top, STONE_STROKE, 1.5)

	# Kat 1 Pencereleri (Kemeriyle birlikte)
	var win_l = iso(cx - w * 0.5, cz + d * 0.5, base_h + 20)
	var win_r = iso(cx + w * 0.5, cz + d * 0.5, base_h + 20)
	_draw_arched_window(win_l, 4.0, 7.0, false)
	_draw_arched_window(win_r, 4.0, 7.0, true)

	# Kat 2: Üst Çıkıntı ve Konsollar (Overhanging Battlement Tier)
	var w2 = 17.5
	var d2 = 17.5
	var h2 = 14.0
	var base_h2 = base_h + h1
	
	var c_f = iso(cx, cz + d2, base_h2)
	var c_l = iso(cx - w2, cz, base_h2)
	var c_r = iso(cx + w2, cz, base_h2)
	
	var c_f_top = iso(cx, cz + d2, base_h2 + h2)
	var c_l_top = iso(cx - w2, cz, base_h2 + h2)
	var c_r_top = iso(cx + w2, cz, base_h2 + h2)
	
	# Konsol çıkıntısı alt pahı
	draw_colored_polygon(PackedVector2Array([p_l_top, p_f_top, c_f, c_l]), STONE_LIGHT.darkened(0.1))
	draw_colored_polygon(PackedVector2Array([p_f_top, p_r_top, c_r, c_f]), STONE_DARK)
	
	# Üst kat dikey duvarları
	draw_colored_polygon(PackedVector2Array([c_l, c_f, c_f_top, c_l_top]), STONE_LIGHT.lightened(0.05))
	draw_colored_polygon(PackedVector2Array([c_f, c_r, c_r_top, c_f_top]), STONE_MID)
	draw_line(c_f, c_f_top, STONE_STROKE, 1.5)

	# Üst Kat Mazgalları
	_draw_keep_crenellations(c_l_top, c_f_top, STONE_LIGHT, 3)
	_draw_keep_crenellations(c_f_top, c_r_top, STONE_MID, 3)

	# Kat 3: Görkemli Piramidal / Konik Şato Çatısı
	var apex_h = base_h2 + h2 + 26.0
	var apex = iso(cx, cz, apex_h)
	
	# Sol Çatı Yüzeyi (Güneş alan aydınlık)
	draw_colored_polygon(PackedVector2Array([c_l_top, c_f_top, apex]), ROOF_LIGHT)
	# Sağ Çatı Yüzeyi (Gölgeli)
	draw_colored_polygon(PackedVector2Array([c_f_top, c_r_top, apex]), ROOF_MID)
	# Arka Sağ Çatı Yüzeyi (Derin gölge)
	var c_b_top = iso(cx, cz - d2, base_h2 + h2)
	draw_colored_polygon(PackedVector2Array([c_r_top, c_b_top, apex]), ROOF_DARK)
	
	# Çatı sırt çizgileri
	draw_line(c_f_top, apex, ROOF_DARK.darkened(0.2), 1.5)
	draw_line(c_l_top, apex, ROOF_LIGHT.lightened(0.2), 1.0)
	draw_line(c_r_top, apex, ROOF_DARK.darkened(0.2), 1.0)


## Kemerli Vitray / Gotik Pencere
func _draw_arched_window(pos: Vector2, width: float, height: float, is_shade: bool) -> void:
	var col = WINDOW_DARK
	var glow = WINDOW_GLOW if not is_shade else WINDOW_GLOW.darkened(0.3)
	draw_rect(Rect2(pos.x - width * 0.5, pos.y - height * 0.5, width, height), col)
	draw_circle(Vector2(pos.x, pos.y - height * 0.5), width * 0.5, col)
	# İç ışık parıltısı
	draw_rect(Rect2(pos.x - width * 0.25, pos.y - height * 0.25, width * 0.5, height * 0.6), glow)


## Başkule mazgal çıkıntıları
func _draw_keep_crenellations(p_start: Vector2, p_end: Vector2, color: Color, count: int) -> void:
	var cren_h = 3.5
	for i in range(count):
		var t0 = float(i * 2) / (count * 2)
		var t1 = float(i * 2 + 1) / (count * 2)
		var p0 = p_start.lerp(p_end, t0)
		var p1 = p_start.lerp(p_end, t1)
		
		var b0 = p0
		var b1 = p1
		var t_1 = p1 + Vector2(0, -cren_h)
		var t_0 = p0 + Vector2(0, -cren_h)
		
		draw_colored_polygon(PackedVector2Array([b0, b1, t_1, t_0]), color.lightened(0.08))
		draw_line(t_0, t_1, STONE_TOP, 1.0)


## Giriş Kapı Binası, Kemer ve Demir Parmaklık (Portcullis)
func _draw_gatehouse(cx: float, cz: float, width: float, base_h: float, height: float) -> void:
	var w2 = width * 0.5
	var d = 6.0
	
	var p_l = iso(cx - w2, cz, base_h)
	var p_r = iso(cx + w2, cz, base_h)
	var p_l_top = iso(cx - w2, cz, base_h + height)
	var p_r_top = iso(cx + w2, cz, base_h + height)
	
	# Kapı kulesi ön cephesi
	draw_colored_polygon(PackedVector2Array([p_l, p_r, p_r_top, p_l_top]), STONE_LIGHT.lightened(0.03))
	draw_line(p_l_top, p_r_top, STONE_TOP, 2.0)

	# Kapı Üstü Mazgalları
	_draw_keep_crenellations(p_l_top, p_r_top, STONE_LIGHT, 2)

	# Kemerli Ahşap Kapı Boşluğu
	var door_w = 9.0
	var door_h = 13.0
	var door_pos = iso(cx, cz + 0.5, base_h + 1.0)
	
	# Kemer arka derinliği
	draw_rect(Rect2(door_pos.x - door_w * 0.5, door_pos.y - door_h, door_w, door_h), Color.BLACK)
	draw_circle(Vector2(door_pos.x, door_pos.y - door_h), door_w * 0.5, Color.BLACK)

	# Ahşap Kapı Kanatları
	draw_rect(Rect2(door_pos.x - door_w * 0.45, door_pos.y - door_h * 0.9, door_w * 0.9, door_h * 0.9), WOOD_DARK)
	
	# Demir Parmaklık (Portcullis Izgara Çizgileri)
	var bar_count = 3
	for b in range(bar_count):
		var bx = door_pos.x - door_w * 0.3 + (b * (door_w * 0.3))
		draw_line(Vector2(bx, door_pos.y - door_h * 0.9), Vector2(bx, door_pos.y), IRON_COLOR, 1.5)
	draw_line(Vector2(door_pos.x - door_w * 0.45, door_pos.y - door_h * 0.5), Vector2(door_pos.x + door_w * 0.45, door_pos.y - door_h * 0.5), IRON_COLOR, 1.5)

	# Kapı Kemer Taşları Vurgusu (Arch Voussoirs)
	var arch_center = Vector2(door_pos.x, door_pos.y - door_h)
	draw_arc(arch_center, door_w * 0.55, -PI, 0.0, 8, STONE_TOP, 2.0)


## Rüzgarda Dalgalanan Krallık Bayrağı (Direk + Flama)
func _draw_royal_banner(cx: float, cz: float, mast_base_h: float) -> void:
	var mast_len = 16.0
	var mast_base = iso(cx, cz, mast_base_h)
	var mast_top = iso(cx, cz, mast_base_h + mast_len)
	
	# Ahşap/Demir Bayrak Direği
	draw_line(mast_base, mast_top, WOOD_DARK, 2.5)
	# Direk Altın Topu
	draw_circle(mast_top, 2.0, ROOF_RIM)

	# Rüzgar Simülasyonu ile Dalgalanan Üçgen / Kırlangıç Flama
	var flag_len = 18.0
	var flag_h = 9.0
	var wave_offset = sin(_time) * 2.5
	var wave_mid = sin(_time + 1.2) * 1.5
	
	var f_p0 = mast_top + Vector2(1.0, 1.0)
	var f_p1 = mast_top + Vector2(1.0, flag_h + 1.0)
	var f_mid_top = mast_top + Vector2(flag_len * 0.5, 2.0 + wave_mid)
	var f_mid_bot = mast_top + Vector2(flag_len * 0.5, flag_h * 0.8 + wave_mid)
	var f_tip = mast_top + Vector2(flag_len, (flag_h * 0.5) + wave_offset)

	var flag_poly = PackedVector2Array([
		f_p0, f_mid_top, f_tip, f_mid_bot, f_p1
	])
	
	# Bayrak Gövdesi
	draw_colored_polygon(flag_poly, FLAG_GOLD)
	
	# Bayrak Üzerinde Krallık Amblem Çizgisi (Kızıl Arma Çizgisi)
	var emblem_poly = PackedVector2Array([
		f_p0 + Vector2(2, 2),
		f_mid_top + Vector2(0, 1),
		f_tip + Vector2(-3, 0),
		f_mid_bot + Vector2(0, -1),
		f_p1 + Vector2(2, -2)
	])
	draw_colored_polygon(emblem_poly, FLAG_EMBLEM)
	
	# Bayrak kenar konturu
	var flag_outline = PackedVector2Array([f_p0, f_mid_top, f_tip, f_mid_bot, f_p1, f_p0])
	draw_polyline(flag_outline, FLAG_GOLD_SHADOW, 1.0)
