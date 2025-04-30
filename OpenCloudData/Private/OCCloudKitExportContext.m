//
//  OCCloudKitExportContext.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/5/25.
//

#import <OpenCloudData/OCCloudKitExportContext.h>
#import <OpenCloudData/OCCKRecordMetadata.h>
#import <OpenCloudData/OCCKMirroredRelationship.h>
#import <OpenCloudData/OCCKRecordZoneMetadata.h>
#import <OpenCloudData/OCCKRecordZoneMoveReceipt.h>
#import <OpenCloudData/OCCKMetadataEntry.h>
#import <OpenCloudData/_NSPersistentHistoryToken.h>
#import <OpenCloudData/OCCKHistoryAnalyzerState.h>
#import <OpenCloudData/_PFRoutines.h>
#import <OpenCloudData/NSManagedObjectID+Private.h>
#import <OpenCloudData/NSSQLBlockRequestContext.h>
#import <OpenCloudData/Log.h>
#import <objc/runtime.h>
#import <OpenCloudData/OCCloudKitSerializer.h>
#import <OpenCloudData/OCCloudKitMetadataCache.h>
#import <OpenCloudData/PFMirroredManyToManyRelationshipV2.h>
#import <OpenCloudData/CKRecord+Private.h>
#import <OpenCloudData/OCSPIResolver.h>

@implementation OCCloudKitExportContext

