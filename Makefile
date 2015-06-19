## Generate the initial mapping file based on the SQL data
mapping:
	docker run -it --rm -v `pwd`:/data testing ./run.sh --mapping --user root --pass lxit --jdbc jdbc:mysql://192.168.59.103:49162/bww

## Transform the SQL data to RDF
transform:
	docker run -it --rm -v `pwd`:/data testing ./run.sh --transform --mapping-file bww-mapping.ttl

## Enrich the RDF data
enrich:
	docker run -it --rm -v `pwd`:/data testing ./run.sh --enrich --rdf-file transformation.ttl

## This help screen
help:
	printf "Available targets\n\n"
	awk '/^[a-zA-Z\-\_0-9]+:/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
			helpCommand = substr($$1, 0, index($$1, ":")-1); \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			printf "%-15s %s\n", helpCommand, helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)