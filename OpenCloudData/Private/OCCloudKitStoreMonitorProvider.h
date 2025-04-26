//
//  OCCloudKitStoreMonitorProvider.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/22/25.
//

#import <OpenCloudData/NSSQLCore.h>
#import <OpenCloudData/OCCloudKitStoreMonitor.h>

NS_ASSUME_NONNULL_BEGIN

#warning TODO

@interface OCCloudKitStoreMonitorProvider : NSObject
- (OCCloudKitStoreMonitor *)createMonitorForObservedStore:(NSSQLCore *)observedStore inTransactionWithLabel:(NSString *)transactionWithLabel __attribute__((objc_direct)) NS_RETURNS_RETAINED;
@end

NS_ASSUME_NONNULL_END
