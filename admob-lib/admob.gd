extends Node

class_name AdMob, "res://admob-lib/icon.png"

# signals
signal banner_loaded
signal banner_failed_to_load(error_code)
signal interstitial_failed_to_load(error_code)
signal interstitial_loaded
signal interstitial_closed
signal rewarded_video_loaded
signal rewarded_video_closed
signal rewarded(currency, ammount)
signal rewarded_video_left_application
signal rewarded_video_failed_to_load(error_code)
signal rewarded_video_opened
signal rewarded_video_started
signal interstitial_requested

# properties
export var is_real:bool setget is_real_set
export var banner_on_top:bool = true
export var banner_id:String = "ca-app-pub-9443221640471166/9049742329"
export var interstitial_id:String = "ca-app-pub-9443221640471166/1781147462"
export var rewarded_id:String = "ca-app-pub-9443221640471166/2680609241"
export var child_directed:bool = false
export var is_personalized:bool = true
export(String, "G", "PG", "T", "MA") var max_ad_content_rate

# "private" properties
var _admob_singleton = null
var _is_interstitial_loaded:bool = false
var _is_rewarded_video_loaded:bool = false
var _is_banner_loaded: bool = false
var _pause_ads : bool = false


func _enter_tree():
	if not init():
		print("AdMob Java Singleton not found")

# setters
func is_real_set(new_val) -> void:
	is_real = new_val
# warning-ignore:return_value_discarded
	init()
	
func child_directed_set(new_val) -> void:
	child_directed = new_val
# warning-ignore:return_value_discarded
	init()

func is_personalized_set(new_val) -> void:
	is_personalized = new_val
# warning-ignore:return_value_discarded
	init()

func max_ad_content_rate_set(new_val) -> void:
	if new_val != "G" and new_val != "PG" \
		and new_val != "T" and new_val != "MA":
			
		max_ad_content_rate = "G"
		print("Invalid max_ad_content_rate, using 'G'")


# initialization
func init() -> bool:
	if(Engine.has_singleton("GodotAdMob")):
		_admob_singleton = Engine.get_singleton("GodotAdMob")
		_admob_singleton.initWithContentRating(
			is_real,
			get_instance_id(),
			child_directed,
			is_personalized,
			max_ad_content_rate
		)
		return true
	return false
	
# load

func load_banner() -> void:
	if _admob_singleton != null and not _pause_ads:
		_admob_singleton.loadBanner(banner_id, banner_on_top)
		print("Loading Banner")

func load_interstitial() -> void:
	if _admob_singleton != null and not _pause_ads:
		_admob_singleton.loadInterstitial(interstitial_id)
		print("Loading Interstitial")
		
func is_interstitial_loaded() -> bool:
	if _admob_singleton != null:
		return _is_interstitial_loaded
	return false
		
func load_rewarded_video() -> void:
	if _admob_singleton != null and not _pause_ads:
		_admob_singleton.loadRewardedVideo(rewarded_id)
		
func is_rewarded_video_loaded() -> bool:
	if _admob_singleton != null:
		return _is_rewarded_video_loaded
	return false

# show / hide

func show_banner() -> void:
	if _admob_singleton != null and _is_banner_loaded:
		_admob_singleton.showBanner()
		print("showing banner")
		
func hide_banner() -> void:
	if _admob_singleton != null:
		_admob_singleton.hideBanner()

func show_interstitial() -> void:
	if _admob_singleton != null and _is_interstitial_loaded:
		_admob_singleton.showInterstitial()
		print("showing Interstitial")
	else:
		emit_signal("interstitial_requested")
	
func show_rewarded_video() -> void:
	if _admob_singleton != null and _is_rewarded_video_loaded:
		_admob_singleton.showRewardedVideo()

# resize

func banner_resize() -> void:
	if _admob_singleton != null:
		_admob_singleton.resize()
		
# dimension
func get_banner_dimension() -> Vector2:
	if _admob_singleton != null:
		return Vector2(_admob_singleton.getBannerWidth(), _admob_singleton.getBannerHeight())
	return Vector2()

# callbacks

func _on_admob_ad_loaded() -> void:
	_is_banner_loaded = true
	print("banner loaded")
	emit_signal("banner_loaded")
	
func _on_admob_banner_failed_to_load(error_code:int) -> void:
	_is_banner_loaded = false
	emit_signal("banner_failed_to_load", error_code)
	print("banner failed to loaded ", error_code)
	
func _on_interstitial_failed_to_load(error_code:int) -> void:
	_is_interstitial_loaded = false
	print("interstitial failed to loaded ", error_code)
	emit_signal("interstitial_failed_to_load", error_code)

func _on_interstitial_loaded() -> void:
	_is_interstitial_loaded = true
	print("Interstitial loadedzz")
	emit_signal("interstitial_loaded")

func _on_interstitial_close() -> void:
	_is_interstitial_loaded = false
	emit_signal("interstitial_closed")

func _on_rewarded_video_ad_loaded() -> void:
	_is_rewarded_video_loaded = true
	emit_signal("rewarded_video_loaded")

func _on_rewarded_video_ad_closed() -> void:
	_is_rewarded_video_loaded = false
	emit_signal("rewarded_video_closed")

func _on_rewarded(currency:String, amount:int) -> void:
	emit_signal("rewarded", currency, amount)
	
func _on_rewarded_video_ad_left_application() -> void:
	emit_signal("rewarded_video_left_application")
	
func _on_rewarded_video_ad_failed_to_load(error_code:int) -> void:
	_is_rewarded_video_loaded = false
	emit_signal("rewarded_video_failed_to_load", error_code)
	
func _on_rewarded_video_ad_opened() -> void:
	emit_signal("rewarded_video_opened")
	
func _on_rewarded_video_started() -> void:
	emit_signal("rewarded_video_started")

