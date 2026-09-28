THEOS_PACKAGE_SCHEME = rootless
ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:15.0

DEBUG = 0
FINALPACKAGE = 1

include $(THEOS)/makefiles/common.mk

PACKAGE_NAME = org.cydia.kiimo.fastx
PACKAGE_VERSION = 1.5.1
PACKAGE_ARCH = iphoneos-arm64
PACKAGE_DEPENDS = firmware (>= 15.0), ellekit
PACKAGE_SECTION = Tweaks
PACKAGE_DESCRIPTION = FastX Rootless tweak and preferences for ElleKit-based jailbreaks

TWEAK_NAME = FastX
FastX_FILES = FastX/Tweak.xm
FastX_CFLAGS = -fobjc-arc
FastX_FRAMEWORKS = UIKit Foundation QuartzCore

BUNDLE_NAME = FastXPrefs
FastXPrefs_FILES = FastXPrefs/RootListController.m
FastXPrefs_INSTALL_PATH = /Library/PreferenceBundles
FastXPrefs_CFLAGS = -fobjc-arc
FastXPrefs_FRAMEWORKS = UIKit Foundation
FastXPrefs_PRIVATE_FRAMEWORKS = Preferences
FastXPrefs_RESOURCE_DIRS = FastXPrefs/Resources

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/bundle.mk

.PHONY: clean package
package::
	@echo "Rootless package output: ./packages/"
