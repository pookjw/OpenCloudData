//
//  OCCloudKitImporter.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/14/25.
//

#import <OpenCloudData/OCCloudKitImporter.h>
#import <OpenCloudData/OCCloudKitMirroringFetchRecordsRequest.h>
#import <OpenCloudData/OCCloudKitImporterFetchRecordsWorkItem.h>
#import <OpenCloudData/OCCloudKitImportDatabaseContext.h>
#import <OpenCloudData/OCCloudKitSerializer.h>
#import <OpenCloudData/OCCloudKitCKQueryBackedImportWorkItem.h>
#import <OpenCloudData/OCCloudKitImporterZoneChangedWorkItem.h>
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
                 database = sp + 0x238 = x19 + 0x28
                 managedObjectContext = sp + 0x240 = x19 + 0x30
                 changeToken = sp + 0x248 = x19 + 0x38
                 error = sp + 0x250 = x19 + 0x40
                 succeed = sp + 0x258 = x19 + 0x48
                 */
                [managedObjectContext performBlockAndWait:^{
                    // self(block) = x19
                    // try-catch 있음
                    abort();
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
                    abort();
                };
                
                /*
                 __54-[PFCloudKitImporter importIfNecessaryWithCompletion:]_block_invoke_2
                 importDatabaseContext = sp + 0x1e0
                 */
                operation.recordZoneWithIDWasDeletedBlock = ^(CKRecordZoneID * _Nonnull zoneID) {
                    abort();
                };
                
                /*
                 __54-[PFCloudKitImporter importIfNecessaryWithCompletion:]_block_invoke_3
                 importDatabaseContext = sp + 0x1b8
                 */
                operation.recordZoneWithIDWasPurgedBlock = ^(CKRecordZoneID * _Nonnull zoneID) {
                    abort();
                };
                
                /*
                 __54-[PFCloudKitImporter importIfNecessaryWithCompletion:]_block_invoke_4
                 importDatabaseContext = sp + 0x190
                 */
                operation.changeTokenUpdatedBlock = ^(CKServerChangeToken * _Nonnull serverChangeToken) {
                    abort();
                };
                
                /*
                 __54-[PFCloudKitImporter importIfNecessaryWithCompletion:]_block_invoke_5
                 importDatabaseContext = sp + 0x168
                 */
                operation.recordZoneWithIDWasDeletedDueToUserEncryptedDataResetBlock = ^(CKRecordZoneID * _Nonnull zoneID) {
                    
                };
                
                __weak OCCloudKitImporter *weakSelf = self;
                /*
                 __54-[PFCloudKitImporter importIfNecessaryWithCompletion:]_block_invoke_6
                 importDatabaseContext = sp + 0x128
                 completion = sp + 0x130
                 weakSelf = sp + 0x138
                 */
                operation.fetchDatabaseChangesCompletionBlock = ^(CKServerChangeToken * _Nullable serverChangeToken, BOOL moreComing, NSError * _Nullable operationError) {
                    abort();
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
         */
        [monitor performBlock:^{
            // self = x27
            // x26
            NSSQLCore * _Nullable store = [monitor retainedMonitoredStore];
            abort();
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

@end
