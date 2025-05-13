//
//  OCCloudKitThrottledNotificationObserver.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/22/25.
//

#import <OpenCloudData/OCCloudKitThrottledNotificationObserver.h>

@implementation OCCloudKitThrottledNotificationObserver

- (instancetype)initWithLabel:(NSString *)label handlerBlock:(void (^)(NSString * _Nonnull))handlerBlock {
    /*
     label = x21
     handlerBlock = x19
     */
    
    if (self = [super init]) {
        // self = x20
        _notificationStalenessInterval = 10;
        
        int zero = 0;
        __atomic_store(&_notificationIteration, &zero, __ATOMIC_RELEASE);
    }
    
    return self;
}

@end
