# configuration parameter
MYSQL_JDBC_STRING=jdbc:mysql://192.168.59.103:49162/bww
MYSQL_USER=root
MYSQL_PASSWORD=lxit

default: help

## build the docker image
build-docker-image:
	docker build -t rpietzsch/bww-docker .

## Generate the initial mapping file based on the SQL data
mapping:
	docker run -it --rm -v `pwd`:/data rpietzsch/bww-docker:latest ./run.sh --mapping --user $(MYSQL_USER) --pass $(MYSQL_PASSWORD) --jdbc $(MYSQL_JDBC_STRING)

## Transform the SQL data to RDF
transform:
	docker run -it --rm -v `pwd`:/data rpietzsch/bww-docker:latest ./run.sh --transform --mapping-file bww-mapping.ttl

## Enrich the RDF data
enrich:
	docker run -it --rm -v `pwd`:/data rpietzsch/bww-docker:latest ./run.sh --enrich --rdf-file transformation.ttl

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