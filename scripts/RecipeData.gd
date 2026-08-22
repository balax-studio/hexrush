class_name RecipeData
extends Resource

## Üretim reçetesi veri modeli.
## Girdi ve çıktı bağımlılıklarını tip güvenli olarak yönetir.

@export var recipe_name: String = ""
@export var inputs: Array[ItemData] = []
@export var input_amounts: Array[int] = []
@export var output_item: ItemData = null
@export var output_amount: int = 1
@export var production_time: float = 2.0 # Saniye cinsinden temel üretim süresi

func _init(_name: String = "", _inputs: Array[ItemData] = [], _amounts: Array[int] = [], _out: ItemData = null, _out_amt: int = 1, _time: float = 2.0) -> void:
	recipe_name = _name
	inputs = _inputs
	input_amounts = _amounts
	output_item = _out
	output_amount = _out_amt
	production_time = _time
