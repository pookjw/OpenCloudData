//
//  OCCloudKitImporter.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/14/25.
//

#import <OpenCloudData/OCCloudKitImporter.h>
#import <OpenCloudData/OCCloudKitMirroringFetchRecordsRequest.h>
#import <OpenCloudData/OCCloudKitImporterFetchRecordsWorkItem.h>
#import <OpenCloudData/OCCloudKitSerializer.h>
#import <OpenCloudData/OCCloudKitCKQueryBackedImportWorkItem.h>
#import <OpenCloudData/OCCloudKitImporterZoneChangedWorkItem.h>
#import <OpenCloudData/OCCloudKitImporterZoneDeletedWorkItem.h>
#import <OpenCloudData/OCCloudKitImportedRecordBytesMetric.h>
#import <OpenCloudData/OCCKDatabaseMetadata.h>
#import <OpenCloudData/OCCloudKitImporterZonePurgedWorkItem.h>
#import <OpenCloudData/OCCKRecordZoneMetadata.h>
#import <OpenCloudData/Log.h>
#import <OpenCloudData/_PFRoutines.h>
#include <objc/runtime.h>

@implementation OCCloudKitImporter

- (instancetype)initWithOptions:(OCCloudKitImporterOptions *)options request:(OCCloudKitMirroringImportRequest *)request {
    /*
     options = x21
     request = x19
     */
    if (self = [super init]) {
        _options = [options copy];
        _request = [request retain];
        _workItemResults = [[NSMutableArray alloc] init];
        _totalImportedBytes = 0;
    }
    
    return self;
}

- (void)dealloc {
    [_options release];
    _options = nil;
    
    [_request release];
    _request = nil;
    
    [_workItems release];
    _workItems = nil;
    
    [_workItemResults release];
    _workItemResults = nil;
    
    [_updatedDatabaseChangeToken release];
    _updatedDatabaseChangeToken = nil;
    
    [super dealloc];
}

