# zengine / zagent build tasks. Needs Go (see go.mod for the version) and nothing else.
VERSION ?= $(shell git describe --tags --always --dirty 2>/dev/null || echo dev)
LDFLAGS := -s -w -X main.version=$(VERSION)
TARGETS := windows/amd64 windows/arm64 linux/amd64 linux/arm64 darwin/amd64 darwin/arm64

.PHONY: build test vet fmt check release clean

build:            ## build ./dist/zagent for this machine
	CGO_ENABLED=0 go build -trimpath -ldflags "$(LDFLAGS)" -o dist/zagent ./cmd/zagent

test:             ## run the unit tests
	go test ./...

vet:
	go vet ./...

fmt:
	gofmt -w cmd internal

check: fmt vet test   ## formatting, vet and tests

release:          ## cross-compile every supported target into ./dist
	@mkdir -p dist
	@for t in $(TARGETS); do \
	  os=$${t%/*}; arch=$${t#*/}; ext=""; [ $$os = windows ] && ext=".exe"; \
	  echo "building $$os/$$arch"; \
	  CGO_ENABLED=0 GOOS=$$os GOARCH=$$arch go build -trimpath -ldflags "$(LDFLAGS)" -o dist/zagent-$$os-$$arch$$ext ./cmd/zagent || exit 1; \
	done

clean:
	rm -rf dist
