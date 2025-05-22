//
//  OCCloudKitExporter.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/4/25.
//

#import "OpenCloudData/Private/Export/OCCloudKitExporter.h"
#import "OpenCloudData/Private/Log.h"
#import "OpenCloudData/Private/OCCloudKitSerializer.h"
#import "OpenCloudData/Private/Model/OCCKRecordZoneMetadata.h"
#import "OpenCloudData/Private/Metric/OCCloudKitExportedRecordBytesMetric.h"
#import "OpenCloudData/SPI/CoreData/NSManagedObjectContext+Private.h"
#import "OpenCloudData/Private/Model/OCCKMetadataEntry.h"
#import "OpenCloudData/Private/Analyzer/OCCloudKitHistoryAnalyzer.h"
#import "OpenCloudData/Private/Analyzer/OCCloudKitHistoryAnalyzerContext.h"
#import "OpenCloudData/Private/Model/OCCKHistoryAnalyzerState.h"
#import "OpenCloudData/Private/Model/OCCKRecordZoneMoveReceipt.h"
#import "OpenCloudData/SPI/OCSPIResolver.h"
#import <objc/runtime.h>

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
    
    BOOL deferred;
    if (request != nil) {
        CKSchedulerActivity *schedulerActivity = request->_schedulerActivity;
        if (schedulerActivity.shouldDefer || request->_deferredByBackgroundTimeout) {
            deferred = YES;
        } else {
            deferred = NO;
        }
    } else {
        deferred = NO;
    }
    
    if (deferred) {
        succeed = NO;
        error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:134419 userInfo:@{NSLocalizedFailureReasonErrorKey: @"The request was aborted because it was deferred by the system."}];
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
            backgroundContextForMonitoredCoordinator.transactionAuthor = [OCSPIResolver NSCloudKitMirroringDelegateExportContextName];
            
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
                    BOOL isInMemoryStore = [OCSPIResolver _PFRoutines__isInMemoryStore_:objc_lookUpClass("_PFRoutines") x1:monitoredStore];
                    
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
                // inlined
                [self fetchRecordZones:zoneIDs];
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
    
    [error autorelease];
    error = nil;
    [monitor release];
    [operation release];
    [zoneIDs release];
}

- (void)finishExportWithResult:(OCCloudKitMirroringResult *)result {
    /*
     self = x19 = sp + 0x8 = x20
     result = sp
     */
    
    // x21
    NSFileManager *fileManager = [NSFileManager.defaultManager retain];
    // x22
    NSMutableArray<NSURL *> * _Nullable writtenAssetURLs;
    {
        OCCloudKitExportContext * _Nullable exportContext = self->_exportContext;
        if (exportContext == nil) {
            writtenAssetURLs = nil;
        } else {
            writtenAssetURLs = exportContext->_writtenAssetURLs;
        }
    }
    
    // sp, #0x68
    NSError * _Nullable error = nil;
    
    // x27
    for (NSURL *writtenAssetURL in writtenAssetURLs) {
        BOOL result = [fileManager removeItemAtURL:writtenAssetURL error:&error];
        if (result) continue;
        if ([error.domain isEqualToString:NSCocoaErrorDomain] && (error.code == NSFileNoSuchFileError)) continue;
        os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData+CloudKit: %s(%d): Failed to delete asset file: %@\n%@",  __func__, __LINE__, writtenAssetURL, error);
    }
    [fileManager release];
    
    OCCloudKitMirroringDelegateOptions * _Nullable delegateOptions;
    {
        OCCloudKitExporterOptions * _Nullable options = self->_options;
        if (options == nil) {
            delegateOptions = nil;
        } else {
            delegateOptions = options->_options;
        }
    }
    
    // x21
    OCCloudKitExportedRecordBytesMetric *metric = [[OCCloudKitExportedRecordBytesMetric alloc] initWithContainerIdentifier:delegateOptions.containerIdentifier];
    
    size_t totalBytes;
    {
        OCCloudKitExportContext * _Nullable exportContext = self->_exportContext;
        if (exportContext == nil) {
            totalBytes = 0;
        } else {
            totalBytes = exportContext->_totalBytes;
        }
    }
    
    [metric addByteSize:totalBytes];
    
    OCCloudKitMetricsClient * _Nullable metricsClient;
    {
        OCCloudKitExporterOptions * _Nullable options = self->_options;
        if (options == nil) {
            metricsClient = nil;
        } else {
            OCCloudKitMirroringDelegateOptions * _Nullable delegateOptions = options->_options;
            if (delegateOptions == nil) {
                metricsClient = nil;
            } else {
                metricsClient = delegateOptions->_metricsClient;
            }
        }
    }
    
    [metricsClient logMetric:metric];
    [metric release];
    
    void (^block)(OCCloudKitMirroringResult *result) = self->_exportCompletionBlock;
    if (block != nil) {
        block(result);
        [self->_exportCompletionBlock release];
        self->_exportCompletionBlock = nil;
    }
}

