#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define AXS_PREFS_PATH @"/var/jb/var/mobile/Library/Preferences/com.axs.axsreborn.prefs.plist"
#define AXS_NOTIFY_CHANGED CFSTR("com.axs.axsreborn.prefs.changed")

@interface AxsManager : NSObject
+ (instancetype)sharedManager;

@property (nonatomic, assign) BOOL isEnabled;
@property (nonatomic, assign) BOOL hideIconLabels;
@property (nonatomic, strong) UIColor *customTintColor;
@property (nonatomic, assign) BOOL globalVibration;
@property (nonatomic, assign) BOOL rightHandLock;
@property (nonatomic, assign) BOOL musicPriorityMute;
@property (nonatomic, assign) BOOL customPowerButtonEnabled;
@property (nonatomic, assign) BOOL bottomGestureEnabled;
@property (nonatomic, assign) NSInteger bottomLeftAction;
@property (nonatomic, assign) BOOL edgeGlowEnabled;
@property (nonatomic, assign) BOOL videoWallpaperEnabled;
@property (nonatomic, assign) BOOL notificationFilterEnabled;
@property (nonatomic, strong) NSArray *blockedKeywords;
@property (nonatomic, assign) BOOL floatingWindowEnabled;
@property (nonatomic, assign) BOOL customApertureEnabled;

- (void)reloadPreferences;
@end
