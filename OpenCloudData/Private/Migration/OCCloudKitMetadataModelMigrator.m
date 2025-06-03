//
//  OCCloudKitMetadataModelMigrator.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/29/25.
//

#import "OpenCloudData/Private/Migration/OCCloudKitMetadataModelMigrator.h"
#import "OpenCloudData/SPI/CoreData/NSSQLBlockRequestContext.h"
#import "OpenCloudData/Private/Log.h"
#import "OpenCloudData/SPI/CoreData/NSManagedObjectContext+Private.h"
#import "OpenCloudData/SPI/CoreData/NSSQLiteConnection.h"
#import "OpenCloudData/Private/OCCloudKitMetadataModel.h"
#import "OpenCloudData/SPI/CoreData/NSSQLModel.h"
#import "OpenCloudData/SPI/CoreData/NSKnownKeysDictionary.h"
#import "OpenCloudData/SPI/OCSPIResolver.h"
#import "OpenCloudData/SPI/CoreData/SQLProperty/NSSQLProperty.h"
#import "OpenCloudData/SPI/CoreData/SQLProperty/NSSQLAttribute.h"
#import "OpenCloudData/Private/Model/OCCKMirroredRelationship.h"
#import "OpenCloudData/SPI/CoreData/NSManagedObjectID+Private.h"
#import "OpenCloudData/SPI/CoreData/SQLProperty/NSSQLPrimaryKey.h"
#import "OpenCloudData/Private/Model/OCCKRecordZoneMetadata.h"
#import "OpenCloudData/SPI/CoreData/NSPersistentHistoryToken+Private.h"
#import "OpenCloudData/Private/Model/OCCKMetadataEntry.h"
#import "OpenCloudData/Private/OCCloudKitMirroringDelegatePreJazzkonMetadata.h"
#import "OpenCloudData/Private/OCCloudKitSerializer.h"
#import "OpenCloudData/Private/Model/OCCKHistoryAnalyzerState.h"
#import "OpenCloudData/SPI/CoreData/NSPersistentStore+Private.h"
#import "OpenCloudData/Private/OCCloudKitMirroringDelegate.h"
#include <objc/runtime.h>

@implementation OCCloudKitMetadataModelMigrator

- (instancetype)initWithStore:(NSSQLCore *)store metadataContext:(NSManagedObjectContext *)metadataContext databaseScope:(CKDatabaseScope)databaseScope metricsClient:(OCCloudKitMetricsClient *)metricsClient {
    /*
     store = x23
     metadataContext = x22
     databaseScope = x20
     metricsClient = x19
     */
    if (self = [super init]) {
        _store = [store retain];
        _metadataContext = [metadataContext retain];
        metadataContext.transactionAuthor = [OCSPIResolver NSCloudKitMirroringDelegateMigrationAuthor];
        _context = [[OCCloudKitMetadataMigrationContext alloc] init];
        _databaseScope = databaseScope;
        _metricsClient = [metricsClient retain];
    }
    
    return self;
}

- (void)dealloc {
    [_store release];
    [_metadataContext release];
    [_context release];
    [_metricsClient release];
    [super dealloc];
}

- (BOOL)checkAndPerformMigrationIfNecessary:(NSError * _Nullable *)error {
    /*
     self = x20
     error = x19
     */
    
    // sp, #0x68
    __block BOOL _succeed = YES;
    // sp, #0x38
    __block NSError * _Nullable _error = nil;
    
    /*
     __71-[PFCloudKitMetadataModelMigrator checkAndPerformMigrationIfNecessary:]_block_invoke
     self = sp + 0x20 = x27 + 0x20
     _succeed = sp + 0x28 = x27 + 0x28
     _error = sp + 0x30 = x27 + 0x30
     */
    // x21
    NSSQLBlockRequestContext *requestContext = [[objc_lookUpClass("NSSQLBlockRequestContext") alloc] initWithBlock:^(NSSQLStoreRequestContext * _Nullable context) {
        /*
         self(block) = x27
         context = x20
         self = x21
         */
        
        _succeed = YES;
        
        // x26
        NSSQLiteConnection * _Nullable connection;
        {
            if (context == nil) {
                connection = nil;
            } else {
                assert(object_getInstanceVariable(context, "_connection", (void **)&connection) != NULL);
            }
        }
        
        // <+84>
        // w19
        BOOL result = [self prepareContextWithConnection:connection error:&_error];
        // <+1068>
        
        if (!result) {
            _succeed = NO;
            [_error retain];
            return;
        }
        
        result = [self calculateMigrationStepsWithConnection:connection error:&_error];
        if (!result) {
            _succeed = NO;
            [_error retain];
            return;
        }
        
        _succeed = [self _redacted_1:connection error:&_error];
        if (!_succeed) {
            [_error retain];
        }
    }
                                                                                                           context:nil
                                                                                                           sqlCore:_store];
    
    [OCSPIResolver NSSQLCore_dispatchRequest_withRetries_:_store x1:requestContext x2:0];
    [requestContext release];
    
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
    
    _succeed = [self commitMigrationMetadataAndCleanup:&_error];
    
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
    
    return _succeed;
}

- (BOOL)commitMigrationMetadataAndCleanup:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct)) {
    // inlined from -[PFCloudKitMetadataModelMigrator checkAndPerformMigrationIfNecessary:]
    // sp, #0xf0
    __block BOOL _succeed = YES;
    // sp, #0xc0
    __block NSError * _Nullable _error = nil;
    
    /*
     __69-[PFCloudKitMetadataModelMigrator commitMigrationMetadataAndCleanup:]_block_invoke
     self = sp + 0xa8 = *(sp + 0x38) + 0x20
     _succeed = sp + 0xb0 = *(sp + 0x38) + 0x28
     _error = sp + 0xb8 = *(sp + 0x38) + 0x30
     */
    [_metadataContext performBlockAndWait:^{
        /*
         self(block) = sp + 0x38
         */
        // sp, #0x180
        NSError * _Nullable __error = nil;
        
        @try {
            if (![OCSPIResolver _PFRoutines__isInMemoryStore_:objc_lookUpClass("_PFRoutines") x1:self->_store]) {
                // sp + 0x188
                NSError * _Nullable __error = nil;
                BOOL result = [self->_metadataContext setQueryGenerationFromToken:nil error:&__error];
                
                if (!result) {
                    os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData+CloudKit: %s(%d): %@: Unable to set query generation on moc: %@", __func__, __LINE__, self, __error);
                }
            }
            
            // <+288>
            OCCKMetadataEntry * _Nullable entry = [OCCKMetadataEntry updateOrInsertMetadataEntryWithKey:@"PFCloudKitMetadataModelMigratorMigrationBeganCommitKey" boolValue:YES forStore:self->_store intoManagedObjectContext:self->_metadataContext error:&__error];
            BOOL hasError;
            if (entry != nil) {
                hasError = ![self->_metadataContext save:&__error];
            } else {
                hasError = YES;
            }
            if (hasError) {
                _succeed = NO;
                _error = [__error retain];
                return;
            }
            
            if (![OCSPIResolver _PFRoutines__isInMemoryStore_:objc_lookUpClass("_PFRoutines") x1:self->_store]) {
                // sp + 0x188
                NSError * _Nullable __error = nil;
                BOOL result = [self->_metadataContext setQueryGenerationFromToken:NSQueryGenerationToken.currentQueryGenerationToken error:&__error];
                
                if (!result) {
                    os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData+CloudKit: %s(%d): %@: Unable to set query generation on moc: %@", __func__, __LINE__, self, __error);
                }
            }
            
            // x21
            OCCKMetadataEntry *entry_1 = [OCCKMetadataEntry entryForKey:[OCSPIResolver PFCloudKitMetadataFrameworkVersionKey] fromStore:self->_store inManagedObjectContext:self->_metadataContext error:&__error];
            if (__error != nil) {
                _succeed = NO;
                _error = [__error retain];
                return;
            }
            
            OCCKMetadataEntry *entry_2 = [OCCKMetadataEntry entryForKey:[OCSPIResolver PFCloudKitMetadataModelVersionHashesKey] fromStore:self->_store inManagedObjectContext:self->_metadataContext error:&__error];
            if (__error != nil) {
                _succeed = NO;
                _error = [__error retain];
                return;
            }
            
            // <+1560>
            // x20
            NSObject<NSSecureCoding> *transformedValue = [entry_2 transformedValue];
            
            BOOL flag;
            if (transformedValue != nil) {
                NSManagedObjectModel * _Nullable currentModel;
                {
                    OCCloudKitMetadataMigrationContext * _Nullable context = self->_context;
                    if (context == nil) {
                        currentModel = nil;
                    } else {
                        currentModel = context->_currentModel;
                    }
                }
                
                if ([currentModel.entityVersionHashesByName isEqual:transformedValue]) {
                    flag = NO;
                } else {
                    flag = YES;
                }
            } else {
                flag = YES;
            }
            
            // <+1608>
            if (flag) {
                BOOL result = [self computeAncillaryEntityPrimaryKeyTableEntriesForStore:self->_store error:&__error];
                if (!result) {
                    _succeed = NO;
                    _error = [__error retain];
                }
            }
            // <+1672>
            if (!_succeed) return;
            
            NSManagedObjectModel * _Nullable currentModel;
            {
                OCCloudKitMetadataMigrationContext * _Nullable context = self->_context;
                if (context == nil) {
                    currentModel = nil;
                } else {
                    currentModel = context->_currentModel;
                }
            }
            
            [OCCKMetadataEntry updateOrInsertMetadataEntryWithKey:[OCSPIResolver PFCloudKitMetadataModelVersionHashesKey] transformedValue:(NSObject<NSSecureCoding> *)currentModel forStore:self->_store intoManagedObjectContext:self->_metadataContext error:&__error];
            if (entry == nil) {
                _succeed = NO;
                _error = [__error retain];
                return;
            }
            
            BOOL flag_0;
            // w23
            BOOL flag_1;
            // w8 // sp + 0x14
            BOOL flag_2;
            if (entry_1 == nil) {
                flag_0 = YES;
                flag_1 = YES;
                flag_2 = NO;
            } else {
                flag_0 = (entry_1.integerValue.unsignedIntegerValue <= 0x399);
                // w23
                flag_1 = (entry_1.integerValue.unsignedIntegerValue < 0x3b1);
                // w8 // sp + 0x14
                flag_2 = (entry_1.integerValue.unsignedIntegerValue < 0x3b3);
            }
            
            if (flag_0) {
                // <+1908>
                // x21
                OCCloudKitMirroringDelegatePreJazzkonMetadata *preJazzkonMetadata = [[OCCloudKitMirroringDelegatePreJazzkonMetadata alloc] initWithStore:self->_store];
                BOOL result = [preJazzkonMetadata load:&__error];
                if (!result) {
                    _succeed = NO;
                    [__error retain];
                    [preJazzkonMetadata release];
                    return;
                }
                
                // x20
                OCCKDatabaseMetadata * _Nullable databaseMetadata = [OCCKDatabaseMetadata databaseMetadataForScope:self->_databaseScope forStore:self->_store inContext:self->_metadataContext error:&__error];
                if (__error != nil) {
                    _succeed = NO;
                    [__error retain];
                    [preJazzkonMetadata release];
                    return;
                }
                
                // <+3296>
                databaseMetadata.currentChangeToken = [preJazzkonMetadata changeTokenForDatabaseScope:self->_databaseScope];
                databaseMetadata.hasSubscription = [preJazzkonMetadata hasInitializedDatabaseSubscription];
                
                if (self->_databaseScope == CKDatabaseScopePrivate) {
                    // x22
                    CKRecordZoneID *zoneID = [OCCloudKitSerializer defaultRecordZoneIDForDatabaseScope:self->_databaseScope];
                    // x20
                    OCCKRecordZoneMetadata * _Nullable metadata = [OCCKRecordZoneMetadata zoneMetadataForZoneID:zoneID inDatabaseWithScope:self->_databaseScope forStore:self->_store inContext:self->_metadataContext error:&__error];
                    
                    if (__error != nil) {
                        [zoneID release];
                        _succeed = NO;
                        _error = [__error retain];
                        [preJazzkonMetadata release];
                        return;
                    }
                    
                    // <+6440>
                    metadata.hasSubscription = [preJazzkonMetadata hasInitializedDatabaseSubscription];
                    metadata.currentChangeToken = [preJazzkonMetadata changeTokenForZoneWithID:zoneID inDatabaseWithScope:self->_databaseScope];
                    metadata.hasSubscription = NO;
                    [zoneID release];
                }
                
                // <+6540>
                if ([preJazzkonMetadata lastHistoryToken] == nil) {
                    [preJazzkonMetadata release];
                    return;
                }
                
                OCCKMetadataEntry * _Nullable entry = [OCCKMetadataEntry updateOrInsertMetadataEntryWithKey:[OCSPIResolver NSCloudKitMirroringDelegateLastHistoryTokenKey] transformedValue:[preJazzkonMetadata lastHistoryToken] forStore:self->_store intoManagedObjectContext:self->_metadataContext error:&__error];
                if (entry == nil) {
                    _succeed = NO;
                    _error = [__error retain];
                    [preJazzkonMetadata release];
                    return;
                }
                
                if ([preJazzkonMetadata ckIdentityRecordName] == nil) {
                    [preJazzkonMetadata release];
                    return;
                }
                
                entry = [OCCKMetadataEntry updateOrInsertMetadataEntryWithKey:[OCSPIResolver NSCloudKitMirroringDelegateCKIdentityRecordNameDefaultsKey] transformedValue:[preJazzkonMetadata ckIdentityRecordName] forStore:self->_store intoManagedObjectContext:self->_metadataContext error:&__error];
                if (entry == nil) {
                    _succeed = NO;
                    _error = [__error retain];
                    [preJazzkonMetadata release];
                    return;
                }
                
                entry = [OCCKMetadataEntry updateOrInsertMetadataEntryWithKey:[OCSPIResolver NSCloudKitMirroringDelegateCheckedCKIdentityDefaultsKey] boolValue:[preJazzkonMetadata hasCheckedCKIdentity] forStore:self->_store intoManagedObjectContext:self->_metadataContext error:&__error];
                if (entry == nil) {
                    _succeed = NO;
                    _error = [__error retain];
                    [preJazzkonMetadata release];
                    return;
                }
                
                // <+2056>
                [preJazzkonMetadata release];
            }
            
            if (flag_1) {
                // <+2060>
                @autoreleasepool {
                    // sp + 0x30
                    NSMutableDictionary<CKRecordZoneID *, OCCKRecordZoneMetadata *> *dictionary = [[NSMutableDictionary alloc] init];
                    // x21
                    NSFetchRequest<OCCKRecordZoneMetadata *> *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[OCCKRecordZoneMetadata entityPath]];
                    fetchRequest.relationshipKeyPathsForPrefetching = @[@"records", @"mirroredRelationships", @"database"];
                    fetchRequest.returnsObjectsAsFaults = NO;
                    fetchRequest.affectedStores = @[self->_store];
                    // <+2240>
                    // x24
                    NSArray<OCCKRecordZoneMetadata *> * _Nullable results = [self->_metadataContext executeFetchRequest:fetchRequest error:&__error];
                    if (results == nil) {
                        _succeed = NO;
                        _error = [__error retain];
                        [dictionary release];
                        return;
                    }
                    // sp + 0x18
                    OCCKDatabaseMetadata * _Nullable databaseMetadata = [OCCKDatabaseMetadata databaseMetadataForScope:self->_databaseScope forStore:self->_store inContext:self->_metadataContext error:&__error];
                    if (databaseMetadata == nil) {
                        _succeed = NO;
                        _error = [__error retain];
                        [dictionary release];
                        return;
                    }
                    
                    // x26
                    for (OCCKRecordZoneMetadata *recordZoneMetadata in results) {
                        if ((recordZoneMetadata.ckOwnerName.length == 0) || (recordZoneMetadata.ckRecordZoneName.length == 0)) {
                            // <+2772>
                            [self->_metadataContext deleteObject:recordZoneMetadata];
                            continue;
                        }
                        
                        // x27
                        CKRecordZoneID *zoneID = [recordZoneMetadata createRecordZoneID];
                        // x28
                        OCCKRecordZoneMetadata *recordZoneMetadata_2 = [dictionary objectForKey:zoneID];
                        if (recordZoneMetadata_2 == nil) {
                            recordZoneMetadata.database = databaseMetadata;
                            [dictionary setObject:recordZoneMetadata forKey:zoneID];
                            [zoneID release];
                            continue;
                        }
                        // x21
                        NSSet<OCCKMirroredRelationship *> *mirroredRelationships = [recordZoneMetadata.mirroredRelationships copy];
                        
                        // <+2460>
                        for (OCCKMirroredRelationship *mirroredRelationship in mirroredRelationships) {
                            mirroredRelationship.recordZone = recordZoneMetadata_2;
                        }
                        // <+2592>
                        [mirroredRelationships release];
                        
                        // x21
                        NSSet<OCCKRecordMetadata *> *records = [recordZoneMetadata.records copy];
                        for (OCCKRecordMetadata *record in records) {
                            record.recordZone = recordZoneMetadata_2;
                        }
                        // <+2740>
                        [records release];
                        
                        [self->_metadataContext deleteObject:recordZoneMetadata];
                        [zoneID release];
                    }
                    // <+3516>
                    [dictionary release];
                }
                
                if (self->_metadataContext.hasChanges) {
                    BOOL result = [self->_metadataContext save:&__error];
                    if (!result) {
                        _succeed = NO;
                        _error = [__error retain];
                        return;
                    }
                }
            }
            
            // <+3704>
            // x21
            CKRecordZoneID *zoneID = [OCCloudKitSerializer defaultRecordZoneIDForDatabaseScope:self->_databaseScope];
            // x22
            OCCKRecordZoneMetadata * _Nullable recordZoneMetadata = [OCCKRecordZoneMetadata zoneMetadataForZoneID:zoneID inDatabaseWithScope:self->_databaseScope forStore:self->_store inContext:self->_metadataContext error:&__error];
            
            BOOL result;
            if (recordZoneMetadata.isInserted) {
                result = [self->_metadataContext save:&__error];
            } else {
                result = NO;
            }
            
            if (!result) {
                [zoneID release];
                _succeed = NO;
                _error = [__error retain];
                return;
            }
            
            // <+3820>
            // x23
            NSFetchRequest<OCCKMirroredRelationship *> *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:[OCCKMirroredRelationship entityPath]];
            fetchRequest.affectedStores = @[self->_store];
            fetchRequest.fetchBatchSize = 500;
            
            /*
             __69-[PFCloudKitMetadataModelMigrator commitMigrationMetadataAndCleanup:]_block_invoke.182
             recordZoneMetadata = sp + 0xa0 = x20 + 0x20
             self = sp + 0xa8 = x20 + 0x28
             _error = sp + 0xb0 = x20 + 0x30
             _succeed = sp + 0xb8 = x20 + 0x38
             */
            [OCSPIResolver _PFRoutines_efficientlyEnumerateManagedObjectsInFetchRequest_usingManagedObjectContext_andApplyBlock_:objc_lookUpClass("_PFRoutines") x1:fetchRequest x2:self->_metadataContext x3:^(NSArray<OCCKMirroredRelationship *> * _Nullable objects, NSError * _Nullable error, BOOL * _Nonnull checkChanges, BOOL * _Nonnull reserved) {
                /*
                 self(block) = x20
                 checkChanges = x19
                 */
                if (objects == nil) {
                    _succeed = NO;
                    _error = [error retain];
                    *checkChanges = YES;
                    return;
                }
                
                // x23
                for (OCCKMirroredRelationship *object in objects) {
                    if (object.recordZone == nil) {
                        object.recordZone = recordZoneMetadata;
                    }
                }
                // <+208>
                
                if (self->_metadataContext.hasChanges) {
                    BOOL result = [self->_metadataContext save:&_error];
                    if (!result) {
                        _succeed = NO;
                        [_error retain];
                    }
                }
            }];
            [fetchRequest release];
            [zoneID release];
            
            if (!_succeed) {
                return;
            }
            
            BOOL _needsAnalyzedHistoryCheck;
            {
                OCCloudKitMetadataMigrationContext * _Nullable context = self->_context;
                if (context == nil) {
                    _needsAnalyzedHistoryCheck = NO;
                } else {
                    _needsAnalyzedHistoryCheck = context->_needsAnalyzedHistoryCheck;
                }
            }
            
            if (_needsAnalyzedHistoryCheck) {
                // <+4068>
    #warning TODO : inlined block -[PFCloudKitMetadataModelMigrator commitMigrationMetadataAndCleanup:]_block_invoke_2 같음 (__error를 안 쓰는 것을 보아 __error 이전인듯)
                @autoreleasepool {
                    // x20
                    NSFetchRequest<OCCKHistoryAnalyzerState *> *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[OCCKHistoryAnalyzerState entityPath]];
                    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"entityId = 0"];
                    
                    NSManagedObjectContext * _Nullable context = self->_metadataContext;
                    // x23
                    NSInteger count;
                    if (context == nil) {
                        count = 0;
                    } else {
                        count = [OCSPIResolver NSManagedObjectContext__countForFetchRequest__error_:context x1:fetchRequest x2:&_error];
                    }
                    
                    if (count == 0) {
                        // nop
                    } else if (count == NSNotFound) {
                        _succeed = NO;
                        [_error retain];
                        [self->_metadataContext reset];
                        return;
                    } else {
                        // <+4240>
                        os_log_with_type(_OCLogGetLogStream(0x11), OS_LOG_TYPE_DEFAULT, "OpenCloudData+CloudKit: %s(%d): Found %lu corrupt analyzed history rows, purging.", __func__, __LINE__, count);
                        
                        // <+4404>
                        // x20
                        fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[OCCKHistoryAnalyzerState entityPath]];
                        // x22
                        NSBatchDeleteRequest *request = [[NSBatchDeleteRequest alloc] initWithFetchRequest:fetchRequest];
                        request.resultType = NSBatchDeleteResultTypeStatusOnly;
                        BOOL boolValue = ((NSNumber *)((NSBatchDeleteResult *)[self->_metadataContext executeRequest:request error:&_error]).result).boolValue;
                        
                        if (!boolValue) {
                            _succeed = NO;
                            [_error retain];
                            [request release];
                            [self->_metadataContext reset];
                            return;
                        }
                        
                        OCCKMetadataEntry * _Nullable entry = [OCCKMetadataEntry entryForKey:[OCSPIResolver NSCloudKitMirroringDelegateLastHistoryTokenKey] fromStore:self->_store inManagedObjectContext:self->_metadataContext error:&_error];
                        if (entry == nil) {
                            _succeed = NO;
                            [_error retain];
                            [request release];
                            [self->_metadataContext reset];
                            return;
                        }
                        
                        [self->_metadataContext deleteObject:entry];
                        [request release];
                    }
                    
                    if (self->_metadataContext.hasChanges) {
                        BOOL result = [self->_metadataContext save:&_error];
                        if (!result) {
                            _succeed = NO;
                            [_error retain];
                            [self->_metadataContext reset];
                            return;
                        }
                    }
                    
                    [self->_metadataContext reset];
                }
            }
            
            // <+4804>
            _succeed = [self checkForOrphanedMirroredRelationshipsInStore:self->_store inManagedObjectContext:self->_metadataContext error:&__error];
            if (!_succeed) {
                _error = [__error retain];
                return;
            }
            
            // <+4896>
            
            // x21
            BOOL isEqual;
            if (flag_2) {
                BOOL result = [self checkForCorruptedRecordMetadataInStore:self->_store inManagedObjectContext:self->_metadataContext error:&__error];
                if (!result) {
                    _succeed = NO;
                    [__error retain];
                    return;
                } else {
                    isEqual = NO;
                }
            } else {
                // <+4956>
                entry = [OCCKMetadataEntry entryForKey:[OCSPIResolver PFCloudKitMetadataClientVersionHashesKey] fromStore:self->_store inManagedObjectContext:self->_metadataContext error:&__error];
                if (__error != nil) {
                    _succeed = NO;
                    _error = [__error retain];
                    return;
                }
                
                if (entry == nil) {
                    isEqual = NO;
                } else {
                    // x20
                    transformedValue = entry.transformedValue;
                    // x21
                    isEqual = [self->_metadataContext.persistentStoreCoordinator.managedObjectModel.entityVersionHashesByName isEqual:transformedValue];
                }
            }
            
            // <+5112>
            
            if (self->_metadataContext.hasChanges) {
                result = [self->_metadataContext save:&__error];
            } else {
                if (![OCSPIResolver _PFRoutines__isInMemoryStore_:objc_lookUpClass("_PFRoutines") x1:self->_store]) {
                    result = [self->_metadataContext setQueryGenerationFromToken:NSQueryGenerationToken.currentQueryGenerationToken error:&__error];
                } else {
                    result = YES;
                }
            }
            
            if (!result) {
                _succeed = NO;
                _error = [__error retain];
                return;
            }
            
            if (!isEqual) {
                BOOL result = [self cleanUpAfterClientMigrationWithStore:self->_store andContext:self->_metadataContext error:&__error];
                if (!result) {
                    _succeed = NO;
                    _error = [__error retain];
                    return;
                }
                
                OCCKMetadataEntry * _Nullable entry = [OCCKMetadataEntry updateOrInsertMetadataEntryWithKey:[OCSPIResolver PFCloudKitMetadataClientVersionHashesKey] transformedValue:self->_metadataContext.persistentStoreCoordinator.managedObjectModel.entityVersionHashesByName forStore:self->_store intoManagedObjectContext:self->_metadataContext error:&__error];
                if (entry == nil) {
                    _succeed = NO;
                    _error = [__error retain];
                    return;
                }
            }
            
            // <+5492>
            NSNumber *versionNumber = [OCSPIResolver _PFRoutines__getPFBundleVersionNumber:objc_lookUpClass("_PFRoutines")];
            entry = [OCCKMetadataEntry updateOrInsertMetadataEntryWithKey:[OCSPIResolver PFCloudKitMetadataClientVersionHashesKey] integerValue:versionNumber forStore:self->_store intoManagedObjectContext:self->_metadataContext error:&__error];
            if (entry == nil) {
                _succeed = NO;
                _error = [__error retain];
                return;
            }
            
            // <+5676>
            // x20
            NSBatchUpdateRequest *request = [[NSBatchUpdateRequest alloc] initWithEntityName:[OCCKRecordZoneMetadata entityPath]];
            request.propertiesToUpdate = @{
                @"needsImport": [NSExpression expressionForConstantValue:@YES],
                @"currentChangeToken": [NSExpression expressionForConstantValue:nil],
                @"lastFetchDate": [NSExpression expressionForConstantValue:nil]
            };
            request.resultType = NSStatusOnlyResultType;
            BOOL boolValue = ((NSNumber *)((NSBatchUpdateResult *)[self->_metadataContext save:&__error]).result).boolValue;
            
            if (!boolValue) {
                _succeed = NO;
                _error = [__error retain];
                [request release];
                return;
            }
            
            [request release];
            _succeed = [self->_metadataContext save:&__error];
            if (!_succeed) {
                _error = [__error retain];
                return;
            }
            
            // x20
            NSMutableDictionary<NSString *, id> *metadata = [self->_store.metadata mutableCopy];
            for (NSString *key in [OCCloudKitMirroringDelegatePreJazzkonMetadata allDefaultsKeys]) {
                [metadata removeObjectForKey:key];
            }
            [metadata removeObjectForKey:@"_NSStoreAncillaryModelVersionHashesMetadataKey"];
            [metadata removeObjectForKey:[OCSPIResolver PFCloudKitMetadataNeedsZoneFetchAfterClientMigrationKey]];
            self->_store.metadata = metadata;
            [metadata release];
            _succeed = [self->_metadataContext save:&__error];
            if (!_succeed) {
                _error = [__error retain];
                return;
            }
        } @catch (NSException *exception) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Unexpected exception thrown during metadata migration: %@\n", exception);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Unexpected exception thrown during metadata migration: %@\n", exception);
            return;
        }
        
        @try {
            // <+816>
            _succeed = [self migrateMetadataForObjectsInStore:self->_store toNSCKRecordMetadataUsingContext:self->_metadataContext error:&__error];
            if (!_succeed) {
                _error = [__error retain];
                return;
            } 
        } @catch (NSException *exception) {
            _succeed = NO;
            _error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:134402 userInfo:@{@"NSUnderlyingException": exception}];
            return;
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
        return NO;
    }
    
    if (_databaseScope == CKDatabaseScopePrivate) {
        // inlined
        _succeed = [self checkForRecordMetadataZoneCorruptionInStore:_store error:&_error];
        
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
    }
    
    [_error release];
    return _succeed;
}

