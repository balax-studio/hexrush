class_name ItemData
extends Resource

## Eşya ve hammadde veri modeli.
## Tier 1: Hammadde (Gıda, Odun)
## Tier 2: İşlenmiş (Un, Kereste)
## Tier 3: Karmaşık (Ekmek, Mobilya)

@export var item_id: String = ""
@export var display_name: String = ""
@export var icon_symbol: String = "📦"
@export var base_value: float = 1.0
@export var tier: int = 1 # 1: Hammadde, 2: İşlenmiş, 3: Karmaşık

func _init(_id: String = "", _name: String = "", _icon: String = "📦", _val: float = 1.0, _tier: int = 1) -> void:
	item_id = _id
	display_name = _name
	icon_symbol = _icon
	base_value = _val
	tier = _tier
