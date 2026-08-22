class_name EventBusSingleton
extends Node

## Küresel Olay Dağıtım Veri Yolu (Type-Safe Event Bus)
## Sahne bağımsız, tip güvenli sinyal yönetimi sağlar.

signal tile_clicked(hex_coords: Vector2i, biome_id: int, state_str: String)
signal tile_conquered(hex_coords: Vector2i, biome_id: int, zone_id: int)
signal resource_updated(resource_name: String, new_total: float, delta_amount: float)
signal castle_upgraded(new_level: int, title_name: String)
signal screen_shake_requested(intensity: float, duration: float)
signal theme_switched(is_dark_mode: bool)