- (instancetype)initWithOptions:(OCCloudKitExporterOptions *)options {
    if (self = [super init]) {
        _options = [options retain];
        _totalBytes = 0;
        _totalRecords = 0;
        _totalRecordIDs = 0;
        _writtenAssetURLs = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)dealloc {
    [_options release];
    _options = nil;
    [_writtenAssetURLs release];
    _writtenAssetURLs = nil;
    [super dealloc];
}

- (BOOL)processAnalyzedHistoryInStore:(NSSQLCore *)store inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable *)error {
    /*
     x19 = error
     */
    
    // x29 - 0x50
    __block BOOL _succeed = YES;
    // sp + 0x50
    __block NSError * _Nullable _error = nil;
    
    /*
     __86-[PFCloudKitExportContext processAnalyzedHistoryInStore:inManagedObjectContext:error:]_block_invoke
     sp + 0x28 = store = x19 + 0x20
     sp + 0x30 = managedObjectContext = x19 + 0x28
     sp + 0x38 = self = x19 + 0x30
     sp + 0x40 = _error = x19 + 0x38
     sp + 0x48 = _succeed = x19 + 0x40
     */
    [managedObjectContext performBlockAndWait:^{
        // original : NSCloudKitMirroringDelegateLastHistoryTokenKey
        OCCKMetadataEntry * _Nullable entry = [OCCKMetadataEntry entryForKey:@"NSCloudKitMirroringDelegateLastHistoryTokenKey" fromStore:store inManagedObjectContext:managedObjectContext error:&_error];
        
        if (_error == nil) {
            _succeed = NO;
            [_error retain];
            
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData+CloudKit: %s(%d): Unable to read the last history token: %@", __func__, __LINE__, self);
            return;
        }
        
        // x20
        NSDictionary<NSString *, NSNumber *> *storeTokens = [(_NSPersistentHistoryToken *)entry.transformedValue storeTokens];
        // x20
        NSNumber *tokenNumber = [storeTokens[store.identifier] retain];
        if (tokenNumber == nil) {
            tokenNumber = [[NSNumber alloc] initWithInt:0];
        }
        
        // x21 / x25
        NSMutableSet<NSManagedObjectID *> *allObjectIDs = [[NSMutableSet alloc] init];
        // *(x19 - 0xc8) + 0x28
        NSMutableDictionary<NSNumber *, NSMutableSet<OCCKHistoryAnalyzerState *> *> *entityIDToStatesSet = [[NSMutableDictionary alloc] init];
        // *(x19 - 0xf8) + 0x28
        __block NSMutableDictionary<NSNumber *, NSMutableSet<NSNumber *> *> *entityIDToReferenceData64Set = [[NSMutableDictionary alloc] init];
        // x22
        NSMutableSet<NSManagedObjectID *> *objectIDs_2 = [[NSMutableSet alloc] init];
        // x23
        NSMutableSet<NSManagedObjectID *> *objectIDs_0_1 = [[NSMutableSet alloc] init];
        
        // x24
        NSFetchRequest<OCCKHistoryAnalyzerState *> *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[OCCKHistoryAnalyzerState entityPath]];
        fetchRequest.returnsObjectsAsFaults = NO;
        fetchRequest.propertiesToFetch = @[@"entityPK", @"entityId", @"finalChangeTypeNum"];
        fetchRequest.fetchBatchSize = 200;
        
        
        // sp + 0x1c0
        __block NSUInteger count_0_1 = 0;
        
        // sp + 0x1a0
        __block NSUInteger count_2 = 0;
        
        /*
         __86-[PFCloudKitExportContext processAnalyzedHistoryInStore:inManagedObjectContext:error:]_block_invoke.14
         sp + 0x140 = store = x20 + 0x20
         sp + 0x148 = objectIDs_2 = x20 + 0x28
         sp + 0x150 = objectIDs_0_1 = x20 + 0x30
         sp + 0x158 = allObjectIDs = x20 + 0x38
         sp + 0x160 = managedObjectContext = x20 + 0x40
         sp + 0x168 = storeTokens = x20 + 0x48
         sp + 0x170 = entityIDToReferenceData64Set = x20 + 0x50
         sp + 0x178 = count_2 = x20 + 0x58
         sp + 0x180 = entityIDToStatesSet = x20 + 0x60
         sp + 0x188 = count_0_1 = x20 + 0x68
         x19 + 0x38 = _error = x20 + 0x70
         x19 + 0x40 = _succeed = x20 + 0x78
         */
        [OCSPIResolver _PFRoutines_efficientlyEnumerateManagedObjectsInFetchRequest_usingManagedObjectContext_andApplyBlock_:objc_lookUpClass("_PFRoutines") x1:fetchRequest x2:managedObjectContext x3:^(NSArray<OCCKHistoryAnalyzerState *> * _Nullable states, NSError * _Nullable __error, BOOL *checkChanges, BOOL *reserved) {
            /*
             x21 = states
             */
            
            if (__error != nil) {
                _error = [__error retain];
                return;
            }
            
            // x27
            for (OCCKHistoryAnalyzerState *state in states) {
                // x26
                NSManagedObjectID * _Nullable analyzedObjectID = state.analyzedObjectID;
                
                if (analyzedObjectID == nil) {
                    [managedObjectContext deleteObject:state];
                    os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Unhandled persistent history change type: %@\n", state);
                    os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Unhandled persistent history change type: %@\n", state);
                } else {
                    // x28
                    NSSQLModel *model = store.model;
                    NSSQLEntity * _Nullable entity = [OCSPIResolver _sqlEntityForEntityDescription:analyzedObjectID.entity x1:model];
                    NSUInteger _entityID;
                    if (entity == nil) {
                        _entityID = 0;
                    } else {
                        Ivar ivar = object_getInstanceVariable(entity, "_entityID", NULL);
                        assert(ivar != NULL);
                        _entityID = *(NSUInteger *)((uintptr_t)entity + ivar_getOffset(ivar));
                    }
                    
                    // x19
                    NSNumber *entityIDNumber = @(_entityID);
                    // x28
                    NSNumber *referenceData64 = @([analyzedObjectID _referenceData64]);
                    
#warning TODO enum 정의 + switch로 변경
                    if (state.finalChangeType == 2) /* Deleted 같음 */ {
                        // x27
                        NSMutableSet<NSNumber *> *referenceData64Set = [entityIDToReferenceData64Set[entityIDNumber] retain];
                        if (referenceData64Set == nil) {
                            referenceData64Set = [[NSMutableSet alloc] init];
                            entityIDToReferenceData64Set[entityIDNumber] = referenceData64Set;
                        }
                        [referenceData64Set addObject:referenceData64];
                        [referenceData64Set release];
                        
                        [objectIDs_2 addObject:analyzedObjectID];
                        count_2 += 1;
                    } else if ((state.finalChangeType == 0) || (state.finalChangeType == 1)) /* 아마 Inserted/Updated 같음 */ {
                        // x27
                        NSMutableSet<OCCKHistoryAnalyzerState *> *statesSet = [entityIDToStatesSet[entityIDNumber] retain];
                        if (statesSet == nil) {
                            statesSet = [[NSMutableSet alloc] init];
                            entityIDToStatesSet[entityIDNumber] = statesSet;
                        }
                        [statesSet addObject:state];
                        [statesSet release];
                        
                        [objectIDs_0_1 addObject:analyzedObjectID];
                        count_0_1 += 1;
                    } else {
                        os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Unhandled persistent history change type: %@", self);
                        os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Unhandled persistent history change type: %@", self);
                    }
                }
                
                [allObjectIDs addObject:analyzedObjectID];
            }
            
            if (managedObjectContext.hasChanges) {
                BOOL result = [managedObjectContext save:&_error];
                if (!result) {
                    _succeed = NO;
                    [_error retain];
                }
            }
            
            if (!_succeed) {
                *checkChanges = YES;
            } else {
                if (count_0_1 >= 500) {
                    /*
                     __86-[PFCloudKitExportContext processAnalyzedHistoryInStore:inManagedObjectContext:error:]_block_invoke.15
                     x10 = entityIDToReferenceData64Set
                     x11 = store
                     x13 = managedObjectContext
                     x12 = tokenNumber
                     x11 = _error
                     x10 = objectIDs_0_1
                     x9 = count_0_1
                     x8 = _succeed
                     
                     tokenNumber = sp + 0xa0 = x19 + 0x20
                     store = sp + 0xa8 = x19 + 0x28
                     entityIDToReferenceData64Set = sp + 0xc0 = x19 + 0x40
                     _error = sp + 0xc8 = x19 + 0x48
                     managedObjectContext = sp + 0xb0 = x19 + 0x30
                     objectIDs_0_1 = sp + 0xb8 = x19 + 0x38
                     count_0_1 = sp + 0xd0 = x19 + 0x50
                     _succeed = sp + 0xd8 = x19 + 0x58
                     */
                    [objc_lookUpClass("_PFRoutines") wrapBlockInGuardedAutoreleasePool:^{
                        // sp + 0x20
                        NSExpression *needsUploadExpr = [NSExpression expressionForConstantValue:@(YES)];
                        // sp + 0x28
                        NSExpression *needsCloudDeleteExpr = [NSExpression expressionForConstantValue:@(NO)];
                        // sp + 0x30
                        NSExpression *pendingExportTransactionNumberExpr = [NSExpression expressionForConstantValue:tokenNumber];
                        
                        NSDictionary<NSString *, NSExpression *> *keyToExprs = @{
                            @"needsUpload": needsUploadExpr,
                            @"needsCloudDelete": needsCloudDeleteExpr,
                            @"pendingExportTransactionNumber": pendingExportTransactionNumberExpr
                        };
                        
                        NSSet<NSManagedObjectID *> * _Nullable objectIDs = [OCCKRecordMetadata batchUpdateMetadataMatchingEntityIdsAndPKs:entityIDToReferenceData64Set withUpdates:keyToExprs inStore:store withManagedObjectContext:managedObjectContext error:&_error];
                        
                        if (objectIDs == nil) {
                            _succeed = NO;
                            [_error retain];
                        } else {
                            [objectIDs_0_1 minusSet:objectIDs];
                            [entityIDToReferenceData64Set release];
                            entityIDToReferenceData64Set = [[NSMutableDictionary alloc] init];
                            count_0_1 = 0;
                        }
                    }];
                }
                
                if (count_2 >= 500) {
                    /*
                     __86-[PFCloudKitExportContext processAnalyzedHistoryInStore:inManagedObjectContext:error:]_block_invoke_2
                     x11 = tokenNumber
                     x10 = entityIDToReferenceData64Set
                     x12 = managedObjectContext
                     x13 = store
                     x14 = objectIDs_2
                     
                     x11 = _error
                     x9 = count_2
                     x8 =  _succeed
                     
                     tokenNumber = sp + 0x40 = x19 + 0x20
                     store = sp + 0x48 = x19 + 0x28
                     entityIDToReferenceData64Set = sp + 0x60 = x19 + 0x40
                     storeTokens = sp + 0x68 = x19 + 0x48
                     managedObjectContext = sp + 0x50 = = x19 + 0x30
                     objectIDs_2 = sp + 0x58 + = x19 + 0x38
                     count_2 = sp + 0x70 = x19 + 0x50
                     _succeed = sp + 0x78 = = x19 + 0x58
                     */
                    [objc_lookUpClass("_PFRoutines") wrapBlockInGuardedAutoreleasePool:^{
                        // sp + 0x20
                        NSExpression *needsUploadExpr = [NSExpression expressionForConstantValue:@(YES)];
                        // sp + 0x28
                        NSExpression *needsCloudDeleteExpr = [NSExpression expressionForConstantValue:@(YES)];
                        // sp + 0x30
                        NSExpression *pendingExportTransactionNumberExpr = [NSExpression expressionForConstantValue:tokenNumber];
                        
                        NSDictionary<NSString *, NSExpression *> *keyToExprs = @{
                            @"needsUpload": needsUploadExpr,
                            @"needsCloudDelete": needsCloudDeleteExpr,
                            @"pendingExportTransactionNumber": pendingExportTransactionNumberExpr
                        };
                        
                        NSSet<NSManagedObjectID *> * _Nullable objectIDs = [OCCKRecordMetadata batchUpdateMetadataMatchingEntityIdsAndPKs:entityIDToReferenceData64Set withUpdates:keyToExprs inStore:store withManagedObjectContext:managedObjectContext error:&_error];
                        
                        if (objectIDs == nil) {
                            _succeed = NO;
                            [_error retain];
                        } else {
                            [objectIDs_2 minusSet:objectIDs];
                            [entityIDToReferenceData64Set release];
                            entityIDToReferenceData64Set = [[NSMutableDictionary alloc] init];
                            count_2 = 0;
                        }
                    }];
                }
            }
        }];
        
        if (_succeed) {
            /*
             __86-[PFCloudKitExportContext processAnalyzedHistoryInStore:inManagedObjectContext:error:]_block_invoke_3
             
             storeTokens = sp + 0xe0 = x19 + 0x20
             
             <q0>
             store = x19 + 0x28
             managedObjectContext = x19 + 0x30
             
             objectIDs_0_1 = sp + 0xf8 = x19 + 0x38
             entityIDToStatesSet = sp + 0x100 = x19 + 0x40
             _error = sp + 0x108 = x19 + 0x48
             count_0_1 = sp + 0x110 = x19 + 0x50
             _succeed = sp + 0x118 = x19 + 0x58
             */
            [objc_lookUpClass("_PFRoutines") wrapBlockInGuardedAutoreleasePool:^{
                // sp + 0x20
                NSExpression *needsUploadExpr = [NSExpression expressionForConstantValue:@(YES)];
                // sp + 0x28
                NSExpression *needsCloudDeleteExpr = [NSExpression expressionForConstantValue:@(NO)];
                // sp + 0x30
                NSExpression *pendingExportTransactionNumberExpr = [NSExpression expressionForConstantValue:tokenNumber];
                
                NSDictionary<NSString *, NSExpression *> *keyToExprs = @{
                    @"needsUpload": needsUploadExpr,
                    @"needsCloudDelete": needsCloudDeleteExpr,
                    @"pendingExportTransactionNumber": pendingExportTransactionNumberExpr
                };
                
                NSSet<NSManagedObjectID *> * _Nullable objectIDs = [OCCKRecordMetadata batchUpdateMetadataMatchingEntityIdsAndPKs:entityIDToReferenceData64Set withUpdates:keyToExprs inStore:store withManagedObjectContext:managedObjectContext error:&_error];
                
                if (objectIDs == nil) {
                    _succeed = NO;
                    [_error retain];
                } else {
                    [objectIDs_0_1 minusSet:objectIDs];
                    [entityIDToReferenceData64Set release];
                    entityIDToReferenceData64Set = [[NSMutableDictionary alloc] init];
                    count_0_1 = 0;
                }
            }];
            
            if (_succeed) {
                /*
                 __86-[PFCloudKitExportContext processAnalyzedHistoryInStore:inManagedObjectContext:error:]_block_invoke_4
                 */
                [objc_lookUpClass("_PFRoutines") wrapBlockInGuardedAutoreleasePool:^{
                    // sp + 0x20
                    NSExpression *needsUploadExpr = [NSExpression expressionForConstantValue:@(YES)];
                    // sp + 0x28
                    NSExpression *needsCloudDeleteExpr = [NSExpression expressionForConstantValue:@(YES)];
                    // sp + 0x30
                    NSExpression *pendingExportTransactionNumberExpr = [NSExpression expressionForConstantValue:tokenNumber];
                    
                    NSDictionary<NSString *, NSExpression *> *keyToExprs = @{
                        @"needsUpload": needsUploadExpr,
                        @"needsCloudDelete": needsCloudDeleteExpr,
                        @"pendingExportTransactionNumber": pendingExportTransactionNumberExpr
                    };
                    
                    NSSet<NSManagedObjectID *> * _Nullable objectIDs = [OCCKRecordMetadata batchUpdateMetadataMatchingEntityIdsAndPKs:entityIDToReferenceData64Set withUpdates:keyToExprs inStore:store withManagedObjectContext:managedObjectContext error:&_error];
                    
                    if (objectIDs == nil) {
                        _succeed = NO;
                        [_error retain];
                    } else {
                        [objectIDs_2 minusSet:objectIDs];
                        [entityIDToReferenceData64Set release];
                        entityIDToReferenceData64Set = [[NSMutableDictionary alloc] init];
                        count_2 = 0;
                    }
                }];
            }
        }
        
        os_log_info(_OCLogGetLogStream(0x11), "OpenCloudData+CloudKit: %s(%d): Finished processing analyzed history with %lu metadata objects to create, %lu deleted rows without metadata.", __func__, __LINE__, objectIDs_0_1.count, objectIDs_2.count);
        
        if (_succeed) {
            /*
             __86-[PFCloudKitExportContext processAnalyzedHistoryInStore:inManagedObjectContext:error:]_block_invoke.28
             objectIDs_0_1 = sp + 0x28 = x19 + 0x20
             q0 = x19, #0x20
             -> store = x19 + 0x30
             -> managedObjectContext = x19 + 0x28
             self = sp + 0x40 = x19 + 0x38
             tokenNumber = sp + 0x48 = x19 + 0x40
             _succeed = sp + 0x50 = x19 + 0x48
             _error = sp + 0x58 = x19 + 0x50
             */
            [objc_lookUpClass("_PFRoutines") wrapBlockInGuardedAutoreleasePool:^{
                // x19 = x0
                
                // sp + 0x58
                NSMutableDictionary<NSNumber *, NSMutableSet<NSNumber *> *> *entityIDToReferenceData64Set = [[NSMutableDictionary alloc] init];
                // sp + 0x50
                NSMutableSet<NSManagedObjectID *> *errorObjectIDs = [[NSMutableSet alloc] init];
                // sp + 0x60
                NSMutableDictionary<CKRecordZoneID *, NSMutableDictionary<NSString *, NSMutableSet<NSManagedObjectID *> *> *> *zoneIDToEntityNameToObjectIDsSet = [[NSMutableDictionary alloc] init];
                
                while (YES) {
                    if (!_succeed) {
                        [zoneIDToEntityNameToObjectIDsSet release];
                        [errorObjectIDs release];
                        [entityIDToReferenceData64Set release];
                        return;
                    }
                    
                    if (objectIDs_0_1.count == 0) {
                        break;
                    } else {
                        // x20
                        NSManagedObjectID *objectID = [objectIDs_0_1 anyObject];
                        [objectIDs_0_1 removeObject:objectID];
                        
                        /*
                         __86-[PFCloudKitExportContext processAnalyzedHistoryInStore:inManagedObjectContext:error:]_block_invoke_2.29
                         managedObjectContext = sp + 0x298 = x19 + 0x20
                         objectID = sp + 0x2a0 = x19 + 0x28
                         
                         <q0>
                         store = x19 + 0x30
                         self = x19 + 0x38
                         
                         zoneIDToEntityNameToObjectIDsSet = sp + 0x2b8 = x19 + 0x40
                         objectIDs_0_1 = sp + 0x2c0 = x19 + 0x48
                         errorObjectIDs = sp + 0x2c8 = x19 + 0x50
                         entityIDToReferenceData64Set = sp + 0x2d0 = x19 + 0x58
                         
                         <q0>
                         _error = x19 + 0x60
                         _succeed = x19 + 0x68
                         */
                        [objc_lookUpClass("_PFRoutines") wrapBlockInGuardedAutoreleasePool:^{
                            void (^finish_1)(void) = ^{
                                if (_succeed) {
                                    if (managedObjectContext.insertedObjects.count >= 500) {
                                        BOOL result = [managedObjectContext save:&_error];
                                        if (result) {
                                            [managedObjectContext reset];
                                        } else {
                                            _succeed = NO;
                                            [_error retain];
                                        }
                                    }
                                }
                            };
                            
                            //
                            
                            // x22 | sp + 0x28
                            NSManagedObject * _Nullable existingObject = [managedObjectContext existingObjectWithID:objectID error:&_error];
                            if (existingObject == nil) {
                                if ((_error.code == NSManagedObjectReferentialIntegrityError) && [_error.domain isEqualToString:NSCocoaErrorDomain]) {
                                    _error = nil;
                                    [errorObjectIDs addObject:objectID];
                                    
                                    NSSQLEntity * _Nullable entity = [OCSPIResolver _sqlEntityForEntityDescription:objectID.entity x1:store.model];
                                    NSUInteger _entityID;
                                    if (entity == nil) {
                                        _entityID = 0;
                                    } else {
                                        Ivar ivar = object_getInstanceVariable(entity, "_entityID", NULL);
                                        assert(ivar != NULL);
                                        _entityID = *(NSUInteger *)((uintptr_t)entity + ivar_getOffset(ivar));
                                    }
                                    // x20
                                    NSNumber *entityIDNumber = @(_entityID);
                                    // x21
                                    NSNumber *referenceData64Number = @([objectID _referenceData64]);
                                    
                                    // x22
                                    NSMutableSet *referenceData64Set = [entityIDToReferenceData64Set[entityIDNumber] retain];
                                    if (referenceData64Set == nil) {
                                        entityIDToReferenceData64Set[entityIDNumber] = referenceData64Set;
                                    }
                                    [referenceData64Set addObject:referenceData64Number];
                                    [referenceData64Set release];
                                } else {
                                    [_error retain];
                                    _succeed = NO;
                                }
                                
#warning Error Leak
                                finish_1();
                                return;
                            }
                            
                            // x21
                            NSSet<NSManagedObjectID *> *relatedObjectIDs = [[OCCloudKitSerializer createSetOfObjectIDsRelatedToObject:existingObject] autorelease];
                            
                            if (relatedObjectIDs.count == 0) {
                                [managedObjectContext refreshObject:existingObject mergeChanges:existingObject.hasChanges];
                                finish_1();
                                return;
                            }
                            
                            //
                            
                            // x25 | sp + 0x20 (retained)
                            NSSet<CKRecordZoneID *> *zoneIDs = [OCCKRecordZoneMetadata fetchZoneIDsAssignedToObjectsWithIDs:relatedObjectIDs fromStore:store inContext:managedObjectContext error:&_error];
                            
                            //
                            
                            void (^finish_2)(void) = ^{
                                [zoneIDs release];
                                [managedObjectContext refreshObject:existingObject mergeChanges:existingObject.hasChanges];
                                finish_1();
                            };
                            
                            //
                            
                            if (zoneIDs == nil) {
                                _succeed = NO;
                                [_error retain];
#warning Error Leak
                                finish_2();
                                return;
                            }
                            
                            // x23
                            CKRecordZoneID *zoneID;
                            if (zoneIDs.count == 0) {
                                if (self->_options->_database.databaseScope == CKDatabaseScopeShared) {
                                    os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData+CloudKit: %s(%d): %@: %@ - Failed to assign an object to a record zone. This usually means the object exists in a shared database and must be assigned to a zone using -[%@ %@]: %@", __func__, __LINE__, self, store, NSStringFromClass([self class]), NSStringFromSelector(_cmd), existingObject);
                                    _succeed = NO;
                                    _error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:2988 userInfo:@{
                                        NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"Failed to assign an object to a record zone. This usually means the object exists in a shared database and must be assigned to a zone using -[%@ %@]: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), existingObject.objectID]}];
                                    
    #warning Error Leak
                                    finish_2();
                                    return;
                                } else {
                                    zoneID = [OCCloudKitSerializer defaultRecordZoneIDForDatabaseScope:self->_options->_database.databaseScope];
                                }
                            } else if (zoneIDs.count != 1) {
                                if (zoneIDs.count < 2) {
                                    zoneID = nil;
                                } else {
                                    _succeed = NO;
                                    _error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:NSCoreDataError userInfo:@{
                                        NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"Object graph corruption detected. Objects related to '%@' are assigned to multiple zones: %@", objectID, zoneIDs]
                                    }];
                                    
    #warning Error Leak
                                    finish_2();
                                    return;
                                }
                            } else {
                                zoneID = [[zoneIDs anyObject] retain];
                            }
                            
                            if (_succeed) {
                                // x24
                                NSMutableDictionary<NSString *, NSMutableSet<NSManagedObjectID *> *> *entityNameToObjectIDsSet = [zoneIDToEntityNameToObjectIDsSet[zoneID] retain];
                                if (entityNameToObjectIDsSet == nil) {
                                    entityNameToObjectIDsSet = [[NSMutableDictionary alloc] init];
                                    zoneIDToEntityNameToObjectIDsSet[zoneID] = entityNameToObjectIDsSet;
                                }
                                // x25
                                NSMutableSet<NSManagedObjectID *> *objectIDsSet = [entityNameToObjectIDsSet[objectID.entityName] retain];
                                if (objectIDsSet == nil) {
                                    objectIDsSet = [[NSMutableSet alloc] init];
                                    entityNameToObjectIDsSet[objectID.entityName] = objectIDsSet;
                                }
                                [objectIDsSet addObject:objectID];
                                [objectIDsSet release];
                                [entityNameToObjectIDsSet release];
                                
                                // x25
                                for (NSManagedObjectID *relatedObjectID in relatedObjectIDs) {
                                    if (![objectIDs_0_1 containsObject:relatedObjectID]) continue;
                                    
                                    [objectIDs_0_1 removeObject:relatedObjectID];
                                    
                                    // x26
                                    NSMutableDictionary<NSString *, NSMutableSet<NSManagedObjectID *> *> *entityNameToObjectIDsSet = [zoneIDToEntityNameToObjectIDsSet[zoneID] retain];
                                    if (entityNameToObjectIDsSet == nil) {
                                        entityNameToObjectIDsSet = [[NSMutableDictionary alloc] init];
                                        zoneIDToEntityNameToObjectIDsSet[zoneID] = entityNameToObjectIDsSet;
                                    }
                                    // x27
                                    NSMutableSet<NSManagedObjectID *> *objectIDsSet = [entityNameToObjectIDsSet[relatedObjectID.entityName] retain];
                                    if (objectIDsSet == nil) {
                                        objectIDsSet = [[NSMutableSet alloc] init];
                                        entityNameToObjectIDsSet[relatedObjectID.entityName] = objectIDsSet;
                                    }
                                    [objectIDsSet addObject:relatedObjectID];
                                    [objectIDsSet release];
                                    [entityNameToObjectIDsSet release];
                                }
                            }
                            
                            [zoneID release];
                            finish_2();
                        }];
                    }
                }
                
                if (!_succeed) {
                    [zoneIDToEntityNameToObjectIDsSet release];
                    [errorObjectIDs release];
                    [entityIDToReferenceData64Set release];
                    return;
                }
                
                // x26
                for (CKRecordZoneID *zoneID in zoneIDToEntityNameToObjectIDsSet) {
                    // x27
                    NSMutableDictionary<NSString *, NSMutableSet<NSManagedObjectID *> *> *entityNameToObjectIDsSet = zoneIDToEntityNameToObjectIDsSet[zoneID];
                    
                    // x20
                    for (NSString *entityName in entityNameToObjectIDsSet) @autoreleasepool {
                        // x22
                        NSMutableSet<NSManagedObjectID *> *objectIDsSet = entityNameToObjectIDsSet[entityName];
                        
                        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
                        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"SELF IN %@", objectIDsSet];
                        fetchRequest.fetchBatchSize = 500;
                        
                        // x22 / w22
                        BOOL preserveLegacyRecordMetadataBehavior;
                        OCCloudKitExporterOptions * _Nullable options = self->_options;
                        if (options == nil) {
                            preserveLegacyRecordMetadataBehavior = NO;
                        } else {
                            preserveLegacyRecordMetadataBehavior = options->_options.preserveLegacyRecordMetadataBehavior;
                        }
                        if (preserveLegacyRecordMetadataBehavior) {
                            // original : NSCKRecordIDAttributeName
                            NSPropertyDescription *propertyDescription = managedObjectContext.persistentStoreCoordinator.managedObjectModel.entitiesByName[entityName].propertiesByName[@"ckRecordID"];
                            if (propertyDescription != nil) {
                                fetchRequest.propertiesToFetch = @[propertyDescription];
                            }
                        }
                        
                        /*
                         __86-[PFCloudKitExportContext processAnalyzedHistoryInStore:inManagedObjectContext:error:]_block_invoke.45
                         zoneID = sp + 0x1c0 = x20 + 0x20
                         tokenNumber = sp + 0x1c8 = x20 + 0x28
                         managedObjectContext = sp + 0x1d0 = x20 + 0x30
                         _error = x20 + 0x38
                         _succeed = x20 + 0x40
                         
                         */
                        [OCSPIResolver _PFRoutines_efficientlyEnumerateManagedObjectsInFetchRequest_usingManagedObjectContext_andApplyBlock_:objc_lookUpClass("_PFRoutines") x1:fetchRequest x2:managedObjectContext x3:^(NSArray<OCCKHistoryAnalyzerState *> * _Nullable states, NSError * _Nullable __error, BOOL *checkChanges, BOOL *reserved) {
                            if (states == nil) {
                                _succeed = NO;
                                _error = [__error retain];
                                return;
                            }
                            
                            /*
                             x20 = self
                             x21 = states
                             x19 = checkChanges
                             */
                            
                            for (OCCKHistoryAnalyzerState *state in states) {
                                // x23
                                OCCKRecordMetadata * _Nullable metadata = [OCCKRecordMetadata insertMetadataForObject:state setRecordName:preserveLegacyRecordMetadataBehavior inZoneWithID:zoneID recordNamePrefix:nil error:&_error];
                                
                                if (metadata == nil) {
                                    [_error retain];
                                    _succeed = NO;
                                    break;
                                } else {
                                    metadata.needsUpload = YES;
                                    metadata.needsCloudDelete = NO;
                                    metadata.pendingExportTransactionNumber = tokenNumber;
                                }
                            }
                            
#warning TODO : Error가 있는 상태에서 Save할 때 Error가 발생하면 Leak이 발생함
                            if (![managedObjectContext save:&_error]) {
                                _succeed = NO;
                                [_error retain];
                            }
                        }];
                    }
                }
                
                if (_succeed) {
                    if (entityIDToReferenceData64Set.count != 0) {
                        NSDictionary<NSString *, NSExpression *> *updates = @{
                            @"needsUpload": [NSExpression expressionForConstantValue:@(YES)],
                            @"needsCloudDelete": [NSExpression expressionForConstantValue:@(YES)]
                        };
                        
                        NSSet<NSManagedObjectID *> * _Nullable objectIDs = [OCCKRecordMetadata batchUpdateMetadataMatchingEntityIdsAndPKs:entityIDToReferenceData64Set withUpdates:updates inStore:store withManagedObjectContext:managedObjectContext error:&_error];
                        if (objectIDs == nil) {
                            _succeed = NO;
                            [_error retain];
                        } else {
                            [errorObjectIDs minusSet:objectIDs];
                        }
                    }
                    
                    if (managedObjectContext.hasChanges) {
                        if (![managedObjectContext save:&_error]) {
#warning TODO : Error가 있는 상태에서 Save할 때 Error가 발생하면 Leak이 발생함
                            _succeed = NO;
                            [_error retain];
                        }
                    }
                }
                
                if (_succeed) {
                    BOOL result = [OCCKHistoryAnalyzerState purgeAnalyzedHistoryFromStore:store withManagedObjectContext:managedObjectContext error:&_error];
                    if (!result) {
                        _succeed = NO;
                        [_error retain];
                    }
                }
                
                [zoneIDToEntityNameToObjectIDsSet release];
                [errorObjectIDs release];
                [entityIDToReferenceData64Set release];
                
                [managedObjectContext reset];
                
                void (^final)(void) = ^{
                    NSFetchRequest<OCCKRecordZoneMoveReceipt *> *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[OCCKRecordZoneMoveReceipt entityPath]];
                    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"needsCloudDelete == 1"];
                    fetchRequest.fetchBatchSize = 500;
                    fetchRequest.returnsObjectsAsFaults = NO;
                    fetchRequest.affectedStores = @[store];
                    
                    /*
                     __86-[PFCloudKitExportContext processAnalyzedHistoryInStore:inManagedObjectContext:error:]_block_invoke_3.57
                     */
                    [OCSPIResolver _PFRoutines_efficientlyEnumerateManagedObjectsInFetchRequest_usingManagedObjectContext_andApplyBlock_:objc_lookUpClass("_PFRoutines") x1:fetchRequest x2:managedObjectContext x3:^(NSArray<OCCKRecordZoneMoveReceipt *> * _Nullable receipts, NSError * _Nullable __error, BOOL *checkChanges, BOOL *reserved) {
                        /*
                         self = x20
                         states = x22
                         checkChanges = x19
                         */
                        
                        // x21
                        NSMutableArray<CKRecordID *> *recordIDs = [[NSMutableArray alloc] init];
                        
                        for (OCCKRecordZoneMoveReceipt *receipt in receipts) {
                            CKRecordID *recordID = [receipt createRecordIDForMovedRecord];
                            [recordIDs addObject:recordID];
                            [recordID release];
                        }
                        
                        // x22
                        NSArray<OCCKMirroredRelationship *> * _Nullable mirroredRelationships = [OCCKMirroredRelationship fetchMirroredRelationshipsMatchingRelatingRecords:@[] andRelatingRecordIDs:recordIDs fromStore:store inManagedObjectContext:managedObjectContext error:&_error];
                        
                        BOOL hasError;
                        if (mirroredRelationships != nil) {
                            // x23
                            NSNumber *noNumber = @NO;
                            // x24
                            NSNumber *yesNumber = @YES;
                            
                            // x26
                            for (OCCKMirroredRelationship *relationship in mirroredRelationships) {
                                relationship.isUploaded = noNumber;
                                relationship.needsDelete = yesNumber;
                            }
                            
                            hasError = [managedObjectContext save:&_error];
                        } else {
                            hasError = YES;
                        }
                        
                        if (hasError) {
                            [_error retain];
                            _succeed = NO;
                        }
                        
                        [recordIDs release];
                    }];
                };
                
                if (_succeed) {
                    // original : NSCloudKitMirroringDelegateScanForRowsMissingFromHistoryKey
                    OCCKMetadataEntry * _Nullable entry = [OCCKMetadataEntry entryForKey:@"NSCloudKitMirroringDelegateScanForRowsMissingFromHistoryKey" fromStore:store inManagedObjectContext:managedObjectContext error:&_error];
                    if (!entry.boolValue) {
                        if (_error != nil) {
                            _succeed = NO;
                            [_error retain];
                        }
                        
                        if (_succeed) {
                            final();
                        }
                        
                        return;
                    }
                    
                    OCCloudKitExporterOptions *options = self->_options;
                    CKDatabase * _Nullable database;
                    if (options == nil) {
                        database = nil;
                    } else {
                        database = options->_database;
                    }
                    
                    CKDatabaseScope databaseScope = database.databaseScope;
                    if ((databaseScope != CKDatabaseScopePublic) && (databaseScope != CKDatabaseScopePrivate)) {
                        if (_error != nil) {
                            _succeed = NO;
                            [_error retain];
                        }
                        
                        if (_succeed) {
                            final();
                        }
                        
                        return;
                    }
                    
                    CKRecordZoneID *zoneID = [OCCloudKitSerializer defaultRecordZoneIDForDatabaseScope:databaseScope];
                    OCCKRecordZoneMetadata * _Nullable zoneMetadata = [OCCKRecordZoneMetadata zoneMetadataForZoneID:zoneID inDatabaseWithScope:databaseScope forStore:store inContext:managedObjectContext error:&_error];
                    if (zoneMetadata == nil) {
                        _succeed = NO;
                        [_error retain];
                        [zoneID release];
                        return;
                    }
                    
                    
                    // sp + 0x50
                    NSSQLModel *model = [store.model retain];
                    
                    // original : NSPersistentStoreMirroringDelegateOptionKey
                    NSSQLModel *mirroringModel = [store ancillarySQLModels][@"NSPersistentStoreMirroringDelegateOptionKey"];
                    
                    // sp + 0x20
//                    NSSQLEntity *recordMetadataEntity = [mirroringModel entityNamed:@"OCCKRecordMetadata"];
                    NSSQLEntity *recordMetadataEntity = [mirroringModel entityNamed:@"NSCKRecordMetadata"];
                    
                    // sp + 0x28
                    NSArray<NSEntityDescription *> *entityDescriptions = [managedObjectContext.persistentStoreCoordinator.managedObjectModel entitiesForConfiguration:store.configurationName];
                    
                    // x20
                    for (NSEntityDescription *entityDescription in entityDescriptions) @autoreleasepool {
                        NSSQLEntity *entity = [model entityNamed:entityDescription.name];
                        if (entity == nil) {
                            continue;
                        }
                        
                        NSSQLEntity * _Nullable _superentity;
                        assert(object_getInstanceVariable(entity, "_superentity", (void **)&_superentity) != NULL);
                        
                        if (_superentity != nil) {
                            continue;
                        }
                        
                        /*
                         entity = sp + 0x118 = x19 + 0x20
                         recordMetadataEntity = sp + 0x120 = x19 + 0x28
                         */
                        
                        // sp + 0x170
                        __block NSArray<NSArray<NSNumber *> *> *arrayOfPrimaryKeysAndEntityIDs;
                        // x20 / sp + 0x38
                        /*
                         __86-[PFCloudKitExportContext processAnalyzedHistoryInStore:inManagedObjectContext:error:]_block_invoke_2.48
                         */
                        NSSQLBlockRequestContext *requestCpntext = [[objc_lookUpClass("NSSQLBlockRequestContext") alloc] initWithBlock:^(NSSQLStoreRequestContext * _Nullable context) {
                            NSSQLiteConnection * _Nullable connection;
                            {
                                if (context == nil) {
                                    connection = nil;
                                } else {
                                    assert(object_getInstanceVariable(context, "_connection", (void **)&connection) != NULL);
                                }
                            }
                            
                            arrayOfPrimaryKeysAndEntityIDs = [OCSPIResolver NSSQLiteConnection_createArrayOfPrimaryKeysAndEntityIDsForRowsWithoutRecordMetadataWithEntity_metadataEntity_:connection x1:entity x2:recordMetadataEntity];
                        }
                                                                                                           context:managedObjectContext
                                                                                                           sqlCore:store];
                        
                        [OCSPIResolver NSSQLCore_dispatchRequest_withRetries_:store x1:requestCpntext x2:0];
                        
                        // x23 / x28
                        NSMutableArray<NSManagedObjectID *> *objectIDs = [[NSMutableArray alloc] init];
                        
                        // x20
                        NSUInteger count = 0;
                        // x24
                        for (NSArray<NSNumber *> *primaryKeyAndEntityID in arrayOfPrimaryKeysAndEntityIDs) @autoreleasepool {
                            count += 1;
                            
                            if (primaryKeyAndEntityID.count != 2) {
                                [model release];
                                model = nil;
                                [objectIDs release];
                                @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                                               reason:[NSString stringWithFormat:@"Unexpected number of items in the pk / ent array: %@", primaryKeyAndEntityID]
                                                             userInfo:nil];
                            }
                            
                            NSSQLEntity * _Nullable sqlEntity = [OCSPIResolver _sqlCoreLookupSQLEntityForEntityID:store x1:primaryKeyAndEntityID[1].unsignedLongValue];
                            
                            // x21
                            NSManagedObjectID *objectID = [store newObjectIDForEntity:sqlEntity pk:primaryKeyAndEntityID[0].integerValue];
                            [objectIDs addObject:objectID];
                            [objectID release];
                            
                            if ((count % 100) == 0) {
                                BOOL result = [self insertRecordMetadataForObjectIDsInBatch:objectIDs inManagedObjectContext:managedObjectContext withPendingTransactionNumber:tokenNumber error:&_error];
#warning TODO : Error나면 break가 없는듯?
                                if (result) {
                                    result = [managedObjectContext save:&_error];
                                    if (!result) {
                                        _succeed = NO;
                                        [_error retain];
                                    }
                                    
                                    [objectIDs release];
                                    objectIDs = [[NSMutableArray alloc] init];
                                } else {
                                    _succeed = NO;
                                    [_error retain];
                                }
                                
                                [managedObjectContext reset];
                            }
                        }
                        
                        if (objectIDs.count != 0) {
                            BOOL result = [self insertRecordMetadataForObjectIDsInBatch:objectIDs inManagedObjectContext:managedObjectContext withPendingTransactionNumber:tokenNumber error:&_error];
                            if (result) {
                                _succeed = NO;
                                [_error retain];
                            }
                        }
                        
                        if (_succeed && managedObjectContext.hasChanges) {
                            BOOL result = [managedObjectContext save:&_error];
                            
                            if (!result) {
                                _succeed = NO;
                                [_error retain];
                            }
                            
                            [managedObjectContext reset];
                        }
                        
                        [objectIDs release];
                        objectIDs = nil;
                        [requestCpntext release];
                        
                        [arrayOfPrimaryKeysAndEntityIDs release];
                    }
                    
                    // original : NSCloudKitMirroringDelegateScanForRowsMissingFromHistoryKey
                    OCCKMetadataEntry * _Nullable entry_2 = [OCCKMetadataEntry entryForKey:@"NSCloudKitMirroringDelegateScanForRowsMissingFromHistoryKey" fromStore:store inManagedObjectContext:managedObjectContext error:&_error];
                    if (entry_2 != nil) {
                        [managedObjectContext deleteObject:entry_2];
                    } else {
                        [_error retain];
                        _succeed = NO;
                    }
                    
                    if (_succeed) {
                        BOOL result = [managedObjectContext save:&_error];
                        if (!result) {
                            _succeed = NO;
                            [_error retain];
                        }
                    }
                    
                    [zoneID release];
                    [model release];
                    
                    if (_succeed) {
                        final();
                    }
                }
            }];
        }
    }];
    
    if (!_succeed) {
        if (_error == nil) {
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d", __func__, __LINE__);
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d", __func__, __LINE__);
        } else {
            if (error) *error = [[_error retain] autorelease];
        }
    }
    
    [_error release];
    return _succeed;
}

- (BOOL)checkForObjectsNeedingExportInStore:(__kindof NSPersistentStore *)store andReturnCount:(NSUInteger *)count withManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable *)error {
    /*
     x23 = store
     x20 = count
     x21 = managedObjectContext
     x19 = error
     */
    
    NSError * _Nullable _error = nil;
    
    NSNumber * _Nullable recordMetadataCountNumber = [OCCKRecordMetadata countRecordMetadataInStore:store
                                                                            matchingPredicate:[NSPredicate predicateWithFormat:@"needsUpload = YES"]
                                                                     withManagedObjectContext:managedObjectContext
                                                                                        error:&_error];
    if (recordMetadataCountNumber == nil) {
        if (error == nil) {
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d", __func__, __LINE__);
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d", __func__, __LINE__);
        } else {
            if (error) *error = _error;
        }
        
        return NO;
    }
    
    // x22
    NSUInteger recordMetadataCount = recordMetadataCountNumber.unsignedIntegerValue;
    
    NSNumber * _Nullable mirroredRelationshipsCountNumber = [OCCKMirroredRelationship countMirroredRelationshipsInStore:store
                                                                                                 matchingPredicate:[NSPredicate predicateWithFormat:@"isUploaded = NO"]
                                                                                          withManagedObjectContext:managedObjectContext
                                                                                                             error:&_error];
    if (mirroredRelationshipsCountNumber == nil) {
        if (_error == nil) {
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d", __func__, __LINE__);
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d", __func__, __LINE__);
        } else {
            if (error) *error = _error;
        }
        
        return NO;
    }
    
    // x24
    NSUInteger mirroredRelationshipsCount = mirroredRelationshipsCountNumber.unsignedIntegerValue;
    
    // x25
    NSInteger recordZoneMetadataCount;
    {
        NSFetchRequest<OCCKRecordZoneMetadata *> *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[OCCKRecordZoneMetadata entityPath]];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"needsShareUpdate = YES OR needsShareDelete = YES"];
        fetchRequest.resultType = NSCountResultType;
        fetchRequest.affectedStores = @[store];
        
        if (managedObjectContext == nil) {
            recordZoneMetadataCount = 0;
        } else {
            recordZoneMetadataCount = [OCSPIResolver NSManagedObjectContext__countForFetchRequest__error_:managedObjectContext x1:fetchRequest x2:&_error];
            
            if (recordZoneMetadataCount == NSNotFound) {
                if (_error == nil) {
                    os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d", __func__, __LINE__);
                    os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d", __func__, __LINE__);
                } else {
                    if (error) *error = _error;
                }
                
                return NO;
            }
        }
    }
    
    NSInteger recordZoneMoveReceiptsCount;
    {
        NSFetchRequest<OCCKRecordZoneMoveReceipt *> *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[OCCKRecordZoneMoveReceipt entityPath]];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"needsCloudDelete = YES"];
        fetchRequest.resultType = NSCountResultType;
        fetchRequest.affectedStores = @[store];
        
        if (managedObjectContext == nil) {
            recordZoneMoveReceiptsCount = 0;
        } else {
            recordZoneMoveReceiptsCount = [OCSPIResolver NSManagedObjectContext__countForFetchRequest__error_:managedObjectContext x1:fetchRequest x2:&_error];
            
            if (recordZoneMoveReceiptsCount == NSNotFound) {
                if (_error == nil) {
                    os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d", __func__, __LINE__);
                    os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d", __func__, __LINE__);
                } else {
                    if (error) *error = _error;
                }
                
                return NO;
            }
        }
    }
    
    *count = (recordMetadataCount + mirroredRelationshipsCount + recordZoneMetadataCount + recordZoneMoveReceiptsCount);
    return YES;
}

