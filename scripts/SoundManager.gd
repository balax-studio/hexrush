class_name SoundManager
extends Node

## Prosedürel SFX Sentetizörü (AudioStreamGenerator).
## Harici ses dosyalarına ihtiyaç duymadan saf matematiksel dalgalarla
## sıfır gecikmeli, hafif ve zengin ses efektleri üretir.

var is_muted: bool = false
var sfx_volume: float = 0.8

var _player: AudioStreamPlayer
var _playback: AudioStreamGeneratorPlayback
var _sample_rate: float = 22050.0

func _ready() -> void:
	_player = AudioStreamPlayer.new()
	var gen = AudioStreamGenerator.new()
	gen.mix_rate = _sample_rate
	gen.buffer_length = 0.5
	_player.stream = gen
	add_child(_player)
	_player.play()
	_playback = _player.get_stream_playback()

## SFX Ses Düzeyi (0.0 - 1.0)
func set_volume(val: float) -> void:
	sfx_volume = clamp(val, 0.0, 1.0)

## Sessize Al / Aç
func set_muted(muted: bool) -> void:
	is_muted = muted

## Sentetize edilmiş dalgayı audio buffer'a basar
func _push_tone_sequence(notes: Array, total_duration: float, wave_type: String = "sine") -> void:
	if is_muted or sfx_volume <= 0.001 or not _playback:
		return
		
	var frames_count = int(_sample_rate * total_duration)
	var available = _playback.get_frames_available()
	var count_to_fill = min(frames_count, available)
	if count_to_fill <= 0:
		return
		
	var buffer = PackedVector2Array()
	buffer.resize(count_to_fill)
	
	var note_duration = total_duration / float(notes.size())
	var note_frames = int(_sample_rate * note_duration)
	
	var phase: float = 0.0
	for i in range(count_to_fill):
		var note_idx = min(int(i / float(note_frames)), notes.size() - 1)
		var freq: float = notes[note_idx]
		
		var t_in_note = fmod(float(i), float(note_frames)) / float(note_frames)
		# Üstel sönümleme (Exponential Decay Envelope)
		var envelope = exp(-t_in_note * 4.5)
		
		var sample: float = 0.0
		if freq > 10.0:
			var phase_inc = (freq * TAU) / _sample_rate
			phase = fmod(phase + phase_inc, TAU)
			
			if wave_type == "square":
				sample = 1.0 if phase < PI else -1.0
			elif wave_type == "triangle":
				sample = (phase / PI) - 1.0 if phase < PI else 3.0 - (phase / PI)
			else: # Sine
				sample = sin(phase)
		
		var final_val = sample * envelope * sfx_volume * 0.45
		buffer[i] = Vector2(final_val, final_val)
		
	_playback.push_buffer(buffer)

# =============================================================================
# SFX ÇALMA FONKSİYONLARI
# =============================================================================

## 1. Buton & Menü Tıklama
func play_click() -> void:
	_push_tone_sequence([880.0, 1320.0], 0.04, "sine")

## 2. Arsa Fethetme / Keşif
func play_tile_unlock() -> void:
	_push_tone_sequence([523.25, 659.25, 783.99], 0.16, "triangle")

## 3. Bina İnşa Etme (Çekiç / Tok Ses)
func play_build() -> void:
	_push_tone_sequence([220.0, 160.0, 110.0], 0.14, "square")

## 4. Kaynak Toplama / Hasat (Altın / Çan Tınısı)
func play_collect() -> void:
	_push_tone_sequence([987.77, 1318.51], 0.09, "sine")

## 5. Bina Seviyesi Yükseltme
func play_upgrade() -> void:
	_push_tone_sequence([440.0, 554.37, 659.25, 880.0], 0.22, "triangle")

## 6. Şato Kademesi Yükseltme
func play_castle_upgrade() -> void:
	_push_tone_sequence([523.25, 659.25, 783.99, 1046.50], 0.35, "triangle")

## 7. Kraliyet Prestij (Rebirth) Zafer Fanfarı
func play_prestige() -> void:
	_push_tone_sequence([523.25, 659.25, 783.99, 1046.50, 1318.51, 1567.98], 0.55, "triangle")

## 8. Hata / Yetersiz Kaynak
func play_error() -> void:
	_push_tone_sequence([180.0, 130.0], 0.12, "square")
