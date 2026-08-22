class_name BuildingData
extends Resource

## Bina ve üretim tesisi veri modeli.
## Üstel maliyet büyüme katsayısını ve geçerli reçeteleri barındırır.

@export var building_name: String = ""
@export var base_cost: float = 100.0
@export var cost_growth_factor: float = 1.15 # Tier 1: 1.07-1.12, Tier 2: 1.15, Tier 3: 1.18
@export var tier: int = 1
@export var available_recipes: Array[RecipeData] = []

func _init(_name: String = "", _cost: float = 100.0, _growth: float = 1.15, _tier: int = 1, _recipes: Array[RecipeData] = []) -> void:
	building_name = _name
	base_cost = _cost
	cost_growth_factor = _growth
	tier = _tier
	available_recipes = _recipes
