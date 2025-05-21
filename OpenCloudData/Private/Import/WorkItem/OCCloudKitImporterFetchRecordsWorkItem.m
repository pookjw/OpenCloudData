//
//  OCCloudKitImporterFetchRecordsWorkItem.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/15/25.
//

#import <OpenCloudData/OCCloudKitImporterFetchRecordsWorkItem.h>
#import <OpenCloudData/OCCloudKitMirroringFetchRecordsRequest.h>
#import <OpenCloudData/OCCloudKitSerializer.h>
#import <OpenCloudData/OCSPIResolver.h>
#import <OpenCloudData/Log.h>

@implementation OCCloudKitImporterFetchRecordsWorkItem

- (instancetype)initWithOptions:(OCCloudKitImporterOptions *)options request:(OCCloudKitMirroringImportRequest *)request {
    if (self = [super initWithOptions:options request:request]) {
        _updatedObjectIDs = [[NSMutableArray alloc] init];
        _failedObjectIDsToError = [[NSMutableDictionary alloc] init];
        _recordIDToObjectID = [[NSMutableDictionary alloc] init];
        _operationsToExecute = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)dealloc {
    [_updatedObjectIDs release];
    [_failedObjectIDsToError release];
    [_recordIDToObjectID release];
    [_operationsToExecute release];
    [super dealloc];
}

- (NSString *)description {
    // self = x19
    // x20
    NSMutableString *result = [[NSMutableString alloc] initWithFormat:@"<%@: %p - %@>", NSStringFromClass([self class]), self, self.request];
    [result appendFormat:@" { %@ %@ %@ %@ }", _updatedObjectIDs, _failedObjectIDsToError, _recordIDToObjectID, _operationsToExecute];
    return [result autorelease];
}

- (void)executeImportOperationsAndAccumulateRecordsWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext completion:(void (^)(OCCloudKitMirroringResult * _Nonnull))completion {
    /*
     self = x22
     managedObjectContext = x19
     completion = sp + 0x30
     */
    // sp + 0x8
    OCCloudKitImporterOptions *options = [self.options retain];
    // sp
    CKDatabase *database = [options.database retain];
    // x26
    OCCloudKitMirroringFetchRecordsRequest *request = (OCCloudKitMirroringFetchRecordsRequest *)self.request;
    // sp + 0x10
    OCCloudKitStoreMonitor *monitor = [self.options.monitor retain];
    // sp, #0x190
    __block BOOL succeed = YES;
    // sp, #0x160
    __block NSError * _Nullable error = nil;
    // sp + 0x18
    NSMutableArray<CKRecordID *> *array_1 = [[NSMutableArray alloc] init];
    // x10 / sp + 0x28
    NSMutableArray<CKRecordFieldKey> *array_2 = [[NSMutableArray alloc] init];
    
    /*
     __121-[PFCloudKitImporterFetchRecordsWorkItem executeImportOperationsAndAccumulateRecordsWithManagedObjectContext:completion:]_block_invoke
     monitor = sp + 0x120 = x21 + 0x20
     request = sp + 0x128 = x21 + 0x28
     array_2 = sp + 0x130 = x21 + 0x30
     managedObjectContext = sp + 0x138 = x21 + 0x38
     self = sp + 0x140 = x21 + 0x40
     array_1 = sp + 0x148 = x21 + 0x48
     error = sp + 0x160 = x21 + 0x50
     succeed = sp + 0x158 = x21 + 0x58
     */
    [monitor performBlock:^{
        // self(block) = x21
        // x19
        NSPersistentStoreCoordinator * _Nullable monitoredCoordinator = monitor.monitoredCoordinator;
        // x20
        NSSQLCore * _Nullable store = [monitor retainedMonitoredStore];
        
        if (store == nil) {
            // <+172>
            succeed = NO;
            error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:134407 userInfo:@{
                NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"Request '%@' was cancelled because the store was removed from the coordinator.", request.requestIdentifier]
            }];
            [monitoredCoordinator release];
            return;
        }
        
        // <+84>
        if (request.entityNameToAttributesToFetch.count != 0) {
            // <+112>
            /*
             __121-[PFCloudKitImporterFetchRecordsWorkItem executeImportOperationsAndAccumulateRecordsWithManagedObjectContext:completion:]_block_invoke_2
             array_2 = sp + 0x80
             */
            [request.entityNameToAttributesToFetch enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSArray * _Nonnull obj, BOOL * _Nonnull stop) {
                abort();
            }];
            // <+412>
        } else {
            // <+332>
            // x23
            NSString *configurationName = store.configurationName;
            // x22
            NSSet<CKRecordFieldKey> *recordKeys = [OCCloudKitSerializer newSetOfRecordKeysForEntitiesInConfiguration:configurationName inManagedObjectModel:store.persistentStoreCoordinator.managedObjectModel includeCKAssetsForFileBackedFutures:YES];
            [array_2 addObjectsFromArray:recordKeys.allObjects];
            [recordKeys release];
            // <+412>
        }
        
        // <+412>
        /*
         __121-[PFCloudKitImporterFetchRecordsWorkItem executeImportOperationsAndAccumulateRecordsWithManagedObjectContext:completion:]_block_invoke_4
         request = sp + 0x28
         store = sp + 0x30
         managedObjectContext = sp + 0x38
         self = sp + 0x40
         array_1 = sp + 0x48
         error = sp + 0x50
         succeed = sp + 0x58
         */
        [managedObjectContext performBlockAndWait:^{
            abort();
        }];
        
        [store release];
    }];
    // <+304>
    
    if (!succeed) {
        // <+484>
        if (completion != nil) {
            // x19
            OCCloudKitMirroringResult *result = [self createMirroringResultForRequest:self.request storeIdentifier:monitor.storeIdentifier success:NO madeChanges:NO error:error];
            completion(result);
            [result release];
        }
        
        // <+1396>
        [error release];
        error = nil;
        [array_1 release];
        [array_2 release];
        [monitor release];
        [options release];
        [database release];
        return;
    }
    
    // <+320>
    // x21
    NSUInteger perOperationObjectThreshold = ((OCCloudKitMirroringFetchRecordsRequest *)self.request).perOperationObjectThreshold;
    // x19
    NSMutableArray<NSArray<CKRecordID *> *> *array_3 = [[NSMutableArray alloc] init];
    
    if (perOperationObjectThreshold <= array_1.count) {
        // <+564>
        if (array_1.count != 0) {
            [array_3 addObject:array_1];
        }
        // <+588>
    } else {
        // <+396>
        NSUInteger x23 = 0;
        NSUInteger x20 = 0;
        NSUInteger x24;
        
        do {
            x24 = x20 + perOperationObjectThreshold;
            NSUInteger len = perOperationObjectThreshold;
            if (x24 > array_1.count) {
                len = x23 + array_1.count;
            }
            
            [array_3 addObject:[array_1 subarrayWithRange:NSMakeRange(x20, len)]];
            x23 -= perOperationObjectThreshold;
            x20 = x24;
        } while (x24 < array_1.count);
        // <+588>
    }
    
    // <+588>
    // sp + 0x20
    [array_3 autorelease];
    
    // x21
    for (NSArray<CKRecordID *> *chunk in array_3) {
        // original : getCloudKitCKFetchRecordsOperationClass
        // x27
        CKFetchRecordsOperation *operation = [[CKFetchRecordsOperation alloc] init];
        // x19
        CKOperationID operationID = operation.operationID;
        
        if (request.options != nil) {
            [request.options applyToOperation:operation];
        }
        
        operation.recordIDs = chunk;
        operation.desiredKeys = array_2;
        
        /*
         __121-[PFCloudKitImporterFetchRecordsWorkItem executeImportOperationsAndAccumulateRecordsWithManagedObjectContext:completion:]_block_invoke_5
         request = sp + 0xb8 = x23 + 0x20
         */
        operation.perRecordProgressBlock = ^(CKRecordID * _Nonnull recordID, double progress) {
            /*
             self(block) = x23
             recordID = x21
             progress = d8
             */
            os_log_with_type(_OCLogGetLogStream(0x11), OS_LOG_TYPE_DEFAULT, "OpenCloudData+CloudKit: %s(%d): %@ '%@': %@ %f", __func__, __LINE__, NSStringFromClass([request class]), request.requestIdentifier, recordID, progress);
        };
        
        // sp + 0x1b0
        __weak OCCloudKitImporterFetchRecordsWorkItem *weakSelf = self;
        /*
         __121-[PFCloudKitImporterFetchRecordsWorkItem executeImportOperationsAndAccumulateRecordsWithManagedObjectContext:completion:]_block_invoke.22
         weakSelf = sp + 0x90
         */
        operation.perRecordCompletionBlock = ^(CKRecord * _Nullable record, CKRecordID * _Nullable recordID, NSError * _Nullable error) {
            [weakSelf fetchFinishedForRecord:record withID:recordID error:error];
        };
        
        /*
         __121-[PFCloudKitImporterFetchRecordsWorkItem executeImportOperationsAndAccumulateRecordsWithManagedObjectContext:completion:]_block_invoke_2.24
         operationID = sp + 0x58 = x19 + 0x20
         completion = sp + 0x60 = x19 + 0x28
         weakSelf = sp + 0x68 = x19 + 0x30
         */
        operation.fetchRecordsCompletionBlock = ^(NSDictionary<CKRecordID *,CKRecord *> * _Nullable recordsByRecordID, NSError * _Nullable operationError) {
            /*
             self(block) = x19
             operationError = x21
             */
            // inline 같음
            
            @autoreleasepool {
                // sp + 0x28
                OCCloudKitImporterFetchRecordsWorkItem *loaded = weakSelf;
                if (loaded == nil) return;
                /*
                 operationID = x22
                 completion = x20
                 */
                
                [loaded->_operationsToExecute removeObjectForKey:operationID];
                if (operationError != nil) {
                    if (([operationError.domain isEqualToString:CKErrorDomain]) && (operationError.code == CKErrorPartialFailure)) {
                        // original : getCloudKitCKPartialErrorsByItemIDKey
                        // x22
                        NSDictionary<CKRecordID *, NSError *> *errorsByItemID = error.userInfo[CKPartialErrorsByItemIDKey];
                        // x27
                        for (CKRecordID *recordID in errorsByItemID) {
                            // x28
                            NSManagedObjectID *objectID = [self->_recordIDToObjectID objectForKey:recordID];
                            if (objectID == nil) {
                                // <+392>
                                os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Fetch operation was notified via partial failure about a recordID that doesn't have an objectID: %@ - %@\n", recordID, operationError);
                                os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Fetch operation was notified via partial failure about a recordID that doesn't have an objectID: %@ - %@\n", recordID, operationError);
                            } else {
                                // _failedObjectIDsToError = x20
                                NSError *error = [errorsByItemID objectForKey:recordID];
                                [loaded->_failedObjectIDsToError setObject:error forKey:objectID];
                            }
                        }
                        
                        [loaded checkAndApplyChangesIfNeeded:nil];
                        // <+676>
                    } else {
                        // <+636>
                        [loaded->_encounteredErrors addObject:operationError];
                        // <+676>
                    }
                } else {
                    // <+664>
                    [loaded checkAndApplyChangesIfNeeded:nil];
                    // <+676>
                }
                
                // <+676>
                if (loaded->_operationsToExecute.count != 0) {
                    // <+696>
                    [loaded.options.database addOperation:loaded->_operationsToExecute.allValues[0]];
                    // <+764>
                } else {
                    // <+748>
                    [loaded fetchOperationFinishedWithError:nil completion:completion];
                }
            }
        };
        
        // <+960>
        [self->_operationsToExecute setObject:operation forKey:operationID];
        [operation release];
    }
    
    // <+1060>
    if (self->_operationsToExecute.count != 0) {
        [options.database addOperation:self->_operationsToExecute.allValues[0]];
        // <+1396>
    } else {
        os_log_with_type(_OCLogGetLogStream(0x11), OS_LOG_TYPE_DEFAULT, "OpenCloudData+CloudKit: %s(%d): Fetch records request did not match any records in the store: %@\n%@", __func__, __LINE__, request, request.objectIDsToFetch);
        
        // <+1336>
        // x19
        OCCloudKitMirroringResult *result = [self createMirroringResultForRequest:self.request storeIdentifier:monitor.storeIdentifier success:YES madeChanges:NO error:nil];
        // nil 확인 없음
        completion(result);
        [result release];
        // <+1396>
    }
    
    // <+1396>
    [error release];
    error = nil;
    [array_1 release];
    [array_2 release];
    [monitor release];
    [options release];
    [database release];
}

