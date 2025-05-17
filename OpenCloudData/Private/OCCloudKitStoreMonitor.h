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
    dispatch_group_t _monitorGroup; // 0x8
    os_unfair_lock _aliveLock; // 0x10
    BOOL _storeIsAlive; // 0x14
    BOOL _declaredDead; // 0x15
    int _retryCount; // 0x18
    int _timeoutSeconds; // 0x1c
    @package __weak NSPersistentStoreCoordinator *_monitoredCoordinator; // 0x20
    __weak NSPersistentStore *_monitoredStore; // 0x28
    @package NSString *_storeIdentifier; // 0x30
}
@property (assign, nonatomic, readonly, direct) BOOL declaredDead;
@property (weak, nonatomic, readonly, direct) NSPersistentStoreCoordinator *monitoredCoordinator;
@property (retain, nonatomic, readonly, direct) NSString *storeIdentifier;
- (instancetype)initForStore:(__kindof NSPersistentStore *)store;
- (void)coordinatorWillRemoveStore:(NSNotification *)notification;
- (void)performBlock:(void (^ NS_NOESCAPE _Nullable)(void))block __attribute__((objc_direct));
- (__kindof NSPersistentStore * _Nullable)retainedMonitoredStore __attribute__((objc_direct)) NS_RETURNS_RETAINED;
- (NSManagedObjectContext *)newBackgroundContextForMonitoredCoordinator __attribute__((objc_direct)) NS_RETURNS_RETAINED;
@end

NS_ASSUME_NONNULL_END
