//
//  OCCloudKitStoreMonitor.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/5/25.
//

#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface OCCloudKitStoreMonitor : NSObject
- (instancetype)initForStore:(__kindof NSPersistentStore *)store;
- (void)coordinatorWillRemoveStore:(NSNotification *)notification;
- (void)performBlock:(void (^ NS_NOESCAPE _Nullable)(void))block __attribute__((objc_direct));
- (__kindof NSPersistentStore * _Nullable)retainedMonitoredStore __attribute__((objc_direct)) NS_RETURNS_RETAINED;
- (NSManagedObjectContext *)newBackgroundContextForMonitoredCoordinator __attribute__((objc_direct)) NS_RETURNS_RETAINED;
@end

NS_ASSUME_NONNULL_END