- (void)fetchFinishedForRecord:(CKRecord *)record withID:(CKRecordID *)recordID error:(NSError *)error {
    // inlined from __121-[PFCloudKitImporterFetchRecordsWorkItem executeImportOperationsAndAccumulateRecordsWithManagedObjectContext:completion:]_block_invoke.22
    /*
     record = x21
     recordID = x19
     error = x20
     */
    // self = sp + 0x8
    
    if (error != nil) {
        os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData+CloudKit: %s(%d): %@ encountered error while fetching record %@\n%@", __func__, __LINE__, self.request, recordID, error);
        // <+252>
        if (recordID != nil) {
            NSManagedObjectID *objectID = [self->_recordIDToObjectID objectForKey:recordID];
            if (objectID == nil) {
                // <+404>
                os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: Fetch operation was notified about a recordID that finished with an error that doesn't have an objectID: %@ - %@", recordID, error);
            }
            [self->_failedObjectIDsToError setObject:error forKey:objectID];
        }
        return;
    }
    
    // <+312>
    if (![recordID.recordName hasPrefix:[OCSPIResolver PFCloudKitFakeRecordNamePrefix]]) {
        // <+348>
        NSManagedObjectID *objectID = [self->_recordIDToObjectID objectForKey:recordID];
        if (objectID == nil) {
            // <+524>
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Fetch operation was notified about an updated recordID that finished that doesn't have an objectID: %@\n", recordID);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Fetch operation was notified about an updated recordID that finished that doesn't have an objectID: %@\n", recordID);
        } else {
            [self->_updatedObjectIDs addObject:objectID];
        }
        
        // <+576>
        [self addUpdatedRecord:record];
    }
}

@end
