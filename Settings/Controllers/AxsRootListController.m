#import "AxsRootListController.h"

// 工业级的 Preference 刷新，利用 Darwin Notification
#define AXS_NOTIFY_CHANGED CFSTR("com.axs.axsreborn.prefs.changed")

@implementation AxsRootListController

- (NSArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
    }
    return _specifiers;
}

- (void)setPreferenceValue:(id)value specifier:(id)specifier {
    [super setPreferenceValue:value specifier:specifier];
    // 发送系统级广播
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), AXS_NOTIFY_CHANGED, NULL, NULL, YES);
}

@end
