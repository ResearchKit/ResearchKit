#!/bin/bash
BASE=`pwd`
DEST=out
VERSION=2.5.0
BUILD="Release"
MACHO="Framework"

usage()
{
cat << EOF

usage: $0 [options]

This script builds Crony SDK for one or two Xcode versions

options:
   -h   Show this message
   -m	Mach-O Type. [Static | Dynamic | Framework | All]. Defaults to Framework
EOF
exit -1;
}

while getopts “hm:” OPTION
do
     case $OPTION in
       h)
             usage
             ;;      
       m)
             MACHO=$OPTARG
             ;;
     esac
done

rm -rf $DEST
rm -rf Build

mkdir -p $DEST

if ([[ -z "$EVAL" ]]); then
	ZIPNAME=Crony$MACHO.zip
else
	ZIPNAME=Crony$MACHO-Eval.zip
fi

BUILD_OPTIONS="-configuration $BUILD UFW_OPEN_BUILD_DIR=False clean build DEPLOYMENT_POSTPROCESSING=YES"

echo "Build Options: " $BUILD_OPTIONS

XCODE_VERSION=
setXcodeVersion() {
	XCODE_VERSION=`xcodebuild -version | sed "s/^.*Xcode \([^ ]*\).*/\1/"`
	XCODE_VERSION=(${XCODE_VERSION})
	echo "Building with Xcode version: $XCODE_VERSION"
}

doBuild() {
	echo $1, $2
	FOLDER_NAME=""
	if [ ! -z $4 ]; then
		FOLDER_NAME="-$4"
	fi
	# echo "Cleaning"
	# xcodebuild  -target $1 clean 

	rm -rf ./Build

	if [ "$2" == "iphonesimulator" ]; then
		BUILD_OPTIONS=$BUILD_OPTIONS -destination='generic/platform=iOS\ Simulator'
		echo $BUILD_OPTIONS
	fi

	GCC="$GCC_PREPROCESSOR_DEFINITIONS $EVAL $APPSTORE_BUILD"

	# GCC=${GCC##*( )}

	echo -e "Build Crony"
	echo -e "xcodebuild GCC_PREPROCESSOR_DEFINITIONS='$GCC' -target $1 -sdk $2 $BUILD_OPTIONS CONFIGURATION_BUILD_DIR=$BASE/Build/$3"

	xcodebuild -target $1 -sdk $2 $BUILD_OPTIONS GCC_PREPROCESSOR_DEFINITIONS="${GCC}" CONFIGURATION_BUILD_DIR=$BASE/Build/$3

	mkdir -p $DEST/$3

	if [[ "$MACHO" = "Framework" ]]; then
		mv Build/$3/Crony.framework $DEST/$3
	fi

	if [[ "$MACHO" = "Dynamic" ]]; then
		mv Build/$3/libCrony* $DEST/$3
		mkdir $DEST/$3/js
		mkdir $DEST/$3/resources
		cp Crony/Interceptor/BSCJSInterceptor.js $DEST/$3/js
		cp Crony/Resources/* $DEST/$3/resources
	fi
	rm -rf ./Build
}

if [[ -d "$PREV_XCODE_PATH" ]]; then
	sudo xcode-select -switch "$PREV_XCODE_PATH"

	setXcodeVersion

	doBuild "CronySim" iphonesimulator CronySim $XCODE_VERSION
	doBuild "Crony" iphoneos Crony $XCODE_VERSION
	# doBuild "CronySimDylib" iphonesimulator CronySim $XCODE_VERSION
	# doBuild "CronyDylib" iphoneos Crony $XCODE_VERSION
	sudo xcode-select -switch "$ORG_XCODE_PATH"
fi

if [[ -d "$XCODE_PATH" ]]; then
	sudo xcode-select -switch "$XCODE_PATH"
	setXcodeVersion

	doBuild "CronySim" iphonesimulator $XCODE_VERSION
	doBuild "Crony" iphoneos $XCODE_VERSION
	sudo xcode-select -switch "$ORG_XCODE_PATH"
else
	setXcodeVersion
	if [[ "$MACHO" = "Static" || "$MACHO" == "All" ]]; then
		doBuild "CronySim" iphonesimulator libCronySim.a
		doBuild "Crony" iphoneos libCrony.a
		xcodebuild -create-xcframework -library $DEST/Crony/libCronySim.a -library $DEST/Crony/libCrony.a -output $DEST/Crony/Crony.xcframework 
		rm -rf $DEST/Crony/libCronySim.a
		rm -rf $DEST/Crony/libCrony.a
	fi

	if [[ "$MACHO" = "Dynamic" || "$MACHO" == "All" ]]; then
		doBuild "CronySimDylib" iphonesimulator libCronySim.dylib
		doBuild "CronyDylib" iphoneos libCrony.dylib
	fi

	if [[ "$MACHO" = "Framework" || "$MACHO" == "All" ]]; then
		doBuild "CronyFramework" iphonesimulator CronySim
		doBuild "CronyFramework" iphoneos Crony
		echo "xcodebuild -create-xcframework -framework $DEST/CronySim/Crony.framework -framework $DEST/Crony/Crony.framework -output $DEST/Crony/Crony.xcframework "
		xcodebuild -create-xcframework -framework $DEST/CronySim/Crony.framework -framework $DEST/Crony/Crony.framework -output $DEST/Crony.xcframework 

		rm -rf $DEST/Crony
		rm -rf $DEST/CronySim

		mkdir $DEST/Crony
		mv $DEST/Crony.xcframework $DEST/Crony
		if [[ "$MACHO" = "Framework" ]]; then
			mkdir $DEST/Crony/headers
			mkdir $DEST/Crony/js
			mkdir $DEST/Crony/resources
			cp Crony/Interceptor/BSCJSInterceptor.js $DEST/Crony/js
			cp Crony/Resources/* $DEST/Crony/resources
			cp Crony/Sources/BSCrony.h $DEST/Crony/headers
		fi
	fi
fi

cp LICENSE $DEST
cp README.md $DEST
cp COPYRIGHT.TXT $DEST
cd $BASE

cd $DEST
touch VERSION-$VERSION
echo "Built with Xcode $XCODE_VERSION" >> VERSION-$VERSION
echo "Built on $(date)" >> VERSION-$VERSION

zip -r -y $ZIPNAME *

cd $BASE


