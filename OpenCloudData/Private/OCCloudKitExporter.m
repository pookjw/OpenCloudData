//
//  OCCloudKitExporter.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/4/25.
//

#import <OpenCloudData/OCCloudKitExporter.h>
#import <OpenCloudData/Log.h>
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
    NSMutableArray *array = [[NSMutableArray alloc] init];
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
         monitor = sp + 0x20 = x19 + 0x20
         self = sp + 0x28 = x19 + 0x28
         array = sp + 0x30 = x19 + 0x30
         error = sp + 0x38 = x19 + 0x38
         succeed = sp + 0x40 = x19 + 0x40
         operation = sp + 0x48 = x19 + 0x48
         */
        [_monitor performBlock:^{
            __kindof NSPersistentStore * _Nullable monitoredStore = [self->_monitor retainedMonitoredStore];
            if (monitoredStore == nil) {
                succeed = NO;
                error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:134407 userInfo:@{NSLocalizedFailureReasonErrorKey: self->_request.requestIdentifier}];
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
                    monitoredCoordinator = monitor->_monitoredCoordinator;
                }
            }
            
            // x22
            NSManagedObjectContext *backgroundContextForMonitoredCoordinator = [monitor newBackgroundContextForMonitoredCoordinator];
            // original : NSCloudKitMirroringDelegateExportContextName
#warning TODO 바꿔도 되나?
            backgroundContextForMonitoredCoordinator.transactionAuthor = @"NSCloudKitMirroringDelegate.export";
            
            /*
             monitoredStore = sp + 0x30 = x19 + 0x20
             backgroundContextForMonitoredCoordinator = sp + 0x38 = x19 + 0x28
             self = sp + 0x40 = x19 + 0x30
             array = sp + 0x48 = x19 + 0x38
             error = sp + 0x50 = x19 + 0x40
             succeed = sp + 0x58 = x19 + 0x48
             operation = sp + 0x60 = x19 + 0x50
             */
            [backgroundContextForMonitoredCoordinator performBlockAndWait:^{
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
                
                // <+316>
                abort();
            }];
            
            // <+184>
            abort();
        }];
        abort();
    }
    
    // <+412>
    abort();
}

@end