- (BOOL)checkForRecordMetadataZoneCorruptionInStore:(NSSQLCore *)store error:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct)) {
    // inlined from -[PFCloudKitMetadataModelMigrator checkAndPerformMigrationIfNecessary:]
    /*
     self = x20
     store = x22
     error = sp, #0x38 (from -[PFCloudKitMetadataModelMigrator checkAndPerformMigrationIfNecessary:])
     */
    
    // sp, #0x140
    __block BOOL _succeed = YES;
    // sp, #0x110
    __block NSError * _Nullable _error = nil;
    
    // x21
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [store.persistentStoreCoordinator retain];
    // x23
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
    context.persistentStoreCoordinator = persistentStoreCoordinator;
    [context _setAllowAncillaryEntities:YES];
    
    /*
     __85-[PFCloudKitMetadataModelMigrator checkForRecordMetadataZoneCorruptionInStore:error:]_block_invoke
     self = x29 - 0xc0 = x19 + 0x20
     store = x29 - 0xb8 = x19 + 0x28
     context = x29 - 0xb0 = x19 + 0x30
     persistentStoreCoordinator = x29 - 0xa8 = x19 + 0x38
     _error = x29 - 0xa0 = x19 + 0x40
     _succeed = x29 - 0x98 = x19 + 0x48
     */
    [context performBlockAndWait:^{
        /*
         self(block) = x19
         */
        
        // original : getCloudKitCKRecordZoneIDClass / getCloudKitCKCurrentUserDefaultName
        // x20
        CKRecordZoneID *zoneID = [[CKRecordZoneID alloc] initWithZoneName:@"com.apple.coredata.cloudkit.zone" ownerName:CKCurrentUserDefaultName];
        
        // x21
        OCCKRecordZoneMetadata * _Nullable metadata = [OCCKRecordZoneMetadata zoneMetadataForZoneID:zoneID inDatabaseWithScope:self->_databaseScope forStore:store inContext:context error:&_error];
        if (metadata == nil) {
            _succeed = NO;
            [_error retain];
        } else {
            if (metadata.isInserted) {
                _succeed = [context save:&_error];
                if (!_succeed) {
                    [_error retain];
                }
            }
        }
        
        if (_succeed) {
            // x21
            NSManagedObjectID *objectID = [metadata.objectID retain];
            // x22
            NSFetchRequest<OCCKRecordMetadata *> *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[OCCKRecordMetadata entityPath]];
            fetchRequest.relationshipKeyPathsForPrefetching = @[@"recordZone"];
            fetchRequest.affectedStores = @[store];
            fetchRequest.fetchBatchSize = 200;
            
            /*
             __85-[PFCloudKitMetadataModelMigrator checkForRecordMetadataZoneCorruptionInStore:error:]_block_invoke_2
             context = sp + 0x28 = x21 + 0x20
             objectID = sp + 0x30 = x21 + 0x28
             _error = sp + 0x38 = x21 + 0x30
             _succeed = sp + 0x40 = x21 + 0x38
             */
            [OCSPIResolver _PFRoutines_efficientlyEnumerateManagedObjectsInFetchRequest_usingManagedObjectContext_andApplyBlock_:objc_lookUpClass("_PFRoutines") x1:fetchRequest x2:context x3:^(NSArray<OCCKRecordMetadata *> * _Nullable objects, NSError * _Nullable error, BOOL * _Nonnull checkChanges, BOOL * _Nonnull reserved) {
                /*
                 self(block) = x21 / sp
                 checkChanges = x20 / sp + 0x8
                 objects = sp + 0x28
                 */
                
                @try {
                    if (objects == nil) {
                        _succeed = NO;
                        _error = [error retain];
                        *checkChanges = YES;
                        return;
                    }
                    
                    // x22
                    OCCKRecordZoneMetadata * _Nullable metadata = [context existingObjectWithID:objectID error:&_error];
                    if (metadata == nil) {
                        os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Failed to refresh zone for assignment during corrupt zone cleanup: %@\n", _error);
                        os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Failed to refresh zone for assignment during corrupt zone cleanup: %@\n", _error);
                        [_error retain];
                        _succeed = NO;
                        *checkChanges = YES;
                        return;
                    }
                    
                    // x27
                    for (OCCKRecordMetadata *_metadata in objects) @autoreleasepool {
                        // x19
                        OCCKRecordZoneMetadata *recordZone = _metadata.recordZone;
                        NSString *zoneName = recordZone.ckRecordZoneName;
                        
                        if ((zoneName == nil) || recordZone.isDeleted) {
                            os_log_with_type(_OCLogGetLogStream(0x11), OS_LOG_TYPE_DEFAULT, "OpenCloudData: %s(%d): Found corrupt zone on record metadata: %@", __func__, __LINE__, _metadata.objectID);
                            _metadata.recordZone = metadata;
                        }
                    }
                    
                    BOOL result = [context save:&_error];
                    
                    if (!result) {
                        _succeed = NO;
                        [_error retain];
                        *checkChanges = YES;
                        return;
                    }
                } @catch (NSException *exception) {
                    os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Failed to refresh zone for assignment during corrupt zone cleanup: %@\n", exception);
                    os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Failed to refresh zone for assignment during corrupt zone cleanup: %@\n", exception);
                }
            }];
            
            [objectID release];
        }
        
        // <+488>
        if ((self->_context != nil) && _succeed) {
            NSPersistentHistoryToken * _Nullable historyToken = [persistentStoreCoordinator currentPersistentHistoryTokenFromStores:@[store]];
            // x21
            NSNumber *token;
            if (historyToken != nil) {
                NSDictionary<NSString *, NSNumber *> *storeTokens = [historyToken storeTokens];
                token = [storeTokens objectForKey:store.identifier];
            } else {
                token = @0;
            }
            
            // x22
            NSBatchUpdateRequest *request = [[NSBatchUpdateRequest alloc] initWithEntityName:[OCCKRecordMetadata entityPath]];
            request.predicate = [NSPredicate predicateWithFormat:@"ckRecordSystemFields == NULL"];
            request.propertiesToUpdate = @{
                @"needsUpload": [NSExpression expressionForConstantValue:@YES],
                @"pendingExportTransactionNumber": [NSExpression expressionForConstantValue:token]
            };
            request.affectedStores = @[store];
            request.resultType = NSStatusOnlyResultType;
            
            BOOL boolValue = ((NSNumber *)((NSBatchUpdateResult *)[context executeRequest:request error:&_error]).result).boolValue;
            if (!boolValue) {
                _succeed = NO;
                [_error retain];
            }
            [request release];
            
            if (_succeed) {
                // <+932>
                // x22
                NSBatchUpdateRequest *request = [[NSBatchUpdateRequest alloc] initWithEntityName:[OCCKRecordMetadata entityPath]];
                request.predicate = [NSPredicate predicateWithFormat:@"ckRecordSystemFields != NULL"];
                request.propertiesToUpdate = @{
                    @"lastExportedTransactionNumber": [NSExpression expressionForConstantValue:@0]
                };
                request.resultType = NSStatusOnlyResultType;
                request.affectedStores = @[store];
                BOOL boolValue = ((NSNumber *)((NSBatchUpdateResult *)[context executeRequest:request error:&_error]).result).boolValue;
                
                if (!boolValue) {
                    _succeed = NO;
                    [_error retain];
                }
                
                [request release];
            }
        }
        
        if (!_succeed) {
            [zoneID release];
            return;
        }
        
        // x21
        NSBatchUpdateRequest *request = [[NSBatchUpdateRequest alloc] initWithEntityName:[OCCKRecordZoneMetadata entityPath]];
        request.predicate = [NSPredicate predicateWithFormat:@"needsNewShareInvitation == NULL"];
        request.propertiesToUpdate = @{
            @"needsNewShareInvitation": [NSExpression expressionForConstantValue:@NO]
        };
        request.resultType = NSStatusOnlyResultType;
        request.affectedStores = @[store];
        BOOL boolValue = ((NSNumber *)((NSBatchUpdateResult *)[context executeRequest:request error:&_error]).result).boolValue;
        
        if (!boolValue) {
            _succeed = NO;
            [_error retain];
        }
        
        [request release];
        [zoneID release];
    }];
    
    [context release];
    
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
    
    [persistentStoreCoordinator release];
    [_error release];
    
    return _succeed;;
}

- (BOOL)prepareContextWithConnection:(NSSQLiteConnection *)connection error:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct)) {
    // inlined from __71-[PFCloudKitMetadataModelMigrator checkAndPerformMigrationIfNecessary:]_block_invoke
    /*
     self = x21
     connection = x26
     error = sp + 0x8
     */
    // sp, #0x10
    __block BOOL _succeed = YES;
    // sp, #0xf8
    __block NSError * _Nullable _error = nil;
    
    NSNumber *version = [OCSPIResolver _PFRoutines__getPFBundleVersionNumber:objc_lookUpClass("_PFRoutines")];
    // x22
    NSManagedObjectModel *model = [OCCloudKitMetadataModel newMetadataModelForFrameworkVersion:version];
    // x23
    NSSQLModel *sqlModel = [[objc_lookUpClass("NSSQLModel") alloc] initWithManagedObjectModel:model];
    self->_context.currentModel = model;
    self->_context.sqlModel = sqlModel;
    
    // sp, #0xf0
    BOOL hasOldMetadataTables = NO;
    // x24
    NSManagedObjectModel *storeMetadataModel = [OCCloudKitMetadataModel identifyModelForStore:self->_store withConnection:connection hasOldMetadataTables:&hasOldMetadataTables];
    // x25
    NSSQLModel *storeSQLModel = [[objc_lookUpClass("NSSQLModel") alloc] initWithManagedObjectModel:storeMetadataModel];
    self->_context.storeMetadataModel = storeMetadataModel;
    self->_context.storeSQLModel = storeSQLModel;
    
    if ([self->_store.metadata objectForKey:[OCSPIResolver PFCloudKitMetadataNeedsZoneFetchAfterClientMigrationKey]] != nil) {
        OCCloudKitMetadataMigrationContext * _Nullable context = self->_context;
        if (context != nil) {
            context->_needsImportAfterClientMigration = _succeed;
        }
    }
    
//    NSSQLEntity *sqlEntity = [sqlModel entityNamed:NSStringFromClass([OCCKMetadataEntry class])];
    NSSQLEntity *sqlEntity = [sqlModel entityNamed:NSStringFromClass(objc_lookUpClass("NSCKMetadataEntry"))];
    NSString *tableName = [sqlEntity tableName];
    BOOL hasTable = [OCSPIResolver NSSQLiteConnection__hasTableWithName_isTemp:connection x1:tableName x2:NO];
    
    if (hasTable) {
        NSKnownKeysDictionary<NSString *, NSSQLEntity *> *entitiesByName;
        assert(object_getInstanceVariable(sqlModel, "_entitiesByName", (void **)&entitiesByName) != NULL);
        
        // sp + 0xc8
        __block BOOL mutated = NO;
        /*
         __70-[PFCloudKitMetadataModelMigrator prepareContextWithConnection:error:]_block_invoke
         storeSQLModel = sp + 0x70
         mutated = sp + 0x78
         */
        [entitiesByName enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull entityName, NSSQLEntity * _Nonnull entity, BOOL * _Nonnull stop) {
            NSSQLEntity * _Nullable _entity = [storeSQLModel entityNamed:entityName];
            
            uint _entityID_1;
            {
                if (entity == nil) {
                    _entityID_1 = 0;
                } else {
                    Ivar ivar = object_getInstanceVariable(entity, "_entityID", NULL);
                    assert(ivar != NULL);
                    _entityID_1 = *(uint *)((uintptr_t)entity + ivar_getOffset(ivar));
                }
            }
            
            uint _entityID_2;
            {
                if (_entity == nil) {
                    _entityID_2 = 0;
                } else {
                    Ivar ivar = object_getInstanceVariable(_entity, "_entityID", NULL);
                    assert(ivar != NULL);
                    _entityID_2 = *(uint *)((uintptr_t)_entity + ivar_getOffset(ivar));
                }
            }
            
            if (_entityID_1 != _entityID_2) {
                mutated = YES;
                *stop = YES;
            }
        }];
        
        if (mutated) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData+CloudKit: %s(%d): Migration discovered mutated entity IDs, precomputing z_ent changes.", __func__, __LINE__);
            _succeed = [self computeAncillaryEntityPrimaryKeyTableEntriesForStore:self->_store error:&_error];
            
            if (!_succeed) {
                [_error retain];
            }
        }
        
        /*
         __70-[PFCloudKitMetadataModelMigrator prepareContextWithConnection:error:]_block_invoke.8
         self = x21 - 0xd8 = x19 + 0x20
         _succeed = x21 - 0xd0 = x19 + 0x28
         _error = x21 - 0xc8 = x19 + 0x30
         */
        [self->_metadataContext performBlockAndWait:^{
            /*
             self(block) = x19
             */
            
            // sp
            NSError * _Nullable __error = nil;
            
            @try {
                NSDictionary<NSString *,OCCKMetadataEntry *> * _Nullable entries = [OCCKMetadataEntry entriesForKeys:@[[OCSPIResolver PFCloudKitMetadataFrameworkVersionKey]] onlyFetchingProperties:@[@"integerValue", @"key"] fromStore:self->_store inManagedObjectContext:self->_metadataContext error:&__error];
                OCCKMetadataEntry *entry = [entries objectForKey:[OCSPIResolver PFCloudKitMetadataFrameworkVersionKey]];
                
                if (__error != nil) {
                    _succeed = NO;
                    _error = [__error retain];
                    return;
                }
                
                if (entry != nil) {
                    {
                        OCCloudKitMetadataMigrationContext * _Nullable context = self->_context;
                        if (context != nil) {
                            context.storeMetadataVersion = entry.integerValue;
                        }
                    }
                    {
                        OCCloudKitMetadataMigrationContext * _Nullable context = self->_context;
                        if (context != nil) {
                            context->_needsMetdataMigrationToNSCKRecordMetadata = self->_context.storeMetadataVersion.integerValue < 0x3ac;
                        }
                    }
                    {
                        OCCloudKitMetadataMigrationContext * _Nullable context = self->_context;
                        if (context != nil) {
                            context->_needsBatchUpdateForSystemFieldsAndLastExportedTransaction = self->_context.storeMetadataVersion.integerValue < 0x4dc;
                        }
                    }
                    {
                        OCCloudKitMetadataMigrationContext * _Nullable context = self->_context;
                        if (context != nil) {
                            context->_needsCleanupFromOrphanedMirroredRelationships = self->_context.storeMetadataVersion.integerValue < 0x538;
                        }
                    }
                }
            } @catch (NSException *exception) {
                _succeed = NO;
                _error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:134402 userInfo:@{@"NSUnderlyingException": exception}];
                return;
            }
            
            @try {
                // <+380>
                NSDictionary<NSString *,OCCKMetadataEntry *> * _Nullable entries = [OCCKMetadataEntry entriesForKeys:@[[OCSPIResolver PFCloudKitMetadataModelVersionHashesKey]] onlyFetchingProperties:@[@"transformedValue", @"key"] fromStore:self->_store inManagedObjectContext:self->_metadataContext error:&__error];
                OCCKMetadataEntry * _Nullable entry = [entries objectForKey:[OCSPIResolver PFCloudKitMetadataModelVersionHashesKey]];
                
                if (__error != nil) {
                    _succeed = NO;
                    _error = [__error retain];
                    return;
                }
                
    #warning TODO Type
                self->_context.storeMetadataVersionHashes = (NSDictionary *)[entry transformedValue];
            } @catch (NSException *exception) {
                os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Unexpected exception thrown during metadata migration: %@\n", exception);
                os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Unexpected exception thrown during metadata migration: %@\n", exception);
            }
        }];
    } else {
        OCCloudKitMetadataMigrationContext * _Nullable context = self->_context;
        if (context != nil) {
            context->_needsMetdataMigrationToNSCKRecordMetadata = YES;
            context->_needsBatchUpdateForSystemFieldsAndLastExportedTransaction = YES;
        }
    }
    
    [model release];
    [sqlModel release];
    [storeMetadataModel release];
    [storeSQLModel release];
    
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
    
    // <+1036>
    return _succeed;
}

