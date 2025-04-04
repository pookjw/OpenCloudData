//
//  OCCloudKitStoreMonitor.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/5/25.
//

#import <OpenCloudData/OCCloudKitStoreMonitor.h>
#import <OpenCloudData/NSPersistentStoreCoordinator+Private.h>
#import <os/lock.h>

//COREDATA_EXTERN NSNotificationName const _NSPersistentStoreCoordinatorPrivateWillRemoveStoreNotification;

@interface OCCloudKitStoreMonitor () {
    dispatch_group_t _monitorGroup;
    os_unfair_lock _aliveLock;
    BOOL _storeIsAlive;
    BOOL _declaredDead;
    int _retryCount;
    int _timeoutSeconds;
    __weak NSPersistentStoreCoordinator *_monitoredCoordinator;
    __weak NSPersistentStore *_monitoredStore;
    NSString *_storeIdentifier;
}
@end

@implementation OCCloudKitStoreMonitor

- (instancetype)initForStore:(__kindof NSPersistentStore *)store {
    if (self = [super init]) {
        _storeIsAlive = NO;
        _monitorGroup = dispatch_group_create();
        _aliveLock = OS_UNFAIR_LOCK_INIT;
        _retryCount = 0;
        _storeIdentifier = [store.identifier retain];
        
        @autoreleasepool {
            __block BOOL storeIsAlive = NO;
            NSString *identifier = _storeIdentifier;
            
            // x22
            NSURL *url = [store.URL retain];
            
            // x23
            NSPersistentStoreCoordinator *persistentStoreCoordinator = [store.persistentStoreCoordinator retain];
            
            [persistentStoreCoordinator performBlockAndWait:^{
                [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(coordinatorWillRemoveStore:) name:@"_NSPersistentStoreCoordinatorPrivateWillRemoveStoreNotification" object:persistentStoreCoordinator];
                storeIsAlive = ([persistentStoreCoordinator persistentStoreForIdentifier:identifier]);
            }];
            
            _storeIsAlive = storeIsAlive;
            
            if (storeIsAlive) {
                _monitoredCoordinator = persistentStoreCoordinator;
                _monitoredStore = store;
            }
            
            [url release];
            [persistentStoreCoordinator release];
        }
    }
    
    return self;
}

- (void)dealloc {
    [_storeIdentifier release];
    dispatch_release(_monitorGroup);
    [NSNotificationCenter.defaultCenter removeObserver:self name:@"_NSPersistentStoreCoordinatorPrivateWillRemoveStoreNotification" object:nil];
    [super dealloc];
}

- (void)coordinatorWillRemoveStore:(__kindof NSPersistentStore *)store {
    abort();
}

- (void)performBlock:(void (^)(void))block {
    abort();
}

- (__kindof NSPersistentStore *)retainedMonitoredStore {
    abort();
}

- (NSManagedObjectContext *)newBackgroundContextForMonitoredCoordinator {
    abort();
}

@end
