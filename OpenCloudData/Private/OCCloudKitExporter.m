//
//  OCCloudKitExporter.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/4/25.
//

#import <OpenCloudData/OCCloudKitExporter.h>
#import <OpenCloudData/Log.h>
#import <OpenCloudData/OCCloudKitSerializer.h>
#import <OpenCloudData/OCCKRecordZoneMetadata.h>
#import <objc/runtime.h>
@import ellekit;

@implementation OCCloudKitExporter

- (instancetype)initWithOptions:(OCCloudKitExporterOptions *)options request:(__kindof OCCloudKitMirroringRequest *)request monitor:(OCCloudKitStoreMonitor *)monitor workQueue:(dispatch_queue_t)workQueue {
    /*
     options = x22
     request = x20
     monitor = x23
     workQueue = x21
     self = x19
     */
    if (self = [super init]) {
        _request = [request retain];
        _options = [options copy];
        _workQueue = workQueue;
        dispatch_retain(workQueue);
        _delegate = nil;
        _exportContext = [[OCCloudKitExportContext alloc] initWithOptions:_options];
        _operationIDToResult = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)dealloc {
    [_monitor release];
    [_exportContext release];
    
    dispatch_queue_t workQueue = _workQueue;
    if (workQueue != nil) {
        dispatch_release(workQueue);
    }
    
    [_options release];
    [_request release];
    [_operationIDToResult release];
    [_exportCompletionBlock release];
    
    [super dealloc];
}

- (void)exportIfNecessaryWithCompletion:(void (^)(OCCloudKitMirroringResult * _Nonnull))completion {
    /*
     self = x19
     completion = x20
     */
    
    if (self->_exportCompletionBlock != nil) {
        os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: exportIfNecessaryWithCompletion invoked multiple times.\n");
        os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: exportIfNecessaryWithCompletion invoked multiple times.\n");
        
        NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:134410 userInfo:@{NSLocalizedFailureReasonErrorKey: @"exportIfNecessaryWithCompletion called re-entrantly, this is a serious bug. Please file a feedback report."}];
        
        NSString * _Nullable storeIdentifier;
        {
            OCCloudKitStoreMonitor * _Nullable monitor = self->_monitor;
            if (monitor == nil) {
                storeIdentifier = nil;
            } else {
                storeIdentifier = monitor->_storeIdentifier;
            }
        }
        OCCloudKitMirroringResult *result = [[OCCloudKitMirroringResult alloc] initWithRequest:_request storeIdentifier:storeIdentifier success:NO madeChanges:NO error:error];
        completion(result);
        [result release];
        return;
    }
    
    _exportCompletionBlock = [completion copy];
    [self checkForZonesNeedingExport];
}

- (void)checkForZonesNeedingExport {
    // self = x21
    
    // x19
    NSMutableArray<CKRecordZoneID *> *zoneIDs = [[NSMutableArray alloc] init];
    // x20
    OCCloudKitStoreMonitor *monitor = [_monitor retain];
    // x22
    OCCloudKitMirroringRequest * _Nullable request = _request;
    
    // sp + 0xb8
    __block BOOL succeed = YES;
    // sp, #0x88
    __block NSError * _Nullable error = nil;
    // sp, #0x58
    __block CKModifyRecordZonesOperation * _Nullable operation = nil;
    
    if (request != nil) {
        CKSchedulerActivity *schedulerActivity = request->_schedulerActivity;
        if (schedulerActivity.shouldDefer || request->_deferredByBackgroundTimeout) {
            succeed = NO;
            error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:134419 userInfo:@{NSLocalizedFailureReasonErrorKey: @"The request was aborted because it was deferred by the system."}];
        }
    } else {
        /*
         __48-[PFCloudKitExporter checkForZonesNeedingExport]_block_invoke
         monitor = sp + 0x20 = x19 + 0x20
         self = sp + 0x28 = x19 + 0x28
         zoneIDs = sp + 0x30 = x19 + 0x30
         error = sp + 0x38 = x19 + 0x38
         succeed = sp + 0x40 = x19 + 0x40
         operation = sp + 0x48 = x19 + 0x48
         */
        [_monitor performBlock:^{
            __kindof NSPersistentStore * _Nullable monitoredStore = [self->_monitor retainedMonitoredStore];
            if (monitoredStore == nil) {
                succeed = NO;
                error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:134407 userInfo:@{NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"Request '%@' was cancelled because the store was removed from the coordinator.", self->_request.requestIdentifier]}];
                return;
            }
            
            // self = x19
            // monitoredStore = x20
            
            // x21
            NSPersistentStoreCoordinator * _Nullable monitoredCoordinator;
            {
                OCCloudKitStoreMonitor * _Nullable monitor = self->_monitor;
                if (monitor == nil) {
                    monitoredCoordinator = nil;
                } else {
                    monitoredCoordinator = [monitor->_monitoredCoordinator retain];
                }
            }
            
            // x22
            NSManagedObjectContext *backgroundContextForMonitoredCoordinator = [monitor newBackgroundContextForMonitoredCoordinator];
            // original : NSCloudKitMirroringDelegateExportContextName
#warning TODO 바꿔도 되나?
            backgroundContextForMonitoredCoordinator.transactionAuthor = @"NSCloudKitMirroringDelegate.export";
            
            /*
             __48-[PFCloudKitExporter checkForZonesNeedingExport]_block_invoke_2
             monitoredStore = sp + 0x30 = x19 + 0x20
             backgroundContextForMonitoredCoordinator = sp + 0x38 = x19 + 0x28
             self = sp + 0x40 = x19 + 0x30
             zoneIDs = sp + 0x48 = x19 + 0x38
             error = sp + 0x50 = x19 + 0x40
             succeed = sp + 0x58 = x19 + 0x48
             operation = sp + 0x60 = x19 + 0x50
             */
            [backgroundContextForMonitoredCoordinator performBlockAndWait:^{
                @try {
                    const void *image = MSGetImageByName("/System/Library/Frameworks/CoreData.framework/CoreData");
                    const void *symbol = MSFindSymbol(image, "+[_PFRoutines _isInMemoryStore:]");
                    BOOL isInMemoryStore = ((BOOL (*)(Class, id))symbol)(objc_lookUpClass("_PFRoutines"), monitoredStore);
                    
                    // self = sp + 0x10
                    
                    if (!isInMemoryStore) {
                        // sp + 0x80
                        NSError * _Nullable _error = nil;
                        
                        // x20
                        NSManagedObjectContext *context = backgroundContextForMonitoredCoordinator;
                        BOOL result = [context setQueryGenerationFromToken:[NSQueryGenerationToken currentQueryGenerationToken] error:&_error];
                        if (!result) {
                            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData+CloudKit: %s(%d): %@: Unable to set query generation on moc: %@", __func__, __LINE__, self, _error);
                        }
                    }
                    
                    // x21
                    CKDatabaseScope databaseScope;
                    {
                        if (self == nil) {
                            databaseScope = 0;
                        } else {
                            OCCloudKitExporterOptions * _Nullable options = self->_options;
                            if (options == nil) {
                                databaseScope = 0;
                            } else {
                                databaseScope = options->_database.databaseScope;
                            }
                        }
                    }
                    
                    if (databaseScope == CKDatabaseScopePublic) {
                        // x22
                        CKRecordZoneID *zoneID = [OCCloudKitSerializer defaultRecordZoneIDForDatabaseScope:databaseScope];
                        OCCKRecordZoneMetadata * _Nullable metadata = [OCCKRecordZoneMetadata zoneMetadataForZoneID:zoneID inDatabaseWithScope:databaseScope forStore:monitoredStore inContext:backgroundContextForMonitoredCoordinator error:&error];
                        
                        if (metadata == nil) {
                            succeed = NO;
                            [error retain];
                        }
                        
                        [zoneID release];
                        
                        if (!succeed) {
                            return;
                        }
                        
                        // x20
                        NSFetchRequest<OCCKRecordZoneMetadata *> *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[OCCKRecordZoneMetadata entityPath]];
                        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"hasRecordZoneNum = NO AND database.databaseScopeNum = %@", @(databaseScope)];
                        
                        NSUInteger fetchLimit;
                        {
                            OCCloudKitExporterOptions * _Nullable options = self->_options;
                            if (options == nil) {
                                fetchLimit = 0;
                            } else {
                                fetchLimit = options->_perOperationObjectThreshold;
                            }
                        }
                        
                        fetchRequest.returnsObjectsAsFaults = NO;
                        fetchRequest.affectedStores = @[monitoredStore];
                        
                        // x21
                        NSArray<OCCKRecordZoneMetadata *> * _Nullable fetchedMetadataArray = [backgroundContextForMonitoredCoordinator executeFetchRequest:fetchRequest error:&error];
                        
                        if (fetchedMetadataArray == nil) {
                            succeed = NO;
                            [error retain];
                            return;
                        }
                        
                        if (fetchedMetadataArray.count == 0) {
                            return;
                        }
                        
                        // sp, #0x8
                        NSMutableArray<CKRecordZone *> *defaultRecordZones = [[NSMutableArray alloc] init];
                        
                        // x25
                        for (OCCKRecordZoneMetadata *metadata in fetchedMetadataArray) @autoreleasepool {
                            // x24
                            CKRecordZoneID *zoneID = [metadata createRecordZoneID];
                            // x26
                            NSString *ownerName = zoneID.ownerName;
                            
                            // original : getCloudKitCKCurrentUserDefaultName, getCloudKitCKRecordZoneDefaultName
                            if ([ownerName isEqualToString:CKCurrentUserDefaultName] && [zoneID.zoneName isEqualToString:CKRecordZoneDefaultName]) {
                                metadata.hasRecordZone = YES;
                                metadata.supportsAtomicChanges = YES;
                                [zoneID release];
                                continue;
                            }
                            
                            // x25
                            NSString *ckOwnerName = metadata.ckOwnerName;
                            // original : getCloudKitCKCurrentUserDefaultName
                            if ([ckOwnerName isEqualToString:CKCurrentUserDefaultName]) {
                                // original : getCloudKitCKRecordZoneClass
                                CKRecordZone *recordZone = [[CKRecordZone alloc] initWithZoneID:zoneID];
                                [defaultRecordZones addObject:recordZone];
                                [recordZone release];
                                [zoneID release];
                                continue;
                            }
                            
                            [zoneIDs addObject:zoneID];
                            [zoneID release];
                        }
                        
                        if (defaultRecordZones.count != 0) {
                            operation = [[CKModifyRecordZonesOperation alloc] initWithRecordZonesToSave:defaultRecordZones recordZoneIDsToDelete:nil];
                            
                            if (self->_request.options != nil) {
                                [self->_request.options applyToOperation:operation];
                            }
                            
                            __weak OCCloudKitExporter *weakSelf = self;
                            
                            /*
                             __48-[PFCloudKitExporter checkForZonesNeedingExport]_block_invoke_18
                             weakSelf = sp + 0x38 = x0 + 0x20
                             */
                            operation.modifyRecordZonesCompletionBlock = ^(NSArray<CKRecordZone *> * _Nullable savedRecordZones, NSArray<CKRecordZoneID *> * _Nullable deletedRecordZoneIDs, NSError * _Nullable operationError) {
                                /*
                                 savedRecordZones = x22
                                 deletedRecordZoneIDs = x21
                                 operationError = x20
                                 */
                                // x19
                                OCCloudKitExporter *loaded = weakSelf;
                                if (loaded == nil) return;
                                
                                /*
                                 __48-[PFCloudKitExporter checkForZonesNeedingExport]_block_invoke_2.19
                                 self = sp + 0x20 = x22 + 0x20
                                 savedRecordZones = sp + 0x28 = x22 + 0x28
                                 deletedRecordZoneIDs = sp + 0x30 = x22 + 0x30
                                 operationError = sp + 0x38 = x22 + 0x38
                                 */
                                dispatch_async(loaded->_workQueue, ^{
                                    // x22 = self
                                    // x19
                                    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
                                    
                                    // x20
                                    OCCloudKitExporter *loaded_2 = loaded;
                                    if (self == nil) {
                                        [pool drain];
                                        return;
                                    }
                                    
                                    if (operationError != nil) {
                                        NSString * _Nullable storeIdentifier;
                                        {
                                            OCCloudKitStoreMonitor * _Nullable monitor = loaded_2->_monitor;
                                            if (monitor == nil) {
                                                storeIdentifier = nil;
                                            } else {
                                                storeIdentifier = monitor->_storeIdentifier;
                                            }
                                        }
                                        
                                        // x21
                                        OCCloudKitMirroringResult *result = [[OCCloudKitMirroringResult alloc] initWithRequest:loaded_2->_request storeIdentifier:storeIdentifier success:NO madeChanges:NO error:operationError];
                                        [loaded_2 finishExportWithResult:result];
                                        [result release];
                                    } else {
                                        NSError * _Nullable _error = nil;
                                        BOOL result = [self updateMetadataForSavedZones:savedRecordZones error:&_error];
                                        if (result) {
                                            [self checkForZonesNeedingExport];
                                        } else {
                                            NSString * _Nullable storeIdentifier;
                                            {
                                                OCCloudKitStoreMonitor * _Nullable monitor = loaded_2->_monitor;
                                                if (monitor == nil) {
                                                    storeIdentifier = nil;
                                                } else {
                                                    storeIdentifier = monitor->_storeIdentifier;
                                                }
                                            }
                                            
                                            OCCloudKitMirroringResult *result = [[OCCloudKitMirroringResult alloc] initWithRequest:loaded_2->_request storeIdentifier:storeIdentifier success:NO madeChanges:NO error:operationError];
                                            [loaded_2 finishExportWithResult:result];
                                            [result release];
                                        }
                                    }
                                    
                                    loaded_2 = nil;
                                    [pool drain];
                                });
                            };
                        }
                        
                        if (backgroundContextForMonitoredCoordinator.hasChanges) {
                            BOOL result = [backgroundContextForMonitoredCoordinator save:&error];
                            if (!result) {
                                succeed = NO;
                                [error retain];
                            }
                        }
                        
                        [defaultRecordZones release];
                    }
                } @catch (NSException *exception) {
                    succeed = NO;
                    error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:134421 userInfo:@{@"NSUnderlyingException": @"Export encountered an unhandled exception while analyzing history in the store."}];
                }
            }];
            
            [backgroundContextForMonitoredCoordinator release];
            [monitoredCoordinator release];
            [monitoredStore release];
        }];
    }
    
    if (succeed) {
        if (operation == nil) {
            if (zoneIDs.count == 0) {
                [self exportIfNecessary];
            } else {
#warning TODO __ckLoggingOverride
                os_log_with_type(_OCLogGetLogStream(0x11), OS_LOG_TYPE_DEFAULT, "OpenCloudData: %s(%d): %@: Fetching record zones: %@", __func__, __LINE__, self, zoneIDs);
                
                // x22
                __kindof OCCloudKitMirroringRequest * _Nullable request = self->_request;
                
                BOOL flag;
                if (request == nil) {
                    flag = YES;
                } else if (request->_schedulerActivity.shouldDefer) {
                    flag = NO;
                } else if (request->_deferredByBackgroundTimeout) {
                    flag = YES;
                } else {
                    flag = NO;
                }
                
                if (flag) {
                    // x29, #0x70
                    __weak OCCloudKitExporter *weakSelf = self;
                    // original : getCloudKitCKFetchRecordZonesOperationClass
                    // x22
                    CKFetchRecordZonesOperation *operation = [[CKFetchRecordZonesOperation alloc] initWithRecordZoneIDs:zoneIDs];
                    
                    // <+1380>
                    abort();
                } else {
                    // x23
                    NSError *error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:134419 userInfo:@{NSLocalizedFailureReasonErrorKey: @"The request was aborted because it was deferred by the system."}];
                    NSString * _Nullable storeIdentifier;
                    {
                        OCCloudKitStoreMonitor * _Nullable monitor = self->_monitor;
                        if (monitor == nil) {
                            storeIdentifier = nil;
                        } else {
                            storeIdentifier = monitor->_storeIdentifier;
                        }
                    }
                    // x22
                    OCCloudKitMirroringResult *request = [[OCCloudKitMirroringResult alloc] initWithRequest:self->_request storeIdentifier:storeIdentifier success:NO madeChanges:NO error:error];
                    [self finishExportWithResult:request];
                    [request release];
                    request = nil;
                    [error release];
                }
            }
        } else {
#warning TODO __ckLoggingOverride
            os_log_with_type(_OCLogGetLogStream(0x11), OS_LOG_TYPE_DEFAULT, "OpenCloudData+CloudKit: %s(%d): %@: Scheduling modifyRecordZonesOperation in response to request: %@ operation: %@\n%@\n%@", __func__, __LINE__, self, self->_request, operation, operation.recordZonesToSave, operation.recordZoneIDsToDelete);
            
            CKDatabase * _Nullable database;
            {
                OCCloudKitExporterOptions * _Nullable options = self->_options;
                if (options == nil) {
                    database = nil;
                } else {
                    database = options->_database;
                }
            }
            [database addOperation:operation];
        }
    } else {
        NSString * _Nullable storeIdentifier;
        {
            OCCloudKitStoreMonitor * _Nullable monitor = self->_monitor;
            if (monitor == nil) {
                storeIdentifier = nil;
            } else {
                storeIdentifier = monitor->_storeIdentifier;
            }
        }
        
        // x22
        OCCloudKitMirroringResult *result = [[OCCloudKitMirroringResult alloc] initWithRequest:self->_request storeIdentifier:storeIdentifier success:succeed madeChanges:NO error:error];
        [self finishExportWithResult:result];
        [result release];
    }
    
    // <+768>
    abort();
}

- (void)finishExportWithResult:(OCCloudKitMirroringResult *)result {
    abort();
}

- (BOOL)updateMetadataForSavedZones:(NSArray<CKRecordZone *> *)savedZones error:(NSError * _Nullable *)error {
    abort();
}

- (void)exportIfNecessary {
    abort();
}

@end
