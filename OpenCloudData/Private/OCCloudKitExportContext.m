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
#import <OpenCloudData/OCCloudKitOperationBatch.h>
#import <OpenCloudData/OCCloudKitMetadataCache.h>
@import ellekit;

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
        
        const void *image = MSGetImageByName("/System/Library/Frameworks/CoreData.framework/CoreData");
        const void *symbol = MSFindSymbol(image, "+[_PFRoutines efficientlyEnumerateManagedObjectsInFetchRequest:usingManagedObjectContext:andApplyBlock:]");
        
        // sp + 0x1c0
        __block NSUInteger count_0_1 = 0;
        
        // sp + 0x1a0
        __block NSUInteger count_2 = 0;
        
        /*
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
        ((void (*)(Class, id, id, id))symbol)(objc_lookUpClass("_PFRoutines"), fetchRequest, managedObjectContext, ^(NSArray<OCCKHistoryAnalyzerState *> * _Nullable states, NSError * _Nullable __error, BOOL *checkChanges, BOOL *reserved) {
            /*
             x21 = states
             */
            
            if (__error != nil) {
                __error = [_error retain];
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
                    
                    const void *image = MSGetImageByName("/System/Library/Frameworks/CoreData.framework/CoreData");
                    const void *symbol = MSFindSymbol(image, "__sqlEntityForEntityDescription");
                    
                    NSSQLEntity * _Nullable entity = ((id (*)(id, id))symbol)(analyzedObjectID.entity, model);
                    uint _entityID;
                    if (entity == nil) {
                        _entityID = 0;
                    } else {
                        Ivar ivar = object_getInstanceVariable(entity, "_entityID", NULL);
                        assert(ivar != NULL);
                        _entityID = *(uint *)((uintptr_t)entity + ivar_getOffset(ivar));
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
        });
        
        if (_succeed) {
            /*
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
                                    
                                    const void *symbol = MSFindSymbol(image, "__sqlEntityForEntityDescription");
                                    
                                    NSSQLEntity * _Nullable entity = ((id (*)(id, id))symbol)(objectID.entity, store.model);
                                    uint _entityID;
                                    if (entity == nil) {
                                        _entityID = 0;
                                    } else {
                                        Ivar ivar = object_getInstanceVariable(entity, "_entityID", NULL);
                                        assert(ivar != NULL);
                                        _entityID = *(uint *)((uintptr_t)entity + ivar_getOffset(ivar));
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
                         zoneID = sp + 0x1c0 = x20 + 0x20
                         tokenNumber = sp + 0x1c8 = x20 + 0x28
                         managedObjectContext = sp + 0x1d0 = x20 + 0x30
                         _error = x20 + 0x38
                         _succeed = x20 + 0x40
                         
                         */
                        ((void (*)(Class, id, id, id))symbol)(objc_lookUpClass("_PFRoutines"), fetchRequest, managedObjectContext, ^(NSArray<OCCKHistoryAnalyzerState *> * _Nullable states, NSError * _Nullable __error, BOOL *checkChanges, BOOL *reserved) {
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
                        });
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
                    
                    const void *symbol = MSFindSymbol(image, "+[_PFRoutines efficientlyEnumerateManagedObjectsInFetchRequest:usingManagedObjectContext:andApplyBlock:]");
                    
                    ((void (*)(Class, id, id, id))symbol)(objc_lookUpClass("_PFRoutines"), fetchRequest, managedObjectContext, ^(NSArray<OCCKRecordZoneMoveReceipt *> * _Nullable receipts, NSError * _Nullable __error, BOOL *checkChanges, BOOL *reserved) {
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
                    });
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
                        return;
                    }
                    
                    
                    // sp + 0x50
                    NSSQLModel *model = [store.model retain];
                    
                    // original : NSPersistentStoreMirroringDelegateOptionKey
                    NSSQLModel *mirroringModel = [store ancillarySQLModels][@"NSPersistentStoreMirroringDelegateOptionKey"];
#warning OC로 해야 하나?
                    // sp + 0x20
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
                        NSSQLBlockRequestContext *requestCpntext = [[objc_lookUpClass("NSSQLBlockRequestContext") alloc] initWithBlock:^(NSSQLStoreRequestContext * _Nonnull context) {
                            const void *symbol = MSFindSymbol(image, "-[NSSQLiteConnection createArrayOfPrimaryKeysAndEntityIDsForRowsWithoutRecordMetadataWithEntity:metadataEntity:]");
                            arrayOfPrimaryKeysAndEntityIDs = ((id (*)(Class, id, id))symbol)(objc_lookUpClass("NSSQLiteConnection"), entry, recordMetadataEntity);
                        }
                                                                                                           context:managedObjectContext
                                                                                                           sqlCore:store];
                        
                        const void *symbol = MSFindSymbol(image, "-[NSSQLCore dispatchRequest:withRetries:]");
                        ((void (*)(Class, id, NSUInteger))symbol)(objc_lookUpClass("NSSQLCore"), requestCpntext, 0);
                        
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
                            
                            const void *symbol = MSFindSymbol(image, "__sqlCoreLookupSQLEntityForEntityID");
                            NSSQLEntity * _Nullable sqlEntity = ((id (*)(id, unsigned long))symbol)(store, primaryKeyAndEntityID[1].unsignedLongValue);
                            
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
            const void *image = MSGetImageByName("/System/Library/Frameworks/CoreData.framework/CoreData");
            const void *symbol = MSFindSymbol(image, "-[NSManagedObjectContext _countForFetchRequest_:error:]");
            recordZoneMetadataCount = ((NSInteger (*)(id, id, id *))symbol)(managedObjectContext, fetchRequest, &_error);
            
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
            const void *image = MSGetImageByName("/System/Library/Frameworks/CoreData.framework/CoreData");
            const void *symbol = MSFindSymbol(image, "-[NSManagedObjectContext _countForFetchRequest_:error:]");
            recordZoneMoveReceiptsCount = ((NSInteger (*)(id, id, id *))symbol)(managedObjectContext, fetchRequest, &_error);
            
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
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __func__, __LINE__);
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __func__, __LINE__);
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
            break;
        }
        
        metadata.needsUpload = YES;
        metadata.pendingExportTransactionNumber = transactionNumner;
        metadata.pendingExportChangeTypeNumber = @0;
    }
    
    if (hasError) {
        if (contextError == nil) {
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __func__, __LINE__);
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __func__, __LINE__);
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
    
    // sp, #0x90
    __block NSError * _Nullable _error = nil;
    // x29, #0x80
    __block BOOL _succeed = NO;
    // sp, #0x60
    __block OCCloudKitSerializer * _Nullable serializer = nil;
    
    // x22
    OCCloudKitOperationBatch *operationBatch = [[OCCloudKitOperationBatch alloc] init];
    
    // x21
    NSMutableSet *set = [[NSMutableSet alloc] init];
    
    /*
     store = sp + 0x20 = x21 + 0x20
     self = sp + 0x28 = x21 + 0x28
     managedObjectContext = sp + 0x30 = x21 + 0x30
     operationBatch = sp + 0x38 = x21 + 0x38
     set = sp + 0x40 = x21 + 0x40
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
            // <+3200>
            abort();
        }
        
        // x24
        for (OCCKRecordMetadata *recordMetadata in fetchedRecordMetadataArray) @autoreleasepool {
            // x24
            NSManagedObjectID *objectID = [recordMetadata createObjectIDForLinkedRow];
            [objectIDs addObject:objectID];
        }
        
        // <+464>
        abort();
    }];
    
    abort();
}

@end
