build:
	mkdir -p builds/web
	godot --headless --export-release "Web" "builds/web/index.html"

serve:
	cd builds/web && t=$(mktemp -d /tmp/cp.XXXXXX) && openssl req -x509 -newkey rsa:2048 -nodes -keyout $t/k.pem -out $t/c.pem -days 1 -subj "/CN=localhost" && python3 -m http.server --tls-cert $t/c.pem --tls-key $t/k.pem ; rm -rf $t

