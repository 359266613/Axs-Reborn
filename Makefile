export TARGET = iphone:clang:latest:15.0
export ARCHS = arm64 arm64e
export SYSROOT = $(THEOS)/sdks/iPhoneOS14.5.sdk
THEOS_PACKAGE_SCHEME = rootless

include $(THEOS)/makefiles/common.mk

SUBPROJECTS += AxsHook
SUBPROJECTS += Settings

include $(THEOS_MAKE_PATH)/aggregate.mk
