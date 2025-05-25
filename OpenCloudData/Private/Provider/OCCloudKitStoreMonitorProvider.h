//
//  OCCloudKitStoreMonitorProvider.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/22/25.
//

#import "OpenCloudData/SPI/CoreData/NSSQLCore.h"
#import "OpenCloudData/Private/OCCloudKitStoreMonitor.h"

NS_ASSUME_NONNULL_BEGIN

@interface OCCloudKitStoreMonitorProvider : NSObject
- (OCCloudKitStoreMonitor *)createMonitorForObservedStore:(NSSQLCore *)observedStore inTransactionWithLabel:(NSString * _Nullable)transactionWithLabel __attribute__((objc_direct)) NS_RETURNS_RETAINED;
@end

NS_ASSUME_NONNULL_END
