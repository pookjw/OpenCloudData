//
//  OCCloudKitSetupAssistant.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/26/25.
//

#import "OpenCloudData/Private/OCCloudKitSetupAssistant.h"

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

- (BOOL)_initializeCloudKitForObservedStore:(NSSQLCore **)observedStorePtr andNoteMetadataInitialization:(BOOL *)metadataInitializationPtr {
    abort();
}

- (void)beginActivityForPhase:(NSUInteger)phase {
    abort();
}

- (void)endActivityForPhase:(NSUInteger)phase withError:(NSError *)error {
    abort();
}

@end