- (BOOL)insertRecordMetadataForObjectIDsInBatch:(NSArray<NSManagedObjectID *> *)objectIDs inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext withPendingTransactionNumber:(NSNumber *)transactionNumner error:(NSError * _Nullable *)error {
    /*
     self = x21
     objectIDs = x23
     managedObjectContext = x22
     error = x19
     */
    
    // sp + 0x68
    NSError * _Nullable contextError = nil;
    
    NSEntityDescription * _Nullable entity = objectIDs.lastObject.entity;
    
    NSEntityDescription * _Nullable rootEntity;
    if (entity == nil) {
        rootEntity = nil;
    } else {
        BOOL _isImmutable;
        assert(object_getInstanceVariable(entity, "_isImmutable", (void **)&_isImmutable) != NULL);
        
        if (_isImmutable) {
            assert(object_getInstanceVariable(entity, "_rootentity", (void **)&rootEntity) != NULL);
        } else {
            rootEntity = entity;
            NSEntityDescription * _Nullable superEntity = rootEntity.superentity;
            while (superEntity != nil) {
                rootEntity = superEntity;
                superEntity = rootEntity.superentity;
            }
        }
    }
    
    // x24
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:rootEntity.name];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"SELF in %@", objectIDs];
    
    // x24
    NSArray<NSManagedObject *> * _Nullable fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&contextError];
    
    if (fetchedObjects == nil) {
        if (contextError == nil) {
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        } else {
            if (error) *error = contextError;
        }
        
        return NO;
    }
    
    BOOL hasError = NO;
    // x27
    for (NSManagedObject *object in fetchedObjects) @autoreleasepool {
        CKDatabaseScope databaseScope;
        {
            OCCloudKitExporterOptions * _Nullable options = self->_options;
            if (options == nil) {
                databaseScope = 0;
            } else {
                databaseScope = options->_database.databaseScope;
            }
        }
        
        // x26
        CKRecordZoneID *zoneID = [OCCloudKitSerializer defaultRecordZoneIDForDatabaseScope:databaseScope];
        
        BOOL preserveLegacyRecordMetadataBehavior;
        {
            OCCloudKitExporterOptions * _Nullable options = self->_options;
            if (options == nil) {
                preserveLegacyRecordMetadataBehavior = NO;
            } else {
                preserveLegacyRecordMetadataBehavior = options->_options.preserveLegacyRecordMetadataBehavior;
            }
        }
        
        // x27
        OCCKRecordMetadata * _Nullable metadata = [OCCKRecordMetadata insertMetadataForObject:object setRecordName:preserveLegacyRecordMetadataBehavior inZoneWithID:zoneID recordNamePrefix:nil error:&contextError];
        if (metadata == nil) {
            hasError = YES;
            [contextError retain];
            [zoneID release];
            break;
        }
        
        metadata.needsUpload = YES;
        metadata.pendingExportTransactionNumber = transactionNumner;
        metadata.pendingExportChangeTypeNumber = @0;
        [zoneID release];
    }
    
    if (hasError) {
        if (contextError == nil) {
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        } else {
            if (error) *error = [contextError autorelease];
        }
        
        return NO;
    }
    
    return YES;
}

