build: update-linux-test-manifest
	@swift build -c release -Xswiftc -warnings-as-errors > /dev/null

test:
	@swift test -Xswiftc -warnings-as-errors

xcode:
	@swift package generate-xcodeproj

update-linux-test-manifest:
	@rm Tests/TOMLDeserializerTests/XCTestManifests.swift
	@touch Tests/TOMLDeserializerTests/XCTestManifests.swift
	@swift test --generate-linuxmain

test-docker:
	@Scripts/run-tests-linux-docker.sh

develop-docker:
	@Scripts/develop-linux-docker.sh

install-%:
	true

test-SwiftPM: test

ensure-CocoaPods:
	pod repo update
	sudo gem install cocoapods -v 1.6.0

test-CocoaPods: ensure-CocoaPods
	pod lib lint --verbose
