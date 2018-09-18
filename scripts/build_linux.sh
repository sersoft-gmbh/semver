#!/bin/sh

if [ "$#" -ne "2" ]; then
	echo "Missing arguments [swift_version] and [script_command]"
	exit 1
fi

SWIFT_VERSION="$1"
SCRIPT_COMMAND="$2"
CONTAINER_TAG="swift:$SWIFT_VERSION"
VOLUME_SRC="$(pwd)"
VOLUME_TARGET="/$(basename "$VOLUME_SRC")"

docker run \
	--mount src="$VOLUME_SRC",target="$VOLUME_TARGET",type=bind \
	--rm \
	"$CONTAINER_TAG" \
	bash -c "cd $VOLUME_TARGET && $SCRIPT_COMMAND"