- (void)importIfNecessaryWithCompletion:(void (^)(OCCloudKitMirroringResult * _Nonnull))completion {
    OCCloudKitStoreMonitor * _Nullable monitor;
    {
        OCCloudKitImporterOptions *options = self->_options;
        if (options == nil) {
            monitor = nil;
        } else {
            monitor = options->_monitor;
        }
    }
    
    /*
     __54-[PFCloudKitImporter importIfNecessaryWithCompletion:]_block_invoke
     monitor = sp + 0x28 = x23 + 0x20
     self = sp + 0x30 = x23 + 0x28
     completion = sp + 0x38 = x23 + 0x30
     */
    [monitor performBlock:^{
        // self(block) = x23
        // x20
        NSSQLCore * _Nullable store = [monitor retainedMonitoredStore];
        // self(block) = sp + 0x38
        if (store == nil) {
            if (completion != nil) {
                // x21
                NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:134407 userInfo:@{
                    NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"Request '%@' was cancelled because the store was removed from the coordinator.", self->_request.requestIdentifier]
                }];
                
                NSString *storeIdentifier;
                {
                    if (monitor == nil) {
                        storeIdentifier = nil;
                    } else {
                        storeIdentifier = monitor->_storeIdentifier;
                    }
                }
                
                // x19
                OCCloudKitMirroringResult *result = [[OCCloudKitMirroringResult alloc] initWithRequest:self->_request storeIdentifier:storeIdentifier success:NO madeChanges:NO error:error];
                completion(result);
                [result release];
            }
            return;
        }
        
        OCCloudKitMirroringImportRequest * _Nullable request = self->_request;
        
        if (request != nil) {
            CKSchedulerActivity *schedulerActivity = request->_schedulerActivity;
            
            if (schedulerActivity.shouldDefer || request->_deferredByBackgroundTimeout) {
                // <+124>
                // x21
                NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:134419 userInfo:@{
                    NSLocalizedFailureReasonErrorKey: @"The request was aborted because it was deferred by the system."
                }];
                
                NSString *storeIdentifier;
                {
                    if (monitor == nil) {
                        storeIdentifier = nil;
                    } else {
                        storeIdentifier = monitor->_storeIdentifier;
                    }
                }
                
                // x19
                OCCloudKitMirroringResult *result = [[OCCloudKitMirroringResult alloc] initWithRequest:self->_request storeIdentifier:storeIdentifier success:NO madeChanges:NO error:error];
                
                // nil 확인 없음
                completion(result);
                [result release];
                [store retain];
                return;
            }
        }
        
        // <+536>
        // store = sp + 0x10
        // x22
        CKDatabase * _Nullable database;
        {
            OCCloudKitImporterOptions * _Nullable options = self->_options;
            if (options == nil) {
                database = nil;
            } else {
                database = options->_database;
            }
        }
        
        // x19
        request = self->_request;
        
        if ([request isKindOfClass:[OCCloudKitMirroringFetchRecordsRequest class]]) {
            // <+584>
            // x19
            OCCloudKitImporterFetchRecordsWorkItem *workItem = [[OCCloudKitImporterFetchRecordsWorkItem alloc] initWithOptions:self->_options request:self->_request];
            
            // assign인듯
            self->_workItems = [[NSArray alloc] initWithObjects:workItem, nil];
            [self processWorkItemsWithCompletion:completion];
            [workItem release];
            [store release];
            return;
        } else {
            // <+660>
            if ((database.databaseScope == CKDatabaseScopePrivate) || (database.databaseScope == CKDatabaseScopeShared)) {
                // <+692>
                // self(block) = x25
                // x21
                NSManagedObjectContext *managedObjectContext = [monitor newBackgroundContextForMonitoredCoordinator];
                
                // sp, #0x2c0
                __block BOOL succeed = YES;
                // sp, #0x290
                __block NSError * _Nullable error = nil; 
                // sp, #0x268
                __block CKServerChangeToken * _Nullable changeToken = nil;
                
                /*
                 __54-[PFCloudKitImporter importIfNecessaryWithCompletion:]_block_invoke.6
                 self = sp + 0x230 = x19 + 0x20
                 store = sp + 0x238 = x19 + 0x28
                 managedObjectContext = sp + 0x240 = x19 + 0x30
                 changeToken = sp + 0x248 = x19 + 0x38
                 error = sp + 0x250 = x19 + 0x40
                 succeed = sp + 0x258 = x19 + 0x48
                 */
                [managedObjectContext performBlockAndWait:^{
                    // self(block) = x19
                    // try-catch 있음
                    @try {
                        CKDatabaseScope databaseScope;
                        {
                            OCCloudKitImporterOptions * _Nullable options = self->_options;
                            if (options == nil) {
                                databaseScope = 0;
                            } else {
                                databaseScope = options->_options.databaseScope;
                            }
                        }
                        
                        changeToken = [[OCCKDatabaseMetadata databaseMetadataForScope:databaseScope forStore:store inContext:managedObjectContext error:&error].currentChangeToken retain];
                        
                        if (error != nil) {
                            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData+CloudKit: %s(%d): Failed to fetch metadata for database: %@", __func__, __LINE__, error);
                            [error retain];
                        }
                    } @catch (NSException *exception) {
                        error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:134421 userInfo:@{
                            @"NSUnderlyingException": @"Import failed because fetching the database metadata encountered an unhandled exception."
                        }];
                    }
                }];
                
                // <+908>
                if (!succeed) {
                    // <+1320>
                    NSString *storeIdentifier;
                    {
                        if (monitor == nil) {
                            storeIdentifier = nil;
                        } else {
                            storeIdentifier = monitor->_storeIdentifier;
                        }
                    }
                    // x19
                    OCCloudKitMirroringResult *result = [[OCCloudKitMirroringResult alloc] initWithRequest:self->_request storeIdentifier:storeIdentifier success:NO madeChanges:NO error:error];
                    // nil 확인 없음
                    completion(result);
                    [result release];
                    [error release];
                    error = nil;
                    [managedObjectContext release];
                    [changeToken release];
                    return;
                }
                
                // x23
                OCCloudKitImportDatabaseContext *importDatabaseContext = [[OCCloudKitImportDatabaseContext alloc] init];
                // original : getCloudKitCKFetchDatabaseChangesOperationClass
                // x24
                CKFetchDatabaseChangesOperation *operation = [[CKFetchDatabaseChangesOperation alloc] init];
                operation.previousServerChangeToken = changeToken;
                [self->_request.options applyToOperation:operation];
                /*
                 __54-[PFCloudKitImporter importIfNecessaryWithCompletion:]_block_invoke.14
                 importDatabaseContext = sp + 0x208
                 */
                operation.recordZoneWithIDChangedBlock = ^(CKRecordZoneID * _Nonnull zoneID) {
                    if (importDatabaseContext != nil) {
                        [importDatabaseContext->_changedRecordZoneIDs addObject:zoneID];
                    }
                };
                
                /*
                 __54-[PFCloudKitImporter importIfNecessaryWithCompletion:]_block_invoke_2
                 importDatabaseContext = sp + 0x1e0
                 */
                operation.recordZoneWithIDWasDeletedBlock = ^(CKRecordZoneID * _Nonnull zoneID) {
                    if (importDatabaseContext != nil) {
                        [importDatabaseContext->_deletedRecordZoneIDs addObject:zoneID];
                    }
                };
                
                /*
                 __54-[PFCloudKitImporter importIfNecessaryWithCompletion:]_block_invoke_3
                 importDatabaseContext = sp + 0x1b8
                 */
                operation.recordZoneWithIDWasPurgedBlock = ^(CKRecordZoneID * _Nonnull zoneID) {
                    if (importDatabaseContext != nil) {
                        [importDatabaseContext->_purgedRecordZoneIDs addObject:zoneID];
                    }
                };
                
                /*
                 __54-[PFCloudKitImporter importIfNecessaryWithCompletion:]_block_invoke_4
                 importDatabaseContext = sp + 0x190
                 */
                operation.changeTokenUpdatedBlock = ^(CKServerChangeToken * _Nonnull serverChangeToken) {
                    importDatabaseContext.updatedChangeToken = serverChangeToken;
                };
                
                /*
                 __54-[PFCloudKitImporter importIfNecessaryWithCompletion:]_block_invoke_5
                 importDatabaseContext = sp + 0x168
                 */
                operation.recordZoneWithIDWasDeletedDueToUserEncryptedDataResetBlock = ^(CKRecordZoneID * _Nonnull zoneID) {
                    if (importDatabaseContext != nil) {
                        [importDatabaseContext->_userResetEncryptedDataZoneIDs addObject:zoneID];
                    }
                };
                
                __weak OCCloudKitImporter *weakSelf = self;
                /*
                 __54-[PFCloudKitImporter importIfNecessaryWithCompletion:]_block_invoke_6
                 importDatabaseContext = sp + 0x128 = x22 + 0x20
                 completion = sp + 0x130 = x22 + 0x28
                 weakSelf = sp + 0x138 = x22 + 0x30
                 */
                operation.fetchDatabaseChangesCompletionBlock = ^(CKServerChangeToken * _Nullable serverChangeToken, BOOL moreComing, NSError * _Nullable operationError) {
                    /*
                     self(block) = x22
                     serverChangeToken = x23
                     operationError = x20
                     */
                    // x19
                    OCCloudKitImporter *loaded = [weakSelf retain];
                    // x21
                    OCCloudKitImportDatabaseContext *context = [importDatabaseContext retain];
                    
                    if (loaded != nil) {
                        context.updatedChangeToken = serverChangeToken;
                        
                        dispatch_queue_t _Nullable workQueue;
                        {
                            OCCloudKitImporterOptions * _Nullable options = loaded->_options;
                            if (options == nil) {
                                workQueue = nil;
                            } else {
                                workQueue = options->_workQueue;
                            }
                        }
                        
                        /*
                         __54-[PFCloudKitImporter importIfNecessaryWithCompletion:]_block_invoke_7
                         loaded = sp + 0x20 = x21 + 0x20
                         context = sp + 0x28 = x21 + 0x28
                         operationError = sp + 0x30 = x21 + 0x30
                         completion = sp + 0x38 = x21 + 0x38
                         */
                        dispatch_async(workQueue, ^{
                            [loaded databaseFetchFinishWithContext:context error:operationError completion:completion];
                        });
                    }
                    
                    [loaded release];
                    [context release];
                };
                
                [database addOperation:operation];
                
                // <+1280>
                [operation release];
                [importDatabaseContext release];
                
                // <+1400>
                [error release];
                error = nil;
                [managedObjectContext release];
                [changeToken release];
                return;
            } else if (database.databaseScope == CKDatabaseScopePublic) {
                // <+1568>
                // x21
                NSPersistentStoreCoordinator * _Nullable monitoredCoordinator;
                {
                    if (monitor == nil) {
                        monitoredCoordinator = nil;
                    } else {
                        monitoredCoordinator = [monitor->_monitoredCoordinator retain];
                    }
                }
                
                // x19
                NSString *configurationName = store.configurationName;
                if (configurationName == nil) configurationName = @"PF_DEFAULT_CONFIGURATION_NAME";
                
                // x22
                NSMutableSet<CKRecordType> *set = [[NSMutableSet alloc] init];
                // sp + 0x30
                NSMutableArray<OCCloudKitCKQueryBackedImportWorkItem *> *array = [[NSMutableArray alloc] init];
                // monitoredCoordinator = sp + 0x8
                
                // w20
                BOOL flag = NO;
                // x27
                for (NSEntityDescription *entityDescription in [monitoredCoordinator.managedObjectModel entitiesForConfiguration:configurationName]) {
                    // <+1772>
                    CKRecordType recordType = [OCCloudKitSerializer recordTypeForEntity:entityDescription];
                    [set addObject:recordType];
                    
                    if (!flag) {
                        // x19
                        for (NSString *name in entityDescription.relationshipsByName) {
                            NSRelationshipDescription *relationshipDescription = [entityDescription.relationshipsByName objectForKey:name];
                            if (relationshipDescription.toMany && relationshipDescription.inverseRelationship.toMany) {
                                [set addObject:@"CDMR"];
                                flag = YES;
                            }
                        }
                    }
                }
                
                // x19
                for (CKRecordType recordType in set) {
                    // x19
                    OCCloudKitCKQueryBackedImportWorkItem *workItem = [[OCCloudKitCKQueryBackedImportWorkItem alloc] initForRecordType:recordType withOptions:self->_options request:self->_request];
                    [array addObject:workItem];
                    [workItem release];
                }
                
                // 기본값 release 안하는듯
                self->_workItems = [array copy];
                [self processWorkItemsWithCompletion:completion];
                [array release];
                [monitoredCoordinator release];
                [set release];
                [store release];
                return;
            } else {
                [store release];
                return;
            }
        }
    }];
}

- (void)processWorkItemsWithCompletion:(void (^)(OCCloudKitMirroringResult * _Nonnull))completion {
    /*
     self = x20
     completion = x19
     */
    
    os_log_with_type(_OCLogGetLogStream(0x11), OS_LOG_TYPE_DEFAULT, "OpenCloudData+CloudKit: %s(%d): %@: Processing work items: %@", __func__, __LINE__, self, self->_workItems);
    // x21
    OCCloudKitStoreMonitor * _Nullable monitor;
    {
        OCCloudKitImporterOptions * _Nullable options = self->_options;
        if (options == nil) {
            monitor = nil;
        } else {
            monitor = [options->_monitor retain];
        }
    }
    
    // x22
    OCCloudKitImporterWorkItem * _Nullable workItem;
    if (self->_workItems.count > 0) {
        workItem = [self->_workItems objectAtIndex:0];
        NSMutableArray<OCCloudKitImporterWorkItem *> *mutableWorkItems = [self->_workItems mutableCopy];
        [mutableWorkItems removeObjectAtIndex:0];
        [self->_workItems release];
        self->_workItems = [mutableWorkItems copy];
        [mutableWorkItems release];
    } else {
        workItem = nil;
    }
    
    if (workItem != nil) {
        // <+332>
        
        /*
         __53-[PFCloudKitImporter processWorkItemsWithCompletion:]_block_invoke
         monitor = sp + 0x60 = x21 + 0x20
         self = sp + 0x68 = x21 + 0x28
         workItem = sp + 0x70 = x21 + 0x30
         completion = sp + 0x78 = x21 + 0x38
         */
        [monitor performBlock:^{
            // self = x21
            // x19
            NSPersistentStoreCoordinator * _Nullable monitoredCoordinator;
            {
                if (monitor == nil) {
                    monitoredCoordinator = nil;
                } else {
                    monitoredCoordinator = [monitor->_monitoredCoordinator retain];
                }
            }
            // x20
            NSSQLCore * _Nullable store = [monitor retainedMonitoredStore];
            if (store == nil) {
                // <+300>
                NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:134407 userInfo:@{
                    NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"Request '%@' was cancelled because the store was removed from the coordinator.", self->_request.requestIdentifier]
                }];
                
                NSString *storeIdentifier;
                {
                    if (monitor == nil) {
                        storeIdentifier = nil;
                    } else {
                        storeIdentifier = monitor->_storeIdentifier;
                    }
                }
                
                // x22
                OCCloudKitMirroringResult *result = [[OCCloudKitMirroringResult alloc] initWithRequest:self->_request storeIdentifier:storeIdentifier success:NO madeChanges:NO error:error];
                
                // nil 확인 없음
                completion(result);
                [result release];
                [store release];
                [monitoredCoordinator release];
                return;
            }
            
            BOOL defer;
            {
                if (self == nil) {
                    defer = NO;
                } else {
                    // x22
                    OCCloudKitMirroringImportRequest * _Nullable request = self->_request;
                    if (request == nil) {
                        defer = NO;
                    } else {
                        CKSchedulerActivity *schedulerActivity = request->_schedulerActivity;
                        if (schedulerActivity.shouldDefer) {
                            defer = YES;
                        } else {
                            defer = request->_deferredByBackgroundTimeout;
                        }
                    }
                }
            }
            
            if (defer) {
                // <+132>
                NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:134419 userInfo:@{
                    NSLocalizedFailureReasonErrorKey: @"The request was aborted because it was deferred by the system."
                }];
                
                NSString *storeIdentifier;
                {
                    if (monitor == nil) {
                        storeIdentifier = nil;
                    } else {
                        storeIdentifier = monitor->_storeIdentifier;
                    }
                }
                
                // x22
                OCCloudKitMirroringResult *result = [[OCCloudKitMirroringResult alloc] initWithRequest:self->_request storeIdentifier:storeIdentifier success:NO madeChanges:NO error:error];
                // nil 확인 없음
                completion(result);
                [result release];
                [store release];
                [monitoredCoordinator release];
                return;
            }
            
            // <+508>
            // sp + 0x40
            __weak OCCloudKitImporter *weakSelf = self;
            /*
             __53-[PFCloudKitImporter processWorkItemsWithCompletion:]_block_invoke_2
             workItem = sp + 0x28 = x21 + 0x20
             completion = sp + 0x30 = x21 + 0x28
             weakSelf = sp + 0x38 = x21 + 0x30
             */
            [workItem doWorkForStore:store inMonitor:monitor completion:^(OCCloudKitMirroringResult * _Nonnull result) {
                /*
                 self(block) = x21
                 result = x20
                 */
                // x19
                OCCloudKitImporter *loaded = [weakSelf retain];
                if (loaded == nil) {
                    [loaded release];
                    return;
                }
                
                dispatch_queue_t _Nullable workQueue;
                {
                    OCCloudKitImporterOptions * _Nullable options = loaded->_options;
                    if (options == nil) {
                        workQueue = nil;
                    } else {
                        workQueue = options->_workQueue;
                    }
                }
                
                /*
                 __53-[PFCloudKitImporter processWorkItemsWithCompletion:]_block_invoke_3
                 loaded = sp + 0x20 = x21 + 0x20
                 result = sp + 0x28 = x21 + 0x28
                 workItem = sp + 0x30 = x21 + 0x30
                 completion = sp + 0x38 = x21 + 0x38
                 */
                dispatch_async(workQueue, ^{
                    @autoreleasepool {
                        [loaded workItemFinished:workItem withResult:result completion:completion];
                    }
                });
            }];
            
            [store release];
            [monitoredCoordinator release];
        }];
    } else {
        // <+396>
        /*
         __53-[PFCloudKitImporter processWorkItemsWithCompletion:]_block_invoke_4
         monitor = sp + 0x28 = x27 + 0x20
         self = sp + 0x30 = x27 + 0x28
         completion = sp + 0x38 = x27 + 0x30
         */
        [monitor performBlock:^{
            // self = x27
            // x26
            NSSQLCore * _Nullable store = [monitor retainedMonitoredStore];
            if (store == nil) {
                // <+916>
                NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:134407 userInfo:@{
                    NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"Request '%@' was cancelled because the store was removed from the coordinator.", self->_request.requestIdentifier]
                }];
                
                NSString *storeIdentifier;
                {
                    if (monitor == nil) {
                        storeIdentifier = nil;
                    } else {
                        storeIdentifier = monitor->_storeIdentifier;
                    }
                }
                
                // x19
                OCCloudKitMirroringResult *result = [[OCCloudKitMirroringResult alloc] initWithRequest:self->_request storeIdentifier:storeIdentifier success:NO madeChanges:NO error:error];
                
                // nil 확인 없음
                completion(result);
                [result release];
                [store release];
                return;
            }
            
            // x20
            NSManagedObjectContext *managedObjectContext = [monitor newBackgroundContextForMonitoredCoordinator];
            
            // sp, #0x128
            __block BOOL succeed = YES;
            // w22
            BOOL madeChanges = NO;
            // sp, #0xc8
            __block OCCloudKitMirroringResult * _Nullable result = nil;
            // sp, #0xf8
            __block NSError * _Nullable error = nil;
            
            if (_workItemResults.count >= 2) {
                // x23
                NSMutableArray<NSError *> *errors = [[NSMutableArray alloc] init];
                // x21
                for (OCCloudKitMirroringResult *result in _workItemResults) {
                    if (!result.success) {
                        succeed = NO;
                        if (result.error != nil) {
                            // <+356>
                            [errors addObject:result.error];
                            // <+432>
                        } else {
                            // <+384>
                            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Work item result failed but did not include an error: %@\n", result);
                            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Work item result failed but did not include an error: %@\n", result);
                            // <+520>
                            continue;
                        }
                    }
                    
                    // <+432>
                    // x19
                    BOOL madeChanges = result.madeChanges;
                    
                    if ([result class] != [OCCloudKitMirroringResult class]) {
                        os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: The importer needs to be taught how to merge results of different types when dealing with multiple work items: %@\n", result);
                        os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: The importer needs to be taught how to merge results of different types when dealing with multiple work items: %@\n", result);
                    }
                    
                    // <+520>
                    succeed |= madeChanges;
                }
                
                // <+792>
                if (errors.count >= 2) {
                    error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:134404 userInfo:@{
                        NSDetailedErrorsKey: errors
                    }];
                    // <+1288>
                } else if (errors.count == 1) {
                    error = [errors.lastObject retain];
                } else {
                    error = nil;
                }
                // <+1296>
                [errors release];
            } else if (_workItemResults.count == 1) {
                // <+1144>
                succeed = _workItemResults.lastObject.success;
                madeChanges = _workItemResults.lastObject.madeChanges;
                error = [_workItemResults.lastObject.error retain];
                result = [_workItemResults.lastObject retain];
                // <+1300>
            } else {
                // <+1244>
                madeChanges = NO;
                error = nil;
            }
            
            // <+1300>
            if (succeed) {
                // <+1316>
                /*
                 __53-[PFCloudKitImporter processWorkItemsWithCompletion:]_block_invoke.45
                 self = sp + 0x50 = x19 + 0x20
                 store = sp + 0x58 = x19 + 0x28
                 managedObjectContext = sp + 0x60 = x19 + 0x30
                 succeed = sp + 0x68 = x19 + 0x38
                 error = sp + 0x70 = x19 + 0x40
                 result = sp + 0x78 = x19 + 0x48
                 */
                [managedObjectContext performBlockAndWait:^{
                    // self(block) = x19
                    @try {
                        // sp + 0x8
                        NSError * _Nullable _error = nil;
                        
                        CKDatabaseScope databaseScope;
                        {
                            OCCloudKitImporterOptions * _Nullable options = self->_options;
                            if (options == nil) {
                                databaseScope = 0;
                            } else {
                                databaseScope = options->_options.databaseScope;
                            }
                        }
                        
                        // x20
                        OCCKDatabaseMetadata * _Nullable metadata = [OCCKDatabaseMetadata databaseMetadataForScope:databaseScope forStore:store inContext:managedObjectContext error:&_error];
                        
                        if (metadata == nil) {
                            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData+CloudKit: %s(%d): %@: Error fetching database metadata update for request: %@\n%@", __func__, __LINE__, self, self->_request, _error);
                            succeed = NO;
                            error = [_error retain];
                            return;
                        }
                        
                        // <+100>
                        metadata.currentChangeToken = self->_updatedDatabaseChangeToken;
                        metadata.lastFetchDate = [NSDate date];
                        
                        BOOL _result = [managedObjectContext save:&_error];
                        if (!_result) {
                            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData+CloudKit: %s(%d): %@: Error fetching database metadata update for request: %@\n%@", __func__, __LINE__, self, self->_request, _error);
                            succeed = NO;
                            error = [_error retain];
                            [result release];
                            result = nil;
                            return;
                        }
                    } @catch (NSException *exception) {
                        error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:134421 userInfo:@{
                            @"NSUnderlyingException": @"Import failed because the post-operation metadata commit hit an unhandled exception."
                        }];
                        [result release];
                        result = nil;
                    }
                }];
                
                // <+1400>
                [managedObjectContext release];
                managedObjectContext = nil;
                // <+1408>
            }
            
            // <+1408>
            if (result == nil) {
                NSString *storeIdentifier;
                {
                    if (monitor == nil) {
                        storeIdentifier = nil;
                    } else {
                        storeIdentifier = monitor->_storeIdentifier;
                    }
                }
                
                result = [[OCCloudKitMirroringResult alloc] initWithRequest:self->_request storeIdentifier:storeIdentifier success:succeed madeChanges:madeChanges error:error];
            }
            
            // <+1484>
            NSString * _Nullable containerIdentifier;
            {
                OCCloudKitImporterOptions * _Nullable options = self->_options;
                if (options == nil) {
                    containerIdentifier = nil;
                } else {
                    OCCloudKitMirroringDelegateOptions * _Nullable delegateOptions = options->_options;
                    if (delegateOptions == nil) {
                        containerIdentifier = nil;
                    } else {
                        containerIdentifier = delegateOptions.containerIdentifier;
                    }
                }
            }
            // x19
            OCCloudKitImportedRecordBytesMetric *metric = [[OCCloudKitImportedRecordBytesMetric alloc] initWithContainerIdentifier:containerIdentifier];
            [metric addByteSize:self->_totalImportedBytes];
            
            OCCloudKitMetricsClient * _Nullable metricsClient;
            {
                OCCloudKitImporterOptions * _Nullable options = self->_options;
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
            
            if (completion != nil) {
                completion(result);
            }
            
            // <+1616>
            [result release];
            result = nil;
            [managedObjectContext release];
            managedObjectContext = nil;
            [error release];
            error = nil;
        }];
    }
}

- (void)workItemFinished:(OCCloudKitImporterWorkItem *)workItem withResult:(OCCloudKitMirroringResult *)result completion:(void (^)(OCCloudKitMirroringResult * _Nonnull))completion {
    // inlined from __53-[PFCloudKitImporter processWorkItemsWithCompletion:]_block_invoke_3
    // self = x20
    
    /*
     __61-[PFCloudKitImporter workItemFinished:withResult:completion:]_block_invoke
     self = sp + 0x20 = x19 + 0x20
     result = sp + 0x28 = x19 + 0x28
     workItem = sp + 0x30 = x19 + 0x30
     completion = sp + 0x38 = x21 + 0x38
     */
    [objc_lookUpClass("_PFRoutines") wrapBlockInGuardedAutoreleasePool:^{
        // self(block) = x19
        [self->_workItemResults addObject:result];
        if (!result.success) {
            return;
        }
        
        if ([workItem isKindOfClass:[OCCloudKitImporterZoneChangedWorkItem class]]) {
            OCCloudKitImporterZoneChangedWorkItem *casted = (OCCloudKitImporterZoneChangedWorkItem *)workItem;
            
            size_t sizeInBytes;
            {
                if (workItem == nil) {
                    sizeInBytes = 0;
                } else {
                    OCCloudKitFetchedRecordBytesMetric * _Nullable fetchedRecordBytesMetric = casted->_fetchedRecordBytesMetric;
                    if (fetchedRecordBytesMetric == nil) {
                        sizeInBytes = 0;
                    } else {
                        sizeInBytes = fetchedRecordBytesMetric->_sizeInBytes.unsignedIntegerValue;
                    }
                }
            }
            
            self->_totalImportedBytes += sizeInBytes;
        }
        
        [self processWorkItemsWithCompletion:completion];
    }];
}

- (void)databaseFetchFinishWithContext:(OCCloudKitImportDatabaseContext *)context error:(NSError *)error completion:(void (^)(OCCloudKitMirroringResult * _Nonnull))completion {
    // inlined from __54-[PFCloudKitImporter importIfNecessaryWithCompletion:]_block_invoke_7
    /*
     self = sp + 0x8
     error = x20
     completion = x19
     */
    if (error != nil) {
        // <+68>
        os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData+CloudKit: %s(%d): %@: Database fetch for request: %@ failed with error: %@", __func__, __LINE__, self, self->_request, error);
        
        if (completion != nil) {
            NSString *storeIdentifier;
            {
                OCCloudKitImporterOptions * _Nullable options = self->_options;
                if (options == nil) {
                    storeIdentifier = nil;
                } else {
                    OCCloudKitStoreMonitor * _Nullable monitor = options->_monitor;
                    if (monitor == nil) {
                        storeIdentifier = nil;
                    } else {
                        storeIdentifier = monitor->_storeIdentifier;
                    }
                }
            }
            
            // x20
            OCCloudKitMirroringResult *result = [[OCCloudKitMirroringResult alloc] initWithRequest:self->_request storeIdentifier:storeIdentifier success:NO madeChanges:NO error:error];
            completion(result);
            [result release];
        }
    } else {
        // <+320>
        /*
         context = x21
         */
        // x20
        OCCloudKitStoreMonitor * _Nullable monitor;
        {
            OCCloudKitImporterOptions * _Nullable options = self->_options;
            if (options == nil) {
                monitor = nil;
            } else {
                monitor = [options->_monitor retain];
            }
        }
        
        /*
         __70-[PFCloudKitImporter databaseFetchFinishWithContext:error:completion:]_block_invoke
         monitor = sp + 0x30 = x22 + 0x20
         self = sp + 0x38 = x22 + 0x28
         context(OCCloudKitImportDatabaseContext) = sp + 0x40 = x22 + 0x30
         completion = sp + 0x48 = x22 + 0x38
         */
        [monitor performBlock:^{
            // self(block) = x22
            // x28
            NSSQLCore * _Nullable store = [monitor retainedMonitoredStore];
            if (store == nil) {
                NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:134407 userInfo:@{
                    NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"Request '%@' was cancelled because the store was removed from the coordinator.", self->_request.requestIdentifier]
                }];
                
                NSString *storeIdentifier;
                {
                    if (monitor == nil) {
                        storeIdentifier = nil;
                    } else {
                        storeIdentifier = monitor->_storeIdentifier;
                    }
                }
                
                // x19
                OCCloudKitMirroringResult *result = [[OCCloudKitMirroringResult alloc] initWithRequest:self->_request storeIdentifier:storeIdentifier success:NO madeChanges:NO error:error];
                completion(result);
                [result release];
                return;
            }
            
            // x19
            NSManagedObjectContext *managedObjectContext = [monitor newBackgroundContextForMonitoredCoordinator];
            
            CKDatabaseScope databaseScope;
            {
                OCCloudKitImporterOptions * _Nullable options = self->_options;
                if (options == nil) {
                    databaseScope = 0;
                } else {
                    databaseScope = options->_options.databaseScope;
                }
            }
            
            // sp, #0x108
            __block BOOL _succeed = YES;
            // sp, #0xd0
            __block NSError * _Nullable _error = nil;
            
            
            /*
             __70-[PFCloudKitImporter databaseFetchFinishWithContext:error:completion:]_block_invoke_2
             store = sp + 0xa0 = x19 + 0x20
             managedObjectContext = sp + 0xa8 = x19 + 0x28
             context(OCCloudKitImportDatabaseContext) = sp + 0xb0 = x19 + 0x30
             _succeed = sp + 0xb8 = x19 + 0x38
             _error = sp + 0xc0 = x19 + 0x40
             databaseScope = sp + 0xc8 = x19 + 0x48
             */
            [managedObjectContext performBlockAndWait:^{
                // self(block) = x19
                
                @try {
                    // sp, #0x58
                    NSError * _Nullable __error = nil;
                    
                    // x20
                    NSFetchRequest<OCCKRecordZoneMetadata *> *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[OCCKRecordZoneMetadata entityPath]];
                    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"needsImport = YES AND database.databaseScopeNum = %@ AND (needsNewShareInvitation = NO OR needsNewShareInvitation = NULL)", @(databaseScope)];
                    fetchRequest.affectedStores = @[store];
                    fetchRequest.returnsObjectsAsFaults = NO;
                    
                    // x20
                    NSArray<OCCKRecordZoneMetadata *> * _Nullable fetchedRecordZoneMetadataArray = [managedObjectContext executeFetchRequest:fetchRequest error:&__error];
                    if (fetchedRecordZoneMetadataArray == nil) {
                        _succeed = NO;
                        _error = [__error retain];
                        return;
                    }
                    
                    // x23
                    for (OCCKRecordZoneMetadata *metadata in fetchedRecordZoneMetadataArray) {
                        // x22
                        CKRecordZoneID *recordZoneID = [metadata createRecordZoneID];
                        if (metadata.needsImport && !([context.deletedRecordZoneIDs containsObject:recordZoneID]) && !([context.purgedRecordZoneIDs containsObject:recordZoneID])) {
                            [context.changedRecordZoneIDs addObject:recordZoneID];
                        }
                        [recordZoneID release];
                    }
                } @catch (NSException *exception) {
                    _succeed = NO;
                    _error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:134421 userInfo:@{
                        @"NSUnderlyingException": @"Import failed because an unhandled exception was encountered while trying to process the results of the database fetch operation."
                    }];
                }
            }];
            
            if (!_succeed) {
                // <+1080>
                NSString *storeIdentifier;
                {
                    if (monitor == nil) {
                        storeIdentifier = nil;
                    } else {
                        storeIdentifier = monitor->_storeIdentifier;
                    }
                }
                
                // x21
                OCCloudKitMirroringResult *result = [[OCCloudKitMirroringResult alloc] initWithRequest:self->_request storeIdentifier:storeIdentifier success:NO madeChanges:NO error:_error];
                completion(result);
                [result release];
                
                [_error release];
                _error = nil;
                [managedObjectContext release];
                [store release];
                return;
            }
            
            // <+264>
            // managedObjectContext = sp + 0x28
            if (context.hasWorkToDo) {
                // <+296>
                os_log_with_type(_OCLogGetLogStream(0x11), OS_LOG_TYPE_DEFAULT, "OpenCloudData+CloudKit: %s(%d): %@: Import request finished: %@ - %@", __func__, __LINE__, self, self->_request, context);
                // <+476>
                // 기존 값에 release 안하고 있음
                self->_updatedDatabaseChangeToken = [context.updatedChangeToken retain];
                
                /*
                 self = x21
                 context(OCCloudKitImportDatabaseContext) = x19
                 completion = sp + 0x18
                 */
                // x22
                NSMutableArray<OCCloudKitImporterWorkItem *> *array_1 = [[NSMutableArray alloc] init];
                // context(OCCloudKitImportDatabaseContext) = sp + 0x20
                
                if (context.changedRecordZoneIDs.count == 0) {
                    // nop
                    // <+1580>
                } else if (context.changedRecordZoneIDs.count <= 400) {
                    // <+1500>
                    // x24
                    OCCloudKitImporterZoneChangedWorkItem *workItem = [[OCCloudKitImporterZoneChangedWorkItem alloc] initWithChangedRecordZoneIDs:context.changedRecordZoneIDs.allObjects options:self->_options request:self->_request];
                    [array_1 addObject:workItem];
                    [workItem release];
                    // <+1580>
                } else {
                    // <+572>
                    // x24
                    NSMutableArray<CKRecordZoneID *> *array_2 = [[NSMutableArray alloc] init];
                    
                    for (CKRecordZoneID *changedRecordZoneID in context.changedRecordZoneIDs) {
                        [array_2 addObject:changedRecordZoneID];
                        
                        if (array_2.count == 400) {
                            // <+708>
                            // x27
                            OCCloudKitImporterZoneChangedWorkItem *workItem = [[OCCloudKitImporterZoneChangedWorkItem alloc] initWithChangedRecordZoneIDs:array_2 options:self->_options request:self->_request];
                            [array_1 addObject:workItem];
                            [workItem release];
                            [array_2 release];
                            array_2 = [[NSMutableArray alloc] init];
                        }
                    }
                    
                    if (array_2.count != 0) {
                        // x25
                        OCCloudKitImporterZoneChangedWorkItem *workItem = [[OCCloudKitImporterZoneChangedWorkItem alloc] initWithChangedRecordZoneIDs:array_2 options:self->_options request:self->_request];
                        [array_1 addObject:workItem];
                        [workItem release];
                    }
                    
                    [array_2 release];
                }
                
                // <+1580>
                // x26
                for (CKRecordZoneID *deletedRecordID in context.deletedRecordZoneIDs) {
                    // x26
                    OCCloudKitImporterZoneDeletedWorkItem *workItem = [[OCCloudKitImporterZoneDeletedWorkItem alloc] initWithDeletedRecordZoneID:deletedRecordID options:self->_options request:self->_request];
                    [array_1 addObject:workItem];
                    [workItem release];
                }
                
                // <+1832>
                // x26
                for (CKRecordZoneID *purgedRecordZoneID in context.purgedRecordZoneIDs) {
                    // x26
                    OCCloudKitImporterZonePurgedWorkItem *workItem = [[OCCloudKitImporterZonePurgedWorkItem alloc] initWithPurgedRecordZoneID:purgedRecordZoneID options:self->_options request:self->_request];
                    [array_1 addObject:workItem];
                    [workItem release];
                }
                
                // x26
                for (CKRecordZoneID *userResetEncryptedDataZoneID in context.userResetEncryptedDataZoneIDs) {
                    OCCloudKitImporterZoneDeletedWorkItem *workItem = [[OCCloudKitImporterZoneDeletedWorkItem alloc] initWithDeletedRecordZoneID:userResetEncryptedDataZoneID options:self->_options request:self->_request];
                    [array_1 addObject:workItem];
                    [workItem release];
                }
                
                self->_workItems = [array_1 copy];
                [array_1 release];
                
                // <+2112>
                [self processWorkItemsWithCompletion:completion];
                // <+2128>
            } else {
                // <+1160>
                os_log_with_type(_OCLogGetLogStream(0x11), OS_LOG_TYPE_DEFAULT, "OpenCloudData+CloudKit: %s(%d): %@: Import request finished with no work to do: %@", __func__, __LINE__, self, self->_request);
                
                /*
                 __70-[PFCloudKitImporter databaseFetchFinishWithContext:error:completion:]_block_invoke.39
                 self = sp + 0x50 = x19 + 0x20
                 store = sp + 0x58 = x19 + 0x28
                 managedObjectContext = sp + 0x60 = x19 + 0x30
                 context(OCCloudKitImportDatabaseContext) = sp + 0x68 = x19 + 0x38
                 _succeed = sp + 0x70 = x19 + 0x40
                 _error = sp + 0x78 = x19 + 0x48
                 */
                [managedObjectContext performBlockAndWait:^{
                    @try {
                        // self = x19
                        // sp, #0x8
                        NSError * _Nullable __error = nil;
                        
                        CKDatabase * _Nullable database;
                        {
                            OCCloudKitImporterOptions * _Nullable options = self->_options;
                            if (options == nil) {
                                database = nil;
                            } else {
                                database = options->_database;
                            }
                        }
                        
                        // x20
                        OCCKDatabaseMetadata * _Nullable metadata = [OCCKDatabaseMetadata databaseMetadataForScope:database.databaseScope forStore:store inContext:managedObjectContext error:&__error];
                        
                        if (metadata == nil) {
                            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData+CloudKit: %s(%d): %@: Error fetching database metadata update for request: %@\n%@", __func__, __LINE__, self, self->_request, __error);
                            return;
                        }
                        
                        metadata.currentChangeToken = context.updatedChangeToken;
                        metadata.lastFetchDate = [NSDate date];
                        
                        BOOL result = [managedObjectContext save:&__error];
                        if (!result) {
                            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData+CloudKit: %s(%d): %@: Error fetching database metadata update for request: %@\n%@", __func__, __LINE__, self, self->_request, __error);
                        }
                    } @catch (NSException *exception) {
                        _succeed = NO;
                        _error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:134421 userInfo:@{
                            @"NSUnderlyingException": @"Import failed because an unhandled exception was encountered while trying to process the results of the database fetch operation."
                        }];
                    }
                }];
                
                if (completion != nil) {
                    // <+1408>
                    NSString *storeIdentifier;
                    {
                        if (monitor == nil) {
                            storeIdentifier = nil;
                        } else {
                            storeIdentifier = monitor->_storeIdentifier;
                        }
                    }
                    
                    // x21
                    OCCloudKitMirroringResult *result = [[OCCloudKitMirroringResult alloc] initWithRequest:self->_request storeIdentifier:storeIdentifier success:YES madeChanges:NO error:nil];
                    completion(result);
                    [result release];
                }
                
                // <+2128>
            }
            
            // <+2128>
            [_error release];
            _error = nil;
            [managedObjectContext release];
            managedObjectContext = nil;
            [store release];
        }];
        [monitor release];
    }
}

@end
