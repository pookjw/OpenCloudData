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
#import <OpenCloudData/NSPersistentStore+OpenCloudData_Private.h>
#import <OpenCloudData/OCCloudKitMirroringInitializeSchemaRequest.h>
#import <OpenCloudData/Log.h>
#import <OpenCloudData/NSCloudKitMirroringDelegate.h>
#import <xpc/xpc.h>
#import <CoreFoundation/CoreFoundation.h>
#import <objc/runtime.h>
#import <objc/message.h>
@import ellekit;

BOOL (*NSCloudKitMirroringDelegate_executeMirroringRequest_error_original)(id, id, id *);
BOOL NSCloudKitMirroringDelegate_executeMirroringRequest_error_custom(id self, id request, id * error) {
    if ([self isKindOfClass:[NSCloudKitMirroringDelegate class]]) {
        return NSCloudKitMirroringDelegate_executeMirroringRequest_error_original(self, request, error);
    } else if ([self isKindOfClass:[OCCloudKitMirroringDelegate class]]) {
        abort();
    } else {
        abort();
    }
}

XPC_EXPORT XPC_NONNULL_ALL XPC_WARN_RESULT XPC_RETURNS_RETAINED xpc_object_t xpc_copy_entitlement_for_self(const char *key);

CF_EXPORT CF_RETURNS_RETAINED CFTypeRef _CFXPCCreateCFObjectFromXPCObject(xpc_object_t object);

@interface OCPersistentCloudKitContainer () {
    NSInteger _operationTimeout;
    NSManagedObjectContext *_metadataContext;
}
@end

@implementation OCPersistentCloudKitContainer

+ (void)load {
    const void *image = MSGetImageByName("/System/Library/Frameworks/CoreData.framework/CoreData");
    const void *symbol = MSFindSymbol(image, "-[NSCloudKitMirroringDelegate executeMirroringRequest:error:]");
    MSHookFunction((void *)symbol, (void *)&NSCloudKitMirroringDelegate_executeMirroringRequest_error_custom, (void **)&NSCloudKitMirroringDelegate_executeMirroringRequest_error_original);
}

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
            
#warning TODO
            OCCloudKitMirroringDelegate *mirroringDelegate = [[NSCloudKitMirroringDelegate alloc] initWithCloudKitContainerOptions:cloudKitContainerOptions];
            
            description.mirroringDelegate = mirroringDelegate;
            
            if (description.options[NSPersistentHistoryTrackingKey] == nil) {
                [description setOption:@YES forKey:NSPersistentHistoryTrackingKey];
            }
            
            [mirroringDelegate release];
        } else if ([description.oc_cloudKitContainerOptions isKindOfClass:[OCCloudKitMirroringDelegateOptions class]]) {
            // interface가 일치함
            OCCloudKitMirroringDelegateOptions *mirroringDelegateOptions = (OCCloudKitMirroringDelegateOptions *)description.oc_cloudKitContainerOptions;
            
            mirroringDelegateOptions.progressProvider = self;
            
#warning TODO
            OCCloudKitMirroringDelegate *mirroringDelegate = [[NSCloudKitMirroringDelegate alloc] initWithCloudKitContainerOptions:mirroringDelegateOptions];
            
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
    
    [super _loadStoreDescriptions:storeDescriptions withCompletionHandler:completionHandler];
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
    if (objectID.temporaryID) {
        return YES;
    }
    
    __kindof NSPersistentStore * _Nullable persistentStore = [objectID.persistentStore retain];
    
    BOOL result;
    if (persistentStore == nil) {
        result = YES;
    } else {
        if (![persistentStore.type isEqualToString:NSSQLiteStoreType]) {
            result = YES;
        } else {
            OCCloudKitMirroringDelegate *mirroringDelegate = (OCCloudKitMirroringDelegate *)[persistentStore.mirroringDelegate retain];
            
            if (mirroringDelegate == nil) {
                result = YES;
            } else {
                BOOL successfullyInitialized = mirroringDelegate->_successfullyInitialized;
                OCCloudKitMirroringDelegateOptions *options = mirroringDelegate->_options;
                
                if (!successfullyInitialized) {
                    CKDatabaseScope databaseScope = options.databaseScope;
                    if (databaseScope == CKDatabaseScopePrivate) {
                        result = YES;
                    } else {
                        result = NO;
                    }
                } else {
                    CKDatabaseScope databaseScope = options.databaseScope;
                    if (databaseScope != CKDatabaseScopePublic) {
                        if (options.databaseScope != CKDatabaseScopeShared) {
                            result = YES;
                        } else {
                            NSError * _Nullable error = nil;
                            NSDictionary<NSManagedObjectID *, CKShare *> * shares = [self fetchSharesMatchingObjectIDs:@[objectID] error:&error];
                            CKShare * _Nullable share = shares[objectID];
                            
                            if (share == nil) {
#warning _NSCoreDataLog
                                NSLog(@"%@", [NSString stringWithFormat:@"CoreData: Failed to fetch the CKShare for an object in the shared database: %@ - %@", objectID, error]);
                                os_log_fault(_OCLogGetLogStream(0x11), "CoreData: Failed to fetch the CKShare for an object in the shared database: %@ - %@", objectID, error);
                                abort();
                            } else {
                                result = (share.currentUserParticipant.permission == CKShareParticipantPermissionReadWrite);
                            }
                        }
                    } else {
                        CKRecordID *currentUserRecordID = mirroringDelegate->_currentUserRecordID;
                        if (currentUserRecordID == nil) {
                            result = NO;
                        } else {
                            [_metadataContext performBlockAndWait:^{
#warning TODO __71-[NSPersistentCloudKitContainer canUpdateRecordForManagedObjectWithID:]_block_invoke
                                abort();
                            }];
                            
                            result = NO;
                        }
                    }
                }
            }
            
            [mirroringDelegate release];
        }
    }
    
    [persistentStore release];
    return result;
}

