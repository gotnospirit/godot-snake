class_name Utils


static func IsMobile() -> bool:
	return OS.has_touchscreen_ui_hint()


static func GetScale() -> float:
	var dpi:int = OS.get_screen_dpi()

	if dpi > 120:
		return ceil(dpi / 120)

	return 1.0
