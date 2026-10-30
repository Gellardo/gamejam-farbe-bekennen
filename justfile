build:
	godot --headless --export-release "Web" "builds/web/index.html"

serve:
	cd builds/web && python3 -m http.server