- (BOOL)initializeCloudKitSchemaWithOptions:(OCPersistentCloudKitContainerSchemaInitializationOptions)options error:(NSError * _Nullable *)error {
    // sp, #0x2c0 + var_2B0 = error ptr
    
    // sp + 0x130
    __block BOOL hasUnknownError = NO;
    // sp + 0x148 (or sp + 0x130 + 0x18)
    __block BOOL contextSucceed = YES;
    
    // x19
    NSUInteger icloudKitEnabledCount = 0;
    
    // sp + 0x30 = self
    // sp + 0x38 = group
    // sp + #0x2c0 + var_2A8 = options
    // sp + #0x2c0 + var_290 = self
    dispatch_group_t group = dispatch_group_create();
    
    for (__kindof NSPersistentStore *persistentStore in self.persistentStoreCoordinator.persistentStores) {
        if (!persistentStore.oc_isCloudKitEnabled) continue;
//        BOOL isCloudKitEnabled = ((BOOL (*)(id, SEL))objc_msgSend)(persistentStore, sel_registerName("isCloudKitEnabled"));
//        if (!isCloudKitEnabled) continue;
        
        @autoreleasepool {
#warning _NSCoreDataLog
            // Inline Function이 있는 것 같음
            NSString *base = @"OpenCloudData+CloudKit: %s(%d): ";
            NSString *content =  @"%@: will initialize cloudkit schema for store: %@";
            NSString *string = [base stringByAppendingString:content];
            NSLog(@"%@", [string stringByAppendingFormat:string, __func__, __LINE__, self, persistentStore]);
            
            dispatch_group_enter(group);
            icloudKitEnabledCount += 1;
        }
    }
    
    // x21
    NSMutableArray<NSError *> *errors_1 = [[NSMutableArray alloc] init];
    
    if (icloudKitEnabledCount != 0) {
        // x23
        NSMutableArray *errors_2 = [[NSMutableArray alloc] init];
        
        // x24
        OCCloudKitMirroringInitializeSchemaRequest *request = [[objc_lookUpClass("NSCloudKitMirroringInitializeSchemaRequest") alloc] initWithOptions:nil completionBlock:^(OCCloudKitMirroringResult * _Nonnull result) {
            // x20 = result
            // x19 = self
            // x0 + 0x20 = expectedErrors
            // x0 + 0x28 = errors_1
            // x0 + 0x30 = group
            // x0 + 0x38 = errors_2
            
            if (!result.success) {
                NSError *error = result.error;
                NSInteger code = error.code;
                
                if ((code - (0x20ULL << 12)) == 0xD13) {
                    [errors_1 addObject:error];
                } else {
                    if (hasUnknownError) hasUnknownError = NO;
                    NSLog(@"OpenCloudData+CloudKit: %s(%d): Initialize schema request failed: %@", __func__, __LINE__, error);
                    hasUnknownError = NO;
                    
                    if (result.error == nil) {
                        os_log_fault(_OCLogGetLogStream(0x11), "CoreData: Initialize schema failed but did not set an error: %@", result);
                        os_log_error(_OCLogGetLogStream(0x11), "CoreData: Initialize schema failed but did not set an error: %@", result);
                    } else {
                        NSError *error = result.error;
                        NSDictionary *userInfo = error.userInfo;
                        
                        if (userInfo[NSUnderlyingErrorKey] == nil) {
                            [errors_2 addObject:error];
                        } else {
                            [errors_2 addObject:userInfo[NSUnderlyingErrorKey]];
                        }
                    }
                }
            } else {
                NSLog(@"OpenCloudData+CloudKit: %s(%d): Finished initialize schema with result: %@", __func__, __LINE__, result);
            }
            
            dispatch_group_leave(group);
        }];
        
        request.schemaInitializationOptions = options;
        
        // x25
        NSManagedObjectContext *backgroundContext = [self newBackgroundContext];
        __block NSError * _Nullable _error = nil;
        
        [backgroundContext performBlockAndWait:^{
            NSError * _Nullable error = nil;
            BOOL result = [backgroundContext executeRequest:request error:&error];
            if (!result) {
                contextSucceed = result;
                _error = [error retain];
            }
        }];
        
        if (contextSucceed) {
            const NSInteger seconds = 30;
            intptr_t overtime = dispatch_group_wait(group, dispatch_time(DISPATCH_TIME_NOW, seconds * NSEC_PER_SEC));
            if (overtime != 0) {
                contextSucceed = NO;
                
                NSError *__error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain
                                                              code:NSCoreDataError
                                                          userInfo:@{NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"Failed to initialize CloudKit schema because the requests timed out (a %lds wait failed).", seconds]}];
                [errors_2 addObject:__error];
                [__error release];
            }
            
            if (contextSucceed) {
                NSDictionary *userInfo;
                if (icloudKitEnabledCount == errors_1.count) {
                    userInfo = @{
                        NSLocalizedFailureReasonErrorKey: @"Couldn't initialize CloudKit schema because no stores were able to succesfully initialize.",
                        NSDetailedErrorsKey: errors_1
                    };
                } else if (errors_2.count != 0) {
                    userInfo = @{@"encounteredErrors": errors_2};
                } else {
                    userInfo = nil;
                }
                
                if (userInfo != nil) {
                    contextSucceed = NO;
                    _error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:NSCoreDataError userInfo:userInfo];
                }
            }
        }
        
        [request release];
        [backgroundContext release];
        [errors_2 release];
        
        [_error autorelease];
        
        if (!contextSucceed) {
            if (_error == nil) {
                os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d", __func__, __LINE__);
                os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d", __func__, __LINE__);
            } else {
                if (error != NULL) {
                    *error = _error;
                }
            }
        }
    }
    
    [errors_1 release];
    dispatch_release(group);
    
    return contextSucceed;
}

