#import "AxsManager.h"

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
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
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
