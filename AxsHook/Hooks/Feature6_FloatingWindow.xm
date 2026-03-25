#import "AxsManager.h"

// ==========================================
// 经典悬浮图标 (Assistive Touch / Draggable Window)
// ==========================================

@interface AxsFloatingWindow : UIWindow
@end

@implementation AxsFloatingWindow

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.windowLevel = UIWindowLevelStatusBar + 1000;
        self.clipsToBounds = YES;
        self.layer.cornerRadius = frame.size.width / 2.0;
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
        
        // 发牌手图标
        UIImageView *icon = [[UIImageView alloc] initWithFrame:self.bounds];
        icon.image = [UIImage systemImageNamed:@"square.grid.2x2.fill"]; // 此处需要 iOS 13+ Symbol 支持
        icon.tintColor = [UIColor whiteColor];
        icon.contentMode = UIViewContentModeCenter;
        [self addSubview:icon];
        
        // 拖拽
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [self addGestureRecognizer:pan];
        
        // 单击
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)handlePan:(UIPanGestureRecognizer *)pan {
    CGPoint translation = [pan translationInView:self.superview];
    self.center = CGPointMake(self.center.x + translation.x, self.center.y + translation.y);
    [pan setTranslation:CGPointZero inView:self.superview];
    
    if (pan.state == UIGestureRecognizerStateEnded) {
        // 吸附屏幕边缘算法
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat targetX = (self.center.x > screenWidth / 2.0) ? (screenWidth - self.bounds.size.width/2.0 - 5) : (self.bounds.size.width/2.0 + 5);
        
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.center = CGPointMake(targetX, self.center.y);
            self.alpha = 0.5;
        } completion:nil];
    } else if (pan.state == UIGestureRecognizerStateBegan) {
        self.alpha = 1.0;
    }
}

- (void)handleTap:(UITapGestureRecognizer *)tap {
    NSLog(@"[AxsReborn] Floating Window Tapped!");
    UIImpactFeedbackGenerator *fb = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
    [fb impactOccurred];
    
    // TODO: 实现展开二级菜单或者极简模式触发
}

@end

%group AxsFloatingWindowGroup
%hook SpringBoard
- (void)applicationDidFinishLaunching:(id)application {
    %orig;
    if ([AxsManager sharedManager].isEnabled && [AxsManager sharedManager].floatingWindowEnabled) {
        static AxsFloatingWindow *floatingWindow = nil;
        if (!floatingWindow) {
            floatingWindow = [[AxsFloatingWindow alloc] initWithFrame:CGRectMake(20, 200, 56, 56)];
            floatingWindow.hidden = NO;
        }
    }
}
%end
%end

%ctor {
    NSString *bundleId = [[NSBundle mainBundle] bundleIdentifier];
    if ([bundleId isEqualToString:@"com.apple.springboard"]) {
        %init(AxsFloatingWindowGroup);
    }
}
