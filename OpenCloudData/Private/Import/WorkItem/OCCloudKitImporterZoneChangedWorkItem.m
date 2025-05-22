//
//  OCCloudKitImporterZoneChangedWorkItem.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/15/25.
//

#import "OpenCloudData/Private/Import/WorkItem/OCCloudKitImporterZoneChangedWorkItem.h"
#import "OpenCloudData/Private/Model/OCCKRecordZoneMetadata.h"
#import "OpenCloudData/SPI/OCSPIResolver.h"
#import "OpenCloudData/Private/Log.h"

@implementation OCCloudKitImporterZoneChangedWorkItem

- (instancetype)initWithChangedRecordZoneIDs:(NSArray<CKRecordZoneID *> *)recordZoneIDs options:(OCCloudKitImporterOptions *)options request:(OCCloudKitMirroringImportRequest *)request {
    /*
     recordZoneIDs = x20
     */
    if (self = [super initWithOptions:options request:request]) {
        // self = x19
        self->_changedRecordZoneIDs = [recordZoneIDs retain];
        self->_fetchedZoneIDToChangeToken = [[NSMutableDictionary alloc] init];
        self->_fetchedZoneIDToMoreComing = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)dealloc {
    [_changedRecordZoneIDs release];
    [_fetchedZoneIDToChangeToken release];
    [_fetchedZoneIDToMoreComing release];
    [super dealloc];
}

- (NSString *)description {
    // self = x19
    // x20
    NSMutableString *result = [[NSMutableString alloc] initWithFormat:@"<%@: %p - %@>", NSStringFromClass([self class]), self, self.request];
    [result appendFormat:@" {\n%@\n}", self->_changedRecordZoneIDs];
    return [result autorelease];
}

- (BOOL)commitMetadataChangesWithContext:(NSManagedObjectContext *)managedObjectContext forStore:(NSSQLCore *)store error:(NSError * _Nullable *)error {
    /*
     self = x23
     managedObjectContext = x22
     store = x21
     error = sp
     */
    // sp, #0x68
    NSError * _Nullable _error = nil;
    // x20 / sp + 0x8
    NSMutableSet<CKRecordZoneID *> *allZoneIDs = [[NSMutableSet alloc] initWithArray:self->_fetchedZoneIDToChangeToken.allKeys];
    [allZoneIDs addObject:self->_fetchedZoneIDToMoreComing.allKeys];
    
    // x25
    for (CKRecordZoneID *zoneID in allZoneIDs) {
        // x26
        OCCKRecordZoneMetadata * _Nullable zoneMetadata = [OCCKRecordZoneMetadata zoneMetadataForZoneID:zoneID inDatabaseWithScope:self.options.options.databaseScope forStore:store inContext:managedObjectContext error:&_error];
        if (_error != nil) {
            // <+480>
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData+CloudKit: %s(%d): Unable to fetch zone metadata for zone: %@\n%@", __func__, __LINE__, zoneID, _error);
            [allZoneIDs release];
            
            if (_error == nil) {
                os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
                os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            } else if (error != NULL) {
                *error = _error;
            }
            
            return NO;
        }
        
        // <+292>
        
        zoneMetadata.currentChangeToken = [self->_fetchedZoneIDToChangeToken objectForKey:zoneID];
        zoneMetadata.needsImport = [self->_fetchedZoneIDToMoreComing objectForKey:zoneMetadata].boolValue;
        zoneMetadata.lastFetchDate = [NSDate date];
    }
    
    // w21
    BOOL result = [super commitMetadataChangesWithContext:managedObjectContext forStore:store error:&_error];
    [allZoneIDs release];
    
    if (!result) {
        if (_error == nil) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        } else if (error != NULL) {
            *error = _error;
        }
    }
    
    return result;
}

- (void)executeImportOperationsAndAccumulateRecordsWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext completion:(void (^)(OCCloudKitMirroringResult * _Nonnull))completion {
    /*
     self = x23
     managedObjectContext = x26
     completion = x22
     */
    // x19 / sp + 0x50
    OCCloudKitImporterOptions *importerOptions = [self.options retain];
    // sp + 0x48
    CKDatabase *database = [importerOptions.database retain];
    // sp + 0x38
    NSPersistentStoreCoordinator * _Nullable monitoredCoordinator = importerOptions.monitor.monitoredCoordinator;
    // sp + 0x58
    NSPersistentStore *store = [importerOptions.monitor retainedMonitoredStore];
    
    if (store == nil) {
        if (completion != nil) {
            // <+900>
            NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:134407 userInfo:@{
                NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"Request '%@' was cancelled because the store was removed from the coordinator.", self.request.requestIdentifier]
            }];
            // x20
            OCCloudKitMirroringResult *result = [[OCCloudKitMirroringResult alloc] initWithRequest:self.request storeIdentifier:importerOptions.monitor.storeIdentifier success:NO madeChanges:NO error:error];
            completion(result);
            [result release];
        }
        
        // <+1792>
        [monitoredCoordinator release];
        [database release];
        [importerOptions release];
        return;
    }
    
    // completion = sp + 0x20
    // sp + 0x40
    NSMutableDictionary<CKRecordZoneID *, CKFetchRecordZoneChangesConfiguration *> *dictionary = [[NSMutableDictionary alloc] init];
    // sp, #0x270
    __block BOOL succeed = YES;
    // sp, #0x240
    __block NSError * _Nullable error = nil;
    // _changedRecordZoneIDs (offset) = sp + 0x10
    // self = sp + 0x18
    
    // x24
    for (CKRecordZoneID *zoneID in self->_changedRecordZoneIDs) {
        // <+344>
        // sp, #0x1d0
        __block CKServerChangeToken * _Nullable previousServerChangeToken = nil;
        
        /*
         __120-[PFCloudKitImporterZoneChangedWorkItem executeImportOperationsAndAccumulateRecordsWithManagedObjectContext:completion:]_block_invoke
         zoneID = sp + 0x198 = x19 + 0x20
         database = sp + 0x1a0 = x19 + 0x28
         store = sp + 0x1a8 = x19 + 0x30
         managedObjectContext = sp + 0x1b0 = x19 + 0x38
         previousServerChangeToken = sp + 0x1b8 = x19 + 0x40
         succeed = sp + 0x1c0 = x19 + 0x48
         error = sp + 0x1c8 = x19 + 0x50
         */
        [managedObjectContext performBlockAndWait:^{
            // self(block) = x19
            @try {
                // sp
                NSError * _Nullable _error = nil;
                OCCKRecordZoneMetadata * _Nullable zoneMetadata = [OCCKRecordZoneMetadata zoneMetadataForZoneID:zoneID inDatabaseWithScope:database.databaseScope forStore:store inContext:managedObjectContext error:&_error];
                if (zoneMetadata) {
                    succeed = NO;
                    error = [_error retain];
                    return;
                }
                
                previousServerChangeToken = [zoneMetadata.currentChangeToken retain];
            } @catch (NSException *exception) {
                succeed = NO;
                error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:134421 userInfo:@{
                    @"NSUnderlyingException": exception,
                    NSLocalizedFailureReasonErrorKey: @"Import failed because fetching the zone change token hit an unhandled exception."
                }];
            }
        }];
        
        // <+468>
        if (!succeed) {
            break;
        }
        
        // <+484>
        // original : getCloudKitCKFetchRecordZoneChangesConfigurationClass
        // x25
        CKFetchRecordZoneChangesConfiguration *configuration = [[CKFetchRecordZoneChangesConfiguration alloc] init];
        configuration.previousServerChangeToken = previousServerChangeToken;
        [previousServerChangeToken release];
        previousServerChangeToken = nil;
        // x21
        NSSet<CKRecordFieldKey> *recordKeys = [OCCloudKitSerializer newSetOfRecordKeysForEntitiesInConfiguration:store.configurationName inManagedObjectModel:monitoredCoordinator.managedObjectModel includeCKAssetsForFileBackedFutures:importerOptions.options.automaticallyDownloadFileBackedFutures];
        // x20
        NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:recordKeys];
        for (CKRecordFieldKey key in recordKeys) {
            [array addObject:key];
        }
        configuration.desiredKeys = array;
        [dictionary setObject:configuration forKey:zoneID];
        [configuration release];
        [recordKeys release];
        [array release];
    }
    
    // <+1132>
    if (!succeed) {
        // self = x20
        if (completion != nil) {
            // <+1664>
            // x20
            OCCloudKitMirroringResult *result = [[OCCloudKitMirroringResult alloc] initWithRequest:self.request storeIdentifier:importerOptions.monitor.storeIdentifier success:NO madeChanges:NO error:error];
            completion(result);
            [result release];
        }
        
        [error release];
        [monitoredCoordinator release];
        [dictionary release];
        [store release];
        [importerOptions release];
        [database release];
        return;
    }
    
    // <+1148>
    /*
     self = x20
     completion = x24
     */
    // original : getCloudKitCKFetchRecordZoneChangesOperationClass
    // x26
    CKFetchRecordZoneChangesOperation *operation = [[CKFetchRecordZoneChangesOperation alloc] initWithRecordZoneIDs:self->_changedRecordZoneIDs configurationsByRecordZoneID:dictionary];
    if (self.request.options != nil) {
        [self.request.options applyToOperation:operation];
    }
    
    // sp + 0x1d0
    __weak OCCloudKitImporterZoneChangedWorkItem *weakSelf = self;
    
    /*
     __120-[PFCloudKitImporterZoneChangedWorkItem executeImportOperationsAndAccumulateRecordsWithManagedObjectContext:completion:]_block_invoke_2
     weakSelf = sp + 0x138
     */
    operation.recordWasChangedBlock = ^(CKRecordID *recordID, CKRecord * _Nullable record, NSError * _Nullable error) {
        // record = x19
        OCCloudKitImporterZoneChangedWorkItem *loaded = weakSelf;
        if (loaded == nil) return;
        
        if (![record.recordID.recordName hasPrefix:[OCSPIResolver PFCloudKitFakeRecordNamePrefix]]) {
            [loaded addUpdatedRecord:record];
        }
    };
    
    /*
     __120-[PFCloudKitImporterZoneChangedWorkItem executeImportOperationsAndAccumulateRecordsWithManagedObjectContext:completion:]_block_invoke_3
     weakSelf = sp + 0x100
     */
    operation.recordWithIDWasDeletedBlock = ^(CKRecordID * _Nonnull recordID, CKRecordType  _Nonnull recordType) {
        /*
         recordID = x20
         recordType = x19
         */
        OCCloudKitImporterZoneChangedWorkItem *loaded = weakSelf;
        if (loaded == nil) return;
        [loaded addDeletedRecordID:recordID ofType:recordType];
    };
    
    /*
     __120-[PFCloudKitImporterZoneChangedWorkItem executeImportOperationsAndAccumulateRecordsWithManagedObjectContext:completion:]_block_invoke_4
     weakSelf = sp + 0xe8
     */
    operation.recordZoneChangeTokensUpdatedBlock = ^(CKRecordZoneID * _Nonnull recordZoneID, CKServerChangeToken * _Nullable serverChangeToken, NSData * _Nullable clientChangeTokenData) {
        /*
         recordZoneID = x20
         serverChangeToken = x19
         */
        OCCloudKitImporterZoneChangedWorkItem *loaded = weakSelf;
        if ((loaded == nil) || (serverChangeToken == nil)) return;
        [loaded->_fetchedZoneIDToChangeToken setObject:serverChangeToken forKey:recordZoneID];
        [loaded checkAndApplyChangesIfNeeded:serverChangeToken];
    };
    
    /*
     __120-[PFCloudKitImporterZoneChangedWorkItem executeImportOperationsAndAccumulateRecordsWithManagedObjectContext:completion:]_block_invoke_5
     weakSelf = sp + 0xb0
     */
    operation.recordZoneFetchCompletionBlock = ^(CKRecordZoneID * _Nonnull recordZoneID, CKServerChangeToken * _Nullable serverChangeToken, NSData * _Nullable clientChangeTokenData, BOOL moreComing, NSError * _Nullable recordZoneError) {
        /*
         recordZoneID = x19
         serverChangeToken = x21
         moreComing = x20
         recordZoneError = x22
         */
        // sp + 0x8
        OCCloudKitImporterZoneChangedWorkItem *loaded = weakSelf;
        if (loaded == nil) return;
        
        if (recordZoneError != nil) {
            [loaded->_encounteredErrors addObject:recordZoneError];
            return;
        }
        
        // <+88>
        [loaded->_fetchedZoneIDToChangeToken setObject:serverChangeToken forKey:recordZoneID];
        [loaded->_fetchedZoneIDToMoreComing setObject:@(moreComing) forKey:recordZoneID];
    };
    
    /*
     __120-[PFCloudKitImporterZoneChangedWorkItem executeImportOperationsAndAccumulateRecordsWithManagedObjectContext:completion:]_block_invoke_6
     completion = sp + 0x80
     weakSelf = sp + 0x88
     */
    operation.fetchRecordZoneChangesCompletionBlock = ^(NSError * _Nullable operationError) {
        /*
         self(block) = x20
         operationError = x19
         */
        
        OCCloudKitImporterZoneChangedWorkItem *loaded = weakSelf;
        if (loaded == nil) return;
        [loaded fetchOperationFinishedWithError:operation completion:completion];
    };
    
    // <+1596>
    [database addOperation:operation];
    
    [error release];
    [monitoredCoordinator release];
    [dictionary release];
    [store release];
    [importerOptions release];
    [database release];
}