@end

@implementation OCPersistentCloudKitContainer (OpenCloudData_Private)

- (void)eventUpdated:(OCPersistentCloudKitContainerEvent *)event {
    @autoreleasepool {
        [NSNotificationCenter.defaultCenter postNotificationName:OCPersistentCloudKitContainerEventChangedNotification object:self userInfo:@{OCPersistentCloudKitContainerEventUserInfoKey: event}];
    }
}

- (void)applyActivityVoucher:(OCPersistentCloudKitContainerActivityVoucher *)activityVoucher toStores:(NSArray<NSPersistentStore *> *)stores {
    NSArray<__kindof NSPersistentStore *> *persistentStores = self.persistentStoreCoordinator.persistentStores;
    
    for (__kindof NSPersistentStore *persistentStore in persistentStores) {
        [(OCCloudKitMirroringDelegate *)persistentStore.mirroringDelegate addActivityVoucher:activityVoucher];
    }
}

- (void)expireActivityVoucher:(OCPersistentCloudKitContainerActivityVoucher *)activityVoucher {
    NSArray<__kindof NSPersistentStore *> *persistentStores = self.persistentStoreCoordinator.persistentStores;
    
    for (__kindof NSPersistentStore *persistentStore in persistentStores) {
        [(OCCloudKitMirroringDelegate *)persistentStore.mirroringDelegate expireActivityVoucher:activityVoucher];
    }
}

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

- (void)publishActivity:(__kindof OCPersistentCloudKitContainerActivity *)activity {
    // TODO
}

@end