- (BOOL)computeAncillaryEntityPrimaryKeyTableEntriesForStore:(NSSQLCore *)store error:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct)) {
    /*
     store = x20
     error = x19
     */
    // sp, #0x30
    __block BOOL _succeed = YES;
    // 안 쓰이지만 정의는 존재함
    __block NSError * _Nullable _error = nil;
    
    /*
     __94-[PFCloudKitMetadataModelMigrator computeAncillaryEntityPrimaryKeyTableEntriesForStore:error:]_block_invoke
     store = sp + 0x20 = x21 + 0x20
     _succeed = sp + 0x28 = x21 + 0x28
     */
    // x21
    NSSQLBlockRequestContext *requestContext = [[objc_lookUpClass("NSSQLBlockRequestContext") alloc] initWithBlock:^(NSSQLStoreRequestContext * _Nullable context) {
        /*
         self(block) = x21 / sp + 0x18
         */
        
        // x19 / sp + 0x28
        NSSQLiteConnection * _Nullable connection;
        {
            if (context == nil) {
                connection = nil;
            } else {
                assert(object_getInstanceVariable(context, "_connection", (void **)&connection) != NULL);
            }
        }
        
        // x20
        NSMutableArray<NSSQLiteStatement *> *statements = [[NSMutableArray alloc] init];
        // x22
        NSSQLiteAdapter * _Nullable adapter = connection.adapter;
        NSSQLModel * _Nullable mirroringModel = [[store ancillarySQLModels] objectForKey:[OCSPIResolver NSPersistentStoreMirroringDelegateOptionKey]];
        
        // x19 / sp + 0x20
        NSMutableArray<NSSQLEntity *> * _Nullable entities;
        {
            if (mirroringModel == nil) {
                entities = nil;
            } else {
                assert(object_getInstanceVariable(mirroringModel, "_entities", (void **)&entities) != NULL);
            }
        }
        
        // x27
        for (NSSQLEntity *entity in entities) {
            /*
             NSSQLPKTableName = x25
             */
            
            uint _entityID;
            {
                if (entity == nil) {
                    _entityID = 0;
                } else {
                    Ivar ivar = object_getInstanceVariable(entity, "_entityID", NULL);
                    assert(ivar != NULL);
                    _entityID = *(uint *)((uintptr_t)entity + ivar_getOffset(ivar));
                }
            }
            NSString *sqlString = [NSString stringWithFormat:@"DELETE FROM %@ WHERE Z_ENT = %@", [OCSPIResolver NSSQLPKTableName], @(_entityID)];
            // x21
            NSSQLiteStatement *statement = [[objc_lookUpClass("NSSQLiteStatement") alloc] initWithEntity:nil sqlString:sqlString];
            [statements addObject:statement];
            [statement release];
            
            // x21
            statement = [OCSPIResolver NSSQLiteAdapter_newPrimaryKeyInitializeStatementForEntity_withInitialMaxPK_:adapter x1:entity x2:0];
            [statements addObject:statement];
            [statement release];
            
            if (connection != nil) {
                BOOL result = [OCSPIResolver NSSQLiteConnection__hasTableWithName_isTemp:connection x1:[entity tableName] x2:NO];
                if (!result) {
                    // x21
                    statement = [OCSPIResolver NSSQLiteAdapter_newSimplePrimaryKeyUpdateStatementForEntity_:adapter x1:entity];
                    [statements addObject:statement];
                    [statement release];
                    
                    uint _entityID;
                    {
                        if (entity == nil) {
                            _entityID = 0;
                        } else {
                            Ivar ivar = object_getInstanceVariable(entity, "_entityID", NULL);
                            assert(ivar != NULL);
                            _entityID = *(uint *)((uintptr_t)entity + ivar_getOffset(ivar));
                        }
                    }
                    NSString *sqlString = [NSString stringWithFormat:@"UPDATE %@ SET Z_ENT = %@", [entity tableName], @(_entityID)];
                    // x21
                    NSSQLiteStatement *statement = [[objc_lookUpClass("NSSQLiteStatement") alloc] initWithEntity:nil sqlString:sqlString];
                    [statements addObject:statement];
                    [statement release];
                }
            }
        }
        
        BOOL hasException;
        @try {
            [OCSPIResolver NSSQLiteConnection_connect:connection];
            [OCSPIResolver NSSQLiteConnection_beginTransaction:connection];
            hasException = NO;
        } @catch (NSException *exception) {
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Exception caught during cleanup of cloudkit metadata primary keys %@ with userInfo %@", exception, exception.userInfo);
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Exception caught during cleanup of cloudkit metadata primary keys %@ with userInfo %@", exception, exception.userInfo);
            [OCSPIResolver NSSQLiteConnection_disconnect:connection];
            [OCSPIResolver NSSQLiteConnection_connect:connection];
            hasException = YES;
        }
        
        if (!hasException) {
            for (NSSQLiteStatement *statement in statements) {
                [OCSPIResolver NSSQLiteConnection_prepareAndExecuteSQLStatement_:connection x1:statement];
            }
            
            @try {
                [OCSPIResolver NSSQLiteConnection_commitTransaction:connection];
            } @catch (NSException *exception) {
                os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Exception caught during cleanup of cloudkit metadata primary keys %@", exception);
                os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Exception caught during cleanup of cloudkit metadata primary keys %@", exception);
                [OCSPIResolver NSSQLiteConnection_rollbackTransaction:connection];
            }
            
            [OCSPIResolver NSSQLiteConnection_endFetchAndRecycleStatement_:connection x1:NO];
            [statements release];
        }
    }
                                                                                                           context:nil
                                                                                                           sqlCore:store];
    
    [OCSPIResolver NSSQLCore_dispatchRequest_withRetries_:store x1:requestContext x2:0];
    [requestContext release];
    
    if (!_succeed) {
        // _succeed 및 _error 할당하는 곳이 없음 - 안 불릴 것
        [_error autorelease];
        if (_error == nil) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        } else {
            if (error != NULL) {
                *error = _error;
            }
        }
    }
    
    return _succeed;
}