- (BOOL)updateMetadataForSavedZones:(NSArray<CKRecordZone *> *)savedZones error:(NSError * _Nullable *)error {
    /*
     self = x21
     savedZones = x22
     error = x19
     */
    
    // sp, #0x88
    __block BOOL _succeed = YES;
    // sp, #0x58
    __block NSError * _Nullable _error = nil;
    // x20
    OCCloudKitStoreMonitor *monitor = [self->_monitor retain];
    
    BOOL shouldDefer;
    {
        __kindof OCCloudKitMirroringRequest * _Nullable request = self->_request;
        
        if (request != nil) {
            CKSchedulerActivity *schedulerActivity = request->_schedulerActivity;
            if (schedulerActivity.shouldDefer || request->_deferredByBackgroundTimeout) {
                shouldDefer = YES;
            } else {
                shouldDefer = NO;
            }
        } else {
            shouldDefer = NO;
        }
    }
    
    if (shouldDefer) {
        _succeed = NO;
        _error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:134419 userInfo:@{NSLocalizedFailureReasonErrorKey: @"The request was aborted because it was deferred by the system."}];
    } else {
        /*
         __56-[PFCloudKitExporter updateMetadataForSavedZones:error:]_block_invoke
         monitor = sp + 0x28 = x19 + 0x20
         savedZones = sp + 0x30 = x19 + 0x28
         self = sp + 0x38 = x19 + 0x30
         _error = sp + 0x40 = x19 + 0x38
         _succeed = sp + 0x48 = x19 + 0x40
         */
        [monitor performBlock:^{
            /*
             self = x19
             */
            
            // x20
            __kindof NSPersistentStore *retainedMonitoredStore = [monitor retainedMonitoredStore];
            
            if (retainedMonitoredStore == nil) {
                _succeed = NO;
                _error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:134407 userInfo:@{NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"Request '%@' was cancelled because the store was removed from the coordinator.", self->_request.requestIdentifier]}];
            } else {
                // x21
                NSPersistentStoreCoordinator * _Nullable monitoredCoordinator;
                {
                    if (monitor == nil) {
                        monitoredCoordinator = nil;
                    } else {
                        monitoredCoordinator = monitor->_monitoredCoordinator;
                    }
                }
                
                // x22
                NSManagedObjectContext *newBackgroundContextForMonitoredCoordinator = [monitor newBackgroundContextForMonitoredCoordinator];
                newBackgroundContextForMonitoredCoordinator.transactionAuthor = [OCSPIResolver NSCloudKitMirroringDelegateExportContextName];
                
                /*
                 __56-[PFCloudKitExporter updateMetadataForSavedZones:error:]_block_invoke_2
                 savedZones = sp + 0x28 = x19 + 0x20
                 self = sp + 0x30 = x19 + 0x28
                 retainedMonitoredStore = sp + 0x38 = x19 + 0x30
                 newBackgroundContextForMonitoredCoordinator = sp + 0x40 = x19 + x38
                 _error = sp + 0x48 = x19 + 0x40
                 _succeed = sp + 0x50 = x19 + 0x48
                 */
                [newBackgroundContextForMonitoredCoordinator performBlockAndWait:^{
                    /*
                     self = x19
                     */
                    
                    @try {
                        // x22
                        for (CKRecordZone *zone in savedZones) {
                            // x24
                            CKRecordZoneID *zoneID = zone.zoneID;
                            
                            CKDatabaseScope databaseScope;
                            {
                                if (self == nil) {
                                    databaseScope = 0;
                                } else {
                                    OCCloudKitExporterOptions * _Nullable options = self->_options;
                                    if (options == nil) {
                                        databaseScope = 0;
                                    } else {
                                        CKDatabase * _Nullable database = options->_database;
                                        if (database == nil) {
                                            databaseScope = 0;
                                        } else {
                                            databaseScope = database.databaseScope;
                                        }
                                    }
                                }
                            }
                            
                            // x23
                            OCCKRecordZoneMetadata * _Nullable metadata = [OCCKRecordZoneMetadata zoneMetadataForZoneID:zoneID inDatabaseWithScope:databaseScope forStore:retainedMonitoredStore inContext:newBackgroundContextForMonitoredCoordinator error:&_error];
                            
                            if (metadata == nil) {
                                _succeed = NO;
                                [_error retain];
                                break;
                            }
                            
                            // x22
                            CKRecordZoneCapabilities capabilities = zone.capabilities;
                            metadata.supportsFetchChanges = (capabilities & CKRecordZoneCapabilityFetchChanges);
                            metadata.supportsRecordSharing = (capabilities & CKRecordZoneCapabilitySharing);
                            metadata.supportsAtomicChanges = (capabilities & CKRecordZoneCapabilityAtomic);
                            metadata.supportsZoneSharing = (capabilities & CKRecordZoneCapabilityZoneWideSharing);
                            metadata.hasRecordZone = YES;
                            
                            BOOL result = [newBackgroundContextForMonitoredCoordinator save:&_error];
                            if (!result) {
                                _succeed = NO;
                                [_error retain];
                                break;
                            }
                        }
                    } @catch (NSException *exception) {
                        _succeed = NO;
                        _error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:134421 userInfo:@{@"NSUnderlyingException": @"Export encountered an unhandled exception while analyzing history in the store."}];
                    }
                }];
                
                [newBackgroundContextForMonitoredCoordinator release];
                [monitoredCoordinator release];
                [retainedMonitoredStore release];
            }
        }];
    }
    
    [monitor release];
    
    if (!_succeed) {
        if (error == nil) {
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            [_error release];
        } else {
            if (error) *error = [_error autorelease];
        }
    }
    
    return _succeed;
}

- (void)exportIfNecessary {
    /*
     self = x20
     */
    
    // x29, #-0x50
    __block BOOL succeed = YES;
    // sp, #0x50
    __block NSError * _Nullable error = nil;
    // x19
    OCCloudKitStoreMonitor *monitor = [self->_monitor retain];
    
    // x21
    OCCloudKitMirroringRequest * _Nullable request = _request;
    
    BOOL deferred;
    if (request != nil) {
        CKSchedulerActivity *schedulerActivity = request->_schedulerActivity;
        if (schedulerActivity.shouldDefer || request->_deferredByBackgroundTimeout) {
            deferred = YES;
        } else {
            deferred = NO;
        }
    } else {
        deferred = NO;
    }
    
    if (deferred) {
        succeed = NO;
        error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:134419 userInfo:@{NSLocalizedFailureReasonErrorKey: @"The request was aborted because it was deferred by the system."}];
    } else {
        /*
         __39-[PFCloudKitExporter exportIfNecessary]_block_invoke
         monitor = sp + 0x28 = x19 + 0x20
         self = sp + 0x30 = x19 + 0x28
         succeed = sp + 0x38 = x19 + 0x30
         error = sp + 0x40 = x19 + 0x38
         */
        [monitor performBlock:^{
            /*
             self = x19
             */
            // x20
            __kindof NSPersistentStore * _Nullable retainedMonitoredStore = [monitor retainedMonitoredStore];
            if (retainedMonitoredStore == nil) {
                succeed = NO;
                error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:134407 userInfo:@{NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"Request '%@' was cancelled because the store was removed from the coordinator.", self->_request.requestIdentifier]}];
                return;
            }
            
            // x21
            NSPersistentStoreCoordinator * _Nullable monitoredCoordinator;
            {
                if (monitor == nil) {
                    monitoredCoordinator = nil;
                } else {
                    monitoredCoordinator = [monitor->_monitoredCoordinator retain];
                }
            }
            
            // x22
            NSManagedObjectContext *newBackgroundContextForMonitoredCoordinator = [monitor newBackgroundContextForMonitoredCoordinator];
            newBackgroundContextForMonitoredCoordinator.transactionAuthor = [OCSPIResolver NSCloudKitMirroringDelegateExportContextName];
            [newBackgroundContextForMonitoredCoordinator _setAllowAncillaryEntities:YES];
            
            /*
             __39-[PFCloudKitExporter exportIfNecessary]_block_invoke_2
             self = sp + 0x30 = + 0x20
             retainedMonitoredStore = sp + 0x38 = + 0x28
             newBackgroundContextForMonitoredCoordinator = sp + 0x40 = + 0x30
             succeed = sp + 0x48 = + 0x38
             error = sp + 0x50 = + 0x40
             */
            [newBackgroundContextForMonitoredCoordinator performBlockAndWait:^{
                /*
                 self(block) = sp + 0x20
                 self = sp + 0x10
                 */
                
                // sp + 0x50
                NSError * _Nullable _error = nil;
                
                @try {
                    BOOL result = [self analyzeHistoryInStore:retainedMonitoredStore withManagedObjectContext:newBackgroundContextForMonitoredCoordinator error:&_error];
                    /* <+2344> */
                    
                    if (!result) {
                        if (_error == nil) {
                            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
                            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
                        } else {
                            error = [_error retain];
                        }
                        
                        succeed = NO;
                        
                        return;
                    }
                } @catch (NSException *exception) {
                    _error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:134421 userInfo:@{@"NSUnderlyingException": @"Export encountered an unhandled exception while analyzing history in the store."}];
                    succeed = NO;
                    error = _error;
                    return;
                }
                
                BOOL shouldDefer;
                {
                    __kindof OCCloudKitMirroringRequest * _Nullable request = self->_request;
                    
                    if (request != nil) {
                        CKSchedulerActivity *schedulerActivity = request->_schedulerActivity;
                        if (schedulerActivity.shouldDefer || request->_deferredByBackgroundTimeout) {
                            shouldDefer = YES;
                        } else {
                            shouldDefer = NO;
                        }
                    } else {
                        shouldDefer = NO;
                    }
                }
                
                if (!shouldDefer) {
                    _error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:134419 userInfo:@{NSLocalizedFailureReasonErrorKey: @"The request was aborted because it was deferred by the system."}];
                    error = _error;
                    succeed = NO;
                    return;
                }
                
                /* <+2892> */
                
                NSNumber * _Nullable countNumber = [OCCKHistoryAnalyzerState countAnalyzerStatesInStore:retainedMonitoredStore withManagedObjectContext:newBackgroundContextForMonitoredCoordinator error:&_error];
                if (countNumber == nil) {
                    succeed = NO;
                    [_error retain];
                    error = _error;
                    return;
                }
                
                NSInteger count = countNumber.integerValue;
                if (count < 1) {
                    OCCKMetadataEntry * _Nullable entry = [OCCKMetadataEntry entryForKey:[OCSPIResolver NSCloudKitMirroringDelegateScanForRowsMissingFromHistoryKey] fromStore:retainedMonitoredStore inManagedObjectContext:newBackgroundContextForMonitoredCoordinator error:&_error];
                    if (entry == nil) {
                        if (_error != nil) {
                            succeed = NO;
                            [_error retain];
                            error = _error;
                            return;
                        }
                    }
                    
                    if (!entry.boolValue) {
                        NSNumber * _Nullable countNumber = [OCCKRecordZoneMoveReceipt countMoveReceiptsInStore:retainedMonitoredStore matchingPredicate:[NSPredicate predicateWithFormat:@"needsCloudDelete == 1"] withManagedObjectContext:newBackgroundContextForMonitoredCoordinator error:&_error];
                        if (countNumber == nil) {
                            succeed = NO;
                            [_error retain];
                            error = _error;
                            return;
                        }
                        
                        count = countNumber.integerValue;
                    }
                }
                
                /* <+3984> */
                if (count > 0) {
                    BOOL result = [self->_exportContext processAnalyzedHistoryInStore:retainedMonitoredStore inManagedObjectContext:newBackgroundContextForMonitoredCoordinator error:&_error];
                    if (!result) {
                        succeed = NO;
                        [_error retain];
                        error = _error;
                        return;
                    }
                }
                
                /* <+2620> */
                BOOL shouldDefer2;
                {
                    __kindof OCCloudKitMirroringRequest * _Nullable request = self->_request;
                    
                    if (request != nil) {
                        CKSchedulerActivity *schedulerActivity = request->_schedulerActivity;
                        if (schedulerActivity.shouldDefer || request->_deferredByBackgroundTimeout) {
                            shouldDefer2 = YES;
                        } else {
                            shouldDefer2 = NO;
                        }
                    } else {
                        shouldDefer2 = NO;
                    }
                }
                
                if (shouldDefer2) {
                    succeed = NO;
                    _error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:134419 userInfo:@{NSLocalizedFailureReasonErrorKey: @"The request was aborted because it was deferred by the system."}];
                    error = _error;
                    return;
                }
                
                /* <+2948> */
                BOOL isInMemoryStore = [OCSPIResolver _PFRoutines__isInMemoryStore_:objc_lookUpClass("_PFRoutines") x1:retainedMonitoredStore];
                
                if (!isInMemoryStore) {
                    NSError * _Nullable __error = nil;
                    BOOL result = [newBackgroundContextForMonitoredCoordinator setQueryGenerationFromToken:NSQueryGenerationToken.currentQueryGenerationToken error:&__error];
                    if (!result) {
                        os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData+CloudKit: %s(%d): %@: Unable to set query generation on moc: %@", __func__, __LINE__, self, __error);
                    }
                }
                
                // sp, #0xb0
                NSUInteger returnCount = 0;
                BOOL result = [self->_exportContext checkForObjectsNeedingExportInStore:retainedMonitoredStore andReturnCount:&returnCount withManagedObjectContext:newBackgroundContextForMonitoredCoordinator error:&_error];
                
                if (!result) {
                    succeed = NO;
                    succeed = [_error retain];
                    return;
                }
                
                os_log_with_type(_OCLogGetLogStream(0x11), OS_LOG_TYPE_DEFAULT, "OpenCloudData+CloudKit: %s(%d): %@: Found %lu objects needing export.", __func__, __LINE__, self, returnCount);
                
                if (returnCount == 0) {
                    /* <+4088> */
                    // x29, #0xa0
                    __block BOOL madeChanges = NO;
                    /*
                     __39-[PFCloudKitExporter exportIfNecessary]_block_invoke.38
                     */
                    [self->_operationIDToResult enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, OCCloudKitMirroringResult * _Nonnull obj, BOOL * _Nonnull stop) {
                        if (obj.madeChanges) {
                            madeChanges = YES;
                            *stop = YES;
                        }
                    }];
                    
                    NSString * _Nullable storeIdentifier;
                    {
                        OCCloudKitStoreMonitor * _Nullable monitor = self->_monitor;
                        if (monitor == nil) {
                            storeIdentifier = nil;
                        } else {
                            storeIdentifier = monitor->_storeIdentifier;
                        }
                    }
                    
                    // x19
                    OCCloudKitMirroringResult * _Nullable mirroringResult = [[OCCloudKitMirroringResult alloc] initWithRequest:self->_request storeIdentifier:storeIdentifier success:YES madeChanges:madeChanges error:NULL];
                    [self finishExportWithResult:mirroringResult];
                    [mirroringResult release];
                    return; /* <+4272> */
                }
                
                /* <+3424> */
                
                // x20
                CKModifyRecordsOperation * _Nullable operation = [self->_exportContext newOperationBySerializingDirtyObjectsInStore:retainedMonitoredStore inManagedObjectContext:newBackgroundContextForMonitoredCoordinator error:&_error];
                
                if (operation == nil) {
                    succeed = NO;
                    error = [_error retain];
                    return;
                }
                
                [self->_delegate exporter:self willScheduleOperations:@[operation]];
                
                /* <3524> */
                // inlined
                [self executeOperation:operation];
                [operation release];
            }];
            
            [newBackgroundContextForMonitoredCoordinator release];
            [monitoredCoordinator release];
            [retainedMonitoredStore release];
        }];
    }
    
    if (!succeed) {
        NSString * _Nullable storeIdentifier;
        {
            OCCloudKitStoreMonitor * _Nullable monitor = self->_monitor;
            if (monitor == nil) {
                storeIdentifier = nil;
            } else {
                storeIdentifier = monitor->_storeIdentifier;
            }
        }
        
        OCCloudKitMirroringResult * _Nullable mirroringResult = [[OCCloudKitMirroringResult alloc] initWithRequest:self->_request storeIdentifier:storeIdentifier success:NO madeChanges:NO error:error];
        [self finishExportWithResult:mirroringResult];
        [mirroringResult release];
    }
    
    [error release];
    [monitor release];
}

- (void)fetchRecordZones:(NSArray<CKRecordZoneID *> *)zoneIDs {
    /* inlined from -checkForZonesNeedingExport */
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
        
        /*
         __39-[PFCloudKitExporter fetchRecordZones:]_block_invoke
         self = sp + 0xf0 = x22 + 0x20
         weakSelf = sp + 0xf8 = x22 + 0x28
         */
        operation.fetchRecordZonesCompletionBlock = ^(NSDictionary<CKRecordZoneID *,CKRecordZone *> * _Nullable recordZonesByZoneID, NSError * _Nullable operationError) {
            /*
             self = x22
             x21 = recordZonesByZoneID
             x20 = operationError
             */
            
            // x19
            OCCloudKitExporter *loaded = [weakSelf retain];
            if (loaded == nil) return;
            
            /*
             __39-[PFCloudKitExporter fetchRecordZones:]_block_invoke_2
             self = sp + 0x28 = x21 + 0x20
             recordZonesByZoneID = sp + 0x30 = x21 + 0x28
             operationError = sp + 0x38 = x21 + 0x30
             */
            dispatch_async(loaded->_workQueue, ^{
                /*
                 self = x21
                 */
                // x19
                NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
                // x20
#warning TODO loaded가 아니라 self를 capture하는 문제가 있음
                OCCloudKitExporter *_self = self;
                // x22
                NSDictionary<CKRecordZoneID *, CKRecordZone *> * _Nullable _recordZonesByZoneID = recordZonesByZoneID;
                // x21
                NSError * _Nullable _operationError = operationError;
                
                if (self == nil) {
                    [pool drain];
                    return;
                }
                
                os_log_with_type(_OCLogGetLogStream(0x11), OS_LOG_TYPE_DEFAULT, "+CloudKit: %s(%d): %@: Finished fetching record zones: %@ - %@", __func__, __LINE__, _self, recordZonesByZoneID, operationError);
                
                if (_operationError != nil) {
                    NSString * _Nullable storeIdentifier;
                    {
                        OCCloudKitStoreMonitor * _Nullable monitor = _self->_monitor;
                        if (monitor == nil) {
                            storeIdentifier = nil;
                        } else {
                            storeIdentifier = monitor->_storeIdentifier;
                        }
                    }
                    
                    // x21
                    OCCloudKitMirroringResult *result = [[OCCloudKitMirroringResult alloc] initWithRequest:_self->_request storeIdentifier:storeIdentifier success:NO madeChanges:NO error:_operationError];
                    [_self finishExportWithResult:result];
                    [result release];
                } else {
                    NSError * _Nullable error = nil;
                    BOOL result = [_self updateMetadataForSavedZones:_recordZonesByZoneID.allValues error:&error];
                    
                    if (result) {
                        [self exportIfNecessary];
                    } else {
                        NSString * _Nullable storeIdentifier;
                        {
                            OCCloudKitStoreMonitor * _Nullable monitor = _self->_monitor;
                            if (monitor == nil) {
                                storeIdentifier = nil;
                            } else {
                                storeIdentifier = monitor->_storeIdentifier;
                            }
                        }
                        
                        // x21
                        OCCloudKitMirroringResult *result = [[OCCloudKitMirroringResult alloc] initWithRequest:_self->_request storeIdentifier:storeIdentifier success:NO madeChanges:NO error:error];
                        [_self finishExportWithResult:result];
                        [result release];
                    }
                }
                
                [pool drain];
            });
            
            [loaded release];
        };
        
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
        [operation release];
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

- (BOOL)analyzeHistoryInStore:(__kindof NSPersistentStore *)store withManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable *)error {
    /* inlined from __39-[PFCloudKitExporter exportIfNecessary]_block_invoke_2 */
    /*
     self = sp + 0x10
     store = x24
     managedObjectContext = x23
     */
    
    // sp + 0x18
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    // sp + 0x60
    NSError * _Nullable _error = nil;
    
    // w25
    BOOL _succeed;
    
    @try {
        BOOL isInMemoryStore = [OCSPIResolver _PFRoutines__isInMemoryStore_:objc_lookUpClass("_PFRoutines") x1:store];
        
        if (!isInMemoryStore) {
            // sp + 0x58
            NSError * _Nullable __error = nil;
            BOOL result = [managedObjectContext setQueryGenerationFromToken:NSQueryGenerationToken.currentQueryGenerationToken error:&_error];
            if (!result) {
                os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData+CloudKit: %s(%d): %@: Unable to set query generation on moc: %@", __func__, __LINE__, self, __error);
            }
        }
        
        OCCKMetadataEntry * _Nullable entry = [OCCKMetadataEntry entryForKey:[OCSPIResolver NSCloudKitMirroringDelegateLastHistoryTokenKey] fromStore:store inManagedObjectContext:managedObjectContext error:&_error];
        
        // x26
        NSObject<NSSecureCoding> * _Nullable transformedValue;
        // w27
        BOOL boolValue;
        // w28
        BOOL shouldAnalyze;
        
        if (error != nil) {
            _succeed = NO;
            [_error retain];
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData+CloudKit: %s(%d): Unable to read the last history token: %@", __func__, __LINE__, _error);
            transformedValue = nil;
            boolValue = NO;
            shouldAnalyze = NO;
        } else {
            transformedValue = entry.transformedValue;
            OCCKMetadataEntry * _Nullable entry = [OCCKMetadataEntry entryForKey:[OCSPIResolver NSCloudKitMirroringDelegateBypassHistoryOnExportKey] fromStore:store inManagedObjectContext:managedObjectContext error:&_error];
            
            if (_error != nil) {
                _succeed = NO;
                [_error retain];
                os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData+CloudKit: %s(%d): Unable to read the bypass entry: %@", __func__, __LINE__, _error);
                boolValue = NO;
                transformedValue = nil;
                shouldAnalyze = NO;
            } else {
                boolValue = entry.boolValue;
                if ((transformedValue == nil) || boolValue) {
                    OCCKMetadataEntry * _Nullable entry = [OCCKMetadataEntry updateOrInsertMetadataEntryWithKey:[OCSPIResolver NSCloudKitMirroringDelegateScanForRowsMissingFromHistoryKey] boolValue:YES forStore:store intoManagedObjectContext:managedObjectContext error:&_error];
                    
                    if (entry == nil) {
                        _succeed = NO;
                        [_error retain];
                        boolValue = NO;
                        transformedValue = nil;
                        shouldAnalyze = NO;
                    } else {
                        _succeed = YES;
                        shouldAnalyze = YES;
                    }
                } else {
                    _succeed = YES;
                    shouldAnalyze = YES;
                }
            }
        }
        
        BOOL flag;
        if (managedObjectContext.hasChanges) {
    #warning TODO Error Leak
            BOOL result = [managedObjectContext save:&_error];
            
            if (!result) {
                _succeed = NO;
                [_error retain];
                flag = NO;
            } else {
                if (shouldAnalyze) {
                    flag = YES;
                } else {
                    flag = NO;
                }
            }
        } else {
            flag = YES;
        }
        
        if (flag) {
            // x21
            OCCloudKitHistoryAnalyzerOptions *options = [[OCCloudKitHistoryAnalyzerOptions alloc] init];
            options.request = self->_request;
            
            // x19 / x22
            OCCloudKitHistoryAnalyzer *analyzer = [[OCCloudKitHistoryAnalyzer alloc] initWithOptions:options managedObjectContext:managedObjectContext];
            
            os_log_with_type(_OCLogGetLogStream(0x11), OS_LOG_TYPE_DEFAULT, "OpenCloudData+CloudKit: %s(%d): %@: Exporting changes since (%d): %@", __func__, __LINE__, self, boolValue, transformedValue);
            
            // x26 / x20
            OCCloudKitHistoryAnalyzerContext * _Nullable analyzerContext = [OCSPIResolver PFHistoryAnalyzer_newAnalyzerContextForStore_sinceLastHistoryToken_inManagedObjectContext_error_:analyzer x1:store x2:transformedValue x3:managedObjectContext x4:&_error];
            
            if (analyzerContext == nil) {
                if (_error == nil) {
                    os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: History analyzer should have set an error if the analyzer context is nil.\n");
                    os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: History analyzer should have set an error if the analyzer context is nil.\n");
                }
                
                _succeed = NO;
                [_error retain];
                
                if (([_error.domain isEqualToString:NSCocoaErrorDomain]) && (_error.code == 134419)) {
                    // sp + 0x58
                    NSError * _Nullable __error = nil;
                    
                    NSPersistentHistoryToken * _Nullable lastProcessedToken;
                    assert(object_getInstanceVariable(analyzer, "_lastProcessedToken", (void **)&lastProcessedToken) != NULL);
                    
                    OCCKMetadataEntry * _Nullable entry = [OCCKMetadataEntry updateOrInsertMetadataEntryWithKey:[OCSPIResolver NSCloudKitMirroringDelegateLastHistoryTokenKey] transformedValue:lastProcessedToken forStore:store intoManagedObjectContext:managedObjectContext error:&__error];
                    
                    if (entry == nil) {
                        os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData+CloudKit: %s(%d): %@: Failed to update exporter history token after deferral: %@", __func__, __LINE__, self, __error);
                    } else {
                        BOOL result = [managedObjectContext save:&__error];
                        if (!result) {
                            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData+CloudKit: %s(%d): %@: Failed to save exporter history token after deferral: %@", __func__, __LINE__, self, __error);
                        }
                    }
                }
                
                [options release];
                [analyzer release];
                [analyzerContext release];
                [pool release];
                [_error autorelease];
                return _succeed;
            }
            
            NSPersistentHistoryToken * _Nullable finalHistoryToken;
            assert(object_getInstanceVariable(analyzerContext, "_finalHistoryToken", (void **)&finalHistoryToken) != NULL);
            if (finalHistoryToken == nil) {
                _succeed = YES;
                [options release];
                [analyzer release];
                [analyzerContext release];
                [pool release];
                return _succeed;
            }
            
            [OCCKMetadataEntry updateOrInsertMetadataEntryWithKey:[OCSPIResolver NSCloudKitMirroringDelegateLastHistoryTokenKey] transformedValue:finalHistoryToken forStore:store intoManagedObjectContext:managedObjectContext error:&_error];
            
            if (_error != nil) {
                _succeed = NO;
                [_error retain];
                
                [options release];
                [analyzer release];
                [analyzerContext release];
                [pool release];
                [_error autorelease];
                return _succeed;
            }
            
            OCCKMetadataEntry * _Nullable entry = [OCCKMetadataEntry entryForKey:[OCSPIResolver NSCloudKitMirroringDelegateBypassHistoryOnExportKey] fromStore:store inManagedObjectContext:managedObjectContext error:&_error];
            
            if (_error != nil) {
                os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData+CloudKit: %s(%d): Unable to read the bypass entry: %@", __func__, __LINE__, _error);
                [_error retain];
                _succeed = NO;
                
                [options release];
                [analyzer release];
                [analyzerContext release];
                [pool release];
                [_error autorelease];
                return _succeed;
            }
            
            if (entry != nil) {
                [managedObjectContext deleteObject:entry];
            }
            
            if (managedObjectContext.hasChanges) {
                BOOL result = [managedObjectContext save:&_error];
                
                if (!result) {
#warning TODO _succeed = NO은 원래 없음
                    _succeed = NO;
                    
                    [_error retain];
                }
                
                [managedObjectContext reset];
            }
            
            [options release];
            [analyzer release];
            [analyzerContext release];
        }
    } @catch (NSException *exception) {
        _error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:134421 userInfo:@{@"NSUnderlyingException": @"Export encountered a fatal exception while analyzing history."}];
        _succeed = NO;
    }
    
    [pool release];
    [_error autorelease];
    return _succeed;
}

