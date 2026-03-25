#import "AxsManager.h"

// ==========================================
// 灵动岛 (Aperture / Dynamic Island Injection)
// 注意：极度依赖 iOS 16.1+ SBSystemApertureViewController 的隐藏 API
// 此处仅进行核心注入框架实现
// ==========================================

@interface SBSystemApertureViewController : UIViewController
@end

%group AxsApertureGroup
%hook SBSystemApertureViewController
- (void)viewDidLoad {
    %orig;
    
    if (![AxsManager sharedManager].isEnabled || ![AxsManager sharedManager].customApertureEnabled) {
        return;
    }
    
    NSLog(@"[AxsReborn] Hooked SBSystemApertureViewController! Injecting O泡果奶/常驻气泡...");
    
    // 在真实场景中，开发者会要求对象遵守 <SAElement>，然后将其传给控制器注册
    // 例如：
    // id myCustomApertureObj = [[AxsApertureElement alloc] init];
    // [self.systemApertureController addElement:myCustomApertureObj];
}
%end
%end

%ctor {
    if (@available(iOS 16.0, *)) {
        NSString *bundleId = [[NSBundle mainBundle] bundleIdentifier];
        if ([bundleId isEqualToString:@"com.apple.springboard"]) {
            %init(AxsApertureGroup);
        }
    }
}
