//
//  OCCloudKitSetupAssistant.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/26/25.
//

#import "OpenCloudData/Private/OCCloudKitSetupAssistant.h"
#import "OpenCloudData/Private/Log.h"

@implementation OCCloudKitSetupAssistant

- (instancetype)initWithSetupRequest:(OCCloudKitMirroringDelegateSetupRequest *)setupRequest mirroringOptions:(OCCloudKitMirroringDelegateOptions *)mirroringOptions observedStore:(NSSQLCore *)observedStore {
    /*
     setupRequest = x22
     mirroringOptions = x21
     observedStore = x19
     */
    if (self = [super init]) {
        _setupRequest = [setupRequest retain];
        _cloudKitSemaphore = dispatch_semaphore_create(0);
        _mirroringOptions = [mirroringOptions retain];
        _storeMonitor = [_mirroringOptions.storeMonitorProvider createMonitorForObservedStore:observedStore inTransactionWithLabel:nil];
    }
    
    return self;
}

- (void)dealloc {
    [_setupRequest release];
    [_setupEvent release];
    [_container release];
    _container = nil;
    [_database release];
    _database = nil;
    [_databaseSubscription release];
    _databaseSubscription = nil;
    [_largeBlobDirectoryURL release];
    _largeBlobDirectoryURL = nil;
    [_mirroringOptions release];
    [_storeMonitor release];
    [_currentUserRecordID release];
    _currentUserRecordID = nil;
    if (_cloudKitSemaphore != nil) {
        dispatch_release(_cloudKitSemaphore);
    }
    [super dealloc];
}

- (BOOL)_initializeCloudKitForObservedStore:(NSError **)error andNoteMetadataInitialization:(BOOL *)metadataInitializationPtr {
    /*
     self = x20
     observedStorePtr = x19
     metadataInitializationPtr = x22
     */
    // w23
    BOOL skipCloudKitSetup = self->_mirroringOptions.skipCloudKitSetup;
    // sp, #0x20
    __block BOOL _succeed = YES;
    // sp, #0xe0
    __block NSError * _Nullable _error = nil;
    
    [self beginActivityForPhase:1];
    
    OCCloudKitStoreMonitor *storeMonitor = _storeMonitor;
    /*
     __56-[PFCloudKitSetupAssistant _checkAndInitializeMetadata:]_block_invoke
     storeMonitor = sp + 0x170
     self = sp + 0x178
     _succeed = sp + 0x180
     _error = sp + 0x188
     */
    [storeMonitor performBlock:^{
        abort();
    }];
    
    [self endActivityForPhase:1 withError:_error];
    
    // x21
    NSError * _Nullable __error = nil;
    if (!_succeed) {
        // <+276>
        __error = [[_error retain] autorelease];
        
        if (__error == nil) {
            // <+900>
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        }
    }
    
    // <+300>
    [_error release];
    _error = nil;
    
    if (!_succeed) {
        // __error = x23
        if (__error == nil) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        }
        if (error != NULL) *error = __error;
        return NO;
    }
    
    _succeed = YES;
    
    if (skipCloudKitSetup) {
        // <+372>
    } else {
        // <+556>
    }
    abort();
}

- (void)beginActivityForPhase:(NSUInteger)phase {
    abort();
}

- (void)endActivityForPhase:(NSUInteger)phase withError:(NSError *)error {
    abort();
}

@end
