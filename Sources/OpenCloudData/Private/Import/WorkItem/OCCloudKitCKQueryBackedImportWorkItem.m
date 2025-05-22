//
//  OCCloudKitCKQueryBackedImportWorkItem.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/15/25.
//

#import "OpenCloudData/Private/Import/WorkItem/OCCloudKitCKQueryBackedImportWorkItem.h"
#import "OpenCloudData/Private/OCCloudKitSerializer.h"
#import "OpenCloudData/Private/Model/OCCKRecordZoneMetadata.h"
#import "OpenCloudData/SPI/OCSPIResolver.h"
#import "OpenCloudData/Private/Log.h"

@implementation OCCloudKitCKQueryBackedImportWorkItem

- (instancetype)initForRecordType:(CKRecordType)recordType withOptions:(OCCloudKitImporterOptions *)options request:(OCCloudKitMirroringImportRequest *)request {
    /*
     recordType = x21
     options = x20
     */
    if (self = [super initWithOptions:options request:request]) {
        _recordType = [recordType retain];
        _zoneIDToQuery = [OCCloudKitSerializer defaultRecordZoneIDForDatabaseScope:options.options.databaseScope];
    }
    
    return self;
}

- (void)dealloc {
    [_recordType release];
    [_maxModificationDate release];
    _maxModificationDate = nil;
    [_queryCursor release];
    _queryCursor = nil;
    [_zoneIDToQuery release];
    [super dealloc];
}

- (NSString *)description {
    // self = x19
    // x20
    NSMutableString *result = [[NSMutableString alloc] initWithString:[super description]];
    /*
     x9 = _zoneIDToQuery
     x10 = _recordType
     x8 = _maxModificationDate ?? @"nil"
     */
    
    [result appendFormat:@" { %@:%@:%@ }", _zoneIDToQuery, _recordType, (_maxModificationDate == nil) ? @"nil" : _maxModificationDate];
    
    return [result autorelease];
}

- (void)addUpdatedRecord:(CKRecord *)record {
    /*
     self = x20
     record = x19
     */
    if (self->_encounteredErrors.count == 0) {
        if (self->_maxModificationDate == nil) {
            self->_maxModificationDate = [record.modificationDate retain];
        } else {
            if ([self->_maxModificationDate compare:record.modificationDate] == NSOrderedAscending) {
                [self->_maxModificationDate release];
                self->_maxModificationDate = [record.modificationDate retain];
            }
        }
    }
    
    [super addUpdatedRecord:record];
}

- (BOOL)applyAccumulatedChangesToStore:(NSSQLCore *)store inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext withStoreMonitor:(OCCloudKitStoreMonitor *)monitor madeChanges:(BOOL *)madeChanges error:(NSError * _Nullable *)error {
    /*
     self = x20
     store = x22
     managedObjectContext = x21
     monitor = x23
     error = x19
     */
    // sp, #0x80
    __block NSError * _Nullable _error = nil;
    // sp, #0x60
    __block BOOL _succeed = [super applyAccumulatedChangesToStore:store inManagedObjectContext:managedObjectContext withStoreMonitor:monitor madeChanges:madeChanges error:&_error];
    
    @try {
        if (!_succeed) {
            if (_error != nil) {
                if (error != NULL) {
                    *error = [[_error retain] autorelease];
                }
            } else {
                os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
                os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            }
            _error = nil;
            return NO;
        }
        
        // <+184>
        if (monitor.declaredDead) {
            return YES;
        }
        
        // <+196>
        /*
         __130-[PFCloudKitCKQueryBackedImportWorkItem applyAccumulatedChangesToStore:inManagedObjectContext:withStoreMonitor:madeChanges:error:]_block_invoke
         self = sp + 0x28 = x19 + 0x20
         store = sp + 0x30 = x19 + 0x28
         managedObjectContext = sp + 0x38 = x19 + 0x30
         _error = sp + 0x40 = x19 + 0x38
         _succeed = sp + 0x48 = x19 + 0x40
         */
        [managedObjectContext performBlockAndWait:^{
            // self(block) = x19
            @try {
                OCCKRecordZoneMetadata * _Nullable zoneMetadata = [OCCKRecordZoneMetadata zoneMetadataForZoneID:self.zoneIDToQuery inDatabaseWithScope:self.options.database.databaseScope forStore:store inContext:managedObjectContext error:&_error];
                if (zoneMetadata == nil) {
                    _succeed = NO;
                    [_error retain];
                    return;
                }
                
                // <+120>
                OCCKRecordZoneQuery * _Nullable zoneQuery = [OCCKRecordZoneQuery zoneQueryForRecordType:self->_recordType inZone:zoneMetadata inStore:store managedObjectContext:managedObjectContext error:&_error];
                if (zoneQuery == nil) {
                    _succeed = NO;
                    [_error retain];
                    return;
                }
                
                zoneQuery.mostRecentRecordModificationDate = self->_maxModificationDate;
                
                _succeed = [managedObjectContext save:&_error];
                if (!_succeed) {
                    [_error retain];
                }
            } @catch (NSException *exception) {
                _succeed = NO;
                _error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:134421 userInfo:@{
                    NSLocalizedFailureReasonErrorKey: @"Import failed because applying the zone query metadata changes hit an unhandled exception.",
                    @"NSUnderlyingException": exception
                }];
            }
        }];
    } @catch (NSException *exception) {
        os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: %@ - Exception thrown during query import: %@\n", self, exception);
        os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: %@ - Exception thrown during query import: %@\n", self, exception);
    } @finally {
        if (!_succeed) {
            if (_error != nil) {
                if (error != NULL) {
                    *error = [[_error retain] autorelease];
                }
            } else {
                os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
                os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            }
            _error = nil;
            return NO;
        }
        
        return YES;
    }
}

- (BOOL)commitMetadataChangesWithContext:(NSManagedObjectContext *)managedObjectContext forStore:(NSSQLCore *)store error:(NSError * _Nullable *)error {
    /*
     self = x22
     managedObjectContext = x21
     store = x20
     error = x19
     */
    
    // sp, #0x58
    NSError * _Nullable _error = nil;
    
    // x23
    OCCKRecordZoneMetadata * _Nullable zoneMetadata = [OCCKRecordZoneMetadata zoneMetadataForZoneID:self->_zoneIDToQuery inDatabaseWithScope:self.options.database.databaseScope forStore:store inContext:managedObjectContext error:&_error];
    
    if (zoneMetadata == nil) {
        if (_error != nil) {
            if (error != NULL) {
                *error = _error;
            }
        } else {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        }
        return NO;
    }
    
    // <+136>
    zoneMetadata.lastFetchDate = [NSDate date];
    // x24
    OCCKRecordZoneQuery * _Nullable zoneQuery = [OCCKRecordZoneQuery zoneQueryForRecordType:self->_recordType inZone:zoneMetadata inStore:store managedObjectContext:managedObjectContext error:&_error];
    if (zoneQuery == nil) {
        if (_error != nil) {
            if (error != NULL) {
                *error = _error;
            }
        } else {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        }
        return NO;
    }
    
    zoneQuery.queryCursor = self->_queryCursor;
    zoneQuery.lastFetchDate = [NSDate date];
    zoneMetadata.needsImport = NO;
    
    for (OCCKRecordZoneQuery *_query in zoneMetadata.queries) {
        if (_query.queryCursor != nil) {
            zoneMetadata.needsImport = YES;
            break;
        }
    }
    
    BOOL result = [super commitMetadataChangesWithContext:managedObjectContext forStore:store error:&_error];
    if (!result) {
        if (_error != nil) {
            if (error != NULL) {
                *error = _error;
            }
        } else {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        }
        return NO;
    }
    
    return YES;
}

