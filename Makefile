.SUFFIXES:


LOCAL_PORT ?= 8080


.PHONY: usage
usage:
	@echo 'Usage: make build'


files/wayback.xml: files/wayback.xml.template
	#sed -e 's/{URL}/$(shell echo $(URL) | sed -e 's/[\/&]/\\&/g')/g' $< > $@
	cp $< $@


.PHONY: build
build: files/wayback.xml files/BDBCollection.xml Dockerfile
	docker build -t wayback .

.PHONY: run
run: data-dirs
	docker run -v `pwd`/data:/data -p 127.0.0.1:$(LOCAL_PORT):8080 wayback

.PHONY: data-dirs
data-dirs:
	@mkdir -p `pwd`/data/{warcs,indexes}

.PHONY: clean-indexes
clean-indexes:
	$(RM) -r data/indexes/*
