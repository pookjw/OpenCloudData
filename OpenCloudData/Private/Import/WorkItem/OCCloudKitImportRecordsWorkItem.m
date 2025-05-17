//
//  OCCloudKitImportRecordsWorkItem.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/15/25.
//

#import <OpenCloudData/OCCloudKitImportRecordsWorkItem.h>
#import <OpenCloudData/CKRecord+Private.h>
#import <OpenCloudData/OCCloudKitSerializer.h>
#import <OpenCloudData/OCSPIResolver.h>
#import <OpenCloudData/OCCKImportOperation.h>
#import <OpenCloudData/OCCKImportPendingRelationship.h>
#import <OpenCloudData/OCCKRecordZoneMetadata.h>
#import <OpenCloudData/Log.h>
#import <OpenCloudData/_PFRoutines.h>
#include <objc/runtime.h>

FOUNDATION_EXTERN void NSRequestConcreteImplementation(id self, SEL _cmd, Class absClass);

@implementation OCCloudKitImportRecordsWorkItem

- (instancetype)initWithOptions:(OCCloudKitImporterOptions *)options request:(OCCloudKitMirroringImportRequest *)request {
    /*
     options = x20
     */
    if (self = [super initWithOptions:options request:request]) {
        _importOperationIdentifier = [[NSUUID alloc] init];
        _assetPathToSafeSaveURL = [[NSMutableDictionary alloc] init];
        _updatedRecords = [[NSMutableArray alloc] init];
        _recordTypeToDeletedRecordID = [[NSMutableDictionary alloc] init];
        _allRecordIDs = [[NSMutableArray alloc] init];
        _totalOperationBytes = 0;
        _currentOperationBytes = 0;
        _countUpdatedRecords = 0;
        _countDeletedRecords = 0;
        _encounteredErrors = [[NSMutableArray alloc] init];
        _failedRelationships = [[NSMutableArray alloc] init];
        _fetchedRecordBytesMetric = [[OCCloudKitFetchedRecordBytesMetric alloc] initWithContainerIdentifier:options.options.containerIdentifier];
        _fetchedAssetBytesMetric = [[OCCloudKitFetchedAssetBytesMetric alloc] initWithContainerIdentifier:options.options.containerIdentifier];
        _incrementalResults = [[NSMutableArray alloc] init];
        _unknownItemRecordIDs = [[NSMutableArray alloc] init];
        _updatedShares = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)dealloc {
    [_assetPathToSafeSaveURL release];
    _assetPathToSafeSaveURL = nil;
    
    [_updatedRecords release];
    _updatedRecords = nil;
    
    [_recordTypeToDeletedRecordID release];
    _recordTypeToDeletedRecordID = nil;
    
    [_allRecordIDs release];
    _allRecordIDs = nil;
    
    [_encounteredErrors release];
    _encounteredErrors = nil;
    
    [_failedRelationships release];
    _failedRelationships = nil;
    
    [_fetchedRecordBytesMetric release];
    _fetchedRecordBytesMetric = nil;
    
    [_fetchedAssetBytesMetric release];
    _fetchedAssetBytesMetric = nil;
    
    [_incrementalResults release];
    _incrementalResults = nil;
    
    [_unknownItemRecordIDs release];
    _unknownItemRecordIDs = nil;
    
    [_updatedShares release];
    _updatedShares = nil;
    
    [super dealloc];
}

- (NSString *)description {
    return [[[NSString alloc] initWithFormat:@"<%@: %p - %@>", NSStringFromClass([self class]), self, self->_request] autorelease];
}

- (void)addUpdatedRecord:(CKRecord *)record {
    /*
     self = x19
     record = x23
     */
    if (self->_encounteredErrors.count != 0) return;
    // x21
    OCCloudKitImporterOptions *options = [self->_options retain];
    // x22
    NSFileManager *fileManager = [NSFileManager.defaultManager retain];
    
    // original : getCloudKitCKRecordTypeShare
    if ([record.recordType isEqualToString:CKRecordTypeShare]) {
        // <+152>
        [self->_updatedShares setObject:(CKShare *)record forKey:record.recordID.zoneID];
    } else {
        // <+196>
        [self->_updatedRecords addObject:record];
    }
    
    // <+248>
    self->_totalOperationBytes += record.size;
    // 0x30 (offset of _totalOperationBytes) = sp + 0x8
    self->_currentOperationBytes += record.size;
    // 0x80 (offset of _currentOperationBytes) = sp
    self->_countUpdatedRecords += 1;
    
    [self->_fetchedRecordBytesMetric addByteSize:record.size];
    
    // record = sp + 0x28
    // sp + 0x30
    NSArray<CKAsset *> *assets = [OCCloudKitSerializer assetsOnRecord:record withOptions:options.options];
    // 0x58 (offset of _encounteredErrors) = sp + 0x38
    // x28
    for (CKAsset *asset in assets) {
        // x26
        NSURL *url = [options.assetStorageURL URLByAppendingPathComponent:[NSUUID UUID].UUIDString isDirectory:NO];
        // sp + 0x48
        NSError * _Nullable error = nil;
        BOOL result = [fileManager moveItemAtURL:asset.fileURL toURL:url error:&error];
        
        if (!result) {
            // <+732>
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData+CloudKit: %s(%d): Failed to copy asset to URL: %@\n%@\n%@\n%@", __func__, __LINE__, url, asset, error, record);
            // <+1072>
            [self->_encounteredErrors addObject:error];
            // <+1088>
        } else {
            // <+580>
            [self->_assetPathToSafeSaveURL setObject:url forKey:asset.fileURL.path];
            
            // x20
            NSDictionary<NSFileAttributeKey, id> * _Nullable attributes = [fileManager attributesOfItemAtPath:url.path error:&error];
            if (attributes == nil) {
                // <+896>
                os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData+CloudKit: %s(%d): Failed to read attributes of asset file at URL: %@\n%@\n%@\n%@", __func__, __LINE__, url, asset, error, record);
                // <+1072>
                [self->_encounteredErrors addObject:error];
                // <+1088>
            } else {
                // <+648>
                self->_totalOperationBytes += attributes.fileSize;
                self->_currentOperationBytes += attributes.fileSize;
                [self->_fetchedAssetBytesMetric addByteSize:attributes.fileSize];
                // <+1088>
            }
            // <+1088>
            // nop
        }
    }
    
    // <+1140>
    [fileManager release];
    [options release];
    
    [self checkAndApplyChangesIfNeeded:NO];
}

- (BOOL)applyAccumulatedChangesToStore:(NSSQLCore *)store inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext withStoreMonitor:(OCCloudKitStoreMonitor *)monitor madeChanges:(BOOL *)madeChanges error:(NSError * _Nullable *)error {
    /*
     self = x21
     store = x23
     managedObjectContext = x22
     monitor = x24
     madeChanges = x20
     error = x19
     */
    
    // x29 - 0x90
    __block BOOL _succeed = YES;
    // sp, #0x98
    __block BOOL _madeChanges = NO;
    // sp, #0x60
    __block NSError * _Nullable _error = nil;
    
    @try {
        if ((self->_updatedRecords.count == 0) && (self->_recordTypeToDeletedRecordID.count == 0) && (self->_unknownItemRecordIDs.count == 0) && (self->_updatedShares.count == 0)) {
            // nop
        } else {
            // <+240>
            if ((monitor == nil) || (monitor.declaredDead)) {
                // <+252>
                _succeed = NO;
                _error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:134407 userInfo:@{NSLocalizedFailureErrorKey: [NSString stringWithFormat:@"Request '%@' was cancelled because the store was removed from the coordinator.", self->_request.requestIdentifier]}];
            } else {
                // <+400>
                /*
                 __124-[PFCloudKitImportRecordsWorkItem applyAccumulatedChangesToStore:inManagedObjectContext:withStoreMonitor:madeChanges:error:]_block_invoke
                 store = sp + 0x30 = x19 + 0x20
                 managedObjectContext = sp + 0x38 = x19 + 0x28
                 self = sp + 0x40 = x19 + 0x30
                 _error = sp + 0x48 = x19 + 0x38
                 _madeChanges = sp + 0x50 = x19 + 0x40
                 _succeed = sp + 0x58 = x19 + 0x48
                 */
                [managedObjectContext performBlockAndWait:^{
                    // self(block) = x19
                    
                    // sp + 0x68
                    OCCloudKitMetadataCache * _Nullable metadataCache = nil;
                    // sp + 0x40
                    OCCloudKitSerializer * _Nullable serializer = nil;
                    
                    @try {
                        if (![OCSPIResolver _PFRoutines__isInMemoryStore_:objc_lookUpClass("_PFRoutines") x1:store]) {
                            // sp, #0x138
                            NSError * _Nullable __error = nil;
                            BOOL result = [managedObjectContext setQueryGenerationFromToken:NSQueryGenerationToken.currentQueryGenerationToken error:&__error];
                            if (!result) {
                                os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData+CloudKit: %s(%d): %@: Unable to set query generation on managedObjectContext: %@", __func__, __LINE__, self, __error);
                            }
                        }
                        
                        // <+288>
                        BOOL result = [self checkForActiveImportOperationInStore:store inManagedObjectContext:managedObjectContext error:&_error];
                        if (!result) {
                            // <+1880>
                            _succeed = NO;
                            [_error retain];
                            [self removeDownloadedAssetFiles];
                            return;
                        }
                        
                        // <+320>
                        metadataCache = [[OCCloudKitMetadataCache alloc] init];
                        serializer = [[OCCloudKitSerializer alloc] initWithMirroringOptions:self.options.options metadataCache:metadataCache recordNamePrefix:nil];
                        serializer.delegate = self;
                        
                        result = [metadataCache cacheMetadataForObjectsWithIDs:@[] andRecordsWithIDs:self->_allRecordIDs inStore:store withManagedObjectContext:managedObjectContext mirroringOptions:self.options.options error:&_error];
                        if (!result) {
                            // <+1920>
                            _succeed = NO;
                            [_error retain];
                            [self removeDownloadedAssetFiles];
                            [metadataCache release];
                            [serializer release];
                            return;
                        }
                        
                        // <+480>
                        // x28
                        for (CKRecordID *recordID in self->_unknownItemRecordIDs) @autoreleasepool {
                            // x21
                            OCCKRecordMetadata * _Nullable recordMetadata = [metadataCache recordMetadataForRecordID:recordID];
                            if (recordMetadata == nil) continue;
                            // x25
                            NSSQLModel *model = store.model;
                            NSEntityDescription * _Nullable entityDescription = [model entityForID:(uint)recordMetadata.entityId.unsignedLongValue].entityDescription;
                            
                            if (entityDescription == nil) {
                                os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: CloudKit Import: Failed to find entity for unknown item recordID: %@ - %@\n", recordID, recordMetadata);
                                os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: CloudKit Import: Failed to find entity for unknown item recordID: %@ - %@\n", recordID, recordMetadata);
                                continue;
                            }
                            
                            // x21
                            CKRecordType recordType = [OCCloudKitSerializer recordTypeForEntity:entityDescription];
                            // <+680>
                            // x25
                            NSMutableArray<CKRecordID *> *deletedRecordIDs = [[self->_recordTypeToDeletedRecordID objectForKey:recordType] retain];
                            if (deletedRecordIDs == nil) {
                                deletedRecordIDs = [[NSMutableArray alloc] init];
                                [self->_recordTypeToDeletedRecordID setObject:deletedRecordIDs forKey:recordType];
                            }
                            [deletedRecordIDs addObject:recordID];
                            [deletedRecordIDs release];
                        }
                        
                        // <+1012>
                        os_log_with_type(_OCLogGetLogStream(0x11), OS_LOG_TYPE_DEFAULT, "OpenCloudData+CloudKit: %s(%d): %@ - Importing updated records:\n%@\nDeleted RecordIDs:\n%@", __func__, __LINE__, self, self->_updatedRecords, self->_recordTypeToDeletedRecordID);
                        
                        result = [serializer applyUpdatedRecords:self->_updatedRecords deletedRecordIDs:self->_recordTypeToDeletedRecordID toStore:store inManagedObjectContext:managedObjectContext onlyUpdatingAttributes:[self entityNameToAttributesToUpdate] andRelationships:[self entityNameToRelationshipsToUpdate] madeChanges:&_madeChanges error:&_error];
                        if (!result) {
                            // <+1920>
                            _succeed = NO;
                            [_error retain];
                            [self removeDownloadedAssetFiles];
                            [metadataCache release];
                            [serializer release];
                            return;
                        }
                        
                        // <+1332>
                        _succeed = [self updateMetadataForAccumulatedChangesInContext:managedObjectContext inStore:store error:&_error];
                        if (!_succeed) {
                            [_error retain];
                            [self removeDownloadedAssetFiles];
                            [metadataCache release];
                            [serializer release];
                            return;
                        }
                        
                        if (!_madeChanges) {
                            _madeChanges = managedObjectContext.hasChanges;
                        }
                        
                        // <+1420>
                        if (![OCSPIResolver _PFRoutines__isInMemoryStore_:objc_lookUpClass("_PFRoutines") x1:store]) {
                            // sp, #0x138
                            NSError * _Nullable __error = nil;
                            BOOL result = [managedObjectContext setQueryGenerationFromToken:NSQueryGenerationToken.currentQueryGenerationToken error:&__error];
                            if (!result) {
                                os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData+CloudKit: %s(%d): %@: Unable to set query generation on managedObjectContext: %@", __func__, __LINE__, self, __error);
                            }
                        }
                        
                        // <+1640>
                        // x21
                        OCCKImportOperation * _Nullable importOperation = [OCCKImportOperation fetchOperationWithIdentifier:self->_importOperationIdentifier fromStore:store inManagedObjectContext:managedObjectContext error:&_error];
                        if (importOperation == nil) {
                            // <+2980>
                            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData+CloudKit: %s(%d): Failed to fetch import operation with identifier '%@': %@", __func__, __LINE__, self->_importOperationIdentifier, _error);
                            
                            if (_error == nil) {
                                // <+3380>
                                _error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:134407 userInfo:@{
                                    NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"The request '%@' was cancelled because it conflicted with another active import operation.", self.request]
                                }];
                            } else {
                                [_error retain];
                            }
                            
                            _succeed = NO;
                            // <+3524>
                            [self removeDownloadedAssetFiles];
                            [metadataCache release];
                            [serializer release];
                            return;
                        }
                        
                        // <+1688>
                        for (OCMirroredRelationship *relationship in self->_failedRelationships) {
                            [OCCKImportPendingRelationship insertPendingRelationshipForFailedRelationship:relationship forOperation:importOperation inStore:store withManagedObjectContext:managedObjectContext];
                        }
                        
                        // <+1848>
                        result = [managedObjectContext save:&_error];
                        if (!result) {
                            // <+3176>
                            if (_error != nil) {
                                _succeed = NO;
                                [_error retain];
                                os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData+CloudKit: %s(%d): Failed to save applied changes from import: %@", __func__, __LINE__, _error);
                                
                                [self removeDownloadedAssetFiles];
                                [metadataCache release];
                                [serializer release];
                                return;
                            }
                            // _error가 nil이면 안 되겠지만, 일단 nil이면 코드가 계속 돌아가는 구조
                        }
                        
                        // <+3524>
                        _succeed = YES;
                        _currentOperationBytes = 0;
                        
                        // <+1968>
                        /*
                         0x78 (offset of _updatedShares) = sp + 0x48
                         _updatedShares = sp + 0x38
                         */
                        // x28
                        for (CKRecordZoneID *recordZoneID in self->_updatedShares) @autoreleasepool {
                            // x26
                            OCCKRecordZoneMetadata * _Nullable zoneMatadata = [OCCKRecordZoneMetadata zoneMetadataForZoneID:recordZoneID inDatabaseWithScope:self.options.options.databaseScope forStore:store inContext:managedObjectContext error:&_error];
                            if (zoneMatadata == nil) {
                                _succeed = NO;
                                [_error retain];
                                break;
                            }
                            
                            // <+2184>
                            // x21
                            CKShare *share = [self->_updatedShares objectForKey:recordZoneID];
                            os_log_with_type(_OCLogGetLogStream(0x11), OS_LOG_TYPE_DEFAULT, "OpenCloudData+CloudKit: %s(%d): Importing updated share: %@", __func__, __LINE__, share);
                            
                            // x24
                            NSData * _Nullable encodedRecord = [self.options.options.archivingUtilities encodeRecord:share error:&_error];
                            
                            if (encodedRecord == nil) {
                                // <+2500>
                                _succeed = NO;
                                [_error retain];
                                os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData+CloudKit: %s(%d): Failed to encode an updated share: %@\n%@\n%@\n%@", __func__, __LINE__, recordZoneID, share, self.options.assetStorageURL, zoneMatadata);
                                break;
                            }
                            
                            // <+2440>
                            zoneMatadata.encodedShareData = encodedRecord;
                            zoneMatadata.needsShareUpdate = NO;
                            // <+2720>
                            [encodedRecord release];
                        }
                        
                        // <+2820>
                        if (_succeed) {
                            result = [managedObjectContext save:&_error];
                            if (!result) {
                                _succeed = NO;
                                [_error retain];
                            }
                        }
                    } @catch (NSException *exception) {
                        _succeed = NO;
                        _error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:134421 userInfo:@{
                            @"NSUnderlyingException": exception,
                            NSLocalizedFailureReasonErrorKey: @"Import failed because applying the accumulated changes hit an unhandled exception."
                        }];
                    }
                    
                    [self removeDownloadedAssetFiles];
                    [metadataCache release];
                    [serializer release];
                }];
                
                if (_succeed) {
                    os_log_with_type(_OCLogGetLogStream(0x11), OS_LOG_TYPE_DEFAULT, "OpenCloudData+CloudKit: %s(%d): Finished importing applying changes for request: %@", __func__, __LINE__, self->_request);
                }
            }
        }
    } @catch (NSException *exception) {
        os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: %@ - Exception thrown during import: %@\n", self, exception);
        os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: %@ - Exception thrown during import: %@\n", self, exception);
    }
    
    // <+656>
    *madeChanges = _madeChanges;
    
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
    _error = nil;
    
    return _succeed;
}

- (void)cloudKitSerializer:(OCCloudKitSerializer *)cloudKitSerializer failedToUpdateRelationship:(OCMirroredManyToManyRelationship *)relationship withError:(NSError *)error {
    [self->_failedRelationships addObject:relationship];
}

- (NSURL *)cloudKitSerializer:(OCCloudKitSerializer *)cloudKitSerializer safeSaveURLForAsset:(CKAsset *)asset {
    return [self->_assetPathToSafeSaveURL objectForKey:asset.fileURL.path];
}

- (BOOL)commitMetadataChangesWithContext:(NSManagedObjectContext *)managedObjectContext forStore:(NSSQLCore *)store error:(NSError * _Nullable *)error {
    /*
     managedObjectContext = x20
     x19 = error
     */
    // sp, #0x8
    NSError * _Nullable _error = nil;
    BOOL result = [OCCKImportOperation purgeFinishedImportOperationsInStore:store withManagedObjectContext:managedObjectContext error:&_error];
    if (!result) {
        os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData+CloudKit: %s(%d): Failed to purge mirrored relationships during import: %@", __func__, __LINE__, _error);
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
    
    result = [managedObjectContext save:&_error];
    if (result) return YES;
    if (_error == nil) return YES; // 실수 아님
    
    os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData+CloudKit: %s(%d): Failed to save changes from import: %@", __func__, __LINE__, _error);
    if (error != NULL) {
        *error = _error;
    }
    return NO;
}

- (OCCloudKitMirroringResult *)createMirroringResultForRequest:(OCCloudKitMirroringRequest *)request storeIdentifier:(NSString *)storeIdentifier success:(BOOL)success madeChanges:(BOOL)madeChanges error:(NSError *)error {
    return [[OCCloudKitMirroringResult alloc] initWithRequest:request storeIdentifier:storeIdentifier success:success madeChanges:madeChanges error:error];
}

- (void)doWorkForStore:(NSSQLCore *)store inMonitor:(OCCloudKitStoreMonitor *)monitor completion:(void (^)(OCCloudKitMirroringResult * _Nonnull))completion {
    /*
     self = x21
     store = x22
     completion = x20
     */
    // x19
    NSManagedObjectContext *managedObjectContext = [monitor newBackgroundContextForMonitoredCoordinator];
    // x23
    OCCloudKitMirroringImportRequest *request = self.request;
    
    if (request.schedulerActivity.shouldDefer || request.deferredByBackgroundTimeout) {
        // <+112>
        if (completion != nil) {
            NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:134419 userInfo:@{
                NSLocalizedFailureReasonErrorKey: @"The request was aborted because it was deferred by the system."
            }];
            // x21
            OCCloudKitMirroringResult *result = [self createMirroringResultForRequest:self.request storeIdentifier:store.identifier success:NO madeChanges:NO error:error];
            completion(result);
            [result release];
        }
        
        [managedObjectContext release];
        return;
    }
    
    // <+276>
    /*
     __71-[PFCloudKitImportRecordsWorkItem doWorkForStore:inMonitor:completion:]_block_invoke
     managedObjectContext = sp + 0x20 = x19 + 0x20
     self = sp + 0x28 = x19 + 0x28
     store = sp + 0x30 = x19 + 0x30
     */
    [managedObjectContext performBlockAndWait:^{
        // self(block) = x19
        // x20
        OCCKImportOperation *importOperation = [NSEntityDescription insertNewObjectForEntityForName:[OCCKImportOperation entityPath] inManagedObjectContext:managedObjectContext];
        importOperation.operationUUID = self.importOperationIdentifier;
        importOperation.importDate = [NSDate date];
        [managedObjectContext assignObject:importOperation toPersistentStore:store];
        
        // sp + 0x8
        NSError * _Nullable error = nil;
        BOOL result = [managedObjectContext save:&error];
        
        if (!result) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Failed to save import operation: %@\n", error);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Failed to save import operation: %@\n", error);
        }
    }];
    
    [self executeImportOperationsAndAccumulateRecordsWithManagedObjectContext:managedObjectContext completion:completion];
    [managedObjectContext release];
}