- (BOOL)calculateMigrationStepsWithConnection:(NSSQLiteConnection * _Nullable)connection error:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct)) {
    /*
     self = x21
     connection = sp + 0x90
     error = sp + 0x58
     */
    // sp, #0x430
    __block BOOL _succeed = YES;
    // sp, #0x400
    __block NSError * _Nullable _error = nil;
    // x24
    OCCloudKitMetadataMigrationContext *context = self->_context;
    BOOL _needsOldTableDrop;
    {
        if (context == nil) {
            _needsOldTableDrop = NO;
        } else {
            _needsOldTableDrop = context->_needsOldTableDrop;
        }
    }
    
    if (_needsOldTableDrop) {
        // x19
        NSSQLiteAdapter *adapter = connection.adapter;
        
        NSArray<NSString *> *tableNames = @[
            @"ZNSCKEXPORTEDOBJECT",
            @"ZNSCKEXPORTMETADATA",
            @"ZNSCKEXPORTOPERATION",
            @"ZNSCKIMPORTOPERATION",
            @"ZNSCKIMPORTPENDINGRELATIONSHIP"
        ];
        
        for (NSString *tableName in tableNames) {
            NSSQLiteStatement *statement = [OCSPIResolver NSSQLiteAdapter_newDropTableStatementForTableNamed_:adapter x1:tableName];
            [context->_migrationStatements addObject:statement];
            context->_hasWorkToDo = YES;
            [statement release];
        }
    }
    
    NSMutableArray<NSSQLEntity *> * _Nullable entities;
    {
        OCCloudKitMetadataMigrationContext * _Nullable context = self->_context;
        if (context == nil) {
            entities = nil;
        } else {
            NSSQLModel * _Nullable sqlModel = context->_sqlModel;
            if (sqlModel == nil) {
                entities = nil;
            } else {
                assert(object_getInstanceVariable(sqlModel, "_entities", (void **)&entities) != NULL);
            }
        }
    }
    
    // x23
    for (NSSQLEntity *entity in entities) {
        if ((connection == nil) || (![OCSPIResolver NSSQLiteConnection__hasTableWithName_isTemp:connection x1:[entity tableName] x2:NO])) {
            OCCloudKitMetadataMigrationContext * _Nullable context = self->_context;
            if (context != nil) {
                [context->_sqlEntitiesToCreate addObject:entity];
                context->_hasWorkToDo = YES;
            }
        } else if (![OCSPIResolver NSSQLiteConnection__tableHasRows_:connection x1:[entity tableName]]) {
            // x19
            NSSQLiteAdapter *adapter = [connection adapter];
            // x19
            NSSQLiteStatement *statement = [OCSPIResolver NSSQLiteAdapter_newDropTableStatementForTableNamed_:adapter x1:[entity tableName]];
            OCCloudKitMetadataMigrationContext * _Nullable context = nil;
            if (context != nil) {
                [context->_migrationStatements addObject:statement];
                context->_hasWorkToDo = YES;
            }
            [statement release];
        } else {
            // x20
            NSArray<NSArray<NSString *> *> *table = [OCSPIResolver NSSQLiteConnection_fetchTableCreationSQLContaining_:connection x1:[entity tableName]];
            
            // sp + 0xb8
            NSString * _Nullable value = nil;
            // x19
            for (NSArray<NSString *> *element in table) {
                // x24
                NSString *tmp = [element objectAtIndex:0];
                
                if ([tmp isEqualToString:[entity tableName]]) {
                    value = [element objectAtIndex:1];
                    break;
                }
            }
            
            if (value == nil) {
                os_log_error(_OCLogGetLogStream(0x11), "CoreData: fault: Couldn't find sql for table '%@', did you check if it exists first?\n", [entity tableName]);
                os_log_fault(_OCLogGetLogStream(0x11), "CoreData: Couldn't find sql for table '%@', did you check if it exists first?\n", [entity tableName]);
            }
            
            if ([[entity name] isEqualToString:NSStringFromClass(objc_lookUpClass("NSCKMirroredRelationship"))] || [[entity name] isEqualToString:NSStringFromClass(objc_lookUpClass("NSCKImportPendingRelationship"))]) {
                NSSQLModel * _Nullable storeSQLModel;
                {
                    OCCloudKitMetadataMigrationContext * _Nullable context = self->_context;
                    if (context == nil) {
                        storeSQLModel = nil;
                    } else {
                        storeSQLModel = context->_storeSQLModel;
                    }
                }
                
                // x19
                NSSQLEntity *oldEntity = [storeSQLModel entityNamed:[entity name]];
                
                if ([value containsString:@"ZENTITYNAME"]) {
                    [self addMigrationStatementToContext:self->_context forRenamingAttributeNamed:@"entityName" withOldColumnName:@"ZENTITYNAME" toAttributeName:@"cdEntityName" onOldSQLEntity:oldEntity andCurrentSQLEntity:entity];
                }
                
                if ([value containsString:@"ZISDELETED"]) {
                    [self addMigrationStatementToContext:self->_context forRenamingAttributeNamed:@"isDeleted" withOldColumnName:@"ZISDELETED" toAttributeName:@"needsDelete" onOldSQLEntity:oldEntity andCurrentSQLEntity:entity];
                }
                
                if ([[entity name] isEqualToString:NSStringFromClass(objc_lookUpClass("NSCKMirroredRelationship"))]) {
                    NSMutableDictionary<NSString *, __kindof NSSQLProperty *> * _Nullable properties;
                    assert(object_getInstanceVariable(entity, "_properties", (void **)&properties) != NULL);
                    // x19
                    __kindof NSSQLProperty * _Nullable property = [properties objectForKey:@"recordZone"];
                    if (![value containsString:[property columnName]]) {
                        // x19
                        NSString *sqlString = [[NSString alloc] initWithFormat:@"ALTER TABLE %@ ADD COLUMN %@ INTEGER", [entity tableName], [property columnName]];
                        // x22
                        NSSQLiteStatement *statement = [[objc_lookUpClass("NSSQLiteStatement") alloc] initWithEntity:entity sqlString:sqlString];
                        
                        OCCloudKitMetadataMigrationContext * _Nullable context = nil;
                        if (context != nil) {
                            [context->_migrationStatements addObject:statement];
                            context->_hasWorkToDo = YES;
                        }
                        [sqlString release];
                        [statement release];
                        
                        // inlined
                        BOOL result = [self addMigrationStatementsToDeleteDuplicateMirroredRelationshipsToContext:self->_context withManagedObjectContext:self->_metadataContext andSQLEntity:entity error:&_error];
                        // <+3004>
                        
                        if (!result) {
                            _succeed = NO;
                            [_error retain];
                        } else {
                            // x22
                            NSArray<NSSQLiteStatement *> *statements = [OCSPIResolver NSSQLiteAdapter_newCreateIndexStatementsForEntity_defaultIndicesOnly_:[connection adapter] x1:entity x2:NO];
                            for (NSSQLiteStatement *statement in statements) {
                                OCCloudKitMetadataMigrationContext *context = self->_context;
                                if (context == nil) continue;
                                [context->_migrationStatements addObject:statement];
                                context->_hasWorkToDo = YES;
                            }
                            [statements release];
                        }
                    }
                } else if ([[entity name] isEqualToString:NSStringFromClass(objc_lookUpClass("NSCKImportPendingRelationship"))]) {
                    // <+1672>
                    NSArray<NSString *> *names = @[
                        @"recordZoneName",
                        @"recordZoneOwnerName",
                        @"relatedRecordZoneName",
                        @"relatedRecordZoneOwnerName"
                    ];
                    // x26
                    for (NSString *name in names) {
                        NSMutableDictionary<NSString *, __kindof NSSQLProperty *> * _Nullable properties;
                        assert(object_getInstanceVariable(entity, "_properties", (void **)&properties) != NULL);
                        // x22
                        __kindof NSSQLProperty * _Nullable property = properties[name];
                        
                        if ([value containsString:[property columnName]]) {
#warning TODO __ckLoggingOverride에 따라 type이 바뀌는 것 같음
                            os_log_with_type(_OCLogGetLogStream(0x11), OS_LOG_TYPE_DEFAULT, "CoreDataOpenCloudDataCloudKit: %s(%d): Skipping migration for '%@' because it already has a column named '%@'", __func__, __LINE__, [entity tableName], [property columnName]);
                        } else {
                            // <+2072>
                            [self addMigrationStatementForAddingAttribute:property toContext:self->_context inStore:self->_store];
                            
                            if ([name isEqualToString:@"recordZoneName"] || [name isEqualToString: @"relatedRecordZoneName"]) {
                                NSString *sqlString = [NSString stringWithFormat:@"UPDATE %@ SET %@ = '%@'", [entity tableName], [property columnName], @"com.apple.coredata.cloudkit.zone"];
                                // x19
                                NSSQLiteStatement *statement = [[objc_lookUpClass("NSSQLiteStatement") alloc] initWithEntity:entity sqlString:sqlString];
                                OCCloudKitMetadataMigrationContext * _Nullable context = nil;
                                if (context != nil) {
                                    [context->_migrationStatements addObject:statement];
                                    context->_hasWorkToDo = YES;
                                }
                                [statement release];
                            } else if ([name isEqualToString:@"recordZoneOwnerName"] || [name isEqualToString:@"relatedRecordZoneOwnerName"]) {
                                // <+2312>
                                // original : getCloudKitCKCurrentUserDefaultName
                                NSString *sqlString = [NSString stringWithFormat:@"UPDATE %@ SET %@ = '%@'", [entity tableName], [property columnName], CKCurrentUserDefaultName];
                                // x19
                                NSSQLiteStatement *statement = [[objc_lookUpClass("NSSQLiteStatement") alloc] initWithEntity:entity sqlString:sqlString];
                                OCCloudKitMetadataMigrationContext * _Nullable context = nil;
                                if (context != nil) {
                                    [context->_migrationStatements addObject:statement];
                                    context->_hasWorkToDo = YES;
                                }
                                [statement release];
                            }
                        }
                    }
                }
            } else if ([[entity name] isEqualToString:NSStringFromClass(objc_lookUpClass("NSCKRecordZoneMetadata"))]) {
                // <+2500> ~ ??
                
                /*
                 __79-[PFCloudKitMetadataModelMigrator calculateMigrationStepsWithConnection:error:]_block_invoke
                 self = sp + 0x320 = x20 + 0x20
                 entity = sp + 0x328 = x20 = 0x28
                 */
                [self->_metadataContext performBlockAndWait:^{
                    /*
                     self(block) = x20
                     */
                    
                    @try {
                        // original : getCloudKitCKRecordZoneIDClass, getCloudKitCKCurrentUserDefaultName
                        // x19
                        CKRecordZoneID *zoneID = [[CKRecordZoneID alloc] initWithZoneName:@"com.apple.coredata.cloudkit.zone" ownerName:CKCurrentUserDefaultName];
                        // x21
                        NSFetchRequest<OCCKRecordZoneMetadata *> *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[OCCKRecordZoneMetadata entityPath]];
                        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"ckRecordZoneName = %@ AND ckOwnerName = %@", zoneID.zoneName, zoneID.ownerName];
                        fetchRequest.resultType = NSCountResultType;
                        fetchRequest.propertiesToFetch = @[@"ckRecordZoneName", @"ckOwnerName"];
                        
                        NSManagedObjectContext *context = self->_metadataContext;
                        if (context != nil) {
                            NSInteger count = [OCSPIResolver NSManagedObjectContext__countForFetchRequest__error_:context x1:fetchRequest x2:&_error];
                            if (count == NSNotFound) {
                                _succeed = NO;
                                [_error retain];
                            } else if (count >= 2) {
                                NSString *sqlString = [NSString stringWithFormat:@"DELETE FROM %@", [entity tableName]];
                                NSSQLiteStatement *statement = [[objc_lookUpClass("NSSQLiteStatement") alloc] initWithEntity:nil sqlString:sqlString];
                                OCCloudKitMetadataMigrationContext *context = self->_context;
                                if (context != nil) {
                                    [context->_migrationStatements addObject:statement];
                                    context->_hasWorkToDo = YES;
                                }
                                [statement release];
                            }
                        }
                        // <+424>
                        [zoneID release];
                    } @catch (NSException *exception) {
                        _succeed = NO;
                        _error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:134402 userInfo:@{@"NSUnderlyingException": exception}];
                    }
                }];
                
                [self->_context addConstrainedEntityToPreflight:entity];
                
                // x22
                NSArray<NSSQLiteStatement *> * _Nullable statements_2;
                {
                    NSSQLiteAdapter * _Nullable adapter = [connection adapter];
                    if (adapter != nil) {
                        statements_2 = [OCSPIResolver NSSQLiteAdapter_newCreateIndexStatementsForEntity_defaultIndicesOnly_:adapter x1:entity x2:NO];
                    } else {
                        statements_2 = nil;
                    }
                }
                
                for (NSSQLiteStatement *statement in statements_2) {
                    OCCloudKitMetadataMigrationContext *context = self->_context;
                    if (context == nil) continue;
                    [context->_migrationStatements addObject:statement];
                    context->_hasWorkToDo = YES;
                }
                [statements_2 release];
            }
            
            // <+3256>
            if ([[entity name] isEqualToString:NSStringFromClass(objc_lookUpClass("NSCKExportMetadata"))] || [[entity name] isEqualToString:NSStringFromClass(objc_lookUpClass("NSCKExportOperation"))] || [[entity name] isEqualToString:NSStringFromClass(objc_lookUpClass("NSCKExportedObject"))]) {
                // <+3388>
                // x19
                NSSQLiteAdapter *adapter = [connection adapter];
                // x19
                NSSQLiteStatement *statement = [OCSPIResolver NSSQLiteAdapter_newDropTableStatementForTableNamed_:adapter x1:[entity tableName]];
                OCCloudKitMetadataMigrationContext *context = self->_context;
                if (context != nil) {
                    [context->_migrationStatements addObject:statement];
                    context->_hasWorkToDo = YES;
                }
                [statement release];
                if (context != nil) {
                    [context->_sqlEntitiesToCreate addObject:entity];
                    context->_hasWorkToDo = YES;
                }
            } else {
                // <+3508>
                if ([[entity name] isEqualToString:NSStringFromClass(objc_lookUpClass("NSCKRecordMetadata"))]) {
                    NSArray<NSString *> *names = @[
                        @"needsUpload",
                        @"needsLocalDelete",
                        @"needsCloudDelete",
                        @"lastExportedTransactionNumber",
                        @"pendingExportTransactionNumber",
                        @"pendingExportChangeTypeNumber",
                        @"encodedRecord"
                    ];
                    
                    for (NSString *name in names) {
                        NSMutableDictionary<NSString *, __kindof NSSQLProperty *> * _Nullable properties;
                        assert(object_getInstanceVariable(entity, "_properties", (void **)&properties) != NULL);
                        // x26
                        __kindof NSSQLProperty *property = [properties objectForKey:name];
                        
                        if ([value containsString:[property columnName]]) {
                            os_log_with_type(_OCLogGetLogStream(0x11), OS_LOG_TYPE_DEFAULT, "OpenCloudData+CloudKit: %s(%d): Skipping migration for '%@' because it already has a column named '%@'", __func__, __LINE__, [entity tableName], [property columnName]);
                            continue;
                        }
                        
                        [self addMigrationStatementForAddingAttribute:property toContext:self->_context inStore:self->_store];
                    }
                    // <+3976>
                    [self->_context addConstrainedEntityToPreflight:entity];
                    
                    // x22
                    NSArray<NSSQLiteStatement *> * _Nullable statements;
                    NSSQLiteAdapter * _Nullable adapter = [connection adapter];
                    if (adapter != nil) {
                        statements = [OCSPIResolver NSSQLiteAdapter_newCreateIndexStatementsForEntity_defaultIndicesOnly_:adapter x1:entity x2:NO];
                    } else {
                        statements = nil;
                    }
                    
                    for (NSSQLiteStatement *statement in statements) {
                        OCCloudKitMetadataMigrationContext * _Nullable context = self->_context;
                        if (context != nil) {
                            [context->_migrationStatements addObject:statement];
                            context->_hasWorkToDo = YES;
                        }
                    }
                    [statements release];
                    // <+4164>
                }
                
                // <+4168>
                if ([[entity name] isEqualToString:NSStringFromClass(objc_lookUpClass("NSCKRecordZoneMetadata"))] || [[entity name] isEqualToString:NSStringFromClass(objc_lookUpClass("NSCKDatabaseMetadata"))]) {
                    // sp, #0x9c
                    BOOL flag;
                    if ([value containsString:@"ZHASCHANGES"]) {
                        // <+4276>~<+4904>
                        flag = [[entity name] isEqualToString:NSStringFromClass(objc_lookUpClass("NSCKRecordZoneMetadata"))];
                        // x27 / sp + 0x28
                        NSMutableString *string_1 = [[NSMutableString alloc] initWithFormat:@"CREATE TEMPORARY TABLE %@_tmp(", [entity tableName]];
                        // x24 / x28
                        NSMutableString *string_2 = [[NSMutableString alloc] initWithFormat:@"INSERT INTO %@_tmp (", [entity tableName]];
                        // sp + 0x68
                        NSMutableString *string_3 = [[NSMutableString alloc] initWithString:@"SELECT"];
                        // x28 / sp + 0x20
                        NSMutableString *string_4 = [[NSMutableString alloc] initWithFormat:@"INSERT INTO %@ (", [entity tableName]];
                        // sp + 0x60
                        NSMutableString *string_5 = [[NSMutableString alloc] initWithString:@"SELECT"];
                        
                        NSSQLEntity * _Nullable rootEntity = entity;
                        while (YES) {
                            if (rootEntity == nil) break;
                            NSSQLEntity * _Nullable _rootEntity;
                            assert(object_getInstanceVariable(rootEntity, "_rootEntity", (void **)&_rootEntity) != NULL);
                            BOOL result = (rootEntity == _rootEntity);
                            rootEntity = _rootEntity;
                            if (result) break;
                        }
                        
                        NSMutableArray<__kindof NSSQLProperty *> *columnsToFetch;
                        assert(object_getInstanceVariable(rootEntity, "_columnsToFetch", (void **)&columnsToFetch) != NULL);
                        // x20
                        NSUInteger count = columnsToFetch.count;
                        
                        if (count > 0) {
                            // x22
                            NSInteger idx = 0;
                            do {
                                // x26
                                __kindof NSSQLProperty *firstProperty = columnsToFetch[idx];
                                
                                if ([value containsString:[firstProperty columnName]]) {
                                    [string_1 appendFormat:@" %@", [firstProperty columnName]];
                                    [string_2 appendFormat:@" %@", [firstProperty columnName]];
                                    [string_4 appendFormat:@" %@", [firstProperty columnName]];
                                    [string_5 appendFormat:@" %@", [firstProperty columnName]];
                                    [string_3 appendFormat:@" %@", [firstProperty columnName]];
                                    
                                    if (idx < (count - 1)) {
                                        [string_1 appendString:@", "];
                                        [string_2 appendString:@", "];
                                        [string_4 appendString:@", "];
                                        [string_5 appendString:@", "];
                                        [string_3 appendString:@", "];
                                    }
                                }
                                
                                idx += 1;
                            } while (count != idx);
                        }
                        
                        // <+4924>~<+5656>
                        [string_1 appendString:@")"];
                        [string_4 appendString:@")"];
                        [string_2 appendString:@")"];
                        [string_3 appendFormat:@" FROM %@", [entity tableName]];
                        [string_5 appendFormat:@" FROM %@_tmp", [entity tableName]];
                        
                        NSMutableArray<NSSQLiteStatement *> *migrationStatements;
                        {
                            OCCloudKitMetadataMigrationContext * _Nullable context = self->_context;
                            if (context == nil) {
                                migrationStatements = nil;
                            } else {
                                migrationStatements = context->_migrationStatements;
                                context->_hasWorkToDo = YES;
                            }
                        }
                        
                        NSSQLiteStatement *statement_1 = [[objc_lookUpClass("NSSQLiteStatement") alloc] initWithEntity:entity sqlString:string_1];
                        [migrationStatements addObject:statement_1];
                        [statement_1 release];
                        
                        NSSQLiteStatement *statement_2 = [[objc_lookUpClass("NSSQLiteStatement") alloc] initWithEntity:entity sqlString:[NSString stringWithFormat:@"%@ %@", string_2, string_3]];
                        [migrationStatements addObject:statement_2];
                        [statement_2 release];
                        
                        NSSQLiteStatement *statement_3 = [[objc_lookUpClass("NSSQLiteStatement") alloc] initWithEntity:entity sqlString:[NSString stringWithFormat:@"DROP TABLE %@", [entity tableName]]];
                        [migrationStatements addObject:statement_3];
                        [statement_3 release];
                        
                        NSSQLiteStatement *statement_4 = [OCSPIResolver NSSQLiteAdapter_newCreateTableStatementForEntity_:[connection adapter] x1:entity];
                        value = [statement_4 sqlString];
                        [migrationStatements addObject:statement_4];
                        [statement_4 release];
                        
                        NSSQLiteStatement *statement_5 = [[objc_lookUpClass("NSSQLiteStatement") alloc] initWithEntity:entity sqlString:[NSString stringWithFormat:@"%@ %@", string_4, string_5]];
                        [migrationStatements addObject:statement_5];
                        [statement_5 release];
                        
                        // x22
                        NSSQLiteStatement *statement_6 = [[objc_lookUpClass("NSSQLiteStatement") alloc] initWithEntity:entity sqlString:[NSString stringWithFormat:@"DROP TABLE %@_tmp", [entity tableName]]];
                        [migrationStatements addObject:statement_6];
                        [self->_context addConstrainedEntityToPreflight:entity];
                        
                        NSSQLiteAdapter * _Nullable adapter = [connection adapter];
                        // x26
                        NSArray<NSSQLiteStatement *> * _Nullable statements;
                        if (adapter != nil) {
                            statements = [OCSPIResolver NSSQLiteAdapter_newCreateIndexStatementsForEntity_defaultIndicesOnly_:adapter x1:entity x2:NO];
                        } else {
                            statements = nil;
                        }
                        
                        for (NSSQLiteStatement *statement in statements) {
                            OCCloudKitMetadataMigrationContext * _Nullable context = self->_context;
                            if (context != nil) {
                                [context->_migrationStatements addObject:statement];
                                context->_hasWorkToDo = YES;
                            }
                        }
                        
                        [statements release];
                        [statement_6 release];
                        [string_1 release];
                        [string_4 release];
                        [string_2 release];
                        [string_3 release];
                        [string_5 release];
                    } else {
                        flag = NO;
                    }
                    
                    // <+5760>
                    for (NSString *name in @[@"lastFetchDate"]) {
                        NSMutableDictionary<NSString *, __kindof NSSQLProperty *> * _Nullable properties;
                        assert(object_getInstanceVariable(entity, "_properties", (void **)&properties) != NULL);
                        // x26
                        __kindof NSSQLProperty *property = [properties objectForKey:name];
                        
                        if ([value containsString:[property columnName]]) {
                            os_log_with_type(_OCLogGetLogStream(0x11), OS_LOG_TYPE_DEFAULT, "OpenCloudData+CloudKit: %s(%d): Skipping migration for '%@' because it already has a column named '%@'", __func__, __LINE__, [entity tableName], [property columnName]);
                            continue;
                        }
                        
                        [self addMigrationStatementForAddingAttribute:property toContext:self->_context inStore:self->_store];
                    }
                    // <+6184>
                    
                    if ([[entity name] isEqualToString:NSStringFromClass(objc_lookUpClass("NSCKRecordZoneMetadata"))]) {
                        NSArray<NSString *> *names = @[
                            @"supportsFetchChanges",
                            @"supportsAtomicChanges",
                            @"supportsRecordSharing",
                            @"supportsZoneSharing"
                        ];
                        
                        for (NSString *name in names) {
                            NSMutableDictionary<NSString *, __kindof NSSQLProperty *> * _Nullable properties;
                            assert(object_getInstanceVariable(entity, "_properties", (void **)&properties) != NULL);
                            // x26
                            __kindof NSSQLProperty *property = [properties objectForKey:name];
                            
                            if ([value containsString:[property columnName]]) {
                                os_log_with_type(_OCLogGetLogStream(0x11), OS_LOG_TYPE_DEFAULT, "OpenCloudData+CloudKit: %s(%d): Skipping migration for '%@' because it already has a column named '%@'", __func__, __LINE__, [entity tableName], [property columnName]);
                                continue;
                            }
                            
                            [self addMigrationStatementForAddingAttribute:property toContext:self->_context inStore:self->_store];
                        }
                        // <+6660>
                        
                        names = @[
                            @"needsImport",
                            @"needsRecoveryFromZoneDelete",
                            @"needsRecoveryFromUserPurge",
                            @"encodedShareData",
                            @"needsShareUpdate",
                            @"needsShareDelete",
                            @"needsRecoveryFromIdentityLoss",
                            @"needsNewShareInvitation"
                        ];
                        for (NSString *name in names) {
                            NSMutableDictionary<NSString *, __kindof NSSQLProperty *> * _Nullable properties;
                            assert(object_getInstanceVariable(entity, "_properties", (void **)&properties) != NULL);
                            // x26
                            __kindof NSSQLProperty *property = [properties objectForKey:name];
                            
                            if ([value containsString:[property columnName]]) {
                                os_log_with_type(_OCLogGetLogStream(0x11), OS_LOG_TYPE_DEFAULT, "OpenCloudData+CloudKit: %s(%d): Skipping migration for '%@' because it already has a column named '%@'", __func__, __LINE__, [entity tableName], [property columnName]);
                                continue;
                            }
                            
                            [self addMigrationStatementForAddingAttribute:property toContext:self->_context inStore:self->_store];
                        }
                    }
                    
                    // <+7084>
                    
                    if (!flag) {
                        NSMutableDictionary<NSString *, __kindof NSSQLProperty *> * _Nullable properties;
                        assert(object_getInstanceVariable(entity, "_properties", (void **)&properties) != NULL);
                        NSString *sqlString = [NSString stringWithFormat:@"UPDATE %@ SET %@=0", [entity tableName], [[properties objectForKey:@"hasRecordZoneNum"] columnName]];
                        NSSQLiteStatement *statement = [[objc_lookUpClass("NSSQLiteStatement") alloc] initWithEntity:entity sqlString:sqlString];
                        OCCloudKitMetadataMigrationContext * _Nullable context = nil;
                        if (context != nil) {
                            [context->_migrationStatements addObject:statement];
                            context->_hasWorkToDo = YES;
                        }
                        [statement release];
                    }
                }
                
                // <+7232>
                if ([[entity name] isEqualToString:NSStringFromClass(objc_lookUpClass("NSCKMetadataEntry"))]) {
                    for (NSString *name in @[@"dateValue"]) {
                        NSMutableDictionary<NSString *, __kindof NSSQLProperty *> * _Nullable properties;
                        assert(object_getInstanceVariable(entity, "_properties", (void **)&properties) != NULL);
                        // x26
                        __kindof NSSQLProperty *property = [properties objectForKey:name];
                        
                        if ([value containsString:[property columnName]]) {
                            os_log_with_type(_OCLogGetLogStream(0x11), OS_LOG_TYPE_DEFAULT, "OpenCloudData+CloudKit: %s(%d): Skipping migration for '%@' because it already has a column named '%@'", __func__, __LINE__, [entity tableName], [property columnName]);
                            continue;
                        }
                        
                        [self addMigrationStatementForAddingAttribute:property toContext:self->_context inStore:self->_store];
                    }
                }
                
                // <+7700>
                if ([[entity name] isEqualToString:NSStringFromClass(objc_lookUpClass("NSCKRecordZoneQuery"))]) {
                    for (NSString *name in @[@"mostRecentRecordModificationDate"]) {
                        NSMutableDictionary<NSString *, __kindof NSSQLProperty *> * _Nullable properties;
                        assert(object_getInstanceVariable(entity, "_properties", (void **)&properties) != NULL);
                        // x26
                        __kindof NSSQLProperty *property = [properties objectForKey:name];
                        
                        if ([value containsString:[property columnName]]) {
                            os_log_with_type(_OCLogGetLogStream(0x11), OS_LOG_TYPE_DEFAULT, "OpenCloudData+CloudKit: %s(%d): Skipping migration for '%@' because it already has a column named '%@'", __func__, __LINE__, [entity tableName], [property columnName]);
                            continue;
                        }
                        
                        [self addMigrationStatementForAddingAttribute:property toContext:self->_context inStore:self->_store];
                    }
                }
                
                // <+8168>
                NSNumber * _Nullable storeMetadataVersion;
                {
                    OCCloudKitMetadataMigrationContext * _Nullable context = self->_context;
                    if (context == nil) {
                        storeMetadataVersion = nil;
                    } else {
                        storeMetadataVersion = context->_storeMetadataVersion;
                    }
                }
                
                if (storeMetadataVersion.integerValue <= 0x3d0) {
                    NSString *sqlString = [NSString stringWithFormat:@"UPDATE %@ SET Z_OPT = 1 WHERE Z_OPT IS NULL OR Z_OPT <= 0", [entity tableName]];
                    NSSQLiteStatement *statement = [[objc_lookUpClass("NSSQLiteStatement") alloc] initWithEntity:entity sqlString:sqlString];
                    OCCloudKitMetadataMigrationContext * _Nullable context = nil;
                    if (context != nil) {
                        [context->_migrationStatements addObject:statement];
                        context->_hasWorkToDo = YES;
                    }
                    [statement release];
                }
            }
        }
    }
    
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

