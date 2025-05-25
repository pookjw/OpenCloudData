//
//  OCCloudKitMirroringDelegate.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/1/25.
//

#import "OpenCloudData/Private/OCCloudKitMirroringDelegate.h"
#import "OpenCloudData/Private/OCCloudKitLogging.h"
#import "OpenCloudData/Private/OCCloudKitStoreComparer.h"
#import "OpenCloudData/Private/Log.h"
#import "OpenCloudData/Private/Request/OCCloudKitMirroringDelegateResetRequest.h"
#import "OpenCloudData/Private/OCCloudKitMirroringDelegateWorkBlockContext.h"
#import "OpenCloudData/Private/Request/OCCloudKitMirroringDelegateSetupRequest.h"
#import "OpenCloudData/Private/Request/OCCloudKitMirroringFetchRecordsRequest.h"
#import "OpenCloudData/Private/Model/OCCKEvent.h"
#import "OpenCloudData/Private/Import/OCCloudKitImporterOptions.h"
#import "OpenCloudData/Private/OCCloudKitSerializer.h"
#import "OpenCloudData/Private/Import/OCCloudKitImporter.h"
#import "OpenCloudData/Private/OCCloudKitModelValidator.h"
#import "OpenCloudData/Private/OCCloudKitOptionsValidator.h"
#import "OpenCloudData/Private/Request/OCCloudKitMirroringDelegateSetupRequestOptions.h"
#include <objc/runtime.h>

CK_EXTERN NSString * const CKIdentityUpdateNotification;

@implementation OCCloudKitMirroringDelegate
@synthesize applicationMonitor = _applicationMonitor;
@synthesize registeredForSubscription = _registeredForSubscription;
@synthesize registeredExportActivityHandler = _registeredExportActivityHandler;
@synthesize registeredImportActivityHandler = _registeredImportActivityHandler;
@synthesize registeredSetupActivityHandler = _registeredSetupActivityHandler;

+ (void)initialize {
    if (self == [OCCloudKitMirroringDelegate class]) {
        [OCCloudKitLogging class];
    }
}

+ (NSValueTransformerName)cloudKitMetadataTransformerName {
    // NSCloudKitMirroringDelegate와 호환성을 갖게 하기 위해 원본 코드에 있는 문자열을 그대로 씀
    return @"com.apple.CoreData.cloudkit.metadata.transformer";
}

+ (BOOL)checkAndCreateDirectoryAtURL:(NSURL *)url wipeIfExists:(BOOL)wipeIfExists error:(NSError * _Nullable *)error {
    /*
     url = x20
     wipeIfExists = x22
     error = x19
     */
    
    // sp + 0x8
    NSError * _Nullable _error = nil;
    
    // x21
    NSFileManager *fileManager = NSFileManager.defaultManager;
    
    BOOL isDirectory = NO;
    BOOL exists = [fileManager fileExistsAtPath:url.path isDirectory:&isDirectory];
    
    if (!exists) {
        BOOL result = [fileManager createDirectoryAtURL:url withIntermediateDirectories:YES attributes:nil error:&_error];
        
        if (result) {
            return YES;
        } else {
            if ((error != NULL) && (_error != nil)) {
                *error = _error;
            }
            return NO;
        }
    } else {
        if (!isDirectory || wipeIfExists) {
            BOOL result = [fileManager removeItemAtURL:url error:&_error];
            
            if (!result) {
                if ((error != NULL) && (_error != nil)) {
                    *error = _error;
                }
                return NO;
            }
            
            result = [fileManager createDirectoryAtURL:url withIntermediateDirectories:YES attributes:nil error:&_error];
            
            if (result) {
                return YES;
            } else {
                if ((error != NULL) && (_error != nil)) {
                    *error = _error;
                }
                return NO;
            }
        } else {
            return YES;
        }
    }
}

+ (BOOL)checkIfContentsOfStore:(__kindof NSPersistentStore *)store matchContentsOfStore:(__kindof NSPersistentStore *)otherStore error:(NSError * _Nullable *)error {
    return [self checkIfContentsOfStore:store matchContentsOfStore:otherStore onlyCompareSharedZones:NO error:error];
}

+ (BOOL)checkIfContentsOfStore:(__kindof NSPersistentStore *)store matchContentsOfStore:(__kindof NSPersistentStore *)otherStore onlyCompareSharedZones:(BOOL)onlyCompareSharedZones error:(NSError * _Nullable *)error {
    /*
     store = x22
     otherStore = x21
     onlyCompareSharedZones = x20
     error = x19
     */
    
    // x21
    OCCloudKitStoreComparer *comparer = [[OCCloudKitStoreComparer alloc] initWithStore:store otherStore:otherStore];
    comparer.onlyCompareSharedZones = onlyCompareSharedZones;
    // x19
    BOOL result = [comparer ensureContentsMatch:error];
    [comparer release];
    return result;
}

+ (NSString *)cloudKitMachServiceName {
    return @"CDDCloudKitMachServiceName";
}

+ (NSXPCConnection *)createCloudKitServerWithMachServiceName:(NSString *)machServiceName andStorageDirectoryPath:(NSString *)storageDirectoryPath {
    abort();
}

+ (BOOL)isFirstPartyContainerIdentifier:(NSString *)identifier {
    return [identifier containsString:@"com.apple."];
}

+ (BOOL)printEventsInStores:(NSArray<__kindof NSPersistentStore *> *)stores startingAt:(NSDate *)startDate endingAt:(NSDate *)endDate error:(NSError * _Nullable *)error {
    abort();
}

+ (void)printMetadataForStoreAtURL:(NSURL *)url withConfiguration:(NSString *)configuration operateOnACopy:(BOOL)operateOnACopy {
    abort();
}

+ (void)printRepresentativeSchemaForModelAtURL:(NSURL *)modelURL orStoreAtURL:(NSURL *)storeURL withConfiguration:(NSString *)configuration {
    abort();
}

+ (void)printSharedZoneWithName:(NSString *)zoneName inStoreAtURL:(NSURL *)storeURL error:(NSError * _Nullable *)error {
    abort();
}

