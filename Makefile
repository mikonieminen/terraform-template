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

check-terraform:
	$(if $(shell which terraform),,$(error "No 'terraform' in PATH, consider installing terraform"))

check-aws-cli:
	$(if $(shell which aws),,$(error "No 'aws' in PATH, consider installing aws cli tools"))

check-aws-session-variable:
ifeq ($(AWS_SESSION_TOKEN),)
	$(error "AWS session not configured, consider running 'eval $$(./get-aws-session-token.sh)'")
endif

check-aws-session-validity:
	$(if $(shell aws sts get-caller-identity),,$(error "Failed to check AWS identity, maybe the session is expired, consider running 'eval $$(./get-aws-session-token.sh)' again"))

check-aws-session: check-aws-cli check-aws-session-variable check-aws-session-validity

show-infra: check-terraform check-aws-session
	terraform -chdir=terraform/infrastructure output
