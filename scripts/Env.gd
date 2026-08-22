class_name Env
extends RefCounted

## Godot 4 için .env Çevre Değişkenleri Okuyucu (DotEnv Loader).
## Proje kökündeki .env dosyasını satır satır ayrıştırır ve OS/uygulama ortamına yükler.

static var _loaded_vars: Dictionary = {}

## .env dosyasını okur ve yükler
static func load_env(path: String = "res://.env") -> bool:
	if not FileAccess.file_exists(path):
		return false
		
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		return false
		
	while not file.eof_reached():
		var line = file.get_line().strip_edges()
		if line.is_empty() or line.begins_with("#"):
			continue
			
		if line.begins_with("export "):
			line = line.substr(7).strip_edges()
			
		var eq_idx = line.find("=")
		if eq_idx != -1:
			var key = line.substr(0, eq_idx).strip_edges()
			var val = line.substr(eq_idx + 1).strip_edges()
			
			# Tırnakları temizle
			if (val.begins_with("\"") and val.ends_with("\"")) or (val.begins_with("'") and val.ends_with("'")):
				val = val.substr(1, val.length() - 2)
				
			# Satır içi yorumları ayıkla
			var comment_idx = val.find(" #")
			if comment_idx != -1:
				val = val.substr(0, comment_idx).strip_edges()
				
			_loaded_vars[key] = val
			OS.set_environment(key, val)
			
	file.close()
	return true

## Belirtilen anahtarın değerini döndürür
static func get_var(key: String, default_value: String = "") -> String:
	if _loaded_vars.has(key):
		return _loaded_vars[key]
	var os_val = OS.get_environment(key)
	if not os_val.is_empty():
		return os_val
	return default_value
