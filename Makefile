
PATH := ./node_modules/.bin:${PATH}
BUILD = build

CS_SRC = $(wildcard *.coffee) $(wildcard test/*.coffee)
JS_SRC = $(wildcard *.js)
JS_OUT = $(addprefix $(BUILD)/, $(CS_SRC:.coffee=.js) $(JS_SRC) parse-regex.js)

.PHONY: build
build: $(JS_OUT)

$(BUILD)/%.js: %.coffee
	@mkdir -p $(dir $@) 
	coffee -c --map -o $(dir $@) $<

$(BUILD)/parse-regex.js: parse-regex.pegjs
	pegjs --cache --allowed-start-rules start $< $@

$(BUILD)/%.js: %.js
	cp %< $@

.PHONY: test
test: $(JS_OUT)
	mocha build/test --require build/test/_support.js

.PHONY: clean
clean:
	rm -r build