+ (BOOL)traceObjectMatchingRecordName:(NSString *)recordName inStores:(NSArray<__kindof NSPersistentStore *> *)stores startingAt:(NSDate *)startDate endingAt:(NSDate *)endDate error:(NSError * _Nullable *)error {
    abort();
}

+ (BOOL)traceObjectMatchingValue:(id)value atKeyPath:(NSString *)keyPath inStores:(NSArray<__kindof NSPersistentStore *> *)stores startingAt:(NSDate *)startDate endingAt:(NSDate *)endDate error:(NSError * _Nullable *)error {
    abort();
}

+ (NSString *)stringForResetReason:(NSUInteger)reason {
    switch (reason) {
        case 1:
            return @"AccountLogin";
        case 2:
            return @"AccountLogout";
        case 3:
            return @"AccountChange";
        case 4:
            return @"UserPurgedZone";
        case 5:
            return @"ZoneDeleted";
        case 6:
            return @"HistoryExpired";
        case 7:
            return @"ServerChangeTokenExpired";
        default:
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Can't generate string for unknown reset sync reason: %lu\n", reason);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Can't generate string for unknown reset sync reason: %lu\n", reason);
            return nil;
    }
}

- (instancetype)initWithCloudKitContainerOptions:(OCPersistentCloudKitContainerOptions *)cloudKitContainerOptions {
    OCCloudKitMirroringDelegateOptions *options;
    
    if ([cloudKitContainerOptions isKindOfClass:[OCCloudKitMirroringDelegateOptions class]]) {
        options = [(OCCloudKitMirroringDelegateOptions *)cloudKitContainerOptions retain];
    } else {
        options = [[OCCloudKitMirroringDelegateOptions alloc] initWithCloudKitContainerOptions:cloudKitContainerOptions];
    }
    
    self = [self initWithOptions:options];
    [options release];
    return self;
}

- (instancetype)initWithOptions:(OCCloudKitMirroringDelegateOptions *)options {
    /*
     options = x20
     */
    
    // x19
    if (self = [self init]) {
        @autoreleasepool {
            _options = [options copy];
            if (_options.progressProvider == nil) {
                _options.progressProvider = self;
            }
        }
        
        static dispatch_queue_t cloudKitQueue;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            dispatch_queue_attr_t attr = dispatch_queue_attr_make_with_autorelease_frequency(NULL, DISPATCH_AUTORELEASE_FREQUENCY_WORK_ITEM);
            // original : "com.apple.coredata.cloudkit.queue"
            cloudKitQueue = dispatch_queue_create("com.pookjw.openclouddata.cloudkit.queue", attr);
        });
        
        _cloudKitQueueSemaphore = dispatch_semaphore_create(0);
        _cloudKitQueue = [cloudKitQueue retain];
        _databaseSubscription = nil;
        _hadObservedStore = NO;
        _setupFinishedMetadataInitialization = NO;
        _registeredForAccountChangeNotifications = NO;
        _requestManager = [[OCCloudKitMirroringRequestManager alloc] init];
        _voucherManager = [[OCCloudKitMirroringActivityVoucherManager alloc] init];
        
        for (OCPersistentCloudKitContainerActivityVoucher *activityVoucher in options.activityVouchers) {
            [_voucherManager addVoucher:activityVoucher];
        }
        
        // sp + 0x28
        __weak OCCloudKitMirroringDelegate *weakSelf = self;
        
        /*
         __47-[NSCloudKitMirroringDelegate initWithOptions:]_block_invoke_2
         weakSelf = sp + 0x20
         */
        _accountChangeObserver = [[OCCloudKitThrottledNotificationObserver alloc] initWithLabel:@"AccountChangeObserver" handlerBlock:^(NSString * _Nonnull assertionLabel) {
            /*
             assertionLabel = x20
             */
            
            // sp + 0x8
            OCCloudKitMirroringDelegate *loaded = weakSelf;
            if (loaded == nil) {
                return;
            }
            
            // x19 / sp + 0x38
            NSError * _Nullable error;
            // original : getCloudKitCKIdentityUpdateNotification
            if ([assertionLabel isEqualToString:CKIdentityUpdateNotification]) {
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:134416 userInfo:nil];
            } else if ([assertionLabel isEqualToString:CKAccountChangedNotification]) {
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:134415 userInfo:nil];
            } else {
                error = nil;
            }
            
            // sp + 0x30
            OCCloudKitMirroringDelegateResetRequest *request = [[OCCloudKitMirroringDelegateResetRequest alloc] initWithError:error completionBlock:nil];
            [loaded _enqueueRequest:request];
            [request release];
        }];
        if (_accountChangeObserver != nil) {
            _accountChangeObserver->_notificationStalenessInterval = 10;
        }
        
        if (_options.automaticallyScheduleImportAndExportOperations) {
            CKScheduler *scheduler;
            {
                // x8
                OCCloudKitMirroringDelegateOptions *options = self->_options;
                if (options != nil) {
                    scheduler = options->_scheduler;
                    if (scheduler == nil) {
                        scheduler = [CKScheduler sharedScheduler];
                    }
                } else {
                    scheduler = [CKScheduler sharedScheduler];
                }
            }
            _scheduler = [scheduler retain];
            
            CKNotificationListener * _Nullable notificationListener;
            if ((_options.databaseScope == CKDatabaseScopePrivate) || (_options.databaseScope == CKDatabaseScopeShared)) {
                OCCloudKitMirroringDelegateOptions * _Nullable options = self->_options;
                {
                    if (options == nil) {
                        notificationListener = nil;
                    } else {
                        notificationListener = [options->_notificationListener retain];
                    }
                }
                
                if (notificationListener == nil) {
                    if (options.apsConnectionMachServiceName.length == 0) {
                        notificationListener = [[CKNotificationListener alloc] init];
                    } else {
                        notificationListener = [[CKNotificationListener alloc] initWithMachServiceName:options.apsConnectionMachServiceName];
                    }
                }
            } else {
                notificationListener = [[CKNotificationListener alloc] init];
            }
            _notificationListener = notificationListener;
        }
    }
    
    return self;
}

- (void)dealloc {
    [self removeNotificationRegistrations];
    
    [_coredatadClient release];
    [_cloudKitQueue release];
    [_cloudKitQueueSemaphore release];
    [_options release];
    [_currentUserRecordID release];
    [_databaseSubscription release];
    [_container release];
    [_database release];
    [_scheduler release];
    [_notificationListener release];
    [_lastInitializationError release];
    [_exporterOptions release];
    [_requestManager release];
    [_sharingUIObserver release];
    [_applicationMonitor release];
    [_accountChangeObserver release];
    [_observedStoreIdentifier release];
    [_importActivityIdentifier release];
    [_exportActivityIdentifier release];
    [_setupActivityIdentifier release];
    [_activityGroupName release];
    [_voucherManager release];
    
    [super dealloc];
}

- (void)removeNotificationRegistrations {
    abort();
}

- (void)_enqueueRequest:(OCCloudKitMirroringRequest *)request __attribute__((objc_direct)) {
    // inlined from __47-[NSCloudKitMirroringDelegate initWithOptions:]_block_invoke_2
    
    /*
     __47-[NSCloudKitMirroringDelegate _enqueueRequest:]_block_invoke
     sef = sp + 0x30 = x19 + 0x20
     request = sp + 0x38 = x19 + 0x28
     */
    // original : @"com.apple.coredata.cloudkit.schedule.enqueue", @"CoreData: CloudKit Scheduling"
    [self _openTransactionWithLabel:@"com.pookjw.openclouddata.cloudkit.schedule.enqueue" assertionLabel:@"OpenCloudData: CloudKit Scheduling" andExecuteWorkBlock:^(OCCloudKitMirroringDelegateWorkBlockContext *context) {
        /*
         self(block) = x19
         context = x20
         */
        
        os_log_with_type(_OCLogGetLogStream(0x11), OS_LOG_TYPE_DEFAULT, "OpenCloudData+CloudKit: %s(%d): %@: enqueuing request: %@", __func__, __LINE__, self, request);
        
        // x21
        OCCloudKitStoreMonitorProvider * _Nullable storeMonitorProvider;
        {
            if (self == nil) {
                storeMonitorProvider = nil;
            } else {
                OCCloudKitMirroringDelegateOptions * _Nullable options = self->_options;
                if (options == nil) {
                    storeMonitorProvider = nil;
                } else {
                    storeMonitorProvider = options->_storeMonitorProvider;
                }
            }
        }
        
        NSSQLCore * _Nullable observedStore = self->_observedStore;
        
        NSString * _Nullable transactionLabel;
        {
            if (context == nil) {
                transactionLabel = nil;
            } else {
                transactionLabel = context->_transactionLabel;
            }
        }
        
        // x20
        OCCloudKitStoreMonitor *monitor = [storeMonitorProvider createMonitorForObservedStore:observedStore inTransactionWithLabel:transactionLabel];
        
        /*
         __47-[NSCloudKitMirroringDelegate _enqueueRequest:]_block_invoke.193
         monitor = sp + 0x28 = x20 + 0x20
         sef = sp + 0x30 = x20 + 0x28
         request = sp + 0x38 = x20 + 0x30
         */
        [monitor performBlock:^{
            /*
             self(block) = x20
             */
            
            // x19
            NSSQLCore *retainedMonitoredStore = [monitor retainedMonitoredStore];
            if (retainedMonitoredStore == nil) {
                // x21
                NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:134407 userInfo:@{
                    NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"Request '%@' was cancelled because the store was removed from the coordinator.", request.requestIdentifier]
                }];
                
                // x21
                OCCloudKitMirroringResult *result = [[OCCloudKitMirroringResult alloc] initWithRequest:request storeIdentifier:self->_observedStoreIdentifier success:NO madeChanges:NO error:error];
                
                [request invokeCompletionBlockWithResult:result];
                [result release];
                [retainedMonitoredStore release];
                return;
            }
            
            // sp + 0x8
            NSError * _Nullable error = nil;
            
            OCCloudKitMirroringRequestManager * _Nullable requestManager;
            {
                if (self == nil) {
                    requestManager = nil;
                } else {
                    requestManager = self->_requestManager;
                }
            }
            
            // x23/w23
            BOOL result = [requestManager enqueueRequest:request error:&error];
            if (!result) {
                os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData+CloudKit: %s(%d): Failed to enqueue request: %@\n%@", __func__, __LINE__, request, error);
                // x21
                OCCloudKitMirroringResult *result = [[OCCloudKitMirroringResult alloc] initWithRequest:request storeIdentifier:self->_observedStoreIdentifier success:NO madeChanges:NO error:error];
                
                [request invokeCompletionBlockWithResult:result];
                [result release];
                [retainedMonitoredStore release];
                return;
            }
            
            os_log_with_type(_OCLogGetLogStream(0x11), OS_LOG_TYPE_DEFAULT, "OpenCloudData+CloudKit: %s(%d): Enqueued request: %@", __func__, __LINE__, request);
            [self beginActivitiesForRequest:request];
            [self checkAndExecuteNextRequest];
            [retainedMonitoredStore release];
        }];
        
        [monitor release];
    }];
}

- (void)_openTransactionWithLabel:(NSString *)label assertionLabel:(NSString *)assertionLabel andExecuteWorkBlock:(void (^)(OCCloudKitMirroringDelegateWorkBlockContext *context))executeWorkBlock __attribute__((objc_direct)) {
    /*
     self = x20
     label = x22
     assertionLabel = x21
     executeWorkBlock = x19
     */
    
    // x21
    OCCloudKitMirroringDelegateWorkBlockContext *context = [[OCCloudKitMirroringDelegateWorkBlockContext alloc] initWithTransactionLabel:label powerAssertionLabel:assertionLabel];
    
    /*
     __92-[NSCloudKitMirroringDelegate _openTransactionWithLabel:assertionLabel:andExecuteWorkBlock:]_block_invoke
     context = sp + 0x20 = x21 + 0x20
     executeWorkBlock = sp + 0x28 = x21 + 0x28
     */
    dispatch_async(_cloudKitQueue, ^{
        // self(block) = x21
        // x20
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        executeWorkBlock(context);
        [pool drain];
    });
    
    [context release];
}

- (void)beginActivitiesForRequest:(__kindof OCCloudKitMirroringRequest *)request {
    /*
     self = x20
     request = x19
     */
    // sp + 0x8
    NSObject<OCCloudKitMirroringDelegateProgressProvider> *progressProvider = [self->_options.progressProvider retain];
    
    if (progressProvider == nil) {
        [progressProvider release];
        return;
    }
    
    if ([request isKindOfClass:[OCCloudKitMirroringDelegateSetupRequest class]]) {
        // x20
        OCPersistentCloudKitContainerEventActivity *activity = [[OCPersistentCloudKitContainerEventActivity alloc] initWithRequestIdentifier:request.requestIdentifier storeIdentifier:self->_observedStoreIdentifier eventType:0];
        request.activity = activity;
        
        // x19
        __kindof OCPersistentCloudKitContainerActivity *beganActivity = [activity beginActivityForPhase:0];
        [progressProvider publishActivity:activity];
        [progressProvider publishActivity:beganActivity];
        
        [activity release];
        [beganActivity release];
    }
    
    [progressProvider release];
}

- (BOOL)validateManagedObjectModel:(NSManagedObjectModel *)managedObjectModel forUseWithStoreWithDescription:(NSPersistentStoreDescription *)storeDescription error:(NSError * _Nullable *)error {
    /*
     error = x19
     */
    // sp, #0x8
    NSError * _Nullable _error = nil;
    
    if (_hadObservedStore) {
        // <+56>
        _error = [NSError errorWithDomain:NSCocoaErrorDomain code:134060 userInfo:@{
            NSLocalizedFailureReasonErrorKey: @"Instances of NSCloudKitMirroringDelegate are not reusable and should have a lifecycle tied to a given instance of NSPersistentStore."
        }];
        
        if (_error == nil) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        } else {
            if (error != NULL) *error = _error;
        }
        
        return NO;
    }
    
    // <+176>
    /*
     self = x22
     managedObjectModel = x20
     storeDescription = x21
     */
    BOOL readOnly = ((NSNumber *)[storeDescription.options objectForKey:@"NSCloudKitMirroringDelegateReadOnlyOptionKey"]).boolValue;
    if (readOnly) {
        return YES;
    }
    
    // <+224>
    // x20
    OCCloudKitModelValidator *validator = [[OCCloudKitModelValidator alloc] initWithManagedObjectModel:managedObjectModel configuration:storeDescription.configuration mirroringDelegateOptions:self->_options];
    validator->_skipValueTransformerValidation = self.options.skipCloudKitSetup;
    BOOL result = [validator _validateManagedObjectModel:validator->_model error:&_error];
    
    if (!result) {
        // <+636>
        [validator release];
        
        if (_error == nil) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        } else {
            if (error != NULL) *error = _error;
        }
        
        return NO;
    }
    
    if (storeDescription == nil) {
        _error = [NSError errorWithDomain:NSCocoaErrorDomain code:134060 userInfo:@{
            NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"Cannot be used without an instance of %@.", NSStringFromClass([NSPersistentStoreDescription class])]
        }];
        
        if (_error == nil) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        } else {
            if (error != NULL) *error = _error;
        }
        
        return NO;
    }
    
    if (![storeDescription.type isEqualToString:NSSQLiteStoreType]) {
        // <+520>
        _error = [NSError errorWithDomain:NSCocoaErrorDomain code:134060 userInfo:@{
            NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"CloudKit integration is only supported for %@ stores.", NSSQLiteStoreType]
        }];
        
        if (_error == nil) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        } else {
            if (error != NULL) *error = _error;
        }
        
        return NO;
    }
    
    // <+352>
    // x23
    OCCloudKitOptionsValidator *optionsValidator = [[OCCloudKitOptionsValidator alloc] init];
    result = [optionsValidator validateOptions:self.options andStoreOptions:storeDescription.options error:&_error];
    [optionsValidator release];
    [validator release];
    
    if (!result) {
        if (_error == nil) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        } else {
            if (error != NULL) *error = _error;
        }
        
        return NO;
    }
    
    return YES;
}

- (void)persistentStoreCoordinator:(NSPersistentStoreCoordinator *)persistentStoreCoordinator didSuccessfullyAddPersistentStore:(__kindof NSPersistentStore *)persistentStore withDescription:(NSPersistentStoreDescription *)storeDescription {
    // original : @"com.apple.coredata.cloudkit.store.added", @"CoreData: CloudKit Add Persistent Store"
    /*
     __108-[NSCloudKitMirroringDelegate persistentStoreCoordinator:didSuccessfullyAddPersistentStore:withDescription:]_block_invoke
     self = sp + 0x28
     persistentStore = sp + 0x30
     persistentStoreCoordinator = sp + 0x38
     */
    [self _openTransactionWithLabel:@"com.pookjw.openclouddata.cloudkit.store.added" assertionLabel:@"OpenCloudData: CloudKit Add Persistent Store" andExecuteWorkBlock:^(OCCloudKitMirroringDelegateWorkBlockContext *context) {
        [self observeChangesForStore:persistentStore inPersistentStoreCoordinator:persistentStoreCoordinator];
    }];
}

- (void)observeChangesForStore:(NSSQLCore *)persistentStore inPersistentStoreCoordinator:(NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // inlined from __108-[NSCloudKitMirroringDelegate persistentStoreCoordinator:didSuccessfullyAddPersistentStore:withDescription:]_block_invoke
    /*
     self = x19
     persistentStore = x21
     persistentStoreCoordinator = x22
     */
    // x20
    NSSQLCore * _Nullable observedStore = self->_observedStore;
    os_log_with_type(_OCLogGetLogStream(0x11), OS_LOG_TYPE_DEFAULT, "OpenCloudData+CloudKit: %s(%d): %@: Observing store: %@", __func__, __LINE__, self, persistentStore);
    if (observedStore != nil) return;
    
    @autoreleasepool {
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(coordinatorWillRemoveStore:) name:NSPersistentStoreCoordinatorWillRemoveStoreNotification object:nil];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(storesDidChange:) name:NSPersistentStoreCoordinatorStoresDidChangeNotification object:nil];
        
        NSString *identifier = persistentStore.identifier;
        // 기존값 release 없음
        _observedStoreIdentifier = [identifier retain];
        // x23 = x23 + 0xa8 (offset of _observedStoreIdentifier)
        
        // original : @"com.apple.coredata.cloudkit.activity.import"
        _importActivityIdentifier = [[NSString stringWithFormat:@"%@.%@", @"com.pookjw.openclouddata.cloudkit.activity.import", identifier] retain];
        // original : @"com.apple.coredata.cloudkit.activity.export"
        _exportActivityIdentifier = [[NSString stringWithFormat:@"%@.%@", @"com.pookjw.openclouddata.cloudkit.activity.export", _observedStoreIdentifier] retain];
        // original : @"com.apple.coredata.cloudkit.activity.setup"
        _setupActivityIdentifier = [[NSString stringWithFormat:@"%@.%@", @"com.pookjw.openclouddata.cloudkit.activity.setup", _observedStoreIdentifier] retain];
        // original : @"com.apple.coredata.cloudkit.%@.%@"
        _activityGroupName = [[NSString stringWithFormat:@"com.pookjw.openclouddata.cloudkit.%@.%@", NSProcessInfo.processInfo.processName, _observedStoreIdentifier] retain];
        
        // <+588>
        if (self.options.automaticallyScheduleImportAndExportOperations) {
            // sp + 0x38
            __weak OCCloudKitMirroringDelegate *weakSelf = self;
            
            @try {
                /*
                 __83-[NSCloudKitMirroringDelegate observeChangesForStore:inPersistentStoreCoordinator:]_block_invoke
                 weakSelf = sp + 0x30
                 */
                [_scheduler registerActivityIdentifier:_exportActivityIdentifier handler:^(CKSchedulerActivity * _Nonnull activity, void (^ _Nonnull completionHandler)(long long)) {
                    /*
                     activity = x21
                     completionHandler = x20
                     */
                    
                    OCCloudKitMirroringDelegate *loaded = weakSelf;
                    if (loaded == nil) {
                        os_log_with_type(_OCLogGetLogStream(0x11), OS_LOG_TYPE_DEFAULT, "OpenCloudData+CloudKit: %s(%d): Got called back for an export activity but the mirroring delegate is gone.", __func__, __LINE__);
                        return;
                    }
                    
                    [loaded _scheduleAutomatedExportWithLabel:@"ExportActivity" activity:activity completionHandler:completionHandler];
                }];
            } @catch (NSException *exception) {
                // <+1368>
                NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:134422 userInfo:@{
                    NSLocalizedFailureReasonErrorKey: @"CloudKit setup failed because it couldn't register a handler for the export activity. There is another instance of this persistent store actively syncing with CloudKit in this process.",
                    NSURLErrorKey: persistentStore.URL,
                    @"NSUnderlyingException": exception,
                    @"activityIdentifier": _exportActivityIdentifier
                }];
                [self resetAfterError:error andKeepContainer:NULL];
                [self tearDown:[NSString stringWithFormat:@"Error %@:%ld", error.domain, error.code]];
                return;
            }
            
            @try {
                /*
                 __83-[NSCloudKitMirroringDelegate observeChangesForStore:inPersistentStoreCoordinator:]_block_invoke.131
                 weakSelf = x19 - 0x70
                 */
                [_scheduler registerActivityIdentifier:_importActivityIdentifier handler:^(CKSchedulerActivity * _Nonnull activity, void (^ _Nonnull completionHandler)(long long)) {
                    /*
                     activity = x20
                     completionHandler = x21
                     */
                    
                    OCCloudKitMirroringDelegate *loaded = weakSelf;
                    if (loaded == nil) {
                        os_log_with_type(_OCLogGetLogStream(0x11), OS_LOG_TYPE_DEFAULT, "OpenCloudData+CloudKit: %s(%d): Got called back for activity: %@, but the mirroring delegate is gone.", __func__, __LINE__, activity);
                        return;
                    }
                    
                    [loaded _scheduleAutomatedExportWithLabel:@"ImportActivity" activity:activity completionHandler:completionHandler];
                }];
            } @catch (NSException *exception) {
                // <+1180>
                NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:134422 userInfo:@{
                    NSLocalizedFailureReasonErrorKey: @"CloudKit setup failed because it couldn't register a handler for the import activity. There is another instance of this persistent store actively syncing with CloudKit in this process.",
                    NSURLErrorKey: persistentStore.URL,
                    @"NSUnderlyingException": exception,
                    @"activityIdentifier": _exportActivityIdentifier
                }];
                [self resetAfterError:error andKeepContainer:NULL];
                [self tearDown:[NSString stringWithFormat:@"Error %@:%ld", error.domain, error.code]];
                return;
            }
            
            @try {
                /*
                 __83-[NSCloudKitMirroringDelegate observeChangesForStore:inPersistentStoreCoordinator:]_block_invoke.136
                 self = sp + 0x80
                 weakSelf = sp + 0x88
                 */
                [_scheduler registerActivityIdentifier:_setupActivityIdentifier handler:^(CKSchedulerActivity * _Nonnull activity, void (^ _Nonnull completionHandler)(long long)) {
                    /*
                     self(block) = x22
                     activity = x20
                     completionHandler = x21
                     */
                    
                    // x19
                    OCCloudKitMirroringDelegate *loaded = weakSelf;
                    if (loaded == nil) {
                        os_log_with_type(_OCLogGetLogStream(0x11), OS_LOG_TYPE_DEFAULT, "OpenCloudData+CloudKit: %s(%d): Got called back for activity: %@, but the mirroring delegate is gone.", __func__, __LINE__, activity);
                        return;
                    }
                    
                    /*
                     __83-[NSCloudKitMirroringDelegate observeChangesForStore:inPersistentStoreCoordinator:]_block_invoke_2
                     self = sp + 0x28
                     activity = sp + 0x30
                     completionHandler = sp + 0x38
                     */
                    dispatch_async(loaded->_cloudKitQueue, ^{
                        [self _setUpCloudKitIntegration:activity];
                        completionHandler(1);
                    });
                }];
            } @catch (NSException *exception) {
                // <+992>
                NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:134422 userInfo:@{
                    NSLocalizedFailureReasonErrorKey: @"CloudKit setup failed because it couldn't register a handler for the setup activity. There is another instance of this persistent store actively syncing with CloudKit in this process.",
                    NSURLErrorKey: persistentStore.URL,
                    @"NSUnderlyingException": exception,
                    @"activityIdentifier": _exportActivityIdentifier
                }];
                [self resetAfterError:error andKeepContainer:NULL];
                [self tearDown:[NSString stringWithFormat:@"Error %@:%ld", error.domain, error.code]];
                return;
            }
        }
        
        // <+884>
        [self _setUpCloudKitIntegration:nil];
    }
}

- (void)coordinatorWillRemoveStore:(NSNotification *)notification {
    abort();
}

- (void)storesDidChange:(NSNotification *)notification {
    abort();
}

- (void)_setUpCloudKitIntegration:(CKSchedulerActivity *)activity {
    /*
     self = x20
     activity = x21
     */
    // x19
    OCCloudKitMirroringDelegateSetupRequestOptions *setupRequestOptions = [[OCCloudKitMirroringDelegateSetupRequestOptions alloc] init];
    if (self.options.defaultOperationConfiguration != nil) {
        setupRequestOptions.operationConfiguration = self.options.defaultOperationConfiguration;
    }
    // x21
    OCCloudKitMirroringDelegateSetupRequest *request = [[OCCloudKitMirroringDelegateSetupRequest alloc] initWithActivity:activity options:setupRequestOptions completionBlock:nil];
    [self beginActivitiesForRequest:request];
    // sp + 0x8
    NSError * _Nullable error = nil;
    // x24
    BOOL result = [_requestManager enqueueRequest:request error:&error];
    
    if (result) {
        // <+200>
        os_log_with_type(_OCLogGetLogStream(0x11), OS_LOG_TYPE_DEFAULT, "OpenCloudData+CloudKit: %s(%d): %@: Successfully enqueued setup request: %@", __func__, __LINE__, self, request);
        [self checkAndExecuteNextRequest];
    } else {
        // <+360>
        os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData+CloudKit: %s(%d): %@: Failed to enqueue setup request, this likely means one is already scheduled and this has collided: %@", __func__, __LINE__, self, error);
    }
    
    // <+496>
    [setupRequestOptions release];
    [request release];
}

- (void)resetAfterError:(NSError *)error andKeepContainer:(const void *)keepContainer {
    abort();
}

- (void)tearDown:(NSString *)string {
    abort();
}

- (void)_scheduleAutomatedExportWithLabel:(NSString *)label activity:(CKSchedulerActivity *)activity completionHandler:(void (^)(long long))completionHandler {
    abort();
}

- (void)addActivityVoucher:(OCPersistentCloudKitContainerActivityVoucher *)activityVoucher {
    abort();
}

- (void)expireActivityVoucher:(OCPersistentCloudKitContainerActivityVoucher *)activityVoucher {
    abort();
}

- (void)checkAndExecuteNextRequest {
    /*
     self = x19
     */
    
    os_log_with_type(_OCLogGetLogStream(0x11), OS_LOG_TYPE_DEFAULT, "OpenCloudData+CloudKit: %s(%d): %@: Checking for pending requests.", __func__, __LINE__, self);
    
    // sp, #0x30
    __weak OCCloudKitMirroringDelegate *weakSelf = self;
    
    /*
     original : @"com.apple.coredata.cloudkit.schedule", @"CoreData: CloudKit Scheduling"
     */
    /*
     __57-[NSCloudKitMirroringDelegate checkAndExecuteNextRequest]_block_invoke
     weakSelf = sp + 0x28
     */
    [self _openTransactionWithLabel:@"com.pookjw.openclouddata.cloudkit.schedule" assertionLabel:@"OpenCloudData: CloudKit Scheduling" andExecuteWorkBlock:^(OCCloudKitMirroringDelegateWorkBlockContext *context) {
        // x19
        OCCloudKitMirroringDelegate *loaded = [weakSelf retain];
        if (loaded == nil) {
            os_log_with_type(_OCLogGetLogStream(0x11), OS_LOG_TYPE_DEFAULT, "OpenCloudData+CloudKit: %s(%d): Unable to schedule work because the mirroring delegate was deallocated.", __func__, __LINE__);
            [loaded release];
            return;
        }
        
        // x20
        OCCloudKitMirroringRequestManager *requestManager = [loaded->_requestManager retain];
        if (requestManager != nil) {
            if (requestManager->_activeRequest != nil) {
                os_log_with_type(_OCLogGetLogStream(0x11), OS_LOG_TYPE_DEFAULT, "OpenCloudData+CloudKit: %s(%d): %@: Deferring additional work. There is still an active request: %@", __func__, __LINE__, loaded, requestManager->_activeRequest);
                [loaded release];
                return;
            }
        }
        
        // <+424>
        // x21
        OCCloudKitMirroringRequest *dequeuedRequest = [requestManager dequeueNextRequest];
        os_log_with_type(_OCLogGetLogStream(0x11), OS_LOG_TYPE_DEFAULT, "OpenCloudData+CloudKit: %s(%d): %@: Executing: %@", __func__, __LINE__, self, dequeuedRequest);
        // x22
        OCPersistentCloudKitContainerActivity *activity = [dequeuedRequest->_activity retain];
        
        if ([activity isKindOfClass:[OCPersistentCloudKitContainerEventActivity class]]) {
            // <+652>
            OCPersistentCloudKitContainerEventActivity *casted = (OCPersistentCloudKitContainerEventActivity *)activity;
            // x23
            __kindof OCPersistentCloudKitContainerActivity *endedActivity = [casted endActivityForPhase:0 withError:NULL];
            [loaded->_options.progressProvider publishActivity:endedActivity];
            [endedActivity release];
            // <+852>
            // fin
        } else {
            // <+800>
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: I don't know how to handle this type of activity yet: %@\n", activity);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: I don't know how to handle this type of activity yet: %@\n", activity);
        }
        
        // <+852>
        [activity release];
        
        if ([dequeuedRequest isKindOfClass:[OCCloudKitMirroringFetchRecordsRequest class]]) {
            // <+884>
            [self _performFetchRecordsRequest:(OCCloudKitMirroringFetchRecordsRequest *)dequeuedRequest];
        } else if ([dequeuedRequest isKindOfClass:[OCCloudKitMirroringImportRequest class]]) {
            // <+980>
            [self _performImportWithRequest:(OCCloudKitMirroringImportRequest *)dequeuedRequest];
        } else if ([dequeuedRequest isKindOfClass:[OCCloudKitMirroringExportRequest class]]) {
            // <+1076>
            [self _performExportWithRequest:(OCCloudKitMirroringExportRequest *)dequeuedRequest];
        } else if ([dequeuedRequest isKindOfClass:[OCCloudKitMirroringResetZoneRequest class]]) {
            // <+1172>
            [self _performResetZoneRequest:(OCCloudKitMirroringResetZoneRequest *)dequeuedRequest];
        } else if ([dequeuedRequest isKindOfClass:[OCCloudKitMirroringResetMetadataRequest class]]) {
            // <+1268>
            [self _performMetadataResetRequest:(OCCloudKitMirroringResetMetadataRequest *)dequeuedRequest];
        } else if ([dequeuedRequest isKindOfClass:[OCCloudKitMirroringDelegateSetupRequest class]]) {
            // <+1432>
            [self _performSetupRequest:(OCCloudKitMirroringDelegateSetupRequest *)dequeuedRequest];
        } else if ([dequeuedRequest isKindOfClass:[OCCloudKitMirroringDelegateResetRequest class]]) {
            // <+1588>
            [self _performDelegateResetRequest:(OCCloudKitMirroringDelegateResetRequest *)dequeuedRequest];
        } else if ([dequeuedRequest isKindOfClass:[OCCloudKitMirroringInitializeSchemaRequest class]]) {
            // <+1632>
            [self _performSchemaInitializationRequest:(OCCloudKitMirroringInitializeSchemaRequest *)dequeuedRequest];
        } else if ([dequeuedRequest isKindOfClass:[OCCloudKitMirroringDelegateSerializationRequest class]]) {
            // <+1676>
            [self _performSerializationRequest:(OCCloudKitMirroringDelegateSerializationRequest *)dequeuedRequest];
        } else if ([dequeuedRequest isKindOfClass:[OCCloudKitMirroringExportProgressRequest class]]) {
            // <+1720>
            [self _performExportProgressRequest:(OCCloudKitMirroringExportProgressRequest *)dequeuedRequest];
        } else if ([dequeuedRequest isKindOfClass:[OCCloudKitMirroringAcceptShareInvitationsRequest class]]) {
            // <+1764>
            [self _performAcceptShareInvitationsRequest:(OCCloudKitMirroringAcceptShareInvitationsRequest *)dequeuedRequest];
        } else {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: %@: Asked to execute a request that isn't understood yet: %@\n", self, dequeuedRequest);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: %@: Asked to execute a request that isn't understood yet: %@\n", self, dequeuedRequest);
        }
        
        [dequeuedRequest release];
        [requestManager release];
        [loaded release];
    }];
}

- (void)logResetSyncNotification:(NSNotification *)notification {
    abort();
}

- (void)_performFetchRecordsRequest:(OCCloudKitMirroringFetchRecordsRequest *)request __attribute__((objc_direct)) {
    // inlined from __57-[NSCloudKitMirroringDelegate checkAndExecuteNextRequest]_block_invoke <+884>~<+948>
    /*
     request = x21
     */
    /*
     original : @"com.apple.coredata.cloudkit.fetch.records", @"CoreData: CloudKit Fetch Records"
     */
    /*
     __59-[NSCloudKitMirroringDelegate _performFetchRecordsRequest:]_block_invoke
     loaded = sp + 0x20
     request = sp + 0x28
     */
    [self _openTransactionWithLabel:@"com.pookjw.openclouddata.cloudkit.fetch.records" assertionLabel:@"OpenCloudData: CloudKit Fetch Records" andExecuteWorkBlock:^(OCCloudKitMirroringDelegateWorkBlockContext *context) {
        /*
         self(block) = x21
         context = x23
         */
        
        if (!self->_successfullyInitialized) {
            [self _requestAbortedNotInitialized:request];
            return;
        }
        // x19
        NSSQLCore * _Nullable observedStore = [self->_observedStore retain];
        
        OCCloudKitStoreMonitorProvider * _Nullable storeMonitorProvider;
        {
            if (self == nil) {
                storeMonitorProvider = nil;
            } else {
                OCCloudKitMirroringDelegateOptions *options = self->_options;
                if (options == nil) {
                    storeMonitorProvider = nil;
                } else {
                    storeMonitorProvider = options->_storeMonitorProvider;
                }
            }
        }
        
        // x20
        OCCloudKitStoreMonitor *monitor = [storeMonitorProvider createMonitorForObservedStore:observedStore inTransactionWithLabel:context->_transactionLabel];
        
        // sp, #0x48
        NSError * _Nullable error = nil;
        
        // <+132>
        // x22
        OCPersistentCloudKitContainerEvent * _Nullable event = [OCCKEvent beginEventForRequest:request withMonitor:monitor error:&error];
        if (event == nil) {
            // <+408>
            // x22
            OCCloudKitMirroringResult *result = [[OCCloudKitMirroringResult alloc] initWithRequest:request storeIdentifier:self->_observedStoreIdentifier success:NO madeChanges:NO error:error];
            [self _importFinishedWithResult:result importer:nil];
            [result release];
            [monitor release];
            [observedStore release];
            return;
        }
        
        NSObject<OCCloudKitMirroringDelegateProgressProvider> * _Nullable progressProvider;
        {
            if (self == nil) {
                progressProvider = nil;
            } else {
                progressProvider = self->_options.progressProvider;
            }
        }
        
        [progressProvider eventUpdated:event];
        // <+168>
        // x25
        OCCloudKitImporterOptions *importerOptions = [[OCCloudKitImporterOptions alloc] initWithOptions:self->_options monitor:monitor assetStorageURL:[OCCloudKitSerializer assetStorageDirectoryURLForStore:observedStore] workQueue:self->_cloudKitQueue andDatabase:self->_database];
        // x24
        OCCloudKitImporter *importer = [[OCCloudKitImporter alloc] initWithOptions:importerOptions request:request];
        [importerOptions release];
        
        /*
         __59-[NSCloudKitMirroringDelegate _performFetchRecordsRequest:]_block_invoke_2
         */
        [importer importIfNecessaryWithCompletion:^(OCCloudKitMirroringResult * _Nonnull result) {
            abort();
        }];
        
        [event release];
        [monitor release];
        [importer release];
        [observedStore release];
    }];
}

- (void)_performImportWithRequest:(OCCloudKitMirroringImportRequest *)request __attribute__((objc_direct)) {
    // inlined from __57-[NSCloudKitMirroringDelegate checkAndExecuteNextRequest]_block_invoke <+980>~<+1044>
    /*
     request = x21
     */
    /*
     original : @"com.apple.coredata.cloudkit.import", @"CoreData: CloudKit Import"
     */
    /*
     __57-[NSCloudKitMirroringDelegate _performImportWithRequest:]_block_invoke
     loaded = sp + 0x20
     request = sp + 0x28
     */
    [self _openTransactionWithLabel:@"com.pookjw.openclouddata.cloudkit.import" assertionLabel:@"OpenCloudData: CloudKit Import" andExecuteWorkBlock:^(OCCloudKitMirroringDelegateWorkBlockContext *context) {
        abort();
    }];
}

- (void)_performExportWithRequest:(OCCloudKitMirroringExportRequest *)request __attribute__((objc_direct)) {
    // inlined from __57-[NSCloudKitMirroringDelegate checkAndExecuteNextRequest]_block_invoke <+1076>~<+1140>
    /*
     request = x21
     */
    /*
     original : @"com.apple.coredata.cloudkit.export", @"CoreData: CloudKit Export"
     */
    /*
     __57-[NSCloudKitMirroringDelegate _performExportWithRequest:]_block_invoke
     loaded = sp + 0x20
     request = sp + 0x28
     */
    [self _openTransactionWithLabel:@"com.pookjw.openclouddata.cloudkit.export" assertionLabel:@"OpenCloudData: CloudKit Export" andExecuteWorkBlock:^(OCCloudKitMirroringDelegateWorkBlockContext *context) {
        abort();
    }];
}

- (void)_performResetZoneRequest:(OCCloudKitMirroringResetZoneRequest *)request __attribute__((objc_direct)) {
    // inlined from __57-[NSCloudKitMirroringDelegate checkAndExecuteNextRequest]_block_invoke <+1172>~<+1236>
    /*
     request = x21
     */
    /*
     original : @"com.apple.coredata.cloudkit.zone.reset", @"CoreData: CloudKit Zone Reset"
     */
    /*
     __57-[NSCloudKitMirroringDelegate _performResetZoneRequest:]_block_invoke
     loaded = sp + 0x20
     request = sp + 0x28
     */
    [self _openTransactionWithLabel:@"com.pookjw.openclouddata.cloudkit.zone.reset" assertionLabel:@"OpenCloudData: CloudKit Zone Reset" andExecuteWorkBlock:^(OCCloudKitMirroringDelegateWorkBlockContext *context) {
        abort();
    }];
}

- (void)_performMetadataResetRequest:(OCCloudKitMirroringResetMetadataRequest *)request __attribute__((objc_direct)) {
    // inlined from __57-[NSCloudKitMirroringDelegate checkAndExecuteNextRequest]_block_invoke <+1268>~<+1340>
    /*
     request = x21
     */
    /*
     original : @"com.apple.coredata.cloudkit.metadata.reset", @"CoreData: CloudKit Metadata Reset"
     */
    /*
     __57-[NSCloudKitMirroringDelegate _performMetadataResetRequest:]_block_invoke
     loaded = sp + 0x20
     request = sp + 0x28
     */
    [self _openTransactionWithLabel:@"com.pookjw.openclouddata.cloudkit.metadata.reset" assertionLabel:@"OpenCloudData: CloudKit Metadata Reset" andExecuteWorkBlock:^(OCCloudKitMirroringDelegateWorkBlockContext *context) {
        abort();
    }];
}

- (void)_performSetupRequest:(OCCloudKitMirroringDelegateSetupRequest *)request __attribute__((objc_direct)) {
    abort();
}

- (void)_performDelegateResetRequest:(OCCloudKitMirroringDelegateResetRequest *)request __attribute__((objc_direct)) {
    abort();
}

- (void)_performSchemaInitializationRequest:(OCCloudKitMirroringInitializeSchemaRequest *)request __attribute__((objc_direct)) {
    abort();
}

- (void)_performSerializationRequest:(OCCloudKitMirroringDelegateSerializationRequest *)request __attribute__((objc_direct)) {
    abort();
}

- (void)_performExportProgressRequest:(OCCloudKitMirroringExportProgressRequest *)request __attribute__((objc_direct)) {
    abort();
}

- (void)_performAcceptShareInvitationsRequest:(OCCloudKitMirroringAcceptShareInvitationsRequest *)request __attribute__((objc_direct)) {
    abort();
}

- (void)_requestAbortedNotInitialized:(OCCloudKitMirroringRequest *)request __attribute__((objc_direct)) {
    abort();
}

- (void)_importFinishedWithResult:(OCCloudKitMirroringResult *)result importer:(OCCloudKitImporter * _Nullable)importer __attribute__((objc_direct)) {
    abort();
}

- (void)exporter:(nonnull OCCloudKitExporter *)exporter willScheduleOperations:(nonnull NSArray<__kindof CKOperation *> *)operations { 
    abort();
}

- (void)applicationStateMonitorEnteredBackground:(nonnull PFApplicationStateMonitor *)applicationStateMonitor { 
    abort();
}

- (void)applicationStateMonitorEnteredForeground:(nonnull PFApplicationStateMonitor *)applicationStateMonitor { 
    abort();
}

- (void)applicationStateMonitorExpiredBackgroundActivityTimeout:(nonnull PFApplicationStateMonitor *)applicationStateMonitor { 
    abort();
}

- (void)eventUpdated:(nonnull OCPersistentCloudKitContainerEvent *)event { 
    abort();
}

- (void)publishActivity:(nonnull __kindof OCPersistentCloudKitContainerActivity *)activity { 
    abort();
}

@end
