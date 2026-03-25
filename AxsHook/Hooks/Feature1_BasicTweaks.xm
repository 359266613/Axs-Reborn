#import "AxsManager.h"

// ==========================================
// 1. 桌面应用图标去名字/去文字
// ==========================================
@interface SBIconView : UIView
- (void)setIconLabelAlpha:(CGFloat)alpha;
@end

%group AxsIconLabels
%hook SBIconView
- (void)setIconLabelAlpha:(CGFloat)alpha {
    if ([AxsManager sharedManager].isEnabled && [AxsManager sharedManager].hideIconLabels) {
        %orig(0.0);
    } else {
        %orig;
    }
}
%end
%end

// ==========================================
// 2. 震动反馈 (UIControl 点击)
// ==========================================
%group AxsVibration
%hook UIControl
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if ([AxsManager sharedManager].isEnabled && [AxsManager sharedManager].globalVibration) {
        UIImpactFeedbackGenerator *fb = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight];
        [fb impactOccurred];
    }
    %orig;
}
%end
%end

// ==========================================
// 3. 自定义强调色 (Color View)
// ==========================================
%group AxsTintColor
%hook UIWindow
- (void)tintColorDidChange {
    %orig;
    UIColor *customTint = [AxsManager sharedManager].customTintColor;
    if ([AxsManager sharedManager].isEnabled && customTint) {
        if (![self.tintColor isEqual:customTint]) {
            self.tintColor = customTint;
        }
    }
}
%end
%end

// ==========================================
// 4. 右手横屏锁定限制
// ==========================================
%group AxsRotationLock
%hook UIViewController
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if ([AxsManager sharedManager].isEnabled && [AxsManager sharedManager].rightHandLock) {
        // 限制只能竖屏以及右侧横屏
        return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeRight;
    }
    return %orig;
}
%end
%end

%ctor {
    NSString *bundleId = [[NSBundle mainBundle] bundleIdentifier];
    if ([bundleId isEqualToString:@"com.apple.springboard"]) {
        %init(AxsIconLabels);
    }
    %init(AxsVibration);
    %init(AxsTintColor);
    %init(AxsRotationLock);
}
