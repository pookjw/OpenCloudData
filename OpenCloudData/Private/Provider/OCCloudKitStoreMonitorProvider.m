//
//  OCCloudKitStoreMonitorProvider.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/22/25.
//

#import <OpenCloudData/OCCloudKitStoreMonitorProvider.h>

@implementation OCCloudKitStoreMonitorProvider

- (OCCloudKitStoreMonitor *)createMonitorForObservedStore:(NSSQLCore *)observedStore inTransactionWithLabel:(NSString *)transactionWithLabel {
    return [[OCCloudKitStoreMonitor alloc] initForStore:observedStore];
}

@end
