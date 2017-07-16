build: FORCE
	swift build && cp .build/debug/App ./app.cgi

release: FORCE
	swift build -c release && cp .build/release/App ./app.cgi

FORCE: