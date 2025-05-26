//
//  OCCloudKitMetadataPurger.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/22/25.
//

#import "OpenCloudData/Private/OCCloudKitMetadataPurger.h"
#import "OpenCloudData/SPI/CoreData/NSPersistentStore+Private.h"
#import "OpenCloudData/Private/Model/OCCKDatabaseMetadata.h"
#import "OpenCloudData/Private/Model/OCCKRecordZoneMetadata.h"
#import "OpenCloudData/Private/Model/OCCKRecordMetadata.h"
#import "OpenCloudData/Private/Model/OCCKMetadataEntry.h"
#import "OpenCloudData/Private/OCCloudKitMetadataModel.h"
#import "OpenCloudData/Private/Model/OCCKImportPendingRelationship.h"
#import "OpenCloudData/Private/Model/OCCKEvent.h"
#import "OpenCloudData/SPI/CoreData/_PFRoutines.h"
#import "OpenCloudData/Private/Log.h"
#import "OpenCloudData/SPI/OCSPIResolver.h"
#import <objc/runtime.h>

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
        _transactionAuthor = [OCSPIResolver NSCloudKitMirroringDelegateResetSyncAuthor];
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
        NSArray<NSEntityDescription *> *entities = [[managedObjectModel entitiesForConfiguration:store.configurationName] retain];
        // x22
        NSMutableSet<CKRecordZoneID *> *recordZonesSet = [[NSMutableSet alloc] initWithArray:recordZones];
        
        OCCKDatabaseMetadata * _Nullable databaseMetadata = [OCCKDatabaseMetadata databaseMetadataForScope:databaseScope forStore:store inContext:managedObjectContext error:&__error];
        if (databaseMetadata == nil) {
            _succeed = NO;
            _error = [__error retain];
            [set release];
            [entities release];
            [recordZonesSet release];
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
                [entities release];
                [recordZonesSet release];
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
                [entities release];
                [recordZonesSet release];
                return;
            }
        }
        
        [OCCKMetadataEntry updateOrInsertMetadataEntryWithKey:[OCSPIResolver NSCloudKitMirroringDelegateBypassHistoryOnExportKey] boolValue:YES forStore:store intoManagedObjectContext:managedObjectContext error:&__error];
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
            [entities release];
            [recordZonesSet release];
            return;
        }
        
        if (options & (1 << 5)) {
            [set addObject:[OCSPIResolver NSCloudKitMirroringDelegateLastHistoryTokenKey]];
        }
        
        if (((options & 0b1100) != 0) && _succeed) {
            if (options & (1 << 2)) {
                // <+3968>
                // x20
                OCCKDatabaseMetadata * _Nullable metadata = [OCCKDatabaseMetadata databaseMetadataForScope:databaseScope forStore:store inContext:managedObjectContext error:&__error];
                
                if (metadata == nil) {
                    if (__error != nil) {
                        _succeed = NO;
                    }
                } else {
                    metadata.currentChangeToken = nil;
                    metadata.hasSubscription = NO;
                }
                
                // x20
                NSSet<OCCKRecordZoneMetadata *> *recordZones = metadata.recordZones;
                // x23
                for (OCCKRecordZoneMetadata *metadata in recordZones) {
                    metadata.currentChangeToken = nil;
                    metadata.hasRecordZone = NO;
                    metadata.hasSubscription = NO;
                    metadata.supportsFetchChanges = NO;
                    metadata.supportsAtomicChanges = NO;
                    metadata.supportsRecordSharing = NO;
                }
                
                BOOL result = [managedObjectContext save:&__error];
                if (!result) {
                    _succeed = NO;
                } else {
                    for (CKRecordZoneID *zoneID in recordZonesSet) {
                        BOOL result = [self _purgeZoneRelatedObjectsInZoneWithID:zoneID inDatabaseWithScope:databaseScope withOptions:options inStore:store usingContext:managedObjectContext error:&__error];
                        
                        if (!result) {
                            _succeed = NO;
                            break;
                        }
                    }
                }
            } else if (options & (1 << 3)) {
                // <+3560>
                if (recordZonesSet.count == 0) {
                    os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Asked to purge zone metadata (trying to recreate after the purge) without any zones from which to purge.\n");
                    os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Asked to purge zone metadata (trying to recreate after the purge) without any zones from which to purge.\n");
                }
                
                // x21
                for (CKRecordZoneID *zoneID in recordZonesSet) {
                    BOOL result = [self _purgeZoneRelatedObjectsInZoneWithID:zoneID inDatabaseWithScope:databaseScope withOptions:options inStore:store usingContext:managedObjectContext error:&__error];
                    if (!result) {
                        _succeed = NO;
                        break;
                    }
                    
                    // x21
                    OCCKRecordZoneMetadata * _Nullable metadata = [OCCKRecordZoneMetadata zoneMetadataForZoneID:zoneID inDatabaseWithScope:databaseScope forStore:store inContext:managedObjectContext createIfMissing:NO error:&__error];
                    if (metadata == nil) {
                        if (__error == nil) {
                            continue;
                        } else {
                            _succeed = NO;
                            break;
                        }
                    }
                    
                    if ((options & (1 << 0)) == 0) {
                        metadata.currentChangeToken = nil;
                        metadata.hasRecordZone = NO;
                        metadata.hasSubscription = NO;
                    } else {
                        [managedObjectContext deleteObject:metadata];
                    }
                }
            }
            
            // nop
        }
        
        if (!_succeed) {
            _error = [__error retain];;
            [set release];
            [entities release];
            [recordZonesSet release];
            return;
        }
        
        if (options & (1 << 4)) {
            [set addObject:[OCSPIResolver NSCloudKitMirroringDelegateCheckedCKIdentityDefaultsKey]];
            [set addObject:[OCSPIResolver NSCloudKitMirroringDelegateCKIdentityRecordNameDefaultsKey]];
        }
        
        if (set.count == 0) {
            [set release];
            [entities release];
            [recordZonesSet release];
            return;
        }
        
        NSDictionary<NSString *,OCCKMetadataEntry *> * _Nullable entries = [OCCKMetadataEntry entriesForKeys:set.allObjects fromStore:store inManagedObjectContext:managedObjectContext error:&__error];
        if (entries == nil) {
            _succeed = NO;
            _error = [__error retain];;
            [set release];
            [entities release];
            [recordZonesSet release];
            return;
        }
        
        for (OCCKMetadataEntry *entry in entries) {
            [managedObjectContext deleteObject:entry];
        }
        
        _succeed = [managedObjectContext save:&_error];
        if (!_succeed) {
            _error = [__error retain];;
        }
        
        [set release];
        [entities release];
        [recordZonesSet release];
        return;
    }];
    
    if (!_succeed) {
        if (_error == nil) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
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

- (BOOL)purgeMetadataMatchingObjectIDs:(NSSet<NSManagedObjectID *> *)objectIDs inRequest:(__kindof OCCloudKitMirroringRequest *)request inStore:(NSSQLCore *)store withMonitor:(OCCloudKitStoreMonitor *)monitor error:(NSError * _Nullable *)error {
    /*
     objectIDs = x21
     store = x20
     error = x19
     */
    
    // x29 - #0x60
    __block BOOL _succeed = YES;
    // sp + 0x50
    __block NSError * _Nullable _error = nil;
    
    // x22
    NSManagedObjectContext *context = [monitor newBackgroundContextForMonitoredCoordinator];
    context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
    
    /*
     __95-[PFCloudKitMetadataPurger purgeMetadataMatchingObjectIDs:inRequest:inStore:withMonitor:error:]_block_invoke
     objectIDs = sp + 0x28 = x19 + 0x20
     store = sp + 0x30 = x19 + 0x28
     context = sp + 0x38 = x19 + 0x30
     _succeed = sp + 0x40 = x19 + 0x38
     _error = sp + 0x48 = x19 + 0x40
     */
    [context performBlockAndWait:^{
        /*
         self(block) = x19
         */
        // sp + 0x20
        NSDictionary<NSNumber *, NSSet<NSNumber *> *> *map = [OCCloudKitMetadataModel createMapOfEntityIDToPrimaryKeySetForObjectIDs:objectIDs fromStore:store];
        
        // x26
        for (NSNumber *entityID in map) @autoreleasepool {
            // x25
            NSMutableSet *set = [[NSMutableSet alloc] init];
            // x27
            NSFetchRequest<OCCKRecordMetadata *> *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[OCCKRecordMetadata entityPath]];
            fetchRequest.predicate = [NSPredicate predicateWithFormat:@"entityId = %@ AND entityPK IN %@", entityID, map[entityID]];
            fetchRequest.fetchBatchSize = 100;
            fetchRequest.affectedStores = @[store];
            
            // x26
            NSArray<OCCKRecordMetadata *> * _Nullable results = [context executeFetchRequest:fetchRequest error:&_error];
            if (results == nil) {
                _succeed = NO;
                [_error retain];
                
#warning TODO: Error Leak
                BOOL result = [context save:&_error];
                if (!result) {
                    [_error retain];
                    _succeed = NO;
                }
                
                [context reset];
                [set release];
                break;
            }
            
            // x28
            for (OCCKRecordMetadata *metadata in results) {
                if (metadata.ckRecordName != nil) {
                    [set addObject:metadata.ckRecordName];
                }
                
                metadata.recordZone.currentChangeToken = nil;
                metadata.recordZone.lastFetchDate = nil;
                metadata.recordZone.database.currentChangeToken = nil;
                metadata.recordZone.database.lastFetchDate = nil;
                [context deleteObject:metadata];
            }
            
            NSArray<NSString *> *entityNames = @[
                [OCCKMirroredRelationship entityPath],
                [OCCKImportPendingRelationship enentityPath]
            ];
            
            for (NSString *entityName in entityNames) {
                NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
                fetchRequest.predicate = [NSPredicate predicateWithFormat:@"recordName IN %@ OR relatedRecordName IN %@", set, set];
                
                // x28
                NSBatchDeleteRequest *request = [[NSBatchDeleteRequest alloc] initWithFetchRequest:fetchRequest];
                request.resultType = NSBatchDeleteResultTypeStatusOnly;
                request.affectedStores = @[store];
                request.resultType = NSBatchDeleteResultTypeStatusOnly;
                
                NSBatchDeleteResult * _Nullable result = [context executeRequest:request error:&_error];
                BOOL boolValue = ((NSNumber *)result.result).boolValue;
                
                if (boolValue) {
                    [request release];
                } else {
                    _succeed = NO;
                    [_error retain];
                    [request release];
                    break;
                }
            }
            
#warning TODO: Error Leak
                BOOL result = [context save:&_error];
                if (!result) {
                    [_error retain];
                    _succeed = NO;
                }
                
                [context reset];
                [set release];
                break;
        }
        
        [map release];
    }];
    
    if (!_succeed) {
        if (_error == nil) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        } else {
            if (error != NULL) {
                *error = [[_error retain] autorelease];
            }
        }
        
        [_error release];
        return _succeed;
    }
    
    return _succeed;
}

- (BOOL)purgeMetadataAfterAccountChangeFromStore:(NSSQLCore *)store inMonitor:(OCCloudKitStoreMonitor *)monitor inDatabaseWithScope:(CKDatabaseScope)databaseScope error:(NSError * _Nullable *)error {
    /*
     store = x22
     databaseScope = x21
     error = x20
     */
    
    // x29, #-0x60
    __block BOOL _succeed = YES;
    // sp, #0x50
    __block NSError * _Nullable _error = nil;
    // x19
    NSManagedObjectContext *context = [monitor newBackgroundContextForMonitoredCoordinator];
    context.transactionAuthor = [OCSPIResolver NSCloudKitMirroringDelegateResetSyncAuthor];
    
    /*
     __105-[PFCloudKitMetadataPurger purgeMetadataAfterAccountChangeFromStore:inMonitor:inDatabaseWithScope:error:]_block_invoke
     store = sp + 0x28 = x19 + 0x20
     context = sp + 0x30 = x19 + 0x28
     _succeed = sp + 0x38 = x19 + 0x30
     _error = sp + 0x40 = x19 + 0x38
     databaseScope = sp + 0x48 = x19 + 0x40
     */
    [context performBlockAndWait:^{
        /*
         self = x19
         */
        // sp, #0x148
        NSError * _Nullable __error = nil;
        // x20
        NSManagedObjectModel *managedObjectModel = [store _persistentStoreCoordinator].managedObjectModel;
        // sp + 0x30
        NSArray<NSEntityDescription *> *entities = [[managedObjectModel entitiesForConfiguration:store.configurationName] retain];
        
        // x24
        for (NSEntityDescription *entity in entities) {
            os_log_with_type(_OCLogGetLogStream(0x11), OS_LOG_TYPE_DEFAULT, "OpenCloudData+CloudKit: %s(%d): %@ - Removing rows after account change: %@", __func__, __LINE__, context.transactionAuthor, entity.name);
            
            // x24
            NSBatchDeleteRequest *request = [[NSBatchDeleteRequest alloc] initWithFetchRequest:[NSFetchRequest fetchRequestWithEntityName:entity.name]];
            request.affectedStores = @[store];
            request.resultType = NSBatchDeleteResultTypeStatusOnly;
            
            NSBatchDeleteResult * _Nullable result = [context executeRequest:request error:&__error];
            BOOL boolValue = ((NSNumber *)result.result).boolValue;
            
            if (!boolValue) {
                _succeed = NO;
                [request release];
                _error = [__error retain];
                [entities release];
                return;
            }
            
            [request release];
        }
        
        NSNumber *version = [OCSPIResolver _PFRoutines__getPFBundleVersionNumber:objc_lookUpClass("_PFRoutines")];
        // x20 / sp + 0x38
        NSManagedObjectModel *model = [OCCloudKitMetadataModel newMetadataModelForFrameworkVersion:version];
        // x28
        NSMutableSet<NSString *> *set = [[NSMutableSet alloc] init];
//            [set addObject:NSStringFromClass([OCCKMetadataEntry class])];
//            [set addObject:NSStringFromClass([OCCKRecordZoneMetadata class])];
//            [set addObject:NSStringFromClass([OCCKDatabaseMetadata class])];
//            [set addObject:NSStringFromClass([OCCKEvent class])];
        // Core Data와 호환성을 갖기 위함
        [set addObject:NSStringFromClass(objc_lookUpClass("NSCKMetadataEntry"))];
        [set addObject:NSStringFromClass(objc_lookUpClass("NSCKRecordZoneMetadata"))];
        [set addObject:NSStringFromClass(objc_lookUpClass("NSCKDatabaseMetadata"))];
        [set addObject:NSStringFromClass(objc_lookUpClass("NSCKEvent"))];
        
        // x26
        for (NSEntityDescription *entity in model) {
            if ([set containsObject:entity.name]) {
                continue;
            }
            
            NSString *entityPath = [OCSPIResolver _PFModelMapPathForEntity:entity];
            // x24
            NSBatchDeleteRequest *request = [[NSBatchDeleteRequest alloc] initWithFetchRequest:[NSFetchRequest fetchRequestWithEntityName:entityPath]];
            request.resultType = NSBatchDeleteResultTypeObjectIDs;
            request.affectedStores = @[store];
            
            // x27
            NSBatchDeleteResult * _Nullable result = [context executeRequest:request error:&__error];
            [request release];
            
            if (result.result == nil) {
                _succeed = NO;
                os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData+CloudKit: %s(%d): Failed to purge cloudkit metadata entity (%@): %@", __func__, __LINE__, entity.name, __error);
                [model release];
                [set release];
                _error = [__error retain];
                [entities release];
                return;
            }
            
            os_log_with_type(_OCLogGetLogStream(0x11), OS_LOG_TYPE_DEFAULT, "OpenCloudData+CloudKit: %s(%d): %@ - Removed cloud metadata after account change %@", __func__, __LINE__, context.transactionAuthor, entity.name);
            
            // x24
            NSArray<NSManagedObjectID *> * _Nullable deletedObjectIDs = result.result;
            
            if (deletedObjectIDs.count != 0) {
                [NSManagedObjectContext mergeChangesFromRemoteContextSave:@{NSDeletedObjectsKey: deletedObjectIDs} intoContexts:@[context]];
            }
        }
        
        [model release];
        [set release];
        
        // x21
        OCCKDatabaseMetadata * _Nullable metadata = [OCCKDatabaseMetadata databaseMetadataForScope:databaseScope forStore:store inContext:context error:&__error];
        if (metadata == nil) {
            _succeed = NO;
            _error = [__error retain];
            [entities release];
            return;
        }
        
        metadata.currentChangeToken = nil;
        metadata.hasSubscription = NO;
        
        // x21
        NSSet<OCCKRecordZoneMetadata *> *recordZones = metadata.recordZones;
        for (OCCKRecordZoneMetadata *metadata in recordZones) {
            metadata.currentChangeToken = nil;
            metadata.hasRecordZone = NO;
            metadata.hasSubscription = NO;
            metadata.supportsFetchChanges = NO;
            metadata.supportsAtomicChanges = NO;
            metadata.supportsRecordSharing = NO;
        }
        
        NSDictionary<NSString *, OCCKMetadataEntry *> * _Nullable entries = [OCCKMetadataEntry entriesForKeys:@[
            [OCSPIResolver NSCloudKitMirroringDelegateLastHistoryTokenKey],
            [OCSPIResolver NSCloudKitMirroringDelegateCheckedCKIdentityDefaultsKey],
            [OCSPIResolver NSCloudKitMirroringDelegateCKIdentityRecordNameDefaultsKey]
        ]
                                                                                                    fromStore:store
                                                                                       inManagedObjectContext:context
                                                                                                        error:&__error];
        
        if (entries == nil) {
            _succeed = NO;
            _error = [__error retain];
            [entities release];
            return;
        }
        
        for (OCCKMetadataEntry *entry in entries.allValues) {
            [context deleteObject:entry];
        }
        
        _succeed = [context save:&__error];
        if (!_succeed) {
            _error = [__error retain];
        }
        
        [entities release];
    }];
    
    if (!_succeed) {
        if (_error == nil) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        } else {
            if (error != NULL) {
                *error = [[_error retain] autorelease];
            }
        }
    }
    
    [_error release];
    return _succeed;
}

