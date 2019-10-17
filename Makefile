build: update-linux-test-manifest
	@swift build -c release -Xswiftc -warnings-as-errors > /dev/null

test:
	@swift test -Xswiftc -warnings-as-errors

xcode:
	@swift package generate-xcodeproj

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

fetch-dependencies:
	@Scripts/fetch-dependencies.py

test-docker:
	@Scripts/ubuntu.sh TOMLDeserializer test 5.1.1 bionic

clean-carthage:
	@echo "Deleting Carthage artifacts…"
	@rm -rf Carthage
	@rm -rf TOMLDeserializer.framework.zip

carthage-archive: clean-carthage install-carthage
	@carthage build --archive

install-carthage: fetch-dependencies
	brew update
	brew outdated carthage || brew upgrade carthage

install-%: fetch-dependencies
	true

test-SwiftPM: test

install-CocoaPods:
	sudo gem install cocoapods -v 1.8.3

test-CocoaPods:
	pod lib lint --verbose

test-iOS:
	set -o pipefail && \
		xcodebuild \
		-workspace TOMLDeserializer.xcworkspace \
		-scheme TOMLDeserializer \
		-configuration Release \
		-destination "name=iPhone 11,OS=13.1" \
		test

test-macOS:
	set -o pipefail && \
		xcodebuild \
		-workspace TOMLDeserializer.xcworkspace \
		-scheme TOMLDeserializer \
		-configuration Release \
		test \

test-tvOS:
	set -o pipefail && \
		xcodebuild \
		-workspace TOMLDeserializer.xcworkspace \
		-scheme TOMLDeserializer \
		-configuration Release \
		-destination "platform=tvOS Simulator,name=Apple TV,OS=13.0" \
		test \

test-carthage:
	set -o pipefail && \
		carthage build \
		--no-skip-current \
		--configuration Release \
		--verbose
	ls Carthage/build/Mac/TOMLDeserializer.framework
	ls Carthage/build/iOS/TOMLDeserializer.framework
	ls Carthage/build/tvOS/TOMLDeserializer.framework
	ls Carthage/build/watchOS/TOMLDeserializer.framework

clean:
	rm -rf Dependencies/NetTime
