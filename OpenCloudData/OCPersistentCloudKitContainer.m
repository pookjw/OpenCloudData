//
//  OCPersistentCloudKitContainer.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 3/30/25.
//

#import <OpenCloudData/OCPersistentCloudKitContainer.h>
#import <OpenCloudData/OCPersistentCloudKitContainer+OpenCloudData_Private.h>
#import <OpenCloudData/OCPersistentCloudKitContainer+Sharing.h>
#import <OpenCloudData/OCPersistentCloudKitContainerOptions+OpenCloudData_Private.h>
#import <OpenCloudData/NSPersistentStoreDescription+OpenCloudData.h>
#import <OpenCloudData/NSManagedObjectContext+Private.h>
#import <OpenCloudData/NSPersistentContainer+Private.h>
#import <OpenCloudData/OCCloudKitMirroringDelegateOptions.h>
#import <OpenCloudData/OCCloudKitMirroringDelegate.h>
#import <OpenCloudData/NSPersistentStoreDescription+Private.h>
#import <OpenCloudData/NSPersistentStore+Private.h>
#import <OpenCloudData/Log.h>
#import <xpc/xpc.h>
#import <CoreFoundation/CoreFoundation.h>

XPC_EXPORT XPC_NONNULL_ALL XPC_WARN_RESULT XPC_RETURNS_RETAINED xpc_object_t xpc_copy_entitlement_for_self(const char *key);

CF_EXPORT CF_RETURNS_RETAINED CFTypeRef _CFXPCCreateCFObjectFromXPCObject(xpc_object_t object);

@interface OCPersistentCloudKitContainer () <OCCloudKitMirroringDelegateProgressProvider> {
    NSInteger _operationTimeout;
    NSManagedObjectContext *_metadataContext;
}
@end

@implementation OCPersistentCloudKitContainer

+ (NSString *)discoverDefaultContainerIdentifier {
    xpc_object_t entitlements = xpc_copy_entitlement_for_self("com.apple.developer.icloud-container-identifiers");
    NSArray *array = (NSArray *)_CFXPCCreateCFObjectFromXPCObject(entitlements);
    
    NSString * _Nullable value;
    if (array.count == 0) {
        value = nil;
    } else {
        value = [[[array objectAtIndex:0] retain] autorelease];
    }
    
    [array release];
    xpc_release(entitlements);
    
    return value;
}

- (instancetype)initWithName:(NSString *)name managedObjectModel:(NSManagedObjectModel *)model {
    if (self = [super initWithName:name managedObjectModel:model]) {
        @autoreleasepool {
            NSString * _Nullable defaultContainerIdentifier = [OCPersistentCloudKitContainer discoverDefaultContainerIdentifier];
            
            if (defaultContainerIdentifier != nil) {
                OCPersistentCloudKitContainerOptions *options = [[OCPersistentCloudKitContainerOptions alloc] initWithContainerIdentifier:defaultContainerIdentifier];
                self.persistentStoreDescriptions.lastObject.oc_cloudKitContainerOptions = options;
                [options release];
            }
            
            NSManagedObjectContext *metadataContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
            _metadataContext = metadataContext;
            metadataContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
            [metadataContext _setAllowAncillaryEntities:YES];
            metadataContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
        }
    }
    
    return self;
}

- (void)dealloc {
    [_metadataContext release];
    [super dealloc];
}

- (void)_loadStoreDescriptions:(NSArray<NSPersistentStoreDescription *> *)storeDescriptions withCompletionHandler:(void (^)(NSPersistentStoreDescription * _Nonnull, NSError * _Nullable))completionHandler {
    for (NSPersistentStoreDescription *description in storeDescriptions) {
        id _Nullable options = description.oc_cloudKitContainerOptions;
        
        if (options == nil) {
            if ((description.mirroringDelegate != nil) && ([description.mirroringDelegate isKindOfClass:[OCCloudKitMirroringDelegate class]])) {
                NSObject<NSPersistentStoreMirroringDelegate> * _Nullable mirroringDelegate = [description.mirroringDelegate retain];
                description.mirroringDelegate = mirroringDelegate;
                [mirroringDelegate release];
            }
            
            continue;
        }
        
        if ([description.oc_cloudKitContainerOptions isKindOfClass:[OCPersistentCloudKitContainerOptions class]]) {
            OCPersistentCloudKitContainerOptions *cloudKitContainerOptions = description.oc_cloudKitContainerOptions;
            
            cloudKitContainerOptions.progressProvider = self;
            
            OCCloudKitMirroringDelegate *mirroringDelegate = [[OCCloudKitMirroringDelegate alloc] initWithCloudKitContainerOptions:cloudKitContainerOptions];
            
            description.mirroringDelegate = mirroringDelegate;
            
            if (description.options[NSPersistentHistoryTrackingKey] == nil) {
                [description setOption:@YES forKey:NSPersistentHistoryTrackingKey];
            }
            
            [mirroringDelegate release];
        } else if ([description.oc_cloudKitContainerOptions isKindOfClass:[OCCloudKitMirroringDelegateOptions class]]) {
            // interface가 일치함
            OCCloudKitMirroringDelegateOptions *mirroringDelegateOptions = (OCCloudKitMirroringDelegateOptions *)description.oc_cloudKitContainerOptions;
            
            mirroringDelegateOptions.progressProvider = self;
            
            OCCloudKitMirroringDelegate *mirroringDelegate = [[OCCloudKitMirroringDelegate alloc] initWithCloudKitContainerOptions:mirroringDelegateOptions];
            
            description.mirroringDelegate = mirroringDelegate;
            
            if (description.options[NSPersistentHistoryTrackingKey] == nil) {
                [description setOption:@YES forKey:NSPersistentHistoryTrackingKey];
            }
            
            [mirroringDelegate release];
        } else {
            NSString *reason = [NSString stringWithFormat:@"%@.%@ must be of type '%@'", NSStringFromClass([NSPersistentStoreDescription class]), NSStringFromSelector(@selector(oc_cloudKitContainerOptions)), NSStringFromClass([OCPersistentCloudKitContainerOptions class])];
            NSDictionary *userInfo = @{@"offendingObject": description.oc_cloudKitContainerOptions};
            
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:userInfo];
        }
    }
}

