
BIN := $(shell pwd)/node_modules/.bin
LOG := $(shell pwd)/log

GLOBALS := __coverage__,buffertools,SlowBuffer,events,util,task
TEST_ENV := test

# Project files definition
TEST_FILES := $(wildcard test/**/*.coffee) $(wildcard test/*.coffee)
SRC_FILES := $(wildcard src/**/*.coffee)
LIB_FILES := $(SRC_FILES:src/%.coffee=lib/%.js)
COV_FILES := $(LIB_FILES:lib/%.js=lib-cov/%.js)

INDEX_FILE = index.js

# Test parameters so we can configure these via make
TEST_TIMEOUT = 100
TEST_REPORTER = list
TDD_REPORTER = min
COVER_REPORTER = mocha-istanbul

# Command-line tools options
MOCHA_OPTS = --timeout $(TEST_TIMEOUT) --reporter $(TEST_REPORTER) --globals $(GLOBALS) --compilers coffee:coffee-script
MOCHA_TDD_OPTS = $(MOCHA_OPTS) --watch --reporter $(TDD_REPORTER)
MOCHA_COVER_OPTS = $(MOCHA_OPTS) --reporter $(COVER_REPORTER)
COFFEE_OPTS = --bare --compile
ISTANBUL_OPTS = instrument --variable global.__coverage__ --no-compact
PLATO_OPTS = -d html-report/


default: node_modules all

node_modules:
	npm install


# File transformations
lib/%.js: node_modules src/%.coffee
	$(BIN)/coffee $(COFFEE_OPTS) --output $(@D) $<

lib-cov/%.js: node_modules lib/%.js
	@mkdir -p $(@D)
	$(BIN)/istanbul $(ISTANBUL_OPTS) --output $@ $<

all: $(LIB_FILES)


# Testing
test: node_modules
	NODE_ENV=$(TEST_ENV) $(BIN)/mocha $(MOCHA_OPTS) $(TEST_FILES)
tdd: node_modules
	NODE_ENV=$(TEST_ENV) $(BIN)/mocha $(MOCHA_TDD_OPTS) $(TEST_FILES)


# Code instrumentation
instrument: $(COV_FILES)

cover: instrument
	NODE_ENV=$(TEST_ENV) COVER=1 $(BIN)/mocha $(MOCHA_COVER_OPTS) $(TEST_FILES)

complex: all
	$(BIN)/plato $(PLATO_OPTS) $(LIB_FILES)


# Cleans
clean:
	-rm -Rf lib/
	-rm -Rf lib-cov/
	-rm -Rf html-report/


.PHONY: debug default all test tdd clean instrument cover complex