- (BOOL)deleteZoneMetadataFromStore:(NSSQLCore *)store inMonitor:(OCCloudKitStoreMonitor *)monitor forRecordZones:(NSArray<CKRecordZoneID *> *)recordZones inDatabaseWithScope:(CKDatabaseScope)databaseScope error:(NSError * _Nullable *)error {
    /*
     store = x22
     recordZones = x23
     databaseScope = x21
     error = x20
     */
    
    // x29 - 0x70
    __block BOOL _succeed = YES;
    // sp, #0x50
    __block NSError * _Nullable _error = nil;
    // x19
    NSManagedObjectContext *context = [monitor newBackgroundContextForMonitoredCoordinator];
    
    context.transactionAuthor = [OCSPIResolver NSCloudKitMirroringDelegateResetSyncAuthor];
    
    /*
     __107-[PFCloudKitMetadataPurger deleteZoneMetadataFromStore:inMonitor:forRecordZones:inDatabaseWithScope:error:]_block_invoke
     recordZones = sp + 0x20 = x19 + 0x20
     store = sp + 0x28 = x19 + 0x28
     context = sp + 0x30 = x19 + 0x30
     _succeed = sp + 0x38 = x19 + 0x38
     _error = sp + 0x40 = x19 + 0x40
     databaseScope = sp + 0x48 = x19 + 0x48
     */
    [context performBlockAndWait:^{
        /*
         self = x19
         */
        
        // sp + 0x58
        NSError * _Nullable __error = nil;
        
        // x20
        NSMutableSet<CKRecordZoneID *> *set = [[NSMutableSet alloc] initWithArray:recordZones];
        
        if (set.count == 0) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Asked to purge zone metadata (trying to recreate after the purge) without any zones from which to purge.\n");
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Asked to purge zone metadata (trying to recreate after the purge) without any zones from which to purge.\n");
        }
        
        // x25
        for (CKRecordZoneID *zondID in set) {
            // x26
            OCCKRecordZoneMetadata * _Nullable metadata = [OCCKRecordZoneMetadata zoneMetadataForZoneID:zondID inDatabaseWithScope:databaseScope forStore:store inContext:context error:&__error];
            
            if (metadata == nil) {
                if (__error == nil) {
                    _succeed = NO;
                    _error = [__error retain];
                    [set release];
                    return;
                }
            } else {
                if (metadata.records.count != 0) {
                    os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Attempting to delete a zone metadata that has records (%ld): %@ - %@\n", databaseScope, store.URL, zondID);
                    os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Attempting to delete a zone metadata that has records (%ld): %@ - %@\n", databaseScope, store.URL, zondID);
                }
                
                [context deleteObject:metadata];
            }
        }
        
        _succeed = [context save:&__error];
        if (!_succeed) {
            _error = [__error retain];
        }
        [set release];
    }];
    
    if (!_succeed) {
        if (_error == nil) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        } else {
            if (error != NULL) {
                *error = [[_error retain] autorelease];
            }
        }
    }
    
    [_error release];
    [context release];
    
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
        [OCSPIResolver _PFRoutines_efficientlyEnumerateManagedObjectsInFetchRequest_usingManagedObjectContext_andApplyBlock_:objc_lookUpClass("_PFRoutines") x1:fetchRequest x2:context x3:^(NSArray<OCCKRecordMetadata *> * _Nullable metadataArray, NSError * _Nullable __error, BOOL *checkChanges, BOOL *reserved) {
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
        }];
        
        if (!_succeed) {
            if (_error == nil) {
                os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
                os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
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
        [OCSPIResolver _PFRoutines_efficientlyEnumerateManagedObjectsInFetchRequest_usingManagedObjectContext_andApplyBlock_:objc_lookUpClass("_PFRoutines") x1:fetchRequest x2:context x3:^(NSArray<OCCKMirroredRelationship *> * _Nullable relationships, NSError * _Nullable __error, BOOL *checkChanges, BOOL *reserved) {
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
        }];
        
        if (!_succeed) {
            if (_error == nil) {
                os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
                os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
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
    
    /*
     __113-[PFCloudKitMetadataPurger _wipeUserRowsAndMetadataForZoneWithID:inDatabaseWithScope:inStore:usingContext:error:]_block_invoke
     dictionary = sp + 0x268 = x19 + 0x20
     _succeed = sp + 0x270 = x19 + 0x28
     _error = sp + 0x278 = x19 + 0x30
     */
    [OCSPIResolver _PFRoutines_efficientlyEnumerateManagedObjectsInFetchRequest_usingManagedObjectContext_andApplyBlock_:objc_lookUpClass("_PFRoutines") x1:fetchRequest x2:context x3:^(NSArray<OCCKRecordMetadata *> * _Nullable metadataArray, NSError * _Nullable __error, BOOL *checkChanges, BOOL *reserved) {
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
    }];
    
    if (!_succeed) {
        if (_error == nil) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
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
        
        // x23
        NSSQLEntity * _Nullable sqlEntity = [OCSPIResolver _sqlCoreLookupSQLEntityForEntityID:store x1:entityId.unsignedIntegerValue];
        
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
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        } else {
            if (error != NULL) {
                *error = [[_error retain] autorelease];
            }
        }
        
        [_error release];
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
                os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
                os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
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
                os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
                os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
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
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
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
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
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

- (BOOL)_purgeBatchOfObjectIDs:(NSSet<NSManagedObjectID *> *)objectIDs fromStore:(NSSQLCore *)store inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct)) {
    /*
     objectIDs = x23
     store = x22
     managedObjectContext = x20
     error = x19
     */
    
    // x21
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:objectIDs.anyObject.entity.name];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"SELF IN %@", objectIDs];
    
    NSBatchDeleteRequest *request = [[NSBatchDeleteRequest alloc] initWithFetchRequest:fetchRequest];
    request.resultType = NSBatchDeleteResultTypeStatusOnly;
    request.affectedStores = @[store];
    
    // x23
    NSBatchDeleteResult *result = [managedObjectContext executeRequest:request error:error];
    BOOL boolValue = ((NSNumber *)result.result).boolValue;
    
    [fetchRequest release];
    [request release];
    
    return boolValue;
}

