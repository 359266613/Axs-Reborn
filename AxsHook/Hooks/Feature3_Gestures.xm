#import "AxsManager.h"

// iOS 13+ 多 Scene 下 keyWindow 已弃用，改用 connectedScenes 获取窗口
static UIWindow *axs_keyWindow(void) {
    if (@available(iOS 13.0, *)) {
        UIApplication *app = [UIApplication sharedApplication];
        for (UIScene *scene in app.connectedScenes) {
            if (![scene isKindOfClass:[UIWindowScene class]]) continue;
            UIWindowScene *windowScene = (UIWindowScene *)scene;
            for (UIWindow *window in windowScene.windows) {
                if (window.isKeyWindow) return window;
            }
            // 兜底：返回该 scene 的第一个 window
            if (windowScene.windows.count > 0) return windowScene.windows.firstObject;
        }
        return nil;
    }

    // iOS < 13 兼容：keyWindow 仍可用，但在较新 SDK 下会触发弃用告警
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return [[UIApplication sharedApplication] keyWindow];
#pragma clang diagnostic pop
}

// ==========================================
// 上滑调度手势系统
// ==========================================
@interface SBSystemGestureManager : NSObject
@end

%group AxsGestures
%hook SBSystemGestureManager
- (void)addGestureRecognizer:(UIGestureRecognizer *)recognizer withType:(NSUInteger)type {
    %orig;
    
    if (![AxsManager sharedManager].isEnabled || ![AxsManager sharedManager].bottomGestureEnabled) {
        return;
    }

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIWindow *window = axs_keyWindow();
        if (window) {
            UIScreenEdgePanGestureRecognizer *edgePan = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(axs_handleBottomEdgePan:)];
            edgePan.edges = UIRectEdgeBottom;
            [window addGestureRecognizer:edgePan];
        }
    });
}

%new
- (void)axs_handleBottomEdgePan:(UIScreenEdgePanGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateRecognized) {
        CGPoint touchPoint = [gesture locationInView:gesture.view];
        CGFloat width = gesture.view.bounds.size.width;
        
        // 左边 1/3
        if (touchPoint.x < width / 3.0) {
            NSLog(@"[AxsReborn] Triggered Bottom Left Gesture Action: %ld", (long)[AxsManager sharedManager].bottomLeftAction);
        } else if (touchPoint.x < width * 2/3.0) {
            // 中间
            NSLog(@"[AxsReborn] Triggered Bottom Center Gesture Action");
        } else {
            // 右边
            NSLog(@"[AxsReborn] Triggered Bottom Right Gesture Action");
        }
    }
}
%end
%end

%ctor {
    NSString *bundleId = [[NSBundle mainBundle] bundleIdentifier];
    if ([bundleId isEqualToString:@"com.apple.springboard"]) {
        %init(AxsGestures);
    }
}
