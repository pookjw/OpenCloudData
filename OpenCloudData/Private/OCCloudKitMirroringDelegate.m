//
//  OCCloudKitMirroringDelegate.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/1/25.
//

#import <OpenCloudData/OCCloudKitMirroringDelegate.h>
#import <OpenCloudData/OCCloudKitLogging.h>
#import <OpenCloudData/OCCloudKitStoreComparer.h>
#import <OpenCloudData/Log.h>
#import <objc/runtime.h>

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
        _accountChangeObserver = [[OCCloudKitThrottledNotificationObserver alloc] initWithLabel:@"AccountChangeObserver" handlerBlock:^(NSString * _Nonnull label) {
            /*
             label = x1
             */
            
            OCCloudKitMirroringDelegate *loaded = weakSelf;
            if (loaded == nil) {
                return;
            }
            
            // TODO
            abort();
        }];
        if (_accountChangeObserver != nil) {
            _accountChangeObserver->_notificationStalenessInterval = 10;
        }
        
        if (_options.automaticallyScheduleImportAndExportOperations) {
            CKScheduler *scheduler;
            {
                // x8
                OCCloudKitMirroringDelegateOptions *options = self->_options;
                if (options == nil) {
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
    [_observedStore release];
    [_observedCoordinator release];
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

@end