- (BOOL)_redacted_1:(NSSQLiteConnection *)connection error:(NSError * _Nullable * _Nonnull)error __attribute__((objc_direct)) {
    // inlined from __71-[PFCloudKitMetadataModelMigrator checkAndPerformMigrationIfNecessary:]_block_invoke <+1108>~<+1708>
    /*
     self = x25
     connection = x20
     error = x24
     */
    
    BOOL hasWorkToDo;
    {
        OCCloudKitMetadataMigrationContext * _Nullable context = self->_context;
        if (context == nil) {
            hasWorkToDo = NO;
        } else {
            hasWorkToDo = context->_hasWorkToDo;
        }
    }
    
    // w23
    BOOL _succeed = YES;
    // x21
    NSError * _Nullable _error = nil;
    
    if (hasWorkToDo) {
        @try {
            [OCSPIResolver NSSQLiteConnection_connect:connection];
            [OCSPIResolver NSSQLiteConnection_beginTransaction:connection];
        } @catch (NSException *exception) {
            _succeed = NO;
            _error = [NSError errorWithDomain:NSCocoaErrorDomain code:134060 userInfo:@{@"NSUnderlyingException": exception}];
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Exception caught during execution of migration statement for cloudkit metadata tables %@ with userInfo %@\n%@\n%@\n", exception, exception.userInfo, self->_store, self->_metadataContext);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Exception caught during execution of migration statement for cloudkit metadata tables %@ with userInfo %@\n%@\n%@\n", exception, exception.userInfo, self->_store, self->_metadataContext);
            
            [OCSPIResolver NSSQLiteConnection_endFetchAndRecycleStatement_:connection x1:NO];
            [OCSPIResolver NSSQLiteConnection_disconnect:connection];
            [OCSPIResolver NSSQLiteConnection_connect:connection];
        }
        
        if (_succeed) {
            // x21
            NSMutableSet<NSSQLEntity *> * _Nullable constrainedEntitiesToPreflight;
            {
                OCCloudKitMetadataMigrationContext * _Nullable context = self->_context;
                if (context == nil) {
                    constrainedEntitiesToPreflight = nil;
                } else {
                    constrainedEntitiesToPreflight = context->_constrainedEntitiesToPreflight;
                }
            }
            
            for (NSSQLEntity *entity in constrainedEntitiesToPreflight) {
                [OCSPIResolver NSSQLiteConnection_dedupeRowsForUniqueConstraintsInCloudKitMetadataEntity_:connection x1:entity];
            }
            
            NSMutableArray<NSSQLiteStatement *> *migrationStatements;
            {
                OCCloudKitMetadataMigrationContext * _Nullable context = self->_context;
                if (context == nil) {
                    migrationStatements = nil;
                } else {
                    migrationStatements = context->_migrationStatements;
                }
            }
            for (NSSQLiteStatement *statement in migrationStatements) {
                [OCSPIResolver NSSQLiteConnection_prepareAndExecuteSQLStatement_:connection x1:statement];
            }
            
            NSMutableArray<NSSQLEntity *> * _Nullable sqlEntitiesToCreate;
            {
                OCCloudKitMetadataMigrationContext * _Nullable context = self->_context;
                if (context == nil) {
                    sqlEntitiesToCreate = nil;
                } else {
                    sqlEntitiesToCreate = context->_sqlEntitiesToCreate;
                }
            }
            
            @try {
                [OCSPIResolver NSSQLiteConnection_createTablesForEntities_:connection x1:sqlEntitiesToCreate];
                [OCSPIResolver NSSQLiteConnection_commitTransaction:connection];
            } @catch (NSException *exception /* x22 */) {
                _succeed = NO;
                _error = [NSError errorWithDomain:NSCocoaErrorDomain code:134060 userInfo:@{NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"An unhandled exception was thrown during CloudKit metadata migration: %@", exception]}];
                os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: Exception caught during execution of migration statement for cloudkit metadata tables %@\n%@\n%@\n", exception, self->_store, self->_metadataContext);
                os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Exception caught during execution of migration statement for cloudkit metadata tables %@\n%@\n%@\n", exception, self->_store, self->_metadataContext);
                [OCSPIResolver NSSQLiteConnection_endFetchAndRecycleStatement_:connection x1:NO];
                [OCSPIResolver NSSQLiteConnection_rollbackTransaction:connection];
            }
        }
    }
    
    if (!_succeed) {
        if (_error == nil) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        } else {
            // null 확인 없음
            *error = _error;
        }
    }
    
    return _succeed;
}

