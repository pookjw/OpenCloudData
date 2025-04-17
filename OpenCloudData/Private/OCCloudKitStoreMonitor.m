//
//  OCCloudKitStoreMonitor.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/5/25.
//

#import <OpenCloudData/OCCloudKitStoreMonitor.h>
#import <OpenCloudData/NSPersistentStoreCoordinator+Private.h>
#import <OpenCloudData/NSManagedObjectContext+Private.h>
#import <OpenCloudData/Log.h>
#import <objc/runtime.h>

//COREDATA_EXTERN NSNotificationName const _NSPersistentStoreCoordinatorPrivateWillRemoveStoreNotification;

# define OS_UNFAIR_LOCK_FLAG_DATA_SYNCHRONIZATION (0x00010000)

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
                [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(coordinatorWillRemoveStore:) name:@"_NSPersistentStoreCoordinatorPrivateWillRemoveStoreNotification" object:nil];
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

- (void)coordinatorWillRemoveStore:(NSNotification *)notification {
    // _NSPersistentStoreCoordinatorPrivateWillRemoveStoreNotification은 안 불리는 Notification으로 보임
    abort();
}

- (void)performBlock:(void (^ NS_NOESCAPE)(void))block {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    if (block != nil) {
        // objc_loadWeakRetained
        id monitoredCoordinator = _monitoredCoordinator;
        dispatch_group_enter(_monitorGroup);
        block();
        dispatch_group_leave(_monitorGroup);
        monitoredCoordinator = nil;
    }
    
    [pool release];
}

- (__kindof NSPersistentStore *)retainedMonitoredStore {
    // x19 = self
    
    if (!_storeIsAlive) return nil;
    if (_declaredDead) return nil;
    
    // x20
    NSPersistentStoreCoordinator *monitoredCoordinator = _monitoredCoordinator;
    if (monitoredCoordinator == nil) {
        return nil;
    }
    
    __block NSPersistentStore * _Nullable store = nil;
    [monitoredCoordinator performBlockAndWait:^{
        store = [[monitoredCoordinator persistentStoreForIdentifier:_storeIdentifier] retain];
    }];
    
    if (store == nil) {
        os_unfair_lock_lock_with_flags(&_aliveLock, OS_UNFAIR_LOCK_FLAG_DATA_SYNCHRONIZATION | OS_UNFAIR_LOCK_FLAG_ADAPTIVE_SPIN);
        _storeIsAlive = NO;
        _declaredDead = YES;
        os_unfair_lock_unlock(&_aliveLock);
    }
    
    return store;
}

- (NSManagedObjectContext *)newBackgroundContextForMonitoredCoordinator {
    // self = x21
    
    // x19
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    
    NSPersistentStoreCoordinator *monitoredCoordinator = _monitoredCoordinator;
    if (monitoredCoordinator == nil) {
        os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Called after the store is dead. This method needs to be called inside a performBlock on the store monitor: %@", self);
        os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: Called after the store is dead. This method needs to be called inside a performBlock on the store monitor: %@", self);
        return context;
    }
    
    context.persistentStoreCoordinator = monitoredCoordinator;
    [context _setAllowAncillaryEntities:YES];
    context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
    
    if (_storeIdentifier != nil) {
        NSArray<NSString *> *old_persistentStoreIdentifiers;
        Ivar _persistentStoreIdentifiersIvar = object_getInstanceVariable(context, "_persistentStoreIdentifiers", (void **)&old_persistentStoreIdentifiers);
        assert(_persistentStoreIdentifiersIvar != NULL);
        [old_persistentStoreIdentifiers release];
        ptrdiff_t offset = ivar_getOffset(_persistentStoreIdentifiersIvar);
        *(id *)((uintptr_t)context + offset) = [@[_storeIdentifier] copy];
    } else {
        os_log_fault(_OCLogGetLogStream(0x11), "fault: Attempt to create context without a store identifier.\n");
        os_log_error(_OCLogGetLogStream(0x11), "fault: Attempt to create context without a store identifier.\n");
    }
    
    if ([monitoredCoordinator persistentStoreForIdentifier:_storeIdentifier] != nil) {
        os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Called after the store is dead. This method needs to be called inside a performBlock on the store monitor: %@", self);
        os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: Called after the store is dead. This method needs to be called inside a performBlock on the store monitor: %@", self);
    }
    
    return context;
}

@end
