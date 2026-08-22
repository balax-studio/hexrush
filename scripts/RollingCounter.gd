class_name RollingCounter
extends RefCounted

## Bilişsel Yük Azaltıcı Formatlayıcı ve Mekanik Sayaç Motoru (UI Polish)

## Büyük sayıları okunabilir kompakt metne dönüştürür (örn: 20375865 -> 20.3M)
static func format_compact(value: float) -> String:
	if value < 0.0:
		return "-" + format_compact(-value)
	
	if value < 1000.0:
		if value == floor(value):
			return str(int(value))
		return "%.1f" % value
	elif value < 1_000_000.0:
		return "%.1fK" % (value / 1_000.0)
	elif value < 1_000_000_000.0:
		return "%.1fM" % (value / 1_000_000.0)
	elif value < 1_000_000_000_000.0:
		return "%.1fB" % (value / 1_000_000_000.0)
	else:
		return "%.1fT" % (value / 1_000_000_000_000.0)

## Sayı artışlarında mekanik sayometre akışı (Tween ile yumuşak geçiş)
static func animate_label_counter(label: Label, from_val: float, to_val: float, duration: float = 0.35, prefix: String = "", suffix: String = "") -> void:
	if not is_instance_valid(label) or not label.is_inside_tree():
		return
	
	var tree := label.get_tree()
	if not tree:
		label.text = prefix + format_compact(to_val) + suffix
		return
		
	var tween := tree.create_tween()
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_method(
		func(curr: float):
			if is_instance_valid(label):
				label.text = prefix + format_compact(curr) + suffix,
		from_val,
		to_val,
		duration
	)
