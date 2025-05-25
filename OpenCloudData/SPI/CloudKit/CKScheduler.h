//
//  CKScheduler.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/22/25.
//

#import "OpenCloudData/SPI/CloudKit/CKSchedulerActivity.h"

NS_ASSUME_NONNULL_BEGIN

@interface CKScheduler : NSObject
+ (CKScheduler *)sharedScheduler;
- (void)registerActivityIdentifier:(NSString *)activityIdentifier handler:(void (^)(CKSchedulerActivity *activity, void (^completionHandler)(long long)))completionHandler;
@end

NS_ASSUME_NONNULL_END
