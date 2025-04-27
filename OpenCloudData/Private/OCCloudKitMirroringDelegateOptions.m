//
//  OCCloudKitMirroringDelegateOptions.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/1/25.
//

#import <OpenCloudData/OCCloudKitMirroringDelegateOptions.h>
#import <OpenCloudData/OCPersistentCloudKitContainerOptions+OpenCloudData_Private.h>
#import <OpenCloudData/OCStaticCloudKitContainerProvider.h>
#import <OpenCloudData/Log.h>

CK_EXTERN NSString * _Nullable CKDatabaseScopeString(CKDatabaseScope);

@implementation OCCloudKitMirroringDelegateOptions
@synthesize progressProvider = _progressProvider;
@synthesize defaultOperationConfiguration = _defaultOperationConfiguration;
@synthesize containerIdentifier = _containerIdentifier;
@synthesize ckAssetThresholdBytes = _ckAssetThresholdBytes;
@synthesize initializeSchema = _initializeSchema;
@synthesize containerOptions = _containerOptions;
@synthesize useEncryptedStorage = _useEncryptedStorage;
@synthesize useDeviceToDeviceEncryption = _useDeviceToDeviceEncryption;
@synthesize operationMemoryThresholdBytes = _operationMemoryThresholdBytes;
@synthesize automaticallyDownloadFileBackedFutures = _automaticallyDownloadFileBackedFutures;
@synthesize automaticallyScheduleImportAndExportOperations = _automaticallyScheduleImportAndExportOperations;
@synthesize preserveLegacyRecordMetadataBehavior = _preserveLegacyRecordMetadataBehavior;
@synthesize apsConnectionMachServiceName = _apsConnectionMachServiceName;
@synthesize databaseScope = _databaseScope;
@synthesize activityVouchers = _activityVouchers;

- (instancetype)init {
    // x19
    if (self = [super init]) {
        _containerProvider = [[OCCloudKitContainerProvider alloc] init];
        _storeMonitorProvider = [[OCCloudKitStoreMonitorProvider alloc] init];
        _metricsClient = [[OCCloudKitMetricsClient alloc] init];
        _useDaemon = YES;
        _useDeviceToDeviceEncryption = NO;
        _preserveLegacyRecordMetadataBehavior = NO;
        _metadataPurger = [[OCCloudKitMetadataPurger alloc] init];
        _defaultOperationConfiguration = nil;
        _databaseScope = CKDatabaseScopePrivate;
        _archivingUtilities = [[OCCloudKitArchivingUtilities alloc] init];
        _test_useLegacySavePolicy = YES;
        _bypassSchedulerActivityForInitialImport = NO;
        _activityVouchers = [[NSArray alloc] init];
        
        if ([NSProcessInfo.processInfo.processName isEqualToString:@"homed"]) {
            _bypassSchedulerActivityForInitialImport = YES;
        }
    }
    
    return self;
}

- (instancetype)initWithContainerIdentifier:(NSString *)containerIdentifier {
    if (self = [self init]) {
        _containerIdentifier = [containerIdentifier retain];
    }
    
    return self;
}

- (instancetype)initWithCloudKitContainerOptions:(OCPersistentCloudKitContainerOptions *)containerOptions {
    // x20
    if (self = [self initWithContainerIdentifier:containerOptions.containerIdentifier]) {
        _automaticallyScheduleImportAndExportOperations = YES;
        _useDeviceToDeviceEncryption = containerOptions.useDeviceToDeviceEncryption;
        _apsConnectionMachServiceName = [containerOptions.apsConnectionMachServiceName retain];
        _databaseScope = containerOptions.databaseScope;
        _containerOptions = containerOptions.containerOptions;
        _operationMemoryThresholdBytes = [containerOptions.operationMemoryThresholdBytes retain];
        _automaticallyDownloadFileBackedFutures = containerOptions.automaticallyDownloadFileBackedFutures;
        _ckAssetThresholdBytes = [containerOptions.ckAssetThresholdBytes retain];
        
        // x21
        @autoreleasepool {
            _progressProvider = containerOptions.progressProvider;
            
            if (containerOptions.testContainerOverride != nil) {
                [_containerProvider release];
                _containerProvider = [[OCStaticCloudKitContainerProvider alloc] initWithContainer:containerOptions.testContainerOverride];
            }
        }
        
        if (containerOptions.activityVouchers.count > 0) {
            [_activityVouchers release];
            _activityVouchers = [containerOptions.activityVouchers retain];
        }
    }
    
    return self;
}

- (void)dealloc {
    [_containerIdentifier release];
    
    [_ckAssetThresholdBytes release];
    _ckAssetThresholdBytes = nil;
    
    [_operationMemoryThresholdBytes release];
    _operationMemoryThresholdBytes = nil;
    
    [_containerOptions release];
    _containerOptions = nil;
    
    [_scheduler release];
    _scheduler = nil;
    
    [_notificationListener release];
    _notificationListener = nil;
    
    [_containerProvider release];
    [_metricsClient release];
    [_metadataPurger release];
    [_storeMonitorProvider release];
    
    [_apsConnectionMachServiceName release];
    _apsConnectionMachServiceName = nil;
    
    [_defaultOperationConfiguration release];
    _defaultOperationConfiguration = nil;
    
    _progressProvider = nil;
    
    [_archivingUtilities release];
    _archivingUtilities = nil;
    
    [_activityVouchers release];
    
    [super dealloc];
}

- (id)copyWithZone:(struct _NSZone *)zone {
    return [self copy];
}

- (id)copy {
    __kindof OCCloudKitMirroringDelegateOptions *copy = [[[self class] alloc] init];
    
    copy->_containerIdentifier = [_containerIdentifier copy];
    copy->_ckAssetThresholdBytes = [_ckAssetThresholdBytes copy];
    copy->_useDeviceToDeviceEncryption = _useDeviceToDeviceEncryption;
    copy->_operationMemoryThresholdBytes = [_operationMemoryThresholdBytes retain];
    copy->_containerOptions = [_containerOptions retain];
    copy->_automaticallyDownloadFileBackedFutures = _automaticallyDownloadFileBackedFutures;
    copy->_automaticallyScheduleImportAndExportOperations = _automaticallyScheduleImportAndExportOperations;
    copy->_scheduler = [_scheduler retain];
    copy->_notificationListener = [_notificationListener retain];
    copy->_skipCloudKitSetup = _skipCloudKitSetup;
    copy->_useDaemon = _useDaemon;
    copy->_useTestDaemon = _useTestDaemon;
    
    [copy->_containerProvider release];
    copy->_containerProvider = [_containerProvider retain];
    
    [copy->_storeMonitorProvider release];
    copy->_storeMonitorProvider = [_storeMonitorProvider retain];
    
    copy->_preserveLegacyRecordMetadataBehavior = _preserveLegacyRecordMetadataBehavior;
    
    copy->_apsConnectionMachServiceName = [_apsConnectionMachServiceName retain];
    
    [copy->_metricsClient release];
    copy->_metricsClient = [_metricsClient retain];
    
    [copy->_metadataPurger release];
    copy->_metadataPurger = [_metadataPurger retain];
    
    copy->_defaultOperationConfiguration = [_defaultOperationConfiguration retain];
    copy->_databaseScope = _databaseScope;
    
    @autoreleasepool {
        copy->_progressProvider = _progressProvider;
    }
    
    [copy->_archivingUtilities release];
    copy->_archivingUtilities = [_archivingUtilities retain];
    
    copy->_test_useLegacySavePolicy = _test_useLegacySavePolicy;
    
    copy.activityVouchers = _activityVouchers;
    copy->_bypassSchedulerActivityForInitialImport = _bypassSchedulerActivityForInitialImport;
    copy->_bypassDasdRateLimiting = _bypassDasdRateLimiting;
    
    return copy;
}

- (void)setActivityVouchers:(NSArray<OCPersistentCloudKitContainerActivityVoucher *> *)activityVouchers {
    if (self->_activityVouchers == activityVouchers) return;
    
    [self->_activityVouchers release];
    
    if (activityVouchers.count > 0) {
        self->_activityVouchers = [activityVouchers retain];
    } else {
        self->_activityVouchers = [[NSArray alloc] init];
    }
}

- (void)setInitializeSchema:(BOOL)initializeSchema {
    _initializeSchema = initializeSchema;
    
    os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: NSCloudKitMirroringDelegateOptions.initializeSchema is no longer supported and will be removed in a future release. Please use -[NSPersistentCloudKitContainer initializeSchemaWithOptions:error:] or NSCloudKitMirroringInitializeSchemaRequest instead.\n");
    os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: NSCloudKitMirroringDelegateOptions.initializeSchema is no longer supported and will be removed in a future release. Please use -[NSPersistentCloudKitContainer initializeSchemaWithOptions:error:] or NSCloudKitMirroringInitializeSchemaRequest instead.\n");
}

- (void)setUseEncryptedStorage:(BOOL)useEncryptedStorage {
    self.useDeviceToDeviceEncryption = useEncryptedStorage;
}