- (BOOL)_purgeObjectsMatchingFetchRequest:(NSFetchRequest *)fetchRequest fromStore:(NSSQLCore *)store usingContext:(NSManagedObjectContext *)context error:(NSError * _Nullable * _Nullable)error {
    /*
     fetchRequest = x0 = x1
     context = x1 = x2
     error = x29 - 0x98 = x19
     */
    
    
    // x29, #-0x50
    __block BOOL _succeed = YES;
    // sp, #0x40
    __block NSError * _Nullable _error = nil;
    
    /*
     __91-[PFCloudKitMetadataPurger _purgeObjectsMatchingFetchRequest:fromStore:usingContext:error:]_block_invoke
     context = sp + 0x28 = x21 + 0x20
     _error = sp + 0x30 = x21 + 0x28
     _succeed = sp + 0x38 = x21 + 0x30
     */
    [OCSPIResolver _PFRoutines_efficientlyEnumerateManagedObjectsInFetchRequest_usingManagedObjectContext_andApplyBlock_:objc_lookUpClass("_PFRoutines") x1:fetchRequest x2:context x3:^(NSArray<__kindof NSManagedObject *> * _Nullable objects, NSError * _Nullable __error, BOOL *checkChanges, BOOL *reserved) {
        /*
         self(block) = x21
         checkChanges = x19
         */
        
        if (__error != nil) {
            _succeed = NO;
            _error = [__error retain];
            return;
        }
        
        /*
         x20 = reserved
         objects = x22
         */
        
        for (__kindof NSManagedObject *object in objects) {
            [context deleteObject:object];
        }
        
        if (context.hasChanges) {
            BOOL result = [context save:&_error];
            if (!result) {
                _succeed = NO;
                [_error retain];
                *checkChanges = YES;
                *reserved = YES; // ???
            }
        }
    }];
    
    if (!_succeed) {
        if (_error == nil) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        } else {
            if (error != NULL) {
                *error = [[_error retain] autorelease];
            }
        }
    }
    
    [_error release];
    return _succeed;
}

