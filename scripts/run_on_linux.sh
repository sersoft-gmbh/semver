#!/bin/sh

if [ "$#" -ne "1" ]; then
	echo "Missing argument [script_command]"
	exit 1
fi

if [ -z "$SWIFT_VERSION" ]; then
	echo "Missing environment variable SWIFT_VERSION!"
	exit 1
fi

SCRIPT_COMMAND="$1"
CONTAINER_TAG="swift:$SWIFT_VERSION"
VOLUME_SRC="$(pwd)"
VOLUME_TARGET="/$(basename "$VOLUME_SRC")"

docker run \
	--mount src="$VOLUME_SRC",target="$VOLUME_TARGET",type=bind \
	--rm \
	"$CONTAINER_TAG" \
	bash -c "cd $VOLUME_TARGET && $SCRIPT_COMMAND"