- (BOOL)canModifyManagedObjectsInStore:(NSPersistentStore *)store {
    if (![store.type isEqualToString:NSSQLiteStoreType]) {
        return YES;
    }
    
    OCCloudKitMirroringDelegate * _Nullable mirroringDelegate = [(OCCloudKitMirroringDelegate *)store.mirroringDelegate retain];
    
    BOOL result;
    if (mirroringDelegate == nil) {
        result = YES;
    } else {
        BOOL successfullyInitialized = mirroringDelegate->_successfullyInitialized;
        OCCloudKitMirroringDelegateOptions *options = mirroringDelegate->_options;
        CKDatabaseScope databaseScope = options.databaseScope;
        
        if (!successfullyInitialized) {
            result = (databaseScope == CKDatabaseScopePrivate);
        } else if (databaseScope != CKDatabaseScopePublic) {
            result = YES;
        } else {
            CKRecordID *currentUserRecordID = mirroringDelegate->_currentUserRecordID;
            result = (currentUserRecordID != nil);
        }
    }
    
    [mirroringDelegate release];
    return result;
}

- (void)setPersistentStoreDescriptions:(NSArray<NSPersistentStoreDescription *> *)persistentStoreDescriptions {
    NSMutableDictionary<NSString *, NSPersistentStoreDescription *> *descriptionsByContainerIdentifier = [[NSMutableDictionary alloc] initWithCapacity:persistentStoreDescriptions.count];
    
    for (NSPersistentStoreDescription *description in persistentStoreDescriptions) {
        OCPersistentCloudKitContainerOptions * _Nullable cloudKitContainerOptions = description.oc_cloudKitContainerOptions;
        NSString * _Nullable containerIdentifier = cloudKitContainerOptions.containerIdentifier;
        if (containerIdentifier == nil) continue;
        if (containerIdentifier.length == 0) continue;
        
        NSPersistentStoreDescription * _Nullable storedDescription = descriptionsByContainerIdentifier[containerIdentifier];
        if (storedDescription == nil) {
            descriptionsByContainerIdentifier[containerIdentifier] = description;
        } else {
            if (storedDescription.oc_cloudKitContainerOptions.databaseScope == description.oc_cloudKitContainerOptions.databaseScope) {
                NSDictionary *userInfo = @{@"storeURL": description.URL};
                @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Cannot assign the same iCloud Container Identifier to multiple persistent stores with the same database scope." userInfo:userInfo];
            }
        }
    }
    
    [descriptionsByContainerIdentifier release];
    
    [super setPersistentStoreDescriptions:persistentStoreDescriptions];
}

- (BOOL)canDeleteRecordForManagedObjectWithID:(NSManagedObjectID *)objectID {
    __kindof NSPersistentStore * _Nullable persistentStore = objectID.persistentStore;
    OCCloudKitMirroringDelegate * _Nullable mirroringDelegate = (OCCloudKitMirroringDelegate *)[persistentStore.mirroringDelegate retain];
    
    BOOL result;
    if (mirroringDelegate == nil) {
        // 원래 코드를 짐작할 수 없으나 NO가 반환되는 것은 확실해보임 https://x.com/_silgen_name/status/1906959715126653051
        result = NO;
    } else {
        CKDatabaseScope databaseScope = mirroringDelegate->_options.databaseScope;
        if (databaseScope == CKDatabaseScopePublic) {
            result = NO;
        } else if (databaseScope != CKDatabaseScopeShared) {
            result = YES;
        } else {
            if (mirroringDelegate->_successfullyInitialized) {
                NSError * _Nullable error = nil;
                NSDictionary<NSManagedObjectID *, CKShare *> * _Nullable shares = [self fetchSharesMatchingObjectIDs:@[objectID] error:&error];
                CKShare * _Nullable share = shares[objectID];
                
                if (share == nil) {
                    os_log_error(_OCLogGetLogStream(0x11), "CoreData: fault: Failed to fetch the CKShare for an object in the shared database: %@ - %@\\n", objectID, error);
                    os_log_fault(_OCLogGetLogStream(0x11), "CoreData: fault: Failed to fetch the CKShare for an object in the shared database: %@ - %@\\n", objectID, error);
                    result = YES;
                } else {
                    CKShareParticipantPermission permission = share.currentUserParticipant.permission;
                    result = (permission == CKShareParticipantPermissionReadWrite);
                }
            } else {
                result = NO;
            }
        }
    }
    
    [mirroringDelegate release];
    return result;
}