- (NSString *)description {
    // x19
    NSMutableString *result = [[super description] mutableCopy];
    
    if (_containerIdentifier == nil) {
        [result appendFormat:@" containerIdentifier:%@", [NSNull null]];
    } else {
        [result appendFormat:@" containerIdentifier:%@", _containerIdentifier];
    }
    
    // original : softLinkCKDatabaseScopeString
    if (CKDatabaseScopeString(_databaseScope) == nil) {
        [result appendFormat:@" databaseScope:%@", [NSNull null]];
    } else {
        [result appendFormat:@" databaseScope:%@", CKDatabaseScopeString(_databaseScope)];
    }
    
    if (_ckAssetThresholdBytes == nil) {
        [result appendFormat:@" ckAssetThresholdBytes:%@", [NSNull null]];
    } else {
        [result appendFormat:@" ckAssetThresholdBytes:%@", _ckAssetThresholdBytes];
    }
    
    if (_operationMemoryThresholdBytes == nil) {
        [result appendFormat:@" operationMemoryThresholdBytes:%@", [NSNull null]];
    } else {
        [result appendFormat:@" operationMemoryThresholdBytes:%@", _operationMemoryThresholdBytes];
    }
    
    [result appendFormat:@" useEncryptedStorage:%@", _useEncryptedStorage ? @"YES" : @"NO"];
    [result appendFormat:@" useDeviceToDeviceEncryption:%@", _useDeviceToDeviceEncryption ? @"YES" : @"NO"];
    [result appendFormat:@" automaticallyDownloadFileBackedFutures:%@", _automaticallyDownloadFileBackedFutures ? @"YES" : @"NO"];
    [result appendFormat:@" automaticallyScheduleImportAndExportOperations:%@", _automaticallyScheduleImportAndExportOperations ? @"YES" : @"NO"];
    [result appendFormat:@" skipCloudKitSetup:%@", _skipCloudKitSetup ? @"YES" : @"NO"];
    [result appendFormat:@" preserveLegacyRecordMetadataBehavior:%@", _preserveLegacyRecordMetadataBehavior ? @"YES" : @"NO"];
    [result appendFormat:@" useDaemon:%@", _useDaemon ? @"YES" : @"NO"];
    
    if (_apsConnectionMachServiceName == nil) {
        [result appendFormat:@" apsConnectionMachServiceName:%@", [NSNull null]];
    } else {
        [result appendFormat:@" apsConnectionMachServiceName:%@", _apsConnectionMachServiceName];
    }
    
    if (_containerProvider == nil) {
        [result appendFormat:@" containerProvider:%@", [NSNull null]];
    } else {
        [result appendFormat:@" containerProvider:%@", _containerProvider];
    }
    
    if (_storeMonitorProvider == nil) {
        [result appendFormat:@" storeMonitorProvider:%@", [NSNull null]];
    } else {
        [result appendFormat:@" storeMonitorProvider:%@", _storeMonitorProvider];
    }
    
    if (_metricsClient == nil) {
        [result appendFormat:@" metricsClient:%@", [NSNull null]];
    } else {
        [result appendFormat:@" metricsClient:%@", _metricsClient];
    }
    
    if (_metadataPurger == nil) {
        [result appendFormat:@" metadataPurger:%@", [NSNull null]];
    } else {
        [result appendFormat:@" metadataPurger:%@", _metadataPurger];
    }
    
    if (_scheduler == nil) {
        [result appendFormat:@" scheduler:%@", [NSNull null]];
    } else {
        [result appendFormat:@" scheduler:%@", _scheduler];
    }
    
    if (_notificationListener == nil) {
        [result appendFormat:@" notificationListener:%@", [NSNull null]];
    } else {
        [result appendFormat:@" notificationListener:%@", _notificationListener];
    }
    
    if (_containerOptions == nil) {
        [result appendFormat:@" containerOptions:%@", [NSNull null]];
    } else {
        [result appendFormat:@" containerOptions:%@", _containerOptions];
    }
    
    if (_defaultOperationConfiguration == nil) {
        [result appendFormat:@" defaultOperationConfiguration:%@", [NSNull null]];
    } else {
        [result appendFormat:@" defaultOperationConfiguration:%@", _defaultOperationConfiguration];
    }
    
    @autoreleasepool {
        if (_progressProvider == nil) {
            [result appendFormat:@" progressProvider:%@", [NSNull null]];
        } else {
            [result appendFormat:@" progressProvider:%@", _progressProvider];
        }
    }
    
    [result appendFormat:@" test_useLegacySavePolicy:%@", _test_useLegacySavePolicy ? @"YES" : @"NO"];
    [result appendFormat:@" archivingUtilities:%@", _archivingUtilities];
    [result appendFormat:@" bypassSchedulerActivityForInitialImport:%@", _bypassSchedulerActivityForInitialImport ? @"YES" : @"NO"];
    [result appendFormat:@" bypassDasdRateLimiting:%@", _bypassDasdRateLimiting ? @"YES" : @"NO"];
    [result appendFormat:@" activityVouchers:%@", _activityVouchers];
    
    
    NSString *copy = [[result copy] autorelease];
    [result release];
    return copy;
}

@end
