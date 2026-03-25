include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AxsHook

AxsHook_FILES = Sources/AxsManager.m \
                Hooks/Feature1_BasicTweaks.xm \
                Hooks/Feature2_PowerAndAudio.xm \
                Hooks/Feature3_Gestures.xm \
                Hooks/Feature4_VisualEffects.xm \
                Hooks/Feature5_NotificationFilter.xm \
                Hooks/Feature6_FloatingWindow.xm \
                Hooks/Feature7_Aperture.xm \
                Hooks/Feature8_QuickSwitch.xm

AxsHook_FRAMEWORKS = UIKit Foundation CoreGraphics QuartzCore
AxsHook_CFLAGS = -fobjc-arc -IHeaders

include $(THEOS_MAKE_PATH)/tweak.mk
