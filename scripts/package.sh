#!/usr/bin/env sh
# Build every platform and package each as a ready-to-run archive with checksums.
# Usage: VERSION=1.0.0 ./scripts/package.sh      (needs go, tar; zip for the Windows archives)
set -eu
cd "$(dirname "$0")/.."
VERSION="${VERSION:-dev}"
case "$VERSION" in ''|*[!A-Za-z0-9._-]*) echo "invalid release version" >&2; exit 1;; esac
mkdir -p dist
stage="$(mktemp -d ./dist/.package-XXXXXX)"
trap 'rm -rf "$stage"' EXIT HUP INT TERM
for t in windows/amd64 windows/arm64 linux/amd64 linux/arm64 darwin/amd64 darwin/arm64; do
  os="${t%/*}"; arch="${t#*/}"; name="zagent-$VERSION-$os-$arch"; bin=zagent
  [ "$os" = windows ] && bin=zagent.exe
  mkdir -p "$stage/$name"
  echo "building $t"
  CGO_ENABLED=0 GOOS="$os" GOARCH="$arch" go build -trimpath -ldflags "-s -w -X main.version=$VERSION" -o "$stage/$name/$bin" ./cmd/zagent
  for f in README.md CHANGELOG.md LICENSE; do [ -f "$f" ] && cp "$f" "$stage/$name/"; done
  cp -r docs examples "$stage/$name/"
  if [ "$os" = windows ]; then (cd "$stage" && zip -qr "../$name.zip" "$name"); else tar -czf "dist/$name.tar.gz" -C "$stage" "$name"; fi
done
(cd dist && if command -v sha256sum >/dev/null; then sha256sum zagent-* > SHA256SUMS.txt; else shasum -a 256 zagent-* > SHA256SUMS.txt; fi)
echo "packaged into $(pwd)/dist"
