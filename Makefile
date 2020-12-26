build: update-linux-test-manifest
	@swift build -c release -Xswiftc -warnings-as-errors > /dev/null

test:
	@swift test -Xswiftc -warnings-as-errors --enable-test-discovery

update-linux-test-manifest:
ifeq ($(shell uname),Darwin)
	@rm Tests/TOMLDeserializerTests/XCTestManifests.swift
	@touch Tests/TOMLDeserializerTests/XCTestManifests.swift
	@swift test --generate-linuxmain
else
	@echo "Only works on macOS"
endif

test-codegen: update-linux-test-manifest
	@git diff --exit-code

test-docker:
	@Scripts/ubuntu.sh TOMLDeserializer test 5.3.2 bionic

install-%:
	true

test-SwiftPM: test