- (void)executeImportOperationsAndAccumulateRecordsWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext completion:(void (^)(OCCloudKitMirroringResult * _Nonnull))completion {
    /*
     self = x20
     completion = x19
     */
    
    // x21
    NSError * _Nullable error = nil;
    // x22
    CKQueryOperation * _Nullable operation = [self newCKQueryOperationFromMetadataInManagedObjectContext:managedObjectContext error:&error];
    
    // operation = x22
    if (operation != nil) {
        // <+412>
        // sp, #0x60
        __weak OCCloudKitCKQueryBackedImportWorkItem *weakSelf = self;
        [self.request.options applyToOperation:operation];
        
        /*
         __120-[PFCloudKitCKQueryBackedImportWorkItem executeImportOperationsAndAccumulateRecordsWithManagedObjectContext:completion:]_block_invoke
         weakSelf = sp + 0x58
         */
        operation.recordMatchedBlock = ^(CKRecordID *recordID, CKRecord * _Nullable record, NSError * _Nullable error) {
            [weakSelf addUpdatedRecord:record];
        };
        
        /*
         __120-[PFCloudKitCKQueryBackedImportWorkItem executeImportOperationsAndAccumulateRecordsWithManagedObjectContext:completion:]_block_invoke_2
         completion = sp + 0x28
         weakSelf = sp + 0x30
         */
        operation.queryCompletionBlock = ^(CKQueryCursor * _Nullable cursor, NSError * _Nullable operationError) {
            /*
             self(block) = x19
             cursor = x21
             operationError = x20
             */
            
            // sp + 0x8
            OCCloudKitCKQueryBackedImportWorkItem * _Nullable loaded = [weakSelf retain];
            if (loaded == nil) {
                return;
            }
            [loaded queryOperationFinishedWithCursor:cursor error:error completion:completion];
            [loaded release];
        };
        
        [self.options.database addOperation:operation];
        [operation release];
    } else {
        // <+616>
        // x20
        OCCloudKitMirroringResult *result = [[OCCloudKitMirroringResult alloc] initWithRequest:self.request storeIdentifier:self.options.monitor.storeIdentifier success:NO madeChanges:NO error:error];
        completion(result);
        [result release];
    }
}

- (CKQueryOperation *)newCKQueryOperationFromMetadataInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct)) {
    // inlined from -[PFCloudKitCKQueryBackedImportWorkItem executeImportOperationsAndAccumulateRecordsWithManagedObjectContext:completion:] <+56>~<+408>
    
    // x29 - 0xa0
    __block NSError * _Nullable _error = nil;
    // x29 - 0xc0
    __block BOOL _succeed = YES;
    // sp + 0xb0
    __block CKQueryOperation * _Nullable operation = nil;
    
    OCCloudKitStoreMonitor *monitor = self.options.monitor;
    /*
     __101-[PFCloudKitCKQueryBackedImportWorkItem newCKQueryOperationFromMetadataInManagedObjectContext:error:]_block_invoke
     monitor = sp, #0x80 = x20 + 0x20
     managedObjectContext = sp, #0x88 = x20 + 0x28
     self = sp + 0x90 = x20 + 0x30
     operation = sp + 0x98 = x20 + 0x38
     _succeed = sp + 0xa0 = x20 + 0x40
     _error = sp + 0xa8 = x20 + 0x48
     */
    [monitor performBlock:^{
        // self(block) = x20
        // x19
        NSSQLCore * _Nullable store = [monitor retainedMonitoredStore];
        
        if (store == nil) {
            _succeed = NO;
            _error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:134407 userInfo:@{
                NSLocalizedFailureErrorKey: [NSString stringWithFormat:@"Request '%@' was cancelled because the store was removed from the coordinator.", self.request.requestIdentifier]
            }];
            return;
        }
        
        // 안 쓰는듯?
        // x21
        NSPersistentStoreCoordinator *monitoredCoordinator = monitor.monitoredCoordinator;
        
        /*
         __101-[PFCloudKitCKQueryBackedImportWorkItem newCKQueryOperationFromMetadataInManagedObjectContext:error:]_block_invoke_2
         self = sp + 0x28 = x19 + 0x20
         store = sp + 0x30 = x19 + 0x28
         managedObjectContext = sp + 0x38 = x19 + 0x30
         operation = sp + 0x40 = x19 + 0x38
         _succeed = sp + 0x48 = x19 + 0x40
         _error = sp + 0x50 = x19 + 0x48
         */
        [managedObjectContext performBlockAndWait:^{
            // self(block) = x19
            
            @try {
                // sp
                NSError * _Nullable __error = nil;
                // x21
                CKRecordZoneID *zoneIDToQuery = self->_zoneIDToQuery;
                
                OCCKRecordZoneMetadata * _Nullable zoneMetadata = [OCCKRecordZoneMetadata zoneMetadataForZoneID:zoneIDToQuery inDatabaseWithScope:self.options.options.databaseScope forStore:store inContext:managedObjectContext error:&__error];
                
                if (zoneMetadata == nil) {
                    _succeed = NO;
                    _error = [__error retain];
                    return;
                }
                
                // x21
                OCCKRecordZoneQuery * _Nullable zoneQuery = [OCCKRecordZoneQuery zoneQueryForRecordType:self->_recordType inZone:zoneMetadata inStore:store managedObjectContext:managedObjectContext error:&__error];
                
                if (zoneQuery == nil) {
                    _succeed = NO;
                    _error = [__error retain];
                    return;
                }
                
                // x20
                CKQuery *ckQuery = [zoneQuery createQueryForUpdatingRecords];
                // original : getCloudKitCKQueryOperationClass
                operation = [[CKQueryOperation alloc] initWithQuery:ckQuery];
                operation.zoneID = self->_zoneIDToQuery;
                operation.cursor = zoneQuery.queryCursor;
                [ckQuery release];
            } @catch (NSException *exception) {
                _succeed = NO;
                _error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:134421 userInfo:@{
                    @"NSUnderlyingException": exception,
                    NSLocalizedFailureReasonErrorKey:  @"Import failed because creating the zone query hit an unhandled exception."
                }];
            }
        }];
        
        [store release];
    }];
    
    if (_succeed) {
        error = nil;
    } else {
        // x21 = _error
        // inline이라 null 확인 없음
        *error = [[_error retain] autorelease];
        if (_error == nil) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        }
        
        [operation release];
        operation = nil;
    }
    
    [_error release];
    _error = nil;
    return operation;
}