- (NSDictionary<NSString *,NSArray<NSAttributeDescription *> *> *)entityNameToAttributesToUpdate {
    return nil;
}

- (NSDictionary<NSString *,NSArray<NSRelationshipDescription *> *> *)entityNameToRelationshipsToUpdate {
    return nil;
}

- (void)executeImportOperationsAndAccumulateRecordsWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext completion:(void (^)(OCCloudKitMirroringResult * _Nonnull))completion {
    NSRequestConcreteImplementation(self, _cmd, [OCCloudKitImporterWorkItem class]);
}

- (BOOL)updateMetadataForAccumulatedChangesInContext:(NSManagedObjectContext *)managedObjectContext inStore:(NSSQLCore *)store error:(NSError * _Nullable *)error {
    return YES;
}

- (void)checkAndApplyChangesIfNeeded:(CKServerChangeToken *)token {
    /*
     self = x20
     token = x19
     */
    if ((self.options.options.operationMemoryThresholdBytes.unsignedIntegerValue == 0) || (self->_currentOperationBytes < self.options.options.operationMemoryThresholdBytes.unsignedIntegerValue)) {
        // <+96>
        if (self->_currentOperationBytes <= 0xa00000) {
            NSUInteger count = self->_allRecordIDs.count;
            if (token != nil) {
                // <+112>
                // nop
            } else {
                if (count < 0x1f5) {
                    // <+180>
                    return;
                } else {
                    // <+112>
                    // nop
                }
            }
        } else {
            // <+112>
            // nop
        }
    }
    
    // <+112>
    /*
     __64-[PFCloudKitImportRecordsWorkItem checkAndApplyChangesIfNeeded:]_block_invoke
     self = sp + 0x20
     token = sp + 0x28
     */
    dispatch_sync(self.options.workQueue, ^{
        /*
         __64-[PFCloudKitImportRecordsWorkItem checkAndApplyChangesIfNeeded:]_block_invoke_2
         self = sp + 0x20 = x19 + 0x20
         token = sp + 0x28 = x19 + 0x28
         */
        [objc_lookUpClass("_PFRoutines") wrapBlockInGuardedAutoreleasePool:^{
            // self(block) = x19
            os_log_with_type(_OCLogGetLogStream(0x11), OS_LOG_TYPE_DEFAULT, "OpenCloudData+CloudKit: %s(%d): %@: Applying accumulated changes at change token: %@", __func__, __LINE__, self, token);
            // x20
            OCCloudKitStoreMonitor *monitor = [self.options.monitor retain];
            
            /*
             __64-[PFCloudKitImportRecordsWorkItem checkAndApplyChangesIfNeeded:]_block_invoke.39
             monitor = sp + 0x28
             self = sp + 0x28
             */
            [monitor performBlock:^{
                // sp, #0x48
                NSError * _Nullable error = nil;
                // x19
                NSSQLCore * _Nullable store = [monitor retainedMonitoredStore];
                if (store == nil) {
                    error = [NSError errorWithDomain:NSCocoaErrorDomain code:134407 userInfo:@{
                        NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"Request '%@' was cancelled because the store was removed from the coordinator.", self.request.requestIdentifier]
                    }];
                    [self->_encounteredErrors addObject:error];
                    return;
                }
                
                // <+76>
                // x20
                NSPersistentStoreCoordinator * _Nullable monitoredCoordinator = [monitor.monitoredCoordinator retain];
                // x21
                NSManagedObjectContext *managedObjectContext = [monitor newBackgroundContextForMonitoredCoordinator];
                managedObjectContext.transactionAuthor = [OCSPIResolver NSCloudKitMirroringDelegateImportContextName];
                
                // sp, #0x47
                BOOL madeChanges = NO;
                BOOL result = [self applyAccumulatedChangesToStore:store inManagedObjectContext:managedObjectContext withStoreMonitor:monitor madeChanges:&madeChanges error:&error];
                
                if (!result) {
                    os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData+CloudKit: %s(%d): %@: Failed to incrementally apply changes during request: %@\n%@", __func__, __LINE__, self, self.request, error);
                    [self->_encounteredErrors addObject:error];
                    [monitoredCoordinator release];
                    [managedObjectContext release];
                    [store release];
                    return;
                }
                
                // <+152>
                /*
                 __64-[PFCloudKitImportRecordsWorkItem checkAndApplyChangesIfNeeded:]_block_invoke_2.40
                 managedObjectContext = sp + 0x30 = x19 + 0x20
                 self = sp + 0x38 = x19 + 0x28
                 */
                [managedObjectContext performBlockAndWait:^{
                    // self(block) = x19
                    if (managedObjectContext.hasChanges) {
                        os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Incremental import left uncommitted changes in the managed object context: %@\n", self.request);
                        os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Incremental import left uncommitted changes in the managed object context: %@\n", self.request);
                    }
                }];
                
                os_log_with_type(_OCLogGetLogStream(0x11), OS_LOG_TYPE_DEFAULT, "OpenCloudData+CloudKit: %s(%d): %@: Successfully applied incremental changes during request: %@", __func__, __LINE__, self, self.request);
                
                // x24/x25
                OCCloudKitMirroringResult *mirroringResult = [self createMirroringResultForRequest:self.request storeIdentifier:monitor.storeIdentifier success:YES madeChanges:madeChanges error:nil];
                [self->_incrementalResults addObject:mirroringResult];
                
                if (!mirroringResult.success) {
                    // <+500>
                    os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Should tear down here and stop subsequent attempts to import from happening.");
                }
                
                [mirroringResult release];
                [monitoredCoordinator release];
                [managedObjectContext release];
                [store release];
            }];
            [monitor release];
            
            [self->_allRecordIDs release];
            self->_allRecordIDs = [[NSMutableArray alloc] init];
            [self->_updatedRecords release];
            self->_updatedRecords = [[NSMutableArray alloc ]init];
            [self->_recordTypeToDeletedRecordID release];
            self->_recordTypeToDeletedRecordID = [[NSMutableDictionary alloc] init];
            [self->_assetPathToSafeSaveURL release];
            self->_assetPathToSafeSaveURL = [[NSMutableDictionary alloc] init];
            [self->_failedRelationships release];
            self->_failedRelationships = [[NSMutableArray alloc] init];
            [self->_unknownItemRecordIDs release];
            self->_unknownItemRecordIDs = nil;
            [self->_updatedShares release];
            self->_updatedShares = [[NSMutableDictionary alloc] init];
        }];
    });
}