- (void)addMigrationStatementToContext:(OCCloudKitMetadataMigrationContext *)context forRenamingAttributeNamed:(NSString *)renamingAttributeName withOldColumnName:(NSString *)oldColumnName toAttributeName:(NSString *)attributeName onOldSQLEntity:(NSSQLEntity *)oldSQLEntity andCurrentSQLEntity:(NSSQLEntity *)currentSQLEntity __attribute__((objc_direct)) {
    /*
     context = x21
     renamingAttributeName = x20
     oldColumnName = x23
     attributeName = x22
     oldSQLEntity = x25
     currentSQLEntity = x19
     */
    
    if (currentSQLEntity == nil) {
        os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Unable to find attribute to migrate to '%@' from '%@' on entity: %@\n", attributeName, renamingAttributeName, currentSQLEntity);
        os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: Unable to find attribute to migrate to '%@' from '%@' on entity: %@\n", attributeName, renamingAttributeName, currentSQLEntity);
        return;
    }
    
    NSMutableDictionary<NSString *, __kindof NSSQLProperty *> * _Nullable properties;
    assert(object_getInstanceVariable(currentSQLEntity, "_properties", (void **)&properties) != NULL);
    // x24
    __kindof NSSQLProperty * _Nullable property = properties[oldColumnName];
    
    if (property == nil) {
        os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Unable to find attribute to migrate to '%@' from '%@' on entity: %@\n", attributeName, renamingAttributeName, currentSQLEntity);
        os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: Unable to find attribute to migrate to '%@' from '%@' on entity: %@\n", attributeName, renamingAttributeName, currentSQLEntity);
        return;
    }
    
    NSString *sqlString = [NSString stringWithFormat: @"ALTER TABLE %@ RENAME COLUMN %@ TO %@", oldColumnName, [property columnName], [currentSQLEntity tableName]];
    NSSQLiteStatement *statement = [[objc_lookUpClass("NSSQLiteStatement") alloc] initWithEntity:oldSQLEntity sqlString:sqlString];
    
    if (context != nil) {
        [context->_migrationStatements addObject:statement];
        context->_hasWorkToDo = YES;
    }
    
    [statement release];
}

- (void)addMigrationStatementForAddingAttribute:(NSSQLAttribute *)attribute toContext:(OCCloudKitMetadataMigrationContext *)context inStore:(NSSQLCore *)store __attribute__((objc_direct)) {
    /*
     attribute = x21
     context = x19
     store = x20
     */
    // x22
    NSSQLEntity *entity = [attribute entity];
    NSString *sqlString = [NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN %@ %@", [attribute columnName], [OCSPIResolver NSSQLiteAdapter_typeStringForColumn_:[store adapter] x1:attribute], [entity tableName]];
    NSSQLiteStatement *statement = [[objc_lookUpClass("NSSQLiteStatement") alloc] initWithEntity:entity sqlString:sqlString];
    if (context != nil) {
        [context->_migrationStatements addObject:statement];
        context->_hasWorkToDo = YES;
    }
    [statement release];
}

- (BOOL)addMigrationStatementsToDeleteDuplicateMirroredRelationshipsToContext:(OCCloudKitMetadataMigrationContext *)context withManagedObjectContext:(NSManagedObjectContext *)managedObjectContext andSQLEntity:(NSSQLEntity *)sqlEntity error:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct)) {
    // inlined from -[PFCloudKitMetadataModelMigrator calculateMigrationStepsWithConnection:error:] <+1492>~<+1668>
    // x29, #-0xb0
    __block BOOL _succeed = YES;
    // sp, #0x450
    __block NSError * _Nullable _error = nil;
    
    /*
     __149-[PFCloudKitMetadataModelMigrator addMigrationStatementsToDeleteDuplicateMirroredRelationshipsToContext:withManagedObjectContext:andSQLEntity:error:]_block_invoke
     managedObjectContext = sp + 0xab0 = x23 + 0x20
     entity = sp + 0xab8 = x23 + 0x28
     context = sp + 0xac0 = x23 + 0x30
     __error = sp + 0xac8 = x23 + 0x38
     __succeed = sp + 0xad0 = x23 + 0x40
     */
    [managedObjectContext performBlockAndWait:^{
        // self = x23
        // x21
        NSFetchRequest<OCCKMirroredRelationship *> *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[OCCKMirroredRelationship entityPath]];
        // x19 / x29 - 0x58 / sp + 0x18
        NSExpressionDescription *expression = [[NSExpressionDescription alloc] init];
        expression.name = @"count";
        expression.expression = [NSExpression expressionWithFormat:@"ckRecordID.@count"];
        expression.expressionResultType = NSInteger64AttributeType;
        
        fetchRequest.propertiesToFetch = @[expression];
        fetchRequest.propertiesToGroupBy = @[@"ckRecordID"];
        fetchRequest.resultType = NSDictionaryResultType;
        
        // x19
        NSArray<NSDictionary<NSString *, id> *> * _Nullable result = [managedObjectContext executeFetchRequest:fetchRequest error:&_error];
        if (result == nil) {
            _succeed = NO;
            [_error retain];
            [expression release];
            return;
        }
        
        // x20
        for (NSDictionary<NSString *, id> *dictionary in result) {
            NSInteger count = ((NSNumber *)dictionary[@"count"]).integerValue;
            
            if (count < 2) {
                continue;
            }
            
            @autoreleasepool {
                // x20
                NSString *ckRecordID = dictionary[@"ckRecordID"];
                if (ckRecordID == nil) {
                    os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Found mirrored relationships without a recordID.\n");
                    os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Found mirrored relationships without a recordID.\n");
                    continue;
                }
                
                // x25
                NSFetchRequest<OCCKMirroredRelationship *> *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[OCCKMirroredRelationship entityPath]];
                fetchRequest.predicate = [NSPredicate predicateWithFormat:@"ckRecordID = %@", ckRecordID];
                fetchRequest.resultType = NSManagedObjectIDResultType;
                
                // x26
                NSArray<NSManagedObjectID *> * _Nullable objectIDs = [managedObjectContext executeFetchRequest:fetchRequest error:&_error];
                if (objectIDs == nil) {
                    _succeed = NO;
                    [_error retain];
                    [expression release];
                    return;
                }
                
                // self = x27
                // x25
                NSMutableArray<NSNumber *> *dataArray = [[NSMutableArray alloc] init];
                
                for (NSManagedObjectID *objectID in objectIDs) {
                    NSNumber *data = @([objectID _referenceData64]);
                    [dataArray addObject:data];
                }
                
                if (dataArray.count != 0) {
                    NSSQLPrimaryKey * _Nullable primaryKey;
                    {
                        if (sqlEntity == nil) {
                            primaryKey = nil;
                        } else {
                            assert(object_getInstanceVariable(sqlEntity, "_primaryKey", (void **)&primaryKey) != NULL);
                        }
                    }
                    
                    NSString *sqlString = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ IN %@", [primaryKey columnName], dataArray, [sqlEntity tableName]];
                    NSSQLiteStatement *statement = [[objc_lookUpClass("NSSQLiteStatement") alloc] initWithEntity:nil sqlString:sqlString];
                    
                    NSMutableArray<NSSQLiteStatement *> *migrationStatements;
                    {
                        OCCloudKitMetadataMigrationContext * _Nullable context = self->_context;
                        if (context == nil) {
                            migrationStatements = nil;
                        } else {
                            migrationStatements = context->_migrationStatements;
                            context->_hasWorkToDo = YES;
                        }
                    }
                    
                    [migrationStatements addObject:statement];
                    [statement release];
                }
                
                [dataArray release];
            }
        }
        
        [expression release];
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

- (BOOL)migrateMetadataForObjectsInStore:(NSSQLCore *)store toNSCKRecordMetadataUsingContext:(NSManagedObjectContext *)context error:(NSError * _Nullable *)error __attribute__((objc_direct)) {
    // inlined from __69-[PFCloudKitMetadataModelMigrator commitMigrationMetadataAndCleanup:]_block_invoke <+816>~<+1544>
    /*
     self(block) = x9
     self = sp + 0x30
     store = x21
     context = x22
     */
    
    OCCKMetadataEntry * _Nullable entry = [OCCKMetadataEntry entryForKey:[OCSPIResolver PFCloudKitMetadataNeedsMetadataMigrationKey] fromStore:store inManagedObjectContext:context error:error];
    // nil 확인 없음
    if (*error != nil) return NO;
    if (!entry.boolValue) return YES;
    
    // sp, #0x210
    __block BOOL _succeed = YES;
    // x29, #-0xb0
    __block NSError * _Nullable _error = nil;
    
    // x23
    NSManagedObjectModel *managedObjectModel = store.persistentStoreCoordinator.managedObjectModel;
    NSArray<NSEntityDescription *> * _Nullable entitiesForConfiguration = [managedObjectModel entitiesForConfiguration:store.configurationName];
    // x28
    for (NSEntityDescription *entity in entitiesForConfiguration) {
        NSAttributeDescription *recordIDAttribute = [entity.attributesByName objectForKey:[OCSPIResolver NSCKRecordIDAttributeName]];
        if (recordIDAttribute == nil) continue;
        NSAttributeDescription *recordSystemFieldsAttribute = [entity.attributesByName objectForKey:[OCSPIResolver NSCKRecordSystemFieldsAttributeName]];
        if (recordSystemFieldsAttribute == nil) continue;
        
        // x28
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entity.name];
        fetchRequest.propertiesToFetch = @[[OCSPIResolver NSCKRecordIDAttributeName], [OCSPIResolver NSCKRecordSystemFieldsAttributeName]];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"%K != nil", [OCSPIResolver NSCKRecordIDAttributeName]];
        fetchRequest.fetchBatchSize = 200;
        fetchRequest.affectedStores = @[store];
        
        /*
         __107-[PFCloudKitMetadataModelMigrator migrateMetadataForObjectsInStore:toNSCKRecordMetadataUsingContext:error:]_block_invoke
         self = sp + 0x1a8 = x21 + 0x20
         store = sp + 0x1b0 = x21 + 0x28
         context = sp + 0x1b8 = x21 + 0x30
         _error = sp + 0x1c0 = x21 + 0x38
         _succeed = sp + 0x1c8 = x21 + 0x40
         */
        [OCSPIResolver _PFRoutines_efficientlyEnumerateManagedObjectsInFetchRequest_usingManagedObjectContext_andApplyBlock_:objc_lookUpClass("_PFRoutines") x1:fetchRequest x2:context x3:^(NSArray<__kindof NSManagedObject *> * _Nullable objects, NSError * _Nullable __error, BOOL * _Nonnull checkChanges, BOOL * _Nonnull reserved) {
            /*
             self(block) = x21
             checkChanges = x20 / sp + 0x10
             objects = x22
             store = x19
             context = x27 / sp + 0x18
             self = x8
             */
            
            if (objects == nil) {
                _succeed = NO;
                _error = [__error retain];
                *checkChanges = YES;
                return;
            }
            
            if (self == nil) {
                _succeed = NO;
                _error = [__error retain];
                *checkChanges = YES;
                return;
            }
            
            // sp + 0x78
            NSError * _Nullable ___error = nil;
            
            // x24 / sp + 0x20
            CKRecordZoneID *zoneID = [OCCloudKitSerializer defaultRecordZoneIDForDatabaseScope:self->_databaseScope];
            // original : getCloudKitCKRecordZoneClass
            // x28 / sp + 0x28
            CKRecordZone *zone = [[CKRecordZone alloc] initWithZoneID:zoneID];
            // x25
            NSDictionary<NSManagedObjectID *, OCCKRecordMetadata *> * _Nullable map = [OCCKRecordMetadata createMapOfMetadataMatchingObjectIDs:[objects valueForKey:@"objectID"] inStore:store inManagedObjectContext:context error:&___error];
            // x26
            OCCloudKitMirroringDelegate * _Nullable mirroringDelegate = (OCCloudKitMirroringDelegate *)store.mirroringDelegate;
            
            if (map == nil) {
                [zone release];
                [zoneID release];
                
                if (__error == nil) {
                    os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
                    os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
                }
                
                _succeed = NO;
                _error = [__error retain];
                *checkChanges = YES;
                
                return;
            }
            
            // x19
            for (__kindof NSManagedObject *object in objects) {
                OCCKRecordMetadata *metadata = [map objectForKey:object.objectID];
                if (metadata != nil) {
                    [metadata setValue:nil forKey:[OCSPIResolver NSCKRecordSystemFieldsAttributeName]];
                } else {
                    if (mirroringDelegate != nil) {
                        OCCloudKitMirroringDelegateOptions *options = mirroringDelegate->_options;
                        // x21
                        OCCKRecordMetadata * _Nullable recordMetadata = [OCCKRecordMetadata insertMetadataForObject:object setRecordName:options.preserveLegacyRecordMetadataBehavior inZoneWithID:zone.zoneID recordNamePrefix:nil error:&___error];
                        // x23
                        NSData *ckRecordSystemFields = [[object valueForKey:[OCSPIResolver NSCKRecordSystemFieldsAttributeName]] retain];
                        recordMetadata.ckRecordSystemFields = ckRecordSystemFields;
                        [ckRecordSystemFields release];
                        [object setValue:nil forKey:[OCSPIResolver NSCKRecordSystemFieldsAttributeName]];
                    }
                }
            }
            // <+508>
            
            if (context.hasChanges) {
                BOOL result = [context save:&___error];
                
                [map release];
                [zone release];
                [zoneID release];
                
                if (!result) {
                    if (__error == nil) {
                        os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
                        os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
                    }
                    
                    _succeed = NO;
                    _error = [__error retain];
                    *checkChanges = YES;
                }
                
                return;
            }
            
            [map release];
            [zone release];
            [zoneID release];
            return;
        }];
        
        if (!_succeed) {
            *error = [[_error retain] autorelease];
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)checkForOrphanedMirroredRelationshipsInStore:(NSSQLCore *)store inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct)) {
    /*
     self = sp + 0x40
     store = x22 / sp, #0x38
     managedObjectContext = x23
     error = x21 = sp + 0x10
     */
    // sp, #0xb8
    NSError * _Nullable _error = nil;
    // x20 / sp + 0x18
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [managedObjectContext.persistentStoreCoordinator retain];
    // x19
    NSFetchRequest<OCCKMirroredRelationship *> *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[OCCKMirroredRelationship entityPath]];
    fetchRequest.propertiesToFetch = @[@"cdEntityName", @"relationshipName"];
    fetchRequest.propertiesToGroupBy = @[@"cdEntityName", @"relationshipName"];
    fetchRequest.resultType = NSDictionaryResultType;
    // x27
    NSArray<NSDictionary<NSString *, id> *> * _Nullable results = [managedObjectContext executeFetchRequest:fetchRequest error:&_error];
    
    if (results == nil) {
        if (_error != nil) {
            if (error != NULL) {
                *error = [[_error retain] autorelease];
            }
        } else {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        }
        
        [persistentStoreCoordinator release];
        return NO;
    }
    // x26
    NSManagedObjectModel *managedObjectModel = persistentStoreCoordinator.managedObjectModel;
    // x20
    for (NSDictionary<NSString *, id> *dictionary in results) @autoreleasepool {
        // x22
        NSString *cdEntityName = dictionary[@"cdEntityName"];
        // x23
        NSString *relationshipName = dictionary[@"relationshipName"];
        
        NSRelationshipDescription * _Nullable relationship = managedObjectModel.entitiesByName[cdEntityName].relationshipsByName[relationshipName];
        if (relationship != nil) continue;
        
        // x20
        NSFetchRequest<OCCKMirroredRelationship *> *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[OCCKMirroredRelationship entityPath]];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"cdEntityName = %@ AND relationshipName = %@", cdEntityName, relationshipName];
        // x20
        NSBatchDeleteRequest *request = [[NSBatchDeleteRequest alloc] initWithFetchRequest:fetchRequest];
        request.resultType = NSBatchDeleteResultTypeCount;
        
        NSBatchDeleteResult * _Nullable result = [managedObjectContext executeRequest:request error:&_error];
        if (result == nil) {
            [request release];
            
            if (_error != nil) {
                if (error != NULL) {
                    *error = [[_error retain] autorelease];
                }
            } else {
                os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
                os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            }
            [persistentStoreCoordinator release];
            
            return NO;
        }
        
        os_log_with_type(_OCLogGetLogStream(0x11), OS_LOG_TYPE_DEFAULT, "OpenCloudData+CloudKit: %s(%d): %@ deleted %@ mirrored relationship entries because %@:%@ is no longer in the managed object model of this store: %@", __func__, __LINE__, self, result.result, cdEntityName, relationshipName, store);
        [request release];
    }
    
    // <+952>
    [persistentStoreCoordinator release];
    return YES;
}