- (BOOL)canUpdateRecordForManagedObjectWithID:(NSManagedObjectID *)objectID {
    /*
     x21 = objectID
     x22 = self
     */
    
    if (objectID.temporaryID) {
        return YES;
    }
    
    // x19
    __kindof NSPersistentStore * _Nullable persistentStore = [objectID.persistentStore retain];
    if (persistentStore == nil) {
        return YES;
    }
    
    if (![persistentStore.type isEqualToString:NSSQLiteStoreType]) {
        // TODO -release
        return YES;
    }
    
    // x20
    OCCloudKitMirroringDelegate *mirroringDelegate = (OCCloudKitMirroringDelegate *)[persistentStore.mirroringDelegate retain];
    if (mirroringDelegate == nil) {
        return YES;
    }
    
    BOOL successfullyInitialized = mirroringDelegate->_successfullyInitialized;
    if (!successfullyInitialized) {
        
    }
    
    abort();
}

@end

@implementation OCPersistentCloudKitContainer (OpenCloudData_Private)

- (BOOL)assignManagedObjects:(NSArray<NSManagedObject *> *)managedObjects toCloudKitRecordZone:(CKRecordZone *)cloudKitRecordZone inPersistentStore:(__kindof NSPersistentStore *)persistentStore error:(NSError * _Nullable *)error {
#warning TODO - Share
    abort();
    /*
     x21 = self
     x25 = managedObjects
     x22 = cloudKitRecordZone
     x20 = error
     */
    // x23
    NSMutableDictionary *dictionary_1 = [[NSMutableDictionary alloc] init];
    
    // x24
    NSMutableDictionary *dictionary_2 = [[NSMutableDictionary alloc] init];
    
    NSManagedObject * _Nullable lastObject = managedObjects.lastObject;
    // x19
    NSManagedObjectContext * _Nullable managedObjectContext = [lastObject.managedObjectContext retain];
    
    [managedObjectContext performBlockAndWait:^{
        
    }];
    
    [self doWorkOnMetadataContext:NO withBlock:^(NSManagedObjectContext * _Nonnull metadataContext) {
        
    }];
    [dictionary_1 release];
    [dictionary_2 release];
    
    [managedObjectContext release];
}

- (void)applyActivityVoucher:(OCPersistentCloudKitContainerActivityVoucher *)activityVoucher toStores:(NSArray<NSPersistentStore *> *)stores {
    NSArray<__kindof NSPersistentStore *> *persistentStores = self.persistentStoreCoordinator.persistentStores;
    
    for (__kindof NSPersistentStore *persistentStore in persistentStores) {
        [(OCCloudKitMirroringDelegate *)persistentStore.mirroringDelegate addActivityVoucher:activityVoucher];
    }
}

- (void)doWorkOnMetadataContext:(BOOL)asynchronous withBlock:(void (^)(NSManagedObjectContext * _Nonnull))block __attribute__((objc_direct)) {
    NSManagedObjectContext *metadataContext = [_metadataContext retain];
    
    void (^handler)(void) = ^{
        NSSet<__kindof NSManagedObject *> *registeredObjects = metadataContext.registeredObjects;
        if (registeredObjects.count != 0) {
            os_log_error(_OCLogGetLogStream(0x11), "CoreData: fault: An operation left registered objects in NSPersistentCloudKitContainer's metadata context: %@\\n", metadataContext.registeredObjects);
            os_log_fault(_OCLogGetLogStream(0x11), "CoreData: fault: An operation left registered objects in NSPersistentCloudKitContainer's metadata context: %@\\n", metadataContext.registeredObjects);
        }
        
        block(metadataContext);
        
        if (metadataContext.hasChanges) {
            os_log_error(_OCLogGetLogStream(0x11), "CoreData: fault: An operation left NSPersistentCloudKitContainer's metadata context dirty: %@\\n", metadataContext);
            os_log_fault(_OCLogGetLogStream(0x11), "CoreData: fault: An operation left NSPersistentCloudKitContainer's metadata context dirty: %@\\n", metadataContext);
        }
        
        [metadataContext reset];
    };
    
    if (asynchronous) {
        [metadataContext performBlock:handler];
    } else {
        [metadataContext performBlockAndWait:handler];
    }
    
    [metadataContext release];
}

@end
