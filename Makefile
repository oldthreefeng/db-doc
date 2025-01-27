LDFLAGS += -X "main.Buildstamp=$(shell date -u '+%Y-%m-%d %H:%M:%S %Z')"
LDFLAGS += -X "main.Githash=$(shell git rev-parse --short HEAD)"
LDFLAGS += -X "main.Goversion=$(shell go version)"
BRANCH := $(shell git symbolic-ref HEAD 2>/dev/null | cut -d"/" -f 3)
BUILD := $(shell git rev-parse --short HEAD)
NEWTAG := $(shell git describe --tags `git rev-list --tags --max-count=1`)
VERSION = $(NEWTAG)-$(BUILD)

BASEPATH := $(shell pwd)
CGO_ENABLED = 0
GOCMD = go
GOBUILD = $(GOCMD) build
GOTEST = $(GOCMD) test
GOMOD = $(GOCMD) mod
GOFILES = $(shell find . -name "*.go" -type f )

NAME := db-doc
DIRNAME := bin
SRCFILE= main.go
SOFTWARENAME=$(NAME)-$(VERSION)

PLATFORMS := windows darwin linux

.PHONY: fmt
fmt:
	@gofmt -s -w ${GOFILES}

.PHONY: test
test: deps
	$(GOTEST) -v ./...

.PHONY: deps
deps:
	$(GOMOD) tidy
	$(GOMOD) download

.PHONY: release
release: windows darwin linux

BUILDDIR:=$(BASEPATH)/build

.PHONY:Asset
Asset:
	@[ -d $(BUILDDIR) ] || mkdir -p $(BUILDDIR)
	@[ -d $(DIRNAME) ] || mkdir -p $(DIRNAME)

.PHONY: $(PLATFORMS)
$(PLATFORMS): Asset deps
	@echo "编译" $@
	GOOS=$@ GOARCH=amd64 CGO_ENABLED=0 GO111MODULE=on GOPROXY=https://goproxy.cn $(GOBUILD) -ldflags '$(LDFLAGS)'  -o $(NAME) $(SRCFILE)
	cp -f $(NAME) $(DIRNAME)
	tar czvf $(BUILDDIR)/$(SOFTWARENAME)-$@-amd64.tar.gz $(DIRNAME)

.PHONY: clean
clean:
	-rm -rf $(NAME)
	-rm -rf $(DIRNAME)
	-rm -rf $(BUILDDIR)

.PHONY: push
push: clean
	-git push origin master
