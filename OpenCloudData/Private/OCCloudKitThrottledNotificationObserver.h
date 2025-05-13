//
//  OCCloudKitThrottledNotificationObserver.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/22/25.
//

#import <Foundation/Foundation.h>
#include <stdatomic.h>

NS_ASSUME_NONNULL_BEGIN

#warning TODO

@interface OCCloudKitThrottledNotificationObserver : NSObject {
    int _notificationIteration;// 0x8
    NSString *_assertionLabel; // 0x10
    NSString *_label; // 0x18
    @package NSInteger _notificationStalenessInterval; // 0x20
    void (^_notificationHandlerBlock)(NSString *label); // 0x28
}
- (instancetype)initWithLabel:(NSString *)label handlerBlock:(void (^)(NSString *label))handlerBlock;
@end

NS_ASSUME_NONNULL_END
