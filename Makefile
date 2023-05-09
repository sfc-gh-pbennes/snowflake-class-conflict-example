# Disable builtin rules and suffixes to improve debugging mode logging
MAKEFLAGS += --no-builtin-rules
.SUFFIXES:

# Assumes coursier (cs) installed
# https://get-coursier.io/docs/cli-installation


snowflake-jdbc-first.log: pom.xml
	mvn -P jdbc-first clean verify &> snowflake-jdbc-first.log

snowflake-ingest-sdk-first.log: pom.xml
	mvn -P ingest-sdk-first clean verify &> snowflake-ingest-sdk-first.log

BCPKIX_164 := $(shell cs fetch org.bouncycastle:bcpkix-jdk15on:1.64 | grep bcpkix)
BCPROV_164 := $(shell cs fetch org.bouncycastle:bcprov-jdk15on:1.64)
BCPKIX_170 := $(shell cs fetch org.bouncycastle:bcpkix-jdk15on:1.70 | grep bcpkix)
BCPROV_170 := $(shell cs fetch org.bouncycastle:bcprov-jdk15on:1.70)

japicmp.bcpkix.164.170.log: $(BCPKIX_164) $(BCPKIX_170)
	cs launch com.github.siom79.japicmp:japicmp:0.17.2 -M japicmp.JApiCmp -- \
	--ignore-missing-classes \
    --only-modified \
    --old $(BCPKIX_164) \
    --new $(BCPKIX_170) &> japicmp.bcpkix.164.170.log

japicmp.bcprov.164.170.log: $(BCPROV_164) $(BCPROV_170)
	cs launch com.github.siom79.japicmp:japicmp:0.17.2 -M japicmp.JApiCmp -- \
	--ignore-missing-classes \
    --only-modified \
    --old $(BCPROV_164) \
    --new $(BCPROV_170) &> japicmp.bcprov.164.170.log

.PHONY: bcpkix_increment
bcpkix_increment: $(BCPKIX_164) $(BCPKIX_170)
	cs launch com.github.siom79.japicmp:japicmp:0.17.2 -M japicmp.JApiCmp -- \
	--semantic-versioning \
	--ignore-missing-classes \
    --only-modified \
    --old $(BCPKIX_164) \
    --new $(BCPKIX_170)

.PHONY: bcprov_increment
bcprov_increment: $(BCPROV_164) $(BCPROV_170)
	cs launch com.github.siom79.japicmp:japicmp:0.17.2 -M japicmp.JApiCmp -- \
	--semantic-versioning \
	--ignore-missing-classes \
    --only-modified \
    --old $(BCPROV_164) \
    --new $(BCPROV_170)

.PHONY: clean
clean:
	rm -f japicmp.bcpkix.164.170.log japicmp.bcprov.164.170.log snowflake-jdbc-first.log snowflake-ingest-sdk-first.log