- (BOOL)checkForCorruptedRecordMetadataInStore:(NSSQLCore *)store inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct)) {
    /*
     store = x22
     managedObjectContext = x20
     error = x19
     */
    // sp, #0xa0
    __block BOOL _succeed = YES;
    // sp, #0x70
    __block NSError * _Nullable _error = nil;
    // x21
    NSManagedObjectModel *managedObjectModel = managedObjectContext.persistentStoreCoordinator.managedObjectModel;
    // x23
    NSFetchRequest<OCCKRecordMetadata *> *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[OCCKRecordMetadata entityPath]];
    fetchRequest.fetchBatchSize = 500;
    fetchRequest.propertiesToFetch = @[@"entityId", @"entityPK"];
    fetchRequest.affectedStores = @[store];
    
    // sp, #0x50
    __block BOOL flag = NO;
    /*
     __103-[PFCloudKitMetadataModelMigrator checkForCorruptedRecordMetadataInStore:inManagedObjectContext:error:]_block_invoke
     store = sp + 0x28 = x19 + 0x20
     managedObjectModel = sp + 0x30 = x19 + 0x28
     flag = sp + 0x38 = x19 + 0x30
     _succeed = sp + 0x40 = x19 + 0x38
     _error = sp + 0x48 = x19 + 0x40
     */
    [OCSPIResolver _PFRoutines_efficientlyEnumerateManagedObjectsInFetchRequest_usingManagedObjectContext_andApplyBlock_:objc_lookUpClass("_PFRoutines") x1:fetchRequest x2:managedObjectContext x3:^(NSArray<OCCKRecordMetadata *> * _Nullable objects, NSError * _Nullable __error, BOOL * _Nonnull checkChanges, BOOL * _Nonnull reserved) {
        /*
         self(block) = x19
         */
        if (objects == nil) {
            _succeed = NO;
            _error = [__error retain];
            return;
        }
        // x21
        for (OCCKRecordMetadata *metadata in objects) {
            // x25
            uint entityId = (uint)metadata.entityId.unsignedIntegerValue;
            
            NSSQLModel * _Nullable model = store.model;
            uint _lastEntityID;
            if (model == nil) {
                _lastEntityID = 0;
            } else {
                Ivar ivar = object_getInstanceVariable(model, "_lastEntityID", NULL);
                assert(ivar != NULL);
                _lastEntityID = *(uint *)((uintptr_t)model + ivar_getOffset(ivar));
            }
            
            if (entityId > _lastEntityID) {
                os_log_with_type(_OCLogGetLogStream(0x11), OS_LOG_TYPE_DEFAULT, "OpenCloudData+CloudKit: %s(%d): Found record metadata that points to missing entity: %@", __func__, __LINE__, metadata);
                flag = YES;
                return;
            }
            
            NSSQLEntity *entity = [store.model entityForID:entityId];
            if (entity == nil) {
                os_log_with_type(_OCLogGetLogStream(0x11), OS_LOG_TYPE_DEFAULT, "OpenCloudData+CloudKit: %s(%d): Found record metadata that points to missing entity: %@", __func__, __LINE__, metadata);
                flag = YES;
                return;
            }
            
            if (store.configurationName.length != 0) {
                if (![store.configurationName isEqualToString:@"PF_DEFAULT_CONFIGURATION_NAME"]) {
                    // x25
                    NSSQLModel * _Nullable model = store.model;
                    uint entityId = (uint)metadata.entityId.unsignedLongValue;
                    // x25
                    NSSQLEntity * _Nullable entity = [model entityForID:entityId];
                    // x25
                    NSEntityDescription *entityDescription = [managedObjectModel.entitiesByName objectForKey:entity.name];
                    BOOL contains = [[managedObjectModel entitiesForConfiguration:store.configurationName] containsObject:entityDescription];
                    
                    if (!contains) {
                        os_log_with_type(_OCLogGetLogStream(0x11), OS_LOG_TYPE_DEFAULT, "OpenCloudData+CloudKit: %s(%d): Found record metadata that points to an entity that is no longer part of the store's configuration: %@", __func__, __LINE__, metadata);
                        flag = YES;
                        return;
                    }
                }
            }
            // <+388>
        }
        // <+1048>
    }];
    
    if (!_succeed) {
        if (_error != nil) {
            if (error != NULL) {
                *error = [[_error retain] autorelease];
            }
        } else {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        }
        return NO;
    }
    
    if (!flag) return YES;
    
    // x21
    NSBatchDeleteRequest *request = [[NSBatchDeleteRequest alloc] initWithFetchRequest:[NSFetchRequest fetchRequestWithEntityName:[OCCKRecordMetadata entityPath]]];
    request.resultType = NSBatchDeleteResultTypeStatusOnly;
    request.affectedStores = @[store];
    // x22
    BOOL boolValue = ((NSNumber *)((NSBatchDeleteResult *)[managedObjectContext executeRequest:request error:&_error]).result).boolValue;
    
    if (boolValue) {
        os_log_with_type(_OCLogGetLogStream(0x11), OS_LOG_TYPE_DEFAULT, "OpenCloudData+CloudKit: %s(%d): Successfully purged record metadata during migration due to corrupted metadatas.", __func__, __LINE__);
    } else {
        os_log_with_type(_OCLogGetLogStream(0x11), OS_LOG_TYPE_DEFAULT, "OpenCloudData+CloudKit: %s(%d): Failed to purged corrupted record metadata during migration: %@", __func__, __LINE__, _error);
        _succeed = NO;
        
        if (_error != nil) {
            if (error != NULL) {
                *error = [[_error retain] autorelease];
            }
        } else {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        }
    }
    
    [request release];
    return _succeed;
}

- (BOOL)cleanUpAfterClientMigrationWithStore:(NSSQLCore *)store andContext:(NSManagedObjectContext *)context error:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct)) {
    /*
     store = x21
     context = x19 / sp + 0x10
     error = sp + 0x8
     */
    // sp, #0xd0
    __block BOOL _succeed = YES;
    // sp, #0xa0
    __block NSError * _Nullable _error = nil;
    
    NSMutableArray<NSSQLEntity *> * _Nullable entities;
    {
        NSSQLModel *model = store.model;
        if (model == nil) {
            entities = nil;
        } else {
            assert(object_getInstanceVariable(model, "_entities", (void **)&entities) != NULL);
        }
    }
    // x22
    NSMutableArray<NSNumber *> *array_1 = [[NSMutableArray alloc] initWithCapacity:entities.count];
    // x23
    NSMutableArray *array_2 = [[NSMutableArray alloc] initWithCapacity:entities.count];
    // x26
    for (NSSQLEntity *entity in entities) {
        uint _entityID;
        if (entity == nil) {
            _entityID = 0;
        } else {
            Ivar ivar = object_getInstanceVariable(entity, "_entityID", NULL);
            assert(ivar != NULL);
            _entityID = *(uint *)((uintptr_t)entity + ivar_getOffset(ivar));
        }
        NSNumber *entityIDNumber = @(_entityID);
        [array_1 addObject:entityIDNumber];
    }
    // <+472>
    // x24
    NSFetchRequest<OCCKRecordMetadata *> *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:[OCCKRecordMetadata entityPath]];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"NOT (entityId IN %@)", array_1];
    // x25
    NSBatchDeleteRequest *request = [[NSBatchDeleteRequest alloc] initWithFetchRequest:fetchRequest];
    request.resultType = NSBatchDeleteResultTypeStatusOnly;
    request.affectedStores = @[store];
    
    BOOL boolValue = ((NSNumber *)((NSBatchDeleteResult *)[context executeRequest:request error:&_error]).result).boolValue;
    if (!boolValue) {
        _succeed = NO;
        [_error retain];
        [fetchRequest release];
        [request release];
        [array_2 release];
        [array_1 release];
        
        if (_error != nil) {
            if (error != NULL) {
                *error = [[_error retain] autorelease];
            }
        } else {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        }
        [_error release];
        return NO;
    }
    
    // x26
    NSFetchRequest<OCCKMirroredRelationship *> *fetchRequest_2 = [[NSFetchRequest alloc] initWithEntityName:[OCCKMirroredRelationship entityPath]];
    fetchRequest_2.fetchBatchSize = 500;
    fetchRequest_2.propertiesToFetch = @[@"cdEntityName", @"relatedEntityName"];
    fetchRequest_2.affectedStores = @[store];
    
    /*
     __89-[PFCloudKitMetadataModelMigrator cleanUpAfterClientMigrationWithStore:andContext:error:]_block_invoke
     array_2 = sp + 0x38 = x20 + 0x20
     store = sp + 0x40 = x20 + 0x28
     context = sp + 0x48 = x20 + 0x30
     _error = sp + 0x50 = x20 + 0x38
     _succeed = sp + 0x58 = x20 + 0x40
     */
    [OCSPIResolver _PFRoutines_efficientlyEnumerateManagedObjectsInFetchRequest_usingManagedObjectContext_andApplyBlock_:objc_lookUpClass("_PFRoutines") x1:fetchRequest_2 x2:context x3:^(NSArray<OCCKMirroredRelationship *> * _Nullable objects, NSError * _Nullable __error, BOOL * _Nonnull checkChanges, BOOL * _Nonnull reserved) {
        /*
         self(block) = x20
         checkChanges = x19
         objects = x23
         reserved = x22
         */
        
        if (objects == nil) {
            [__error retain];
            _succeed = NO;
            _error = __error;
            return;
        }
        
        // x21
        NSMutableArray<NSManagedObjectID *> *array_3 = [[NSMutableArray alloc] init];
        // x25
        for (OCCKMirroredRelationship *relationship in objects) {
            if (![array_2 containsObject:relationship.cdEntityName] || ![array_2 containsObject:relationship.relatedEntityName]) {
                [array_3 addObject:relationship.objectID];
            }
        }
        
        if (array_3.count != 0) {
            // x23
            NSBatchDeleteRequest *request = [[NSBatchDeleteRequest alloc] initWithObjectIDs:array_3];
            request.resultType = NSBatchDeleteResultTypeStatusOnly;
            request.affectedStores = @[store];
            BOOL boolValue = ((NSNumber *)((NSBatchDeleteResult *)[context executeRequest:request error:&_error]).result).boolValue;
            
            if (!boolValue) {
                _succeed = NO;
                [_error retain];
            }
            [request release];
        }
        
        [array_3 release];
    }];
    
    [fetchRequest_2 release];
    
    if (!_succeed) {
        [_error retain];
        [fetchRequest release];
        [request release];
        [array_2 release];
        [array_1 release];
        
        if (_error != nil) {
            if (error != NULL) {
                *error = [[_error retain] autorelease];
            }
        } else {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        }
        [_error release];
        return NO;
    }
    
    [fetchRequest release];
    [request release];
    [array_2 release];
    [array_1 release];
    return YES;
}

@end