- (BOOL)checkForActiveImportOperationInStore:(NSSQLCore *)store inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable *)error {
    /*
     self = x21
     error = x20
     */
    // sp, #0x8
    NSError * _Nullable _error = nil;
    
    OCCKImportOperation * _Nullable operation = [OCCKImportOperation fetchOperationWithIdentifier:self.importOperationIdentifier fromStore:store inManagedObjectContext:managedObjectContext error:&_error];
    
    if ((operation == nil) && (_error == nil)) {
        _error = [NSError errorWithDomain:NSCocoaErrorDomain code:134407 userInfo:@{
            NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"The request '%@' was cancelled because it conflicted with another active import operation.", self.request]
        }];
        if (error != NULL) {
            *error = _error;
        }
    } else if (operation != nil) {
        // nop
    } else {
        if (_error == nil) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        } else {
            if (error != NULL) {
                *error = _error;
            }
        }
    }
    
    return (operation != nil);
}

- (void)removeDownloadedAssetFiles {
    // self = x20
    // sp, #0x58
    NSError * _Nullable error = nil;
    // x19
    NSFileManager *fileManager = [NSFileManager.defaultManager retain];
    // x25
    for (NSURL *url in self->_assetPathToSafeSaveURL.allValues) {
        BOOL result = [fileManager removeItemAtURL:url error:&error];
        if (!result) {
            // <+224>
            if (!([error.domain isEqualToString:NSCocoaErrorDomain]) || (error.code != NSFileNoSuchFileError)) {
                os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData+CloudKit: %s(%d): Unable to delete processed asset file: %@\n%@", __func__, __LINE__, url, error);
            }
        }
    }
    
    [fileManager release];
}

@end
