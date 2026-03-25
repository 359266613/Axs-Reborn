#import "AxsManager.h"

// ==========================================
// 1. 电源键长按快速动作
// ==========================================
@interface SBLockHardwareButtonActions : NSObject
- (void)performLongPressAction;
@end

%group AxsPowerButton
%hook SBLockHardwareButtonActions
- (void)performLongPressAction {
    if ([AxsManager sharedManager].isEnabled && [AxsManager sharedManager].customPowerButtonEnabled) {
        NSLog(@"[AxsReborn] Custom Power Button Long Press Triggered");
        // [在这里实现点亮手电筒或者截图等快速动作]
        return; // 取消原本的 Siri 或关机界面
    }
    %orig;
}
%end
%end

// ==========================================
// 2. 音乐优先 (静音通知状态拦截)
// 挂钩 NCNotificationDispatcher 或 SBMediaController
// ==========================================
@interface SBMediaController : NSObject
+ (id)sharedInstance;
- (BOOL)isPlaying;
@end

%group AxsMusicPriority
%hook NCNotificationDispatcher
- (void)postNotificationWithRequest:(id)request {
    if ([AxsManager sharedManager].isEnabled && [AxsManager sharedManager].musicPriorityMute) {
        // 通过 runtime 检查 SBMediaController
        Class SMCClass = NSClassFromString(@"SBMediaController");
        if (SMCClass) {
            id mediaController = [SMCClass sharedInstance];
            if ([mediaController isPlaying]) {
                // 如果正在播放，将通知的 sound 和 alert 静音处理（只保留常亮显示）
                NSLog(@"[AxsReborn] Music Priority Mute Triggered for Notification");
                // TODO: 结合 NotificationRequest 深度修改 SoundType = None
            }
        }
    }
    %orig;
}
%end
%end

%ctor {
    NSString *bundleId = [[NSBundle mainBundle] bundleIdentifier];
    if ([bundleId isEqualToString:@"com.apple.springboard"]) {
        %init(AxsPowerButton);
        %init(AxsMusicPriority);
    }
}
