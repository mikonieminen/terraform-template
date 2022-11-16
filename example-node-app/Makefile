COMMIT_HASH := $(shell git show -s --format='%h' HEAD)
COMMIT_TAG := $(shell git tag --points-at HEAD | head -n1)
COMMIT_DATE := $(shell git show -s --format='%cs' HEAD | tr -d '-')

RELEASE_ID := $(if $(COMMIT_TAG),$(COMMIT_TAG),$(COMMIT_DATE)-$(COMMIT_HASH))

GIT_HOOK_SOURCES := $(wildcard .git-hooks/*)

FORCE:

version-info: FORCE
	mkdir -p build
	git show -s --format="%H%d" HEAD > build/version-info

install-git-hooks: $(GIT_HOOK_SOURCES)
	ln -s -r -f $? .git/hooks/$(notdir $?)

create-dist-bundle: version-info
	tar -cf example-node-app-v$(RELEASE_ID).tgz build/version-info package.json yarn.lock index.js public/*
