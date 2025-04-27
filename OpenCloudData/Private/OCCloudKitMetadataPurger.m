//
//  OCCloudKitMetadataPurger.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/22/25.
//

#import <OpenCloudData/OCCloudKitMetadataPurger.h>
#import <OpenCloudData/NSPersistentStore+Private.h>
#import <OpenCloudData/OCCKDatabaseMetadata.h>
#import <OpenCloudData/OCCKRecordZoneMetadata.h>
#import <OpenCloudData/OCCKRecordMetadata.h>
#import <OpenCloudData/OCCKMetadataEntry.h>
#import <OpenCloudData/_PFRoutines.h>
#import <OpenCloudData/Log.h>
@import ellekit;

CK_EXTERN NSString * const NSCloudKitMirroringDelegateResetSyncAuthor;
COREDATA_EXTERN NSString * const NSCloudKitMirroringDelegateBypassHistoryOnExportKey;
COREDATA_EXTERN NSString * const NSCloudKitMirroringDelegateLastHistoryTokenKey;

@implementation OCCloudKitMetadataPurger

- (BOOL)purgeMetadataFromStore:(NSSQLCore *)store inMonitor:(OCCloudKitStoreMonitor *)monitor withOptions:(NSUInteger)options forRecordZones:(NSArray<CKRecordZoneID *> *)recordZones inDatabaseWithScope:(CKDatabaseScope)databaseScope andTransactionAuthor:(NSString *)transactionAuthor error:(NSError * _Nullable *)error {
    /*
     self = x21
     store = x25
     options = x23
     recordZones = x24
     databaseScope = x22
     transactionAuthor = x26
     error = x20
     */
    
    // x19
    NSManagedObjectContext *managedObjectContext = [monitor newBackgroundContextForMonitoredCoordinator];
    
    NSString *_transactionAuthor;
    if (transactionAuthor.length == 0) {
        _transactionAuthor = NSCloudKitMirroringDelegateResetSyncAuthor;
    } else {
        _transactionAuthor = transactionAuthor;
    }
    
    // sp, #0x90
    __block BOOL _succeed = YES;
    // sp, #0x60
    __block NSError * _Nullable _error = nil;
    
    /*
     __135-[PFCloudKitMetadataPurger purgeMetadataFromStore:inMonitor:withOptions:forRecordZones:inDatabaseWithScope:andTransactionAuthor:error:]_block_invoke
     store = sp + 0x20 = x21 + 0x20
     recordZones = sp + 0x28 = x21 + 0x28
     managedObjectContext = sp + 0x30 = x21 + 0x30
     self = sp + 0x38 = x21 + 0x38
     _succeed = sp + 0x40 = x21 + 0x40
     _error = sp + 0x48 = x21 + 0x48
     options = sp + 0x50 = x21 + 0x50
     databaseScope = sp + 0x58 = x21 + 0x58
     */
    [managedObjectContext performBlockAndWait:^{
        /*
         self(block) = x21 / sp + 0x78
         */
        
        // sp, #0x240
        NSError * _Nullable __error = nil;
        
        // sp + 0x48
        NSMutableSet<NSString *> *set = [[NSMutableSet alloc] init];
        // x20
        NSManagedObjectModel *managedObjectModel = [store _persistentStoreCoordinator].managedObjectModel;
        // sp + 0x28
        NSArray<NSEntityDescription *> *entities = [managedObjectModel entitiesForConfiguration:store.configurationName];
        // x22
        NSMutableSet<CKRecordZoneID *> *recordZonesSet = [[NSMutableSet alloc] initWithArray:recordZones];
        
        OCCKDatabaseMetadata * _Nullable databaseMetadata = [OCCKDatabaseMetadata databaseMetadataForScope:databaseScope forStore:store inContext:managedObjectContext error:&__error];
        if (databaseMetadata == nil) {
            _succeed = NO;
            _error = [__error retain];
            [set release];
            return;
        }
        
        // x20
        NSSet<OCCKRecordZoneMetadata *> *recordZoneMetadataSet = databaseMetadata.recordZones;
        
        for (OCCKRecordZoneMetadata *recordZoneMetadata in recordZoneMetadataSet) {
            // x23
            CKRecordZoneID *zoneID = [recordZoneMetadata createRecordZoneID];
            [recordZonesSet addObject:zoneID];
            [zoneID release];
        }
        
        if (recordZonesSet.count == 0) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Asked to purge system fields without any zones from which to purge.\n");
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Asked to purge system fields without any zones from which to purge.\n");
        }
        
        // x20
        for (CKRecordZoneID *zoneID in recordZonesSet) {
            os_log_with_type(_OCLogGetLogStream(0x11), OS_LOG_TYPE_DEFAULT, "OpenCloudData+CloudKit: %s(%d): %@ - Purging system fields from data in zone: %@", __func__, __LINE__, managedObjectContext.transactionAuthor, zoneID);
            
            BOOL result = [self _wipeSystemFieldsAndResetUploadStateForMetadataInZoneWithID:zoneID inDatabaseWithScope:databaseScope inStore:store usingContext:managedObjectContext error:&__error];
            
            if (!result) {
                _error = [__error retain];
                _succeed = NO;
                [set release];
                return;
            }
        }
        
        if (recordZonesSet.count == 0) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Asked to purge user rows without any zones from which to purge.\n"); 
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Asked to purge user rows without any zones from which to purge.\n"); 
        }
        
        // x20
        for (CKRecordZoneID *zoneID in recordZonesSet) {
            os_log_with_type(_OCLogGetLogStream(0x11), OS_LOG_TYPE_DEFAULT, "OpenCloudData+CloudKit: %s(%d): %@ - Removing cloud metadata and client rows in zone: %@", __func__, __LINE__, managedObjectContext.transactionAuthor, zoneID);
            
            BOOL result = [self _wipeUserRowsAndMetadataForZoneWithID:zoneID inDatabaseWithScope:databaseScope inStore:store usingContext:managedObjectContext error:&__error];
            if (!result) {
                _error = [__error retain];
                _succeed = NO;
                [set release];
                return;
            }
        }
        
        [OCCKMetadataEntry updateOrInsertMetadataEntryWithKey:NSCloudKitMirroringDelegateBypassHistoryOnExportKey boolValue:YES forStore:store intoManagedObjectContext:managedObjectContext error:&__error];
        BOOL result;
        if (__error == nil) {
            result = [managedObjectContext save:&__error];
        } else {
            result = NO;
        }
        
        if (!result) {
            _succeed = NO;
            _error = [__error retain];;
            [set release];
            return;
        }
        
        if (options & (1 << 5)) {
            [set addObject:NSCloudKitMirroringDelegateLastHistoryTokenKey];
        }
        
        if (((options & 0b1100) != 0) && _succeed && (options)) {
            
        }
        
        if (((options & 0b1100) != 0) && _succeed) {
            if (options & (1 << 2)) {
                // <+3968>
            } else if (options == (1 << 3)) {
                // <+3560>
            }
            
            // nop
        }
        
        // <+4436>
        abort();
    }];
    
    if (!_succeed) {
        if (_error == nil) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __func__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __func__, __LINE__);
        } else {
            if (error != NULL) {
                *error = [[_error retain] autorelease];
            }
        }
    }
    
    [managedObjectContext release];
    [_error release];
    _error = nil;
    
    return _succeed;
}

