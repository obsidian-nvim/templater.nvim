MINITEST = deps/mini.test

.PHONY: test
test: $(MINITEST)
	nvim --headless --noplugin -u ./scripts/minimal_init.lua -c "lua MiniTest.run()"

$(MINITEST):
	mkdir -p deps
	git clone --filter=blob:none https://github.com/echasnovski/mini.test $(MINITEST)

