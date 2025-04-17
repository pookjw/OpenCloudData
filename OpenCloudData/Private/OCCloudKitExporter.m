//
//  OCCloudKitExporter.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/4/25.
//

#import <OpenCloudData/OCCloudKitExporter.h>
#import <OpenCloudData/Log.h>

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
    
    BOOL succeed = YES;;
    NSError * _Nullable error = nil;
    if (request != nil) {
        CKSchedulerActivity *schedulerActivity = request->_schedulerActivity;
        if (schedulerActivity.shouldDefer || request->_deferredByBackgroundTimeout) {
            succeed = NO;
            error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:134419 userInfo:@{NSLocalizedFailureReasonErrorKey: @"The request was aborted because it was deferred by the system."}];
        }
    } else {
        // <+332>
        [_monitor performBlock:^{
            // __48-[PFCloudKitExporter checkForZonesNeedingExport]_block_invoke
        }];
        abort();
    }
    
    // <+412>
    abort();
}

@end
