#!/bin/sh

set -o pipefail && xcodebuild clean build test -workspace Podcasts.xcworkspace -scheme Podcasts -destination 'name=iPhone 11 Pro,OS=14.0' | xcpretty