- (BOOL)_purgeZoneRelatedObjectsInZoneWithID:(CKRecordZoneID *)zoneID inDatabaseWithScope:(CKDatabaseScope)databaseScope withOptions:(NSUInteger)options inStore:(NSSQLCore *)store usingContext:(NSManagedObjectContext *)context error:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct)) {
    /*
     zoneID = x22
     options = x23
     store = x21
     context = x20
     error = x19
     */
    
    NSError * _Nullable _error = nil;
    
    if ((options & 0x41) != 0) {
        NSFetchRequest<OCCKRecordMetadata *> *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[OCCKRecordMetadata entityPath]];
        fetchRequest.fetchBatchSize = 1000;
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"recordZone.ckRecordZoneName = %@ AND recordZone.ckOwnerName = %@", zoneID.zoneName, zoneID.ownerName];
        fetchRequest.affectedStores = @[store];
        BOOL result = [self _purgeObjectsMatchingFetchRequest:fetchRequest fromStore:store usingContext:context error:&_error];
        if (!result) {
            if (_error == nil) {
                os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
                os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            } else {
                if (error != NULL) {
                    *error = _error;
                }
            }
            
            return NO;
        }
    }
    
    // <+268>
    if ((options & 0x81) != 0) {
        NSFetchRequest<OCCKMirroredRelationship *> *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[OCCKMirroredRelationship entityPath]];
        fetchRequest.fetchBatchSize = 1000;
        fetchRequest.predicate = [NSPredicate predicateWithFormat: @"recordZone.ckRecordZoneName = %@ AND recordZone.ckOwnerName = %@", zoneID.zoneName, zoneID.ownerName];
        fetchRequest.affectedStores = @[store];
        
        // x23
        NSBatchDeleteRequest *request = [[NSBatchDeleteRequest alloc] initWithFetchRequest:fetchRequest];
        request.resultType = NSBatchDeleteResultTypeStatusOnly;
        request.affectedStores = @[store];
        request.resultType = NSBatchDeleteResultTypeStatusOnly; // ???
        
        NSBatchDeleteResult * _Nullable result = [context executeRequest:request error:&_error];
        BOOL boolValue = ((NSNumber *)result.result).boolValue;
        [request release];
        
        if (!boolValue) {
            if (_error == nil) {
                os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
                os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            } else {
                if (error != NULL) {
                    *error = _error;
                }
            }
            
            return NO;
        }
    }
    
    return YES;
}

@end