- (CKModifyRecordsOperation *)newOperationBySerializingDirtyObjectsInStore:(NSSQLCore *)store inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable *)error {
    /*
     self = x20
     store = x24
     managedObjectContext = x23
     error = x19
     */
    
    // sp, #0x90 / [[sp, #0x98], #0x28]
    __block NSError * _Nullable _error = nil;
    // x29 - #0x80, [[x29, #-0x78], #0x18]
    __block BOOL _succeed = YES;
    // sp, #0x60 / [[sp, #0x60], #0x28]
    __block OCCloudKitSerializer * _Nullable serializer = nil;
    
    // x22
    OCCloudKitOperationBatch *operationBatch = [[OCCloudKitOperationBatch alloc] init];
    
    // x21
    NSMutableSet<NSManagedObjectID *> *deletedObjectIDsSet = [[NSMutableSet alloc] init];
    
    /*
     store = sp + 0x20 = x21 + 0x20
     self = sp + 0x28 = x21 + 0x28
     managedObjectContext = sp + 0x30 = x21 + 0x30
     operationBatch = sp + 0x38 = x21 + 0x38
     deletedObjectIDsSet = sp + 0x40 = x21 + 0x40
     _error = sp + 0x48 = x21 + 0x48
     _succeed = sp + 0x50 = x21 + 0x50
     serializer = sp + 0x58 = x21 + 0x58
     */
    [managedObjectContext performBlockAndWait:^{
        // x21 = block
        
        // x19
        NSMutableArray<NSManagedObjectID *> *objectIDs = [[NSMutableArray alloc] init];
        
        // x20
        NSFetchRequest<OCCKRecordMetadata *> *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[OCCKRecordMetadata entityPath]];
        fetchRequest.returnsObjectsAsFaults = NO;
        fetchRequest.affectedStores = @[store];
        
        NSUInteger fetchLimit;
        {
            OCCloudKitExporterOptions * _Nullable options = self->_options;
            if (options == nil) {
                fetchLimit = 0;
            } else {
                fetchLimit = options->_perOperationObjectThreshold;
            }
        }
        fetchRequest.fetchLimit = fetchLimit;
        
        fetchRequest.propertiesToFetch = @[@"entityId", @"entityPK"];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"needsUpload = YES"];
        
        // sp, #0x78
        OCCloudKitMetadataCache *cache = nil;
        
        // x22
        NSArray<OCCKRecordMetadata *> * _Nullable fetchedRecordMetadataArray = [managedObjectContext executeFetchRequest:fetchRequest error:&_error];
        
        if (fetchedRecordMetadataArray == nil) {
            _succeed = NO;
            cache = nil;
            [_error retain];
            
            [objectIDs release];
            [cache release];
            
            return;
        }
        
        // x24
        for (OCCKRecordMetadata *recordMetadata in fetchedRecordMetadataArray) @autoreleasepool {
            // x24
            NSManagedObjectID *objectID = [recordMetadata createObjectIDForLinkedRow];
            [objectIDs addObject:objectID];
            [objectID release];
        }
        
        cache = [[OCCloudKitMetadataCache alloc] init];
        
        OCCloudKitMirroringDelegateOptions * _Nullable options;
        {
            OCCloudKitExporterOptions * _Nullable _options = self->_options;
            if (_options == nil) {
                options = nil;
            } else {
                options = _options->_options;
            }
        }
        
        BOOL result = [cache cacheMetadataForObjectsWithIDs:objectIDs andRecordsWithIDs:@[] inStore:store withManagedObjectContext:managedObjectContext mirroringOptions:options error:&_error];
        if (!result) {
            _succeed = NO;
            [_error retain];
            
            [objectIDs release];
            [cache release];
            
            return;
        }
        
        serializer = [[OCCloudKitSerializer alloc] initWithMirroringOptions:options metadataCache:cache recordNamePrefix:nil];
        
        // x26
        for (OCCKRecordMetadata *recordMetadata in fetchedRecordMetadataArray) @autoreleasepool {
            // sp, #0x50
            NSManagedObjectID *objectID = [recordMetadata createObjectIDForLinkedRow];
            // sp, #0x60
            CKRecordType recordType = [OCCloudKitSerializer recordTypeForEntity:objectID.entity];
            // sp, #0x80
            CKRecordID *recordID = [recordMetadata createRecordID];
            
            CKRecordZoneID *zoneID = recordID.zoneID;
            
            BOOL shouldFinish;
            if (zoneID == nil) {
                os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData+CloudKit: %s(%d): %@: Ignoring dirty metadata for record in immutable zone: %@", __func__, __LINE__, self, recordID);
                recordMetadata.needsUpload = NO;
                recordMetadata.needsCloudDelete = NO;
                shouldFinish = YES;
            } else if (![cache->_mutableZoneIDs containsObject:zoneID]) {
                os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData+CloudKit: %s(%d): %@: Ignoring dirty metadata for record in immutable zone: %@", __func__, __LINE__, self, recordID);
                recordMetadata.needsUpload = NO;
                recordMetadata.needsCloudDelete = NO;
                shouldFinish = YES;
            } else {
                if (recordMetadata.needsCloudDelete) {
                    [operationBatch addDeletedRecordID:recordID forRecordOfType:recordType];
                    shouldFinish = YES;
                } else {
                    shouldFinish = NO;
                }
            }
            
            // 5 = break, 0 = continue
            int (^finalize)(void) = ^int {
                /* <+1076> */
                [recordID release];
                [objectID release];
                
                if (managedObjectContext.hasChanges) {
                    // x20
                    NSUInteger insertedCount = managedObjectContext.insertedObjects.count;
                    // x23
                    NSUInteger updatedCount = managedObjectContext.updatedObjects.count;
                    NSUInteger deletedCount = managedObjectContext.deletedObjects.count;
                    
                    if (((insertedCount & updatedCount) + deletedCount) >= 0xc9) {
                        BOOL result = [managedObjectContext save:&_error];
                        if (!result) {
                            _succeed = NO;
                            [_error retain];
                        }
                    }
                }
                
                if (_succeed) {
                    if ([self currentBatchExceedsThresholds:operationBatch]) {
                        return 5;
                    } else {
                        return 0;
                    }
                } else {
                    return 5;
                }
            };
            
            if (shouldFinish) {
                if (finalize() != 0) {
                    break;
                } else {
                    continue;
                }
            }
            
            // x24
            NSManagedObject * _Nullable object = [managedObjectContext existingObjectWithID:objectID error:&_error];
            
            if (object == nil) {
                if (_error == nil) {
                    if (finalize() != 0) {
                        break;
                    } else {
                        continue;
                    }
                }
                
                if ([_error.domain isEqualToString:NSCocoaErrorDomain] && (_error.code == NSManagedObjectReferentialIntegrityError)) {
                    recordMetadata.needsCloudDelete = YES;
                    [operationBatch addDeletedRecordID:recordID forRecordOfType:recordType];
                    
                    if (finalize() != 0) {
                        break;
                    } else {
                        continue;
                    }
                }
            }
            
            // x20
            if (![object.objectID.persistentStore.identifier isEqualToString:store.identifier]) {
                if (finalize() != 0) {
                    break;
                } else {
                    continue;
                }
            }
            
            // sp + 0x18
            NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
            
            // sp + 0x30
            NSArray<CKRecord *> * _Nullable records;
            if (serializer == nil) {
                records = nil;
            } else {
                records = [serializer newCKRecordsFromObject:object fullyMaterializeRecords:NO includeRelationships:YES error:&_error];
            }
            
            [managedObjectContext refreshObject:object mergeChanges:managedObjectContext.hasChanges];
            
            if (records == nil) {
                _succeed = NO;
                [_error retain];
            } else {
                // x20
                for (CKRecord *record in records) {
                    NSMutableSet<CKRecordID *> * _Nullable deletedRecordIDs;
                    if (operationBatch == nil) {
                        deletedRecordIDs = nil;
                    } else {
                        deletedRecordIDs = operationBatch->_deletedRecordIDs;
                    }
                    
                    if ([deletedRecordIDs containsObject:record.recordID]) {
                        [operationBatch addDeletedRecordID:record.recordID forRecordOfType:recordType];
                    } else {
                        [operationBatch addRecord:record];
                    }
                    
                    BOOL result = [self currentBatchExceedsThresholds:operationBatch];
                    
                    if (result) {
                        break;
                    }
                }
            }
            
            // x20
            for (OCCKRecordZoneMoveReceipt *moveReceipt in recordMetadata.moveReceipts) {
                if (!moveReceipt.needsCloudDelete) continue;
                
                BOOL result = [self currentBatchExceedsThresholds:operationBatch];
                if (result) break;
                
                // x27
                CKRecordID *recordID = [moveReceipt createRecordIDForMovedRecord];
                
                [operationBatch addDeletedRecordID:recordID forRecordOfType:recordType];
                [deletedObjectIDsSet addObject:moveReceipt.objectID];
                
                [recordID release];
            }
            
            [pool release];
            [records release];
            
            if (finalize() != 0) {
                break;
            } else {
                continue;
            }
        }
        
        /* <+2316> */
        
        if (!_succeed) {
            [objectIDs release];
            [cache release];
            return;
        }
        
        void (^batch_3236)(void) = ^{
            /* <+3236> */
            if (_succeed && ![self currentBatchExceedsThresholds:operationBatch]) {
                NSFetchRequest<OCCKRecordZoneMetadata *> *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[OCCKRecordZoneMetadata entityPath]];
                fetchRequest.predicate = [NSPredicate predicateWithFormat:@"needsShareUpdate = YES OR needsShareDelete = YES"];
                fetchRequest.propertiesToFetch = @[@"encodedShareData"];
                
                // x20
                NSArray<OCCKRecordZoneMetadata *> * _Nullable fetchedMetadataArray = [managedObjectContext executeFetchRequest:fetchRequest error:&_error];
                
                if (fetchedMetadataArray != nil) {
                    // x26
                    for (OCCKRecordZoneMetadata *metadata in fetchedMetadataArray) {
                        // x28
                        CKRecordZoneID *zoneID = [metadata createRecordZoneID];
                        
                        if (metadata.encodedShareData == nil) {
                            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Zone metadata is missing it's encoded share data but is marked for a mutation: %@ - %@\n", zoneID, metadata);
                            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Zone metadata is missing it's encoded share data but is marked for a mutation: %@ - %@\n", zoneID, metadata);
                        }
                        
                        // x27
                        OCCloudKitArchivingUtilities * _Nullable _archivingUtilities;
                        if (self->_options == nil) {
                            _archivingUtilities = nil;
                        } else if (self->_options->_options == nil) {
                            _archivingUtilities = nil;
                        } else {
                            _archivingUtilities = self->_options->_options->_archivingUtilities;
                        }
                        
                        // x27
                        CKShare * _Nullable share = [_archivingUtilities shareFromEncodedData:metadata.encodedShareData inZoneWithID:zoneID error:&_error];
                        
                        if (share == nil) {
                            _succeed = NO;
                            [_error retain];
                            [zoneID release];
                            break;
                        } else {
                            if (metadata.needsShareUpdate) {
                                [operationBatch addRecord:share];
                                
                                if ([self currentBatchExceedsThresholds:operationBatch]) {
                                    [zoneID release];
                                    [share release];
                                    break;
                                } else {
                                    [zoneID release];
                                    [share release];
                                    continue;
                                }
                            } else {
                                if (metadata.needsShareDelete) {
                                    // x24
                                    CKRecordID *recordID = share.recordID;
                                    [operationBatch addDeletedRecordID:recordID forRecordOfType:share.recordType];
                                    
                                    if ([self currentBatchExceedsThresholds:operationBatch]) {
                                        [zoneID release];
                                        [share release];
                                        break;
                                    } else {
                                        [zoneID release];
                                        [share release];
                                        continue;
                                    }
                                } else {
                                    os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Fetched dirty zone that didn't need a share update or delete: %@\n", metadata);
                                    os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Fetched dirty zone that didn't need a share update or delete: %@\n", metadata);
                                    [zoneID release];
                                    [share release];
                                    continue;
                                }
                            }
                        }
                    }
                } else {
                    _succeed = NO;
                    [_error retain];
                }
            }
            
            /* <+4188> */
            if (_succeed && ![self currentBatchExceedsThresholds:operationBatch]) {
                NSFetchRequest<OCCKRecordZoneMoveReceipt *> *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[OCCKRecordZoneMoveReceipt entityPath]];
                fetchRequest.affectedStores = @[store];
                
                OCCloudKitExporterOptions * _Nullable _options = self->_options;
                NSUInteger fetchLimit;
                if (_options == nil) {
                    fetchLimit = 0; 
                } else {
                    fetchLimit = _options->_perOperationObjectThreshold;
                }
                fetchRequest.fetchLimit = fetchLimit;
                
                fetchRequest.relationshipKeyPathsForPrefetching = @[@"recordMetadata"];
                fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(needsCloudDelete == 1) AND !(SELF IN %@)"];
                fetchRequest.returnsObjectsAsFaults = NO;
                
                // sp, #0x80
                NSArray<OCCKRecordZoneMoveReceipt *> * _Nullable fetchedMoveReceipts = [managedObjectContext executeFetchRequest:fetchRequest error:&_error];
                
                if (fetchedMoveReceipts != nil) {
                    // x26
                    for (OCCKRecordZoneMoveReceipt *moveReceipt in fetchedMoveReceipts) @autoreleasepool {
                        if ([self currentBatchExceedsThresholds:operationBatch]) {
                            continue;
                        }
                        
                        // x25
                        CKRecordID *recordIDForMovedRecord = [moveReceipt createRecordIDForMovedRecord];
                        // x26
                        NSManagedObjectID *objectIDForLinkedRow = [moveReceipt.recordMetadata createObjectIDForLinkedRow];
                        
                        CKRecordType recordType = [OCCloudKitSerializer recordTypeForEntity:moveReceipt.entity];
                        [operationBatch addDeletedRecordID:recordIDForMovedRecord forRecordOfType:recordType];
                        
                        [recordIDForMovedRecord release];
                        [objectIDForLinkedRow release]; // x26으로 아무것도 안함
                    }
                } else {
                    _succeed = NO;
                    [_error retain];
                }
            }
            
            /* <+4696> */
            if (_succeed && managedObjectContext.hasChanges) {
                BOOL result = [managedObjectContext save:&_error];
                _succeed = result;
                if (_error != nil) [_error retain];
            }
        };
        
        
        void (^batch_4884)(void) = ^{
            /* <+4884> */
            
            NSMutableSet<CKRecordID *> * _Nullable deletedRecordIDs;
            if (operationBatch != nil) {
                deletedRecordIDs = operationBatch->_deletedRecordIDs;
            } else {
                deletedRecordIDs = nil;
            }
            
            // x20
            NSSet<CKRecordID *> * _Nullable markedRecordIDs = [OCCKMirroredRelationship markRelationshipsForDeletedRecordIDs:deletedRecordIDs.allObjects inStore:store withManagedObjectContext:managedObjectContext error:&_error];
            
            if (markedRecordIDs == nil) {
                _succeed = NO;
                [_error retain];
            } else {
                // x24
                for (CKRecordID *recordID in markedRecordIDs) {
                    if ([self currentBatchExceedsThresholds:operationBatch]) {
                        [objectIDs release];
                        [cache release];
                        return;
                    }
                    
                    NSMutableSet<CKRecordID *> * _Nullable deletedRecordIDs;
                    if (operationBatch != nil) {
                        deletedRecordIDs = operationBatch->_deletedRecordIDs;
                    } else {
                        deletedRecordIDs = nil;
                    }
                    
                    if (![deletedRecordIDs containsObject:recordID]) {
                        [operationBatch addDeletedRecordID:recordID forRecordOfType:@"CDMR"];
                    }
                }
            }
            
            batch_3236();
        };
        
        if ([self currentBatchExceedsThresholds:operationBatch]) {
            batch_4884();
            
            /* <+4780> */
            [objectIDs release];
            [cache release];
            return;
        }
        
        // sp, #0x80
        NSArray<OCCKMirroredRelationship *> * _Nullable mirroredRelationships = [OCCKMirroredRelationship fetchMirroredRelationshipsMatchingPredicate:[NSPredicate predicateWithFormat:@"isUploaded = NO"] fromStore:store inManagedObjectContext:managedObjectContext error:&_error];
        
        if (mirroredRelationships == nil) {
            /* <+4856> */
            _succeed = NO;
            [_error retain];
            
#warning error Leak
            batch_4884();
            
            /* <+4780> */
            [objectIDs release];
            [cache release];
            
            return;
        }
        
        // sp, #0x58
        NSManagedObjectModel *managedObjectModel = managedObjectContext.persistentStoreCoordinator.managedObjectModel;
        
        // x28
        for (OCCKMirroredRelationship *mirroredRelationship in mirroredRelationships) {
            if ([self currentBatchExceedsThresholds:operationBatch]) {
                batch_4884();
                return;
            }
            
            // x20
            CKRecordID *recordID = [mirroredRelationship createRecordID];
            
            if (cache != nil) {
                if ([cache->_mutableZoneIDs containsObject:recordID.zoneID]) {
                    BOOL flag;
                    
                    if (operationBatch != nil) {
                        if ([operationBatch->_recordIDs containsObject:recordID]) {
                            flag = NO;
                        } else {
                            if ([operationBatch->_deletedRecordIDs containsObject:recordID]) {
                                flag = NO;
                            } else {
                                flag = YES;
                            }
                        }
                    } else {
                        flag = NO;
                    }
                    
                    if (flag) {
#warning needsDelete는 NSNumber임
                        if (mirroredRelationship.needsDelete) {
                            [operationBatch addDeletedRecordID:recordID forRecordOfType:@"CDMR"];
                            [recordID release];
                            continue;
                        } else {
                            // go to <+2876>
                        }
                    } else {
                        [recordID release];
                        continue;
                    }
                } else {
                    os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData+CloudKit: %s(%d): %@: Ignoring update to dirty mirrored relationship because the zone is not mutable: %@", __func__, __LINE__, self, recordID);
                    [recordID release];
                    continue;
                }
            } else {
                os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData+CloudKit: %s(%d): %@: Ignoring update to dirty mirrored relationship because the zone is not mutable: %@", __func__, __LINE__, self, recordID);
                [recordID release];
                continue;
            }
            
            /* <+2876> */
            
            // x23
            CKRecordID *recordIDForRecord = [mirroredRelationship createRecordIDForRecord];
            // x25
            CKRecordID *recordIDForRelatedRecord = [mirroredRelationship createRecordIDForRelatedRecord];
            // x26
            NSDictionary<NSString *, NSEntityDescription *> *entitiesByName = managedObjectModel.entitiesByName;
            // x26
            NSDictionary<NSString *, NSRelationshipDescription *> *relationshipsByName = entitiesByName[mirroredRelationship.cdEntityName].relationshipsByName;
            // x26
            NSRelationshipDescription *relationship = relationshipsByName[mirroredRelationship.relationshipName];
            
            // x28
            PFMirroredManyToManyRelationshipV2 *mirroredManyToManyRelationship = [[objc_lookUpClass("PFMirroredManyToManyRelationshipV2") alloc] initWithRecordID:recordID forRecordWithID:recordIDForRecord relatedToRecordWithID:recordIDForRelatedRecord byRelationship:relationship withInverse:relationship.inverseRelationship andType:0];
            
            // original : getCloudKitCKRecordClass
            // x26
            CKRecord *record = [[CKRecord alloc] initWithRecordType:@"CDMR" recordID:recordID];
            
            BOOL useDeviceToDeviceEncryption;
            if (self == nil) {
                useDeviceToDeviceEncryption = NO;
            } else {
                useDeviceToDeviceEncryption = self->_options->_options.useDeviceToDeviceEncryption;
            }
            
            [mirroredManyToManyRelationship populateRecordValues:(useDeviceToDeviceEncryption ? record.encryptedValueStore : record)];
            [operationBatch addRecord:record];
            
            [record release];
            [mirroredManyToManyRelationship release];
            [recordIDForRecord release];
            [recordIDForRelatedRecord release];
            
            [recordID release];
        }
        
        batch_3236();
        [objectIDs release];
        [cache release];
    }];
    
    {
        // x23
        NSMutableArray *writtenAssetURLs_1 = self->_writtenAssetURLs;
        NSMutableArray * _Nullable writtenAssetURLs_2;
        if (serializer == nil) {
            writtenAssetURLs_2 = nil;
        } else {
            writtenAssetURLs_2 = serializer->_writtenAssetURLs;
        }
        [writtenAssetURLs_1 addObjectsFromArray:[[writtenAssetURLs_2 copy] autorelease]];
    }
    
    // x23
    CKModifyRecordsOperation * _Nullable result = nil;
    if (_succeed && (serializer != nil)) {
        if (operationBatch->_records.count != operationBatch->_deletedRecordIDs.count) {
            // original : getCloudKitCKModifyRecordsOperationClass
            result = [[CKModifyRecordsOperation alloc] initWithRecordsToSave:operationBatch->_records recordIDsToDelete:operationBatch->_deletedRecordIDs.allObjects];
            
            self->_totalBytes += operationBatch->_sizeInBytes;
            self->_totalRecords += operationBatch->_records.count;
            self->_totalRecordIDs += operationBatch->_deletedRecordIDs.count;
        } else {
            result = nil;
        }
    }
    
    [operationBatch release];
    [serializer release];
    serializer = nil;
    [deletedObjectIDsSet release];
    
    if (_succeed) {
        [_error release];
    } else {
        if (_error == nil) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        } else {
            if (error) *error = [_error autorelease];
        }
        
        [result release];
        result = nil;
    }
    
    return result;
}