- (BOOL)_wipeSystemFieldsAndResetUploadStateForMetadataInZoneWithID:(CKRecordZoneID *)zoneID inDatabaseWithScope:(CKDatabaseScope)databaseScope inStore:(NSSQLCore *)store usingContext:(NSManagedObjectContext *)context error:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct)) {
    // inlined from __135-[PFCloudKitMetadataPurger purgeMetadataFromStore:inMonitor:withOptions:forRecordZones:inDatabaseWithScope:andTransactionAuthor:error:]_block_invoke
    /*
     store = x21
     context = x28
     zoneID = x20
     */
    
    // sp, #0x2b0 / x23
    __block BOOL _succeed = YES;
    // sp + 0x280 / x25
    __block NSError * _Nullable _error = nil;
    
    const void *image = MSGetImageByName("/System/Library/Frameworks/CoreData.framework/CoreData");
    const void *symbol = MSFindSymbol(image, "+[_PFRoutines efficientlyEnumerateManagedObjectsInFetchRequest:usingManagedObjectContext:andApplyBlock:]");
    
    {
        // x26
        NSFetchRequest<OCCKRecordMetadata *> *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[OCCKRecordMetadata entityPath]];
        fetchRequest.returnsObjectsAsFaults = NO;
        fetchRequest.fetchBatchSize = 250;
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"recordZone.ckRecordZoneName = %@ AND recordZone.ckOwnerName = %@", zoneID.zoneName, zoneID.ownerName];
        fetchRequest.affectedStores = @[store];
        
        /*
         __135-[PFCloudKitMetadataPurger _wipeSystemFieldsAndResetUploadStateForMetadataInZoneWithID:inDatabaseWithScope:inStore:usingContext:error:]_block_invoke
         context = x29 - 0xe0 = x20 + 0x20
         _error = x29 - 0xf8 = x20 + 0x28
         _succeed = x29 - 0xf0 = x20 + 0x30
         */
        ((void (*)(Class, id, id, id))symbol)(objc_lookUpClass("_PFRoutines"), fetchRequest, context, ^(NSArray<OCCKRecordMetadata *> * _Nullable metadataArray, NSError * _Nullable __error, BOOL *checkChanges, BOOL *reserved) {
            /*
             self(block) = x20
             checkChanges = x19
             */
            
            if (__error != nil) {
                *checkChanges = YES;
                _succeed = NO;
                _error = [__error retain];
                return;
            }
            
            // x23
            for (OCCKRecordMetadata *metadata in metadataArray) {
                metadata.encodedRecord = nil;
                metadata.ckRecordSystemFields = nil;
                metadata.ckShare = nil;
            }
            
            if (context.hasChanges) {
                BOOL result = [context save:&_error];
                if (!result) {
                    *checkChanges = YES;
                    _succeed = NO;
                    [_error retain];
                }
            }
        });
        
        if (!_succeed) {
            if (_error == nil) {
                os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __func__, __LINE__);
                os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __func__, __LINE__);
            } else {
                if (error != NULL) {
                    *error = [[_error retain] autorelease];
                }
            }
            
            [_error release];
            return _succeed;
        }
    }
    
    {
        // x26
        NSFetchRequest<OCCKMirroredRelationship *> *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[OCCKMirroredRelationship entityPath]];
        fetchRequest.returnsObjectsAsFaults = NO;
        fetchRequest.fetchBatchSize = 250;
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"recordZone.ckRecordZoneName = %@ AND recordZone.ckOwnerName = %@", zoneID.zoneName, zoneID.ownerName];
        fetchRequest.affectedStores = @[store];
        
        /*
         __135-[PFCloudKitMetadataPurger _wipeSystemFieldsAndResetUploadStateForMetadataInZoneWithID:inDatabaseWithScope:inStore:usingContext:error:]_block_invoke_2
         context = sp + 0x268 = x20 + 0x20
         _error = sp + 0x270 = x20 + 0x28
         _succeed = sp + 0x278 = x20 + 0x30
         */
        ((void (*)(Class, id, id, id))symbol)(objc_lookUpClass("_PFRoutines"), fetchRequest, context, ^(NSArray<OCCKMirroredRelationship *> * _Nullable relationships, NSError * _Nullable __error, BOOL *checkChanges, BOOL *reserved) {
            /*
             self(block) = x20
             checkChanges = x19
             */
            
            if (__error != nil) {
                *checkChanges = YES;
                _succeed = NO;
                _error = [__error retain];
                return;
            }
            
            // x24
            for (OCCKMirroredRelationship *relationship in relationships) {
                relationship.ckRecordSystemFields = nil;
                relationship.isUploaded = @NO;
            }
            
            if (context.hasChanges) {
                BOOL result = [context save:&_error];
                if (!result) {
                    *checkChanges = YES;
                    _succeed = NO;
                    [_error retain];
                }
            }
        });
        
        if (!_succeed) {
            if (_error == nil) {
                os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __func__, __LINE__);
                os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __func__, __LINE__);
            } else {
                if (error != NULL) {
                    *error = [[_error retain] autorelease];
                }
            }
            
            [_error release];
            return _succeed;
        }
    }
    
    return _succeed;
}

