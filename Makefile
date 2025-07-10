SRC = $(shell find . \( -path ./engine/BUILD -o -path ./engine/DEBUG \) -prune -o -name '*.lua' -print) \
	$(shell find assets -type f)
DEBUG_SRC = $(shell find engine/DEBUG)

LOVE_WIN32_ZIP_URL = https://github.com/love2d/love/releases/download/11.3/love-11.3-win32.zip


petecataque.love: $(SRC)
	zip -r $@ $^

build/index.html: petecataque.love
	npx love.js $< $(@D) -t petecataque -c

petecataque-web.zip: build/index.html
	zip $@ build/*