- (void)queryOperationFinishedWithCursor:(CKQueryCursor *)cursor error:(NSError *)error completion:(void (^)(OCCloudKitMirroringResult * _Nonnull))completion {
    // inlined from __120-[PFCloudKitCKQueryBackedImportWorkItem executeImportOperationsAndAccumulateRecordsWithManagedObjectContext:completion:]_block_invoke_2
    os_log_with_type(_OCLogGetLogStream(0x11), OS_LOG_TYPE_DEFAULT, "OpenCloudData+CloudKit: %s(%d): %@: Finished with cursor: %@\n%@", __func__, __LINE__, self, cursor, error);
    
    if (error != nil) {
        // <+264>
        if (([error.domain isEqualToString:CKErrorDomain]) && (error.code == CKErrorUnknownItem)) {
            // <+324>
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData+CloudKit: %s(%d): %@: Failed due to querying for an unknown record type (not fatal, schema needs to be initialized): %@", __func__, __LINE__, self, error);
            error = nil;
        } else {
            // <+516>
            // nop
        }
    } else {
        // <+480>
        if (cursor != nil) {
            // 기본값 release 안해줌
            self->_queryCursor = [cursor retain];
        }
    }
    
    [self fetchOperationFinishedWithError:error completion:completion];
}

- (BOOL)updateMetadataForAccumulatedChangesInContext:(NSManagedObjectContext *)managedObjectContext inStore:(NSSQLCore *)store error:(NSError * _Nullable *)error {
    /*
     self = x22
     managedObjectContext = x21
     store = x20
     error = x19
     */
    
    // sp, #0x18
    NSError * _Nullable _error = nil;
    // x23
    OCCKRecordZoneMetadata * _Nullable zoneMetadata = [OCCKRecordZoneMetadata zoneMetadataForZoneID:self->_zoneIDToQuery inDatabaseWithScope:self.options.options.databaseScope forStore:store inContext:managedObjectContext error:&_error];
    if (zoneMetadata == nil) {
        if (_error != nil) {
            if (error != NULL) {
                *error = [[_error retain] autorelease];
            }
        } else {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        }
        _error = nil;
        return NO;
    }
    
    // x24
    OCCKRecordZoneQuery * _Nullable zoneQuery = [OCCKRecordZoneQuery zoneQueryForRecordType:self->_recordType inZone:zoneMetadata inStore:store managedObjectContext:managedObjectContext error:&_error];
    if (zoneQuery == nil) {
        if (_error != nil) {
            if (error != NULL) {
                *error = [[_error retain] autorelease];
            }
        } else {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        }
        _error = nil;
        return NO;
    }
    
    zoneQuery.queryCursor = self->_queryCursor;
    zoneQuery.lastFetchDate = zoneMetadata.lastFetchDate;
    
    // 원래는 error를 주입하고 result가 NO이면 _error를 error에 주입하고, _error가 nil이면 Log를 출력하는 이상한 구조다.
    return [super updateMetadataForAccumulatedChangesInContext:managedObjectContext inStore:store error:error];
}

@end
