// ==========================================
// 边缘发光特效 / 跑马灯
// ==========================================

// 该 Hook 直接使用 UIWindow/CALayer/UIColor/CABasicAnimation/dispatch/NSString 等类型，
// 需要在此处显式引入对应头文件，避免在 -Werror 下因声明缺失导致编译失败。
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <dispatch/dispatch.h>
#import <dispatch/time.h>
#import <math.h>

#import "AxsManager.h"

@interface SBCoverSheetWindow : UIWindow
@end

%group AxsVisualGlow
%hook SBCoverSheetWindow
- (void)setHidden:(BOOL)hidden {
    %orig;
    
    if (hidden || ![AxsManager sharedManager].isEnabled || ![AxsManager sharedManager].edgeGlowEnabled) {
        return;
    }
    
    // 注入动态 Layer 跑马灯
    CALayer *glowLayer = [CALayer layer];
    glowLayer.frame = self.bounds;
    glowLayer.borderWidth = 4.0;
    glowLayer.borderColor = [UIColor systemBlueColor].CGColor;
    glowLayer.cornerRadius = 35.0; // 圆角适配
    
    CABasicAnimation *pulse = [CABasicAnimation animationWithKeyPath:@"opacity"];
    pulse.duration = 1.5;
    pulse.fromValue = @(0.1);
    pulse.toValue = @(0.9);
    pulse.autoreverses = YES;
    pulse.repeatCount = HUGE_VALF;
    [glowLayer addAnimation:pulse forKey:@"axs_glow"];
    
    [self.layer addSublayer:glowLayer];
    
    // 定时清理，避免持续掉电
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [glowLayer removeFromSuperlayer];
    });
}
%end
%end

%ctor {
    NSString *bundleId = [[NSBundle mainBundle] bundleIdentifier];
    if ([bundleId isEqualToString:@"com.apple.springboard"]) {
        %init(AxsVisualGlow);
    }
}
