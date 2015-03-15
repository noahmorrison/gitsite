# site variables
port = 7505
exclude = Makefile $(shell find jade)
output_dir = ./site

# compilers
html_compiler = jade -P -O jade/options.json
css_compiler = stylus
js_compiler = babel

# extensions
html_ext = jade
css_ext = styl
js_ext = js

# files
all_files = $(filter-out $(exclude), \
              $(patsubst ./%, %, \
                $(shell find -L . -not -path "$(output_dir)/*" -type f)))

html_files = $(filter %.$(html_ext), $(all_files))
css_files = $(filter %.$(css_ext), $(all_files))
js_files = $(filter %.$(js_ext), $(all_files))
other_files = $(filter-out $(html_files), \
                $(filter-out $(css_files), \
                  $(filter-out $(js_files), \
                    $(all_files))))

html = $(html_files:%.$(html_ext)=site/%.html)
css = $(css_files:%.$(css_ext)=site/%.css)
js = $(js_files:%.$(js_ext)=site/%.js)
other = $(other_files:%=site/%)

# sub recipies
site/%.html: %.$(html_ext)
	@mkdir -p $(dir $@)
	$(html_compiler) $(@:site/%.html=%.$(html_ext)) -o $(dir $@)

site/%.css: %.$(css_ext)
	@mkdir -p $(dir $@)
	$(css_compiler) $(@:site/%.css=%.$(css_ext)) -o $(dir $@)

site/%.js: %.$(js_ext)
	@mkdir -p $(dir $@)
	$(js_compiler) $(@:site/%.$(js_ext)=%.js) -o $(dir $@)

site/%: %
	@mkdir -p $(dir $@)
	@cp $? $@
	@echo "-> $@"

# recipies
$(output_dir): $(html) $(css) $(js) $(other)

.PHONY: server
server: site
	static -p $(port) $(output_dir)

.PHONY: clean
clean:
	rm -r -f $(output_dir)
