#import "AxsManager.h"

@implementation AxsManager

+ (instancetype)sharedManager {
    static AxsManager *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

- (instancetype)init {
    if (self = [super init]) {
        [self reloadPreferences];
        
        // Listen to CFNotification
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)AxsPrefsReloadCallback, AXS_NOTIFY_CHANGED, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
    }
    return self;
}

- (void)reloadPreferences {
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:AXS_PREFS_PATH];
    if (!prefs) prefs = @{};
    
    self.isEnabled = prefs[@"isEnabled"] ? [prefs[@"isEnabled"] boolValue] : YES;
    self.hideIconLabels = [prefs[@"hideIconLabels"] boolValue];
    
    NSInteger tintIndex = [prefs[@"tintColorIndex"] integerValue];
    switch (tintIndex) {
        case 1: self.customTintColor = [UIColor systemBlueColor]; break;
        case 2: self.customTintColor = [UIColor systemOrangeColor]; break;
        case 3: self.customTintColor = [UIColor systemPinkColor]; break;
        default: self.customTintColor = nil; break;
    }
    
    self.globalVibration = [prefs[@"globalVibration"] boolValue];
    self.rightHandLock = [prefs[@"rightHandLock"] boolValue];
    self.musicPriorityMute = [prefs[@"musicPriorityMute"] boolValue];
    self.customPowerButtonEnabled = [prefs[@"customPowerButtonEnabled"] boolValue];
    self.bottomGestureEnabled = [prefs[@"bottomGestureEnabled"] boolValue];
    self.bottomLeftAction = [prefs[@"bottomLeftAction"] integerValue];
    self.edgeGlowEnabled = [prefs[@"edgeGlowEnabled"] boolValue];
    self.videoWallpaperEnabled = [prefs[@"videoWallpaperEnabled"] boolValue];
    self.notificationFilterEnabled = [prefs[@"notificationFilterEnabled"] boolValue];
    
    NSString *kw = prefs[@"blockedKeywords"];
    self.blockedKeywords = kw ? [kw componentsSeparatedByString:@","] : @[];
    
    self.floatingWindowEnabled = [prefs[@"floatingWindowEnabled"] boolValue];
    self.customApertureEnabled = [prefs[@"customApertureEnabled"] boolValue];
    
    NSLog(@"[AxsReborn] Settings reloaded. Enabled = %d", self.isEnabled);
}

static void AxsPrefsReloadCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    [[AxsManager sharedManager] reloadPreferences];
}

@end
