#!/bin/bash

EXPECTED_OS=$1
EXPECTED_ARCH=$2
EXPECTED_RELEASE=$3

# how to run Arturo (e.g. for WASI builds: through a WebAssembly runtime)
ARTURO=${ARTURO:-arturo}

echo "Testing Arturo..."
$ARTURO -v
$ARTURO -e "print [{os:} sys\os]"
$ARTURO -e "print [{release:} sys\release]"
$ARTURO -e "print [{arch:} sys\cpu\arch]"

DETECTED_OS=$($ARTURO -e "print sys\os")
if [ "$DETECTED_OS" != "$EXPECTED_OS" ]; then
    echo "UNEXPECTED OS: Expected $EXPECTED_OS, got $DETECTED_OS"
    exit 1
fi

DETECTED_ARCH=$($ARTURO -e "print sys\cpu\arch")
if [ "$DETECTED_ARCH" != "$EXPECTED_ARCH" ]; then
    echo "UNEXPECTED ARCH: Expected $EXPECTED_ARCH, got $DETECTED_ARCH"
    exit 1
fi

DETECTED_RELEASE=$($ARTURO -e "print sys\release")
if [ "$DETECTED_RELEASE" != "$EXPECTED_RELEASE" ]; then
    echo "UNEXPECTED RELEASE: Expected $EXPECTED_RELEASE, got $DETECTED_RELEASE"
    exit 1
fi

DETECTED_TIME=$($ARTURO tests/timezone.art | tr -d '\r' | sed 's/[[:space:]]*$//')
if [ "$DETECTED_TIME" != "March 8 2009 7:30AM" ]; then
    echo "UNEXPECTED TIME (not on UTC?): Expected March 8 2009 7:30AM, got $DETECTED_TIME"
    exit 1
fi

echo "✓ All checks passed: $EXPECTED_OS / $EXPECTED_ARCH / $EXPECTED_RELEASE"