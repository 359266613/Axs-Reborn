#import "AxsManager.h"

@interface NCNotificationRequest : NSObject
@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, copy, readonly) NSString *message;
@end

// ==========================================
// 云顶天宫 / 海王通知拦截过滤
// ==========================================
%group AxsNotificationFilter
%hook NCNotificationDispatcher
- (void)postNotificationWithRequest:(NCNotificationRequest *)request {
    if ([AxsManager sharedManager].isEnabled && [AxsManager sharedManager].notificationFilterEnabled) {
        NSString *content = [NSString stringWithFormat:@"%@ %@", request.title ?: @"", request.message ?: @""];
        NSArray *blocked = [AxsManager sharedManager].blockedKeywords;
        
        BOOL isBlocked = NO;
        for (NSString *keyword in blocked) {
            NSString *cleanKw = [keyword stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if (cleanKw.length > 0 && [content containsString:cleanKw]) {
                isBlocked = YES;
                break;
            }
        }
        
        if (isBlocked) {
            NSLog(@"[AxsReborn] Blocked Notification due to keyword match: %@", content);
            
            // 产生震动反馈提示已拦截
            UIImpactFeedbackGenerator *feedback = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleHeavy];
            [feedback impactOccurred];
            
            return; // 拦截原生流，不调用 %orig
        }
    }
    %orig;
}
%end
%end

%ctor {
    NSString *bundleId = [[NSBundle mainBundle] bundleIdentifier];
    if ([bundleId isEqualToString:@"com.apple.springboard"]) {
        %init(AxsNotificationFilter);
    }
}
