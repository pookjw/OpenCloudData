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
#import <OpenCloudData/Log.h>

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
                NSMutableSet *set = [[NSMutableSet alloc] init];
                // sp + 0x30
                NSMutableArray *array = [[NSMutableArray alloc] init];
                // monitoredCoordinator = sp + 0x8
                
                // x27
                for (NSEntityDescription *entityDescription in [monitoredCoordinator.managedObjectModel entitiesForConfiguration:configurationName]) {
                    // <+1772>
                    abort();
                }
                abort();
            } else {
                [store release];
                return;
            }
        }
    }];
}

- (void)processWorkItemsWithCompletion:(void (^)(OCCloudKitMirroringResult * _Nonnull))completion {
    abort();
}

@end