- (BOOL)_wipeUserRowsAndMetadataForZoneWithID:(CKRecordZoneID *)zoneID inDatabaseWithScope:(CKDatabaseScope)databaseScope inStore:(NSSQLCore *)store usingContext:(NSManagedObjectContext *)context error:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct)) {
    // inlined from __135-[PFCloudKitMetadataPurger purgeMetadataFromStore:inMonitor:withOptions:forRecordZones:inDatabaseWithScope:andTransactionAuthor:error:]_block_invoke
    /*
     self = x25
     databaseScope = sp + 0x68
     store = x24
     managedObjectContext = x28
     */
    
    // sp, #0x2b0
    __block BOOL _succeed = YES;
    // sp, #0x280
    __block NSError * _Nullable _error = nil;
    // x21
    NSMutableDictionary<NSNumber *, NSMutableSet<NSNumber *> *> *dictionary = [[NSMutableDictionary alloc] init];
    
    // x26
    NSFetchRequest<OCCKRecordMetadata *> *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[OCCKRecordMetadata entityPath]];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"recordZone.ckRecordZoneName = %@ AND recordZone.ckOwnerName = %@ AND entityId != NULL AND entityPK != NULL", zoneID.zoneName, zoneID.ownerName];
    fetchRequest.propertiesToFetch = @[@"entityId", @"entityPK"];
    fetchRequest.affectedStores = @[store];
    fetchRequest.fetchBatchSize = 1000;
    
    const void *image = MSGetImageByName("/System/Library/Frameworks/CoreData.framework/CoreData");
    const void *symbol = MSFindSymbol(image, "+[_PFRoutines efficientlyEnumerateManagedObjectsInFetchRequest:usingManagedObjectContext:andApplyBlock:]");
    
    /*
     __113-[PFCloudKitMetadataPurger _wipeUserRowsAndMetadataForZoneWithID:inDatabaseWithScope:inStore:usingContext:error:]_block_invoke
     dictionary = sp + 0x268 = x19 + 0x20
     _succeed = sp + 0x270 = x19 + 0x28
     _error = sp + 0x278 = x19 + 0x30
     */
    ((void (*)(Class, id, id, id))symbol)(objc_lookUpClass("_PFRoutines"), fetchRequest, context, ^(NSArray<OCCKRecordMetadata *> * _Nullable metadataArray, NSError * _Nullable __error, BOOL *checkChanges, BOOL *reserved) {
        /*
         self(block) = x19
         */
        
        if (__error != nil) {
            // checkChanges = x21
            _succeed = NO;
            _error = [__error retain];
            *checkChanges = YES;
            return;
        }
        
        // x21
        NSNumber * _Nullable lastEntityId = nil;
        // x23
        NSMutableSet<NSNumber *> * _Nullable set = nil;
        
        // metadataArray = x20
        // x24
        for (OCCKRecordMetadata *metadata in metadataArray) {
            if (lastEntityId != nil) {
                NSInteger entityId_1 = lastEntityId.integerValue;
                NSInteger entityID_2 = metadata.entityId.integerValue;
                
                if (entityId_1 == entityID_2) {
                    [set addObject:metadata.entityPK];
                    continue;
                }
            }
            
            [lastEntityId release];
            lastEntityId = [metadata.entityId retain];
            [set release];
            
            set = [dictionary[lastEntityId] retain];
            if (set == nil) {
                set = [[NSMutableSet alloc] init];
                dictionary[metadata.entityId] = set;
            }
            
            [set addObject:metadata.entityPK];
        }
        
        [lastEntityId release];
        [set release];
    });
    
    if (!_succeed) {
        if (_error == nil) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __func__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __func__, __LINE__);
        } else {
            if (error != NULL) {
                *error = [[_error retain] autorelease];
            }
        }
        
        [_error release];
        [dictionary release];
        return _succeed;
    }
    
    /*
     __113-[PFCloudKitMetadataPurger _wipeUserRowsAndMetadataForZoneWithID:inDatabaseWithScope:inStore:usingContext:error:]_block_invoke_2
     store = x29 - 0xe0 = x20 + 0x20
     self = x29 - 0xd8= x20 + 0x28
     context = x29 - 0xd0 = x20 + 0x30
     _succeed = x29 - 0xc8 = x20 + 0x38
     _error = x29 - 0xc0 = x20 + 0x40
     */
    [dictionary enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull entityId, NSMutableSet<NSNumber *> * _Nonnull entityPKSet, BOOL * _Nonnull stop) {
        /*
         self(block) = x20
         entityId = x21
         entityPKSet = x22
         stop = x19
         */
        
        const void *symbol = MSFindSymbol(image, "__sqlCoreLookupSQLEntityForEntityID");
        // x23
        NSSQLEntity * _Nullable sqlEntity = ((id (*)(id, unsigned long))symbol)(store, entityId.unsignedIntegerValue);
        
        if (sqlEntity == nil) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Cannot create objectID. Unable to find entity with id '%@' in store '%@'\n%@\n", entityId, store, self);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData:: Cannot create objectID. Unable to find entity with id '%@' in store '%@'\n%@\n", entityId, store, self);
            
            if (!_succeed) *stop = YES;
            return;
        }
        
        // x21
        NSMutableSet<NSManagedObjectID *> *set = [[NSMutableSet alloc] init];
        // x28
        for (NSNumber *entityPK in entityPKSet) {
            if (entityPK.longValue < 1) {
                os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Cannot create objectID: got a 0 pk for entity: %@\n", [sqlEntity entityDescription].name);
                os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Cannot create objectID: got a 0 pk for entity: %@\n", [sqlEntity entityDescription].name);
            } else {
                // x26
                NSManagedObjectID *objectID = [store newObjectIDForEntity:sqlEntity pk:entityPK.longValue];
                [set addObject:objectID];
                [objectID release];
            }
            
            if (set.count >= 500) {
                @autoreleasepool {
                    NSError * _Nullable __error = nil;
                    BOOL result = [self _purgeBatchOfObjectIDs:set fromStore:store inManagedObjectContext:context error:&__error];
                    if (!result) {
                        _succeed = NO;
                        _error = [__error retain];
                    }
                }
            }
            
            if (!_succeed) {
                break;
            }
        }
        
        if (_succeed && (set.count != 0)) {
            @autoreleasepool {
                NSError * _Nullable __error = nil;
                BOOL result = [self _purgeBatchOfObjectIDs:set fromStore:store inManagedObjectContext:context error:&__error];
                if (!result) {
                    _succeed = NO;
                    _error = [__error retain];
                }
            }
        }
        
        [set release];
        if (!_succeed) *stop = YES;
    }];
    
    if (!_succeed) {
        if (_error == nil) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __func__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __func__, __LINE__);
        } else {
            if (error != NULL) {
                *error = [_error autorelease];
            }
        }
        
        [dictionary release];
        return _succeed;
    }
    
    {
        // x26
        NSFetchRequest<OCCKRecordMetadata *> *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[OCCKRecordMetadata entityPath]];
        fetchRequest.returnsObjectsAsFaults = NO;
        fetchRequest.fetchBatchSize = 250;
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"recordZone.ckRecordZoneName = %@ AND recordZone.ckOwnerName = %@", zoneID.zoneName, zoneID.ownerName];
        fetchRequest.affectedStores = @[store];
        
        BOOL result = [self _purgeObjectsMatchingFetchRequest:fetchRequest fromStore:store usingContext:context error:&_error];
        if (!result) {
            _succeed = NO;
            
            if (_error == nil) {
                os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __func__, __LINE__);
                os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __func__, __LINE__);
            } else {
                if (error != NULL) {
                    *error = [[_error retain] autorelease];
                }
            }
            
            [dictionary release];
            return _succeed;
        }
    }
    {
        // x26
        NSFetchRequest<OCCKMirroredRelationship *> *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[OCCKMirroredRelationship entityPath]];
        fetchRequest.returnsObjectsAsFaults = NO;
        fetchRequest.fetchBatchSize = 250;
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"recordZone.ckRecordZoneName = %@ AND recordZone.ckOwnerName = %@", zoneID.zoneName, zoneID.ownerName];
        fetchRequest.affectedStores = @[store];
        BOOL result = [self _purgeObjectsMatchingFetchRequest:fetchRequest fromStore:store usingContext:context error:&_error];
        if (!result) {
            _succeed = NO;
            
            if (_error == nil) {
                os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __func__, __LINE__);
                os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __func__, __LINE__);
            } else {
                if (error != NULL) {
                    *error = [[_error retain] autorelease];
                }
            }
            
            [dictionary release];
            return _succeed;
        }
    }
    
    OCCKRecordZoneMetadata * _Nullable metadata = [OCCKRecordZoneMetadata zoneMetadataForZoneID:zoneID inDatabaseWithScope:databaseScope forStore:store inContext:context error:&_error];
    
    if (metadata == nil) {
        _succeed = NO;
        
        if (_error == nil) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __func__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __func__, __LINE__);
        } else {
            if (error != NULL) {
                *error = [[_error retain] autorelease];
            }
        }
        
        [dictionary release];
        return _succeed;
    }
    
    BOOL result = [context save:&_error];
    if (!result) {
        _succeed = NO;
        
        if (_error == nil) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __func__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __func__, __LINE__);
        } else {
            if (error != NULL) {
                *error = [[_error retain] autorelease];
            }
        }
        
        [dictionary release];
        return _succeed;
    }
    
    [dictionary release];
    
    return _succeed;
}

// NSMutableSet일 수도? _wipeUserRowsAndMetadataForZoneWithID에서 500개 넘어가면 호출되는데, 비워주는 로직이 있을 것 같음
- (BOOL)_purgeBatchOfObjectIDs:(NSSet<NSManagedObjectID *> *)objectIDs fromStore:(NSSQLCore *)store inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct)) {
    abort();
}

- (BOOL)_purgeObjectsMatchingFetchRequest:(NSFetchRequest *)fechRequest fromStore:(NSSQLCore *)store usingContext:(NSManagedObjectContext *)context error:(NSError * _Nullable * _Nullable)error {
    abort();
}

@end
