
BIN  := $(shell pwd)/node_modules/.bin
LOG  := $(shell pwd)/log

GLOBALS  := "__coverage__,_\$$jscoverage,buffertools,SlowBuffer,events,util,task"
TEST_ENV := test

# Project files definition
TEST_FILES := $(wildcard test/**/*.coffee) $(wildcard test/*.coffee)
SRC_FILES  := $(wildcard src/**/*.coffee) $(wildcard src/*.coffee)
LIB_FILES  := $(SRC_FILES:src/%.coffee=lib/%.js)
COV_FILES  := $(SRC_FILES:src/%.coffee=src-cov/%.js)

# Test parameters so we can configure these via make
TEST_TIMEOUT  = 100
TEST_REPORTER = list
TDD_REPORTER  = min

# Command-line tools options
MOCHA_OPTS      = --timeout $(TEST_TIMEOUT) \
                  --reporter $(TEST_REPORTER) \
                  --globals $(GLOBALS) \
                  --compilers coffee:coffee-script
SUPERVISOR_OPTS = -q -n exit -e 'coffee|litcoffee|js|node' \
                  -i '.git,node_modules,public,script,src-cov,html-report'
COFFEE_OPTS     = --bare --compile


default: node_modules all

all: $(LIB_FILES)

node_modules:
	npm install


# File transformations
lib: $(LIB_FILES)
lib/%.js: src/%.coffee | node_modules
	$(BIN)/coffee $(COFFEE_OPTS) --output $(@D) $?


# Testing
test: $(SRC_FILES) $(TEST_FILES) | node_modules
	NODE_ENV=$(TEST_ENV) $(BIN)/mocha $(MOCHA_OPTS) $(TEST_FILES)

tdd: TEST_REPORTER=$(TDD_REPORTER)
tdd:
	NODE_ENV=$(TEST_ENV) $(BIN)/supervisor $(SUPERVISOR_OPTS) \
	  -x $(BIN)/mocha -- $(MOCHA_OPTS) $(TEST_FILES)


# Code coverage
src-cov: src-cov/.timestamp
src-cov/.timestamp: $(SRC_FILES) | node_modules
	NODE_ENV=$(TEST_ENV) $(BIN)/coffeeCoverage ./src ./src-cov
	touch src-cov/.timestamp # trick regeneration of src-cov target

travis-cov: TEST_REPORTER=travis-cov
travis-cov: src-cov/.timestamp $(TEST_FILES)
	NODE_ENV=$(TEST_ENV) SCV_COVER=1 $(BIN)/mocha $(MOCHA_OPTS)

html-cov: coverage.html
coverage.html: TEST_REPORTER=html-cov
coverage.html: src-cov/.timestamp $(TEST_FILES)
	NODE_ENV=$(TEST_ENV) SCV_COVER=1 $(BIN)/mocha $(MOCHA_OPTS) | tee coverage.html

json-cov: coverage.json
coverage.json: TEST_REPORTER=json-cov
coverage.json: src-cov/.timestamp $(TEST_FILES)
	NODE_ENV=$(TEST_ENV) SCV_COVER=1 $(BIN)/mocha $(MOCHA_OPTS) | tee coverage.json


# Cleans
clean:
	-rm -Rf lib/
	-rm -Rf src-cov/
	-rm -Rf lib-cov/
	-rm -Rf html-report/
	-rm coverage.html
	-rm coverage.json

