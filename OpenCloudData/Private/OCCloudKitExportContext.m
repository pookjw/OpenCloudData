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
#import <OpenCloudData/Log.h>
#import <objc/runtime.h>
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
        
        // <+840>
        abort();
    }];
    
    // <+176>
    abort();
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
        if (error == nil) {
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
            recordZoneMetadataCount = ((NSInteger (*)(id, id, id *))symbol)(managedObjectContext, fetchRequest, error);
            
            if (recordZoneMetadataCount == NSNotFound) {
#warning TODO
                // <+476>
                abort();
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
            recordZoneMoveReceiptsCount = ((NSInteger (*)(id, id, id *))symbol)(managedObjectContext, fetchRequest, error);
            
            if (recordZoneMoveReceiptsCount == NSNotFound) {
                if (error == nil) {
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

@end