- (BOOL)currentBatchExceedsThresholds:(OCCloudKitOperationBatch *)batch {
    // x9
    NSUInteger count;
    if (batch == nil) {
        count = 0;
    } else {
        count = batch->_records.count + batch->_deletedRecordIDs.count;
    }
    
    OCCloudKitExporterOptions * _Nullable options = self->_options;
    
    // x10
    NSUInteger perOperationObjectThreshold;
    if (options == nil) {
        perOperationObjectThreshold = 0;
    } else {
        perOperationObjectThreshold = options->_perOperationObjectThreshold;
    }
    
    if (count == perOperationObjectThreshold) {
        return YES;
    }
    
    // x9
    size_t sizeInBytes;
    if (batch == nil) {
        sizeInBytes = 0;
    } else {
        sizeInBytes = batch->_sizeInBytes;
    }
    
    // x8
    NSUInteger perOperationBytesThreshold;
    if (options == nil) {
        perOperationBytesThreshold = 0;
    } else {
        perOperationBytesThreshold = options->_perOperationBytesThreshold;
    }
    
    return perOperationBytesThreshold <= sizeInBytes;
}

- (BOOL)modifyRecordsOperationFinishedForStore:(NSSQLCore *)store withSavedRecords:(NSArray<CKRecord *> *)savedRecords deletedRecordIDs:(NSArray<CKRecordID *> *)deletedRecordIDs operationError:(NSError *)operationError managedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable *)error {
    // x19 = error
    
    // x29 - #0x50 / [x29, #-0x48]
    __block BOOL _succeed = YES;
    
    // x29 - #0x38
    __block NSError * _Nullable _error = nil;
    
    
    /*
     savedRecords = sp + 0x28 = x24 + 0x20
     store = sp + 0x30 = x24 + 0x28
     managedObjectContext = sp + 0x38 = x24 + 0x30
     self = sp + 0x40 = x24 + 0x38
     deletedRecordIDs = sp + 0x48 = x24 + 0x40
     _succeed = sp + 0x50 = x24 + 0x48
     _error = sp + 0x58 = x24 + 0x50
     */
    [managedObjectContext performBlockAndWait:^{
        if (!_succeed) {
            return;
        }
        
        // self = x24
        
        // x20 / sp + 0x50
        NSMutableDictionary<CKRecordID *, CKRecord *> *otherRecordIDToRecord = [[NSMutableDictionary alloc] initWithCapacity:savedRecords.count];
        // sp + 0x58
        NSMutableArray<CKRecord *> *mirroredRelationshipRecords = [[NSMutableArray alloc] init];
        // sp + 0x48
        NSMutableArray<CKRecord *> *shareRecords = [[NSMutableArray alloc] init];
        // sp + 0x38
        NSMutableArray<CKRecordID *> *wideShareRecordIDs = [[NSMutableArray alloc] init];
        
        // x25
        for (CKRecord *record in savedRecords) {
            if ([OCCloudKitSerializer isMirroredRelationshipRecordType:record.recordType]) {
                [mirroredRelationshipRecords addObject:record];
            } else {
                // original : getCloudKitCKRecordTypeShare
                if ([record.recordType isEqualToString:CKRecordTypeShare]) {
                    [shareRecords addObject:record];
                } else {
                    otherRecordIDToRecord[record.recordID] = record;
                }
            }
        }
        
        // sp + 0x40
        NSDictionary<CKRecordID *, OCCKRecordMetadata *> * _Nullable mapOfMetadata = [OCCKRecordMetadata createMapOfMetadataMatchingRecords:savedRecords andRecordIDs:@[] inStore:store withManagedObjectContext:managedObjectContext error:&_error];
        
        if (mapOfMetadata == nil) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData+CloudKit: %s(%d): Failed to fetch record metadata for saved records: %@\n%@", __func__, __LINE__, _error, savedRecords);
            _succeed = NO;
            [_error retain];
        } else {
            // x28
            for (CKRecordID *recordID in otherRecordIDToRecord.allKeys) {
                // x23
                CKRecord *record = otherRecordIDToRecord[recordID];
                OCCKRecordMetadata *recordMedatata = mapOfMetadata[recordID];
                
                if (record == nil) {
                    os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData+CloudKit: %s(%d): %@: Can't find record for recordID '%@' even though it was supposedly saved in these records: %@", __func__, __LINE__, self, recordID, savedRecords);
                    continue;
                }
                
                // recordMedatata = x20
                
                if (recordMedatata == nil) {
                    os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData+CloudKit: %s(%d): %@: Can't find metadata for recordID '%@' even though it was supposedly saved in these records: %@", __func__, __LINE__, self, recordID, savedRecords);
                    continue;
                }
                
                recordMedatata.needsUpload = NO;
                
                OCCloudKitArchivingUtilities * _Nullable archivingUtilities;
                {
                    OCCloudKitExporterOptions * _Nullable options = self->_options;
                    if (options == nil) {
                        archivingUtilities = nil;
                    } else {
                        OCCloudKitMirroringDelegateOptions * _Nullable delegateOptions = options->_options;
                        if (delegateOptions == nil) {
                            archivingUtilities = nil;
                        } else {
                            archivingUtilities = delegateOptions->_archivingUtilities;
                        }
                    }
                }
                
                // x23
                NSData * _Nullable encodedRecord = [archivingUtilities encodeRecord:record error:&_error];
                
                if (encodedRecord == nil) {
                    _succeed = NO;
                    [_error retain];
                    continue;
                }
                
                recordMedatata.encodedRecord = encodedRecord;
                [encodedRecord release];
            }
        }
        
        if (!_succeed) {
            [mirroredRelationshipRecords release];
            [mapOfMetadata release];
            [otherRecordIDToRecord release];
            [shareRecords release];
            [wideShareRecordIDs release];
            return;
        }
        
        // x25
        for (CKRecord *record in shareRecords) {
            // x26
            CKRecordZoneID *zoneID = record.recordID.zoneID;
            
            CKDatabaseScope databaseScope;
            {
                OCCloudKitExporterOptions * _Nullable options = self->_options;
                if (options == nil) {
                    databaseScope = 0;
                } else {
                    databaseScope = options->_database.databaseScope;
                }
            }
            
            // x23
            OCCKRecordZoneMetadata * _Nullable recordZoneMetadata = [OCCKRecordZoneMetadata zoneMetadataForZoneID:zoneID inDatabaseWithScope:databaseScope forStore:store inContext:managedObjectContext error:&_error];
            
            if (recordZoneMetadata == nil) {
                _succeed = NO;
                [_error retain];
            } else {
                OCCloudKitArchivingUtilities * _Nullable archivingUtilities;
                {
                    OCCloudKitExporterOptions * _Nullable options = self->_options;
                    if (options == nil) {
                        archivingUtilities = nil;
                    } else {
                        OCCloudKitMirroringDelegateOptions * _Nullable delegateOptions = options->_options;
                        if (delegateOptions == nil) {
                            archivingUtilities = nil;
                        } else {
                            archivingUtilities = delegateOptions->_archivingUtilities;
                        }
                    }
                }
                
                // x25
                NSData * _Nullable encodedRecord = [archivingUtilities encodeRecord:record error:&_error];
                if (encodedRecord == nil) {
                    _succeed = NO;
                    [_error retain];
                } else {
                    recordZoneMetadata.encodedShareData = encodedRecord;
                    recordZoneMetadata.needsShareUpdate = YES;
                }
                
                [encodedRecord release];
            }
        }
        
        if (!_succeed) {
            [mirroredRelationshipRecords release];
            [mapOfMetadata release];
            [otherRecordIDToRecord release];
            [shareRecords release];
            [wideShareRecordIDs release];
            return;
        }
        
        /*
         self = sp + 0x148 = x21 + 0x20
         */
        BOOL result = [OCCKMirroredRelationship updateMirroredRelationshipsMatchingRecords:mirroredRelationshipRecords
                                                                                  forStore:store
                                                                  withManagedObjectContext:managedObjectContext
                                                                                usingBlock:^BOOL(OCCKMirroredRelationship * _Nonnull relationship, CKRecord * _Nonnull record, NSError * _Nullable * _Nullable error) {
            /*
             x21 = self
             x19 = relationship
             x20 = record
             */
            
            relationship.isUploaded = @YES;
            
            OCCloudKitArchivingUtilities * _Nullable archivingUtilities;
            {
                OCCloudKitExporterOptions * _Nullable options = self->_options;
                if (options == nil) {
                    archivingUtilities = nil;
                } else {
                    OCCloudKitMirroringDelegateOptions * _Nullable delegateOptions = options->_options;
                    if (delegateOptions == nil) {
                        archivingUtilities = nil;
                    } else {
                        archivingUtilities = delegateOptions->_archivingUtilities;
                    }
                }
            }
            
            NSData *ckRecordSystemFields = [archivingUtilities newArchivedDataForSystemFieldsOfRecord:record];
            relationship.ckRecordSystemFields = ckRecordSystemFields;
            [ckRecordSystemFields release];
            
            return YES;
        }
                                                                                     error:&_error];
        
        if (!result) {
            _succeed = NO;
            [_error retain];
        }
        
        if (!_succeed) {
            [mirroredRelationshipRecords release];
            [mapOfMetadata release];
            [otherRecordIDToRecord release];
            [shareRecords release];
            [wideShareRecordIDs release];
            return;
        }
        
        result = [OCCKMirroredRelationship purgeMirroredRelationshipsWithRecordIDs:deletedRecordIDs fromStore:store withManagedObjectContext:managedObjectContext error:&_error];
        
        if (!result) {
            _succeed = NO;
            [_error retain];
        }
        
        if (!_succeed) {
            [mirroredRelationshipRecords release];
            [mapOfMetadata release];
            [otherRecordIDToRecord release];
            [shareRecords release];
            [wideShareRecordIDs release];
            return;
        }
        
        // x25
        NSMutableDictionary<CKRecordZoneID *, NSMutableSet<NSString *> *> *zoneIDToRecordNamesSet = [[NSMutableDictionary alloc] init];
        
        // x27
        for (CKRecordID *deletedRecordID in deletedRecordIDs) {
            NSMutableSet<NSString *> *recordNamesSet = [zoneIDToRecordNamesSet[deletedRecordID.zoneID] retain];
            if (recordNamesSet == nil) {
                recordNamesSet = [[NSMutableSet alloc] init];
                zoneIDToRecordNamesSet[deletedRecordID.zoneID] = recordNamesSet;
            }
            [recordNamesSet addObject:deletedRecordID.recordName];
            [recordNamesSet release];
            
            // original : getCloudKitCKRecordNameZoneWideShare
            if ([deletedRecordID.recordName isEqualToString:CKRecordNameZoneWideShare]) {
                [wideShareRecordIDs addObject:deletedRecordID];
            }
        }
        
        // x20
        for (CKRecordZoneID *zoneID in zoneIDToRecordNamesSet) {
            // x26 / sp + 0x10
            NSMutableSet<NSString *> *recordNamesSet = [zoneIDToRecordNamesSet[zoneID] retain];
            // x27
            NSBatchUpdateRequest *request = [[NSBatchUpdateRequest alloc] initWithEntityName:[OCCKRecordZoneMoveReceipt entityPath]];
            // x28 / sp
            NSString *zoneName = zoneID.zoneName;
            // sp + 0x8
            NSString *ownerName = zoneID.ownerName;
            
            request.predicate = [NSPredicate predicateWithFormat:@"zoneName = %@ AND ownerName = %@ AND recordName in %@", zoneName, ownerName, recordNamesSet];
            request.affectedStores = @[store];
            request.propertiesToUpdate = @{@"needsCloudDelete": [NSExpression expressionForConstantValue:@NO]};
            request.resultType = NSStatusOnlyResultType;
            
            BOOL result = ((NSNumber *)((NSBatchUpdateResult *)[managedObjectContext executeRequest:request error:&_error]).result).boolValue;
            if (!result) {
                // NO이면 break만 하고 아무것도 안하고 <+3376>, <+3380>에서 release함
                [recordNamesSet release]; // <+3376>
                [request release]; // <+3380>
                break;
            }
            
            // 원래 x26, x27에 0x0이 할당하지만 필요 없음
            [recordNamesSet release];
            [request release];
        }
        
        for (CKRecordID *recordID in wideShareRecordIDs) {
            // x28
            CKRecordZoneID *zoneID = recordID.zoneID;
            
            CKDatabaseScope databaseScope;
            {
                OCCloudKitExporterOptions * _Nullable options = self->_options;
                if (options == nil) {
                    databaseScope = 0;
                } else {
                    databaseScope = options->_database.databaseScope;
                }
            }
            
            OCCKRecordZoneMetadata * _Nullable recordZoneMetadata = [OCCKRecordZoneMetadata zoneMetadataForZoneID:zoneID inDatabaseWithScope:databaseScope forStore:store inContext:managedObjectContext error:&_error];
            if (recordZoneMetadata == nil) {
                _succeed = NO;
                [_error retain];
                break;
            }
            
            recordZoneMetadata.needsShareDelete = NO;
        }
        
#warning Error Leak : wideShareRecordIDs에서 error가 발생하여 break 되면 leak
        result = [managedObjectContext save:&_error];
        if (!result) {
            _succeed = NO;
            [_error retain];
        }
        
        [zoneIDToRecordNamesSet release]; // x25
        
        [mirroredRelationshipRecords release];
        [mapOfMetadata release];
        [otherRecordIDToRecord release];
        [shareRecords release];
        [wideShareRecordIDs release];
    }];
    
    if (!_succeed) {
        if (_error == nil) {
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d", __func__, __LINE__);
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d", __func__, __LINE__);
        } else {
            if (error) *error = [[_error retain] autorelease];
        }
    }
    
    [_error release];
    return _succeed;
}

@end
