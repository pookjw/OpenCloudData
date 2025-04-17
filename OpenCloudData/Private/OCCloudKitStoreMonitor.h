//
//  OCCloudKitStoreMonitor.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/5/25.
//

#import <CoreData/CoreData.h>
#import <os/lock.h>

NS_ASSUME_NONNULL_BEGIN

@interface OCCloudKitStoreMonitor : NSObject {
    dispatch_group_t _monitorGroup;
    os_unfair_lock _aliveLock;
    BOOL _storeIsAlive;
    BOOL _declaredDead;
    int _retryCount;
    int _timeoutSeconds;
    __weak NSPersistentStoreCoordinator *_monitoredCoordinator;
    __weak NSPersistentStore *_monitoredStore;
    @package NSString *_storeIdentifier; // 0x30
}
- (instancetype)initForStore:(__kindof NSPersistentStore *)store;
- (void)coordinatorWillRemoveStore:(NSNotification *)notification;
- (void)performBlock:(void (^ NS_NOESCAPE _Nullable)(void))block __attribute__((objc_direct));
- (__kindof NSPersistentStore * _Nullable)retainedMonitoredStore __attribute__((objc_direct)) NS_RETURNS_RETAINED;
- (NSManagedObjectContext *)newBackgroundContextForMonitoredCoordinator __attribute__((objc_direct)) NS_RETURNS_RETAINED;
@end

NS_ASSUME_NONNULL_END