- (void)executeOperation:(CKModifyRecordsOperation *)operation {
    // inlined from __48-[PFCloudKitExporter checkForZonesNeedingExport]_block_invoke_2 <+3524>
    
    /*
     self = x21
     operation = x20
     */
    
    // x29 - #0xb0
    __weak OCCloudKitExporter *weakSelf = self;
    
    if (self->_request.options != nil) {
        [self->_request.options applyToOperation:operation];
    }
    
    operation.savePolicy = CKRecordSaveChangedKeys;
    
    BOOL test_useLegacySavePolicy;
    {
        OCCloudKitExporterOptions * _Nullable options = self->_options;
        if (options == nil) {
            test_useLegacySavePolicy = NO;
        } else {
            OCCloudKitMirroringDelegateOptions * _Nullable delegateOptions = options->_options;
            if (delegateOptions == nil) {
                test_useLegacySavePolicy = NO;
            } else {
                test_useLegacySavePolicy = delegateOptions->_test_useLegacySavePolicy;
            }
        }
    }
    
    if (!test_useLegacySavePolicy) {
        operation.savePolicy = CKRecordSaveIfServerRecordUnchanged;
    }
    
    // x19
    CKOperationID operationID = operation.operationID;
    
    /*
     __39-[PFCloudKitExporter executeOperation:]_block_invoke
     operationID = x29 - 0x80 = x23 + 0x20
     weakSelf = x29 - 0x78 = x23 + 0x28
     */
    operation.modifyRecordsCompletionBlock = ^(NSArray<CKRecord *> * _Nullable savedRecords, NSArray<CKRecordID *> * _Nullable deletedRecordIDs, NSError * _Nullable operationError) {
        /*
         self(block) = x23
         savedRecords = x22
         deletedRecordIDs = x21
         operationError = x20
         */
        
        // x19
        OCCloudKitExporter *loaded = weakSelf;
        if (loaded == nil) return;
        
        
        /*
         __39-[PFCloudKitExporter executeOperation:]_block_invoke_2
         loaded = sp + 0x28 = x21 + 0x20
         operationID = sp + 0x30 = x21 + 0x28
         savedRecords = sp + 0x38 = x21 + 0x30
         deletedRecordIDs = sp + 0x40 = x21 + 0x38
         operationError = sp + 0x48 = x21 + 0x40
         */
        dispatch_async(loaded->_workQueue, ^{
            // inlined
            [self exportOperationFinished:operationID savedRecords:savedRecords deletedRecordIDs:deletedRecordIDs operationError:operationError];
        });
    };
    
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

- (void)exportOperationFinished:(CKOperationID)operationID savedRecords:(NSArray<CKRecord *> *)savedRecords deletedRecordIDs:(NSArray<CKRecordID *> *)deletedRecordIDs operationError:(NSError *)operationError {
    // inlined from __39-[PFCloudKitExporter executeOperation:]_block_invoke_2
    /*
     __39-[PFCloudKitExporter executeOperation:]_block_invoke_2
     self = x20
     operationID = sp + 0x30 = x21 + 0x28 = x25
     savedRecords = sp + 0x38 = x21 + 0x30 = x26
     deletedRecordIDs = sp + 0x40 = x21 + 0x38 = x27
     operationError = sp + 0x48 = x21 + 0x40 = x21
     */
    
    // x19
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    os_log_with_type(_OCLogGetLogStream(0x11), OS_LOG_TYPE_DEFAULT, "OpenCloudData+CloudKit: %s(%d): Modify records finished: %@\n%@\n%@", __func__, __LINE__, savedRecords, deletedRecordIDs, operationError);
    
    // x23
    NSString * _Nullable storeIdentifier;
    {
        OCCloudKitStoreMonitor * _Nullable monitor = self->_monitor;
        if (monitor == nil) {
            storeIdentifier = nil;
        } else {
            storeIdentifier = monitor->_storeIdentifier;
        }
    }
    
    if (operationError != nil) {
        // x21
        OCCloudKitMirroringResult *result = [[OCCloudKitMirroringResult alloc] initWithRequest:self->_request storeIdentifier:storeIdentifier success:NO madeChanges:(self->_operationIDToResult.count != 0) error:operationError];
        [self finishExportWithResult:result];
        [result release];
    } else {
        // x21
        OCCloudKitStoreMonitor *monitor = [self->_monitor retain];
        
        /*
         __95-[PFCloudKitExporter exportOperationFinished:withSavedRecords:deletedRecordIDs:operationError:]_block_invoke
         monitor = sp + 0x20 = x20 + 0x20
         self = sp + 0x28 = x20 + 0x28
         savedRecords = sp + 0x30 = x20 + 0x30
         deletedRecordIDs = sp + 0x38 = x20 + 0x38
         nil = sp + 0x40 = x20 + 0x40
         operationID = sp + 0x48 = x20 + 0x48
         */
        [monitor performBlock:^{
            /*
             self(block) = x20
             */
            
            // x19
            __kindof NSPersistentStore *retainedMonitoredStore = [monitor retainedMonitoredStore];
            
            if (retainedMonitoredStore == nil) {
                NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:134407 userInfo:@{NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"Request '%@' was cancelled because the store was removed from the coordinator.", self->_request.requestIdentifier]}];
                
                NSString * _Nullable storeIdentifier;
                {
                    OCCloudKitStoreMonitor * _Nullable monitor = self->_monitor;
                    if (monitor == nil) {
                        storeIdentifier = nil;
                    } else {
                        storeIdentifier = monitor->_storeIdentifier;
                    }
                }
                
                // x19
                OCCloudKitMirroringResult *result = [[OCCloudKitMirroringResult alloc] initWithRequest:self->_request storeIdentifier:storeIdentifier success:NO madeChanges:NO error:error];
                [self finishExportWithResult:result];
                [result release];
                return;
            }
            
            // x22
            NSPersistentStoreCoordinator * _Nullable monitoredCoordinator;
            {
                OCCloudKitStoreMonitor * _Nullable monitor = self->_monitor;
                if (monitor == nil) {
                    monitoredCoordinator = nil;
                } else {
                    monitoredCoordinator = monitor->_monitoredCoordinator;
                }
            }
            
            // x21
            NSManagedObjectContext *newBackgroundContextForMonitoredCoordinator = [self->_monitor newBackgroundContextForMonitoredCoordinator];
            
            newBackgroundContextForMonitoredCoordinator.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
            newBackgroundContextForMonitoredCoordinator.transactionAuthor = [OCSPIResolver NSCloudKitMirroringDelegateExportContextName];
            
            // x29, #-0x78
            __block BOOL succeed = YES;
            
            // sp, #0x78
            __block NSError * _Nullable error = nil;
            
            NSError * const _Nullable operationError = nil;
            
            /*
             __95-[PFCloudKitExporter exportOperationFinished:withSavedRecords:deletedRecordIDs:operationError:]_block_invoke_2
             self = sp + 0x30 = + 0x20
             retainedMonitoredStore = sp + 0x38 = + 0x28
             savedRecords = sp + 0x40 = + 0x30
             deletedRecordIDs = sp + 0x48 = + 0x38
             operationError = sp + 0x50 = + 0x40
             newBackgroundContextForMonitoredCoordinator = sp + 0x58 = + 0x48
             operationID = sp + 0x60 = + 0x50
             error = sp + 0x68 = + 0x58
             succeed = sp + 0x70 = + 0x60
             */
            [newBackgroundContextForMonitoredCoordinator performBlockAndWait:^{
                /*
                 self = sp + 0x38
                 */
                BOOL result = [self->_exportContext modifyRecordsOperationFinishedForStore:retainedMonitoredStore withSavedRecords:savedRecords deletedRecordIDs:deletedRecordIDs operationError:operationError managedObjectContext:newBackgroundContextForMonitoredCoordinator error:&error];
                
                if (!result) {
                    os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData+CloudKit: %s(%d): %@ - Failed to update metadadata after operation finished (%@): %@", __func__, __LINE__, self, operationID, error);
                    [error retain];
                    return;
                }
                
                // sp + 0x40
                OCCloudKitExporter *_self = self;
                if (_self == nil) {
                    succeed = NO;
                    [error retain];
                    return;
                }
                
                // x9 / sp + 0x48
                NSArray<CKRecord *> *_savedRecords = savedRecords;
                // x23
                NSArray<CKRecordID *> *_deletedRecordIDs = deletedRecordIDs;
                // x20 / sp + 0x8
                __kindof NSPersistentStore *_retainedMonitoredStore = retainedMonitoredStore;
                // x25
                NSManagedObjectContext *_newBackgroundContextForMonitoredCoordinator = newBackgroundContextForMonitoredCoordinator;
                // error = sp + 0x20
                
                // sp + 0x118
                NSError * _Nullable _error = nil;
                
                // ?????
                // sp + 0x30
                NSMutableDictionary *dictionary_1 = [[NSMutableDictionary alloc] init];
                // sp + 0x28
                NSMutableDictionary *dictionary_2 = [[NSMutableDictionary alloc] init];
                
                // x22
                NSDictionary<CKRecordID *, OCCKRecordMetadata *> * _Nullable mapOfMetadata = [OCCKRecordMetadata createMapOfMetadataMatchingRecords:_savedRecords andRecordIDs:_deletedRecordIDs inStore:_retainedMonitoredStore withManagedObjectContext:_newBackgroundContextForMonitoredCoordinator error:&_error];
                
                if (mapOfMetadata == nil) {
                    os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData+CloudKit: %s(%d): %@ - Failed to fetch metadata for post-export update: %@\n%@\n%@", __func__, __LINE__, _self, _error, _savedRecords, _deletedRecordIDs);
                    
                    if (_error != nil) {
                        error = [_error retain];
                    } else {
                        os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
                        os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
                    }
                    
                    succeed = NO;
                    
                    [mapOfMetadata release];
                    [dictionary_1 release];
                    [dictionary_2 release];
                    
                    return;
                }
                
                // x28
                for (CKRecord *record in _savedRecords) {
                    // original : getCloudKitCKRecordTypeShare
                    if ([OCCloudKitSerializer isMirroredRelationshipRecordType:record.recordType] || [record.recordType isEqualToString:CKRecordTypeShare]) {
                        continue;
                    }
                    
                    // x20
                    OCCKRecordMetadata *metadata = mapOfMetadata[record.recordID];
                    
                    if (metadata == nil) {
                        os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Metadata Inconsistency: Missing metadata for record: %@\n", record);
                        os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Metadata Inconsistency: Missing metadata for record: %@", record);
                        continue;
                    }
                    
                    OCCloudKitArchivingUtilities * _Nullable _archivingUtilities;
                    {
                        OCCloudKitExporterOptions * _Nullable options = _self->_options;
                        if (options == nil) {
                            _archivingUtilities = nil;
                        } else {
                            OCCloudKitMirroringDelegateOptions * _Nullable delegateOptions = options->_options;
                            if (delegateOptions == nil) {
                                _archivingUtilities = nil;
                            } else {
                                _archivingUtilities = delegateOptions->_archivingUtilities;
                            }
                        }
                    }
                    
                    // x28
                    NSData * _Nullable encodedData = [_archivingUtilities encodeRecord:record error:&_error];
                    
                    if (encodedData != nil) {
                        metadata.encodedRecord = encodedData;
                        metadata.ckRecordSystemFields = nil;
                    }
                    
                    [encodedData release];
                    
                    if (metadata.pendingExportTransactionNumber != nil ){
                        metadata.lastExportedTransactionNumber = metadata.pendingExportTransactionNumber;
                        metadata.pendingExportTransactionNumber = nil;
                    }
                    
                    if (encodedData == nil) {
                        if (_error != nil) {
                            error = [_error retain];
                        } else {
                            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
                            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
                        }
                        
                        succeed = NO;
                        
                        [mapOfMetadata release];
                        [dictionary_1 release];
                        [dictionary_2 release];
                        
                        return;
                    }
                }
                
                for (CKRecordID *recordID in _deletedRecordIDs) {
                    OCCKRecordMetadata *metadata = mapOfMetadata[recordID];
                    
                    if (metadata == nil) {
                        continue;
                    }
                    
                    [_newBackgroundContextForMonitoredCoordinator deleteObject:metadata];
                }
                
                // x20
                NSArray<OCCKRecordZoneMoveReceipt *> * _Nullable receipts = [OCCKRecordZoneMoveReceipt moveReceiptsMatchingRecordIDs:_deletedRecordIDs inManagedObjectContext:_newBackgroundContextForMonitoredCoordinator persistentStore:_retainedMonitoredStore error:&_error];
                
                if (receipts == nil) {
                    if (_error != nil) {
                        error = [_error retain];
                    } else {
                        os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
                        os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
                    }
                    
                    succeed = NO;
                    
                    [mapOfMetadata release];
                    [dictionary_1 release];
                    [dictionary_2 release];
                    
                    return;
                }
                
                for (OCCKRecordZoneMoveReceipt *receipt in receipts) {
                    receipt.needsCloudDelete = NO;
                }
                
                result = [newBackgroundContextForMonitoredCoordinator save:&error];
                
                if (!result) {
                    os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d", __func__, __LINE__);
                    os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d", __func__, __LINE__);
                    
                    succeed = NO;
                    [error retain];
                }
                
                [mapOfMetadata release];
                [dictionary_1 release];
                [dictionary_2 release];
            }];
            
            NSString * _Nullable storeIdentifier;
            {
                OCCloudKitStoreMonitor * _Nullable monitor = self->_monitor;
                if (monitor == nil) {
                    storeIdentifier = nil;
                } else {
                    storeIdentifier = monitor->_storeIdentifier;
                }
            }
            
            // x23
            OCCloudKitMirroringResult *result = [[OCCloudKitMirroringResult alloc] initWithRequest:self->_request storeIdentifier:storeIdentifier success:succeed madeChanges:succeed error:error];
            self->_operationIDToResult[operationID] = result;
            
            if (succeed) {
                [self exportIfNecessary];
            }
            
            [result release];
            [error release];
        }];
        
        [monitor release];
    }
    
    [pool drain];
}

@end