- (BOOL)updateMetadataForAccumulatedChangesInContext:(NSManagedObjectContext *)managedObjectContext inStore:(NSSQLCore *)store error:(NSError * _Nullable *)error {
    /*
     self = x22
     managedObjectContext = x21
     store = x20
     error = sp + 0x8
     */
    // sp, #0x68
    NSError * _Nullable _error = nil;
    // x25
    for (CKRecordZoneID *zoneID in self->_fetchedZoneIDToChangeToken) {
        // x26
        OCCKRecordZoneMetadata * _Nullable zoneMetadata = [OCCKRecordZoneMetadata zoneMetadataForZoneID:zoneID inDatabaseWithScope:self.options.database.databaseScope forStore:store inContext:managedObjectContext error:&_error];
        if (zoneMetadata == nil) {
            // <+356>
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData+CloudKit: %s(%d): Unable to fetch zone metadata for zone: %@\n%@", __func__, __LINE__, zoneID, _error);
            
            if (_error == nil) {
                os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
                os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            } else if (error != NULL) {
                *error = _error;
            }
            return NO;
        }
        
        // <+224>
        zoneMetadata.currentChangeToken = [self->_fetchedZoneIDToChangeToken objectForKey:zoneID];
    }
    
    BOOL result = [super updateMetadataForAccumulatedChangesInContext:managedObjectContext inStore:store error:&_error];
    
    if (!result) {
        if (_error == nil) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        } else if (error != NULL) {
            *error = _error;
        }
    }
    
    return result;
}

@end
