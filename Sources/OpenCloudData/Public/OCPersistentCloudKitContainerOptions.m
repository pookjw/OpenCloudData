//
//  OCPersistentCloudKitContainerOptions.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 3/30/25.
//

#import "OpenCloudData/Public/OCPersistentCloudKitContainerOptions.h"
#import "OpenCloudData/Private/OCPersistentCloudKitContainerOptions+OpenCloudData_Private.h"

@interface OCPersistentCloudKitContainerOptions ()
@property (assign, nonatomic) BOOL useEncryptedStorage;
@property (assign) BOOL useDeviceToDeviceEncryption;
@property (retain, nonatomic) NSString *apsConnectionMachServiceName;
@property (retain, nonatomic) NSNumber *operationMemoryThresholdBytes;
@property (nonatomic) BOOL automaticallyDownloadFileBackedFutures;
@property (retain, nonatomic, nullable) NSNumber *ckAssetThresholdBytes;
@property (retain, nonatomic, nullable) CKContainerOptions *containerOptions;
@property (copy, nonatomic, null_resettable) NSArray<OCPersistentCloudKitContainerActivityVoucher *> *activityVouchers;
@property (weak, nonatomic, nullable) NSObject<OCCloudKitMirroringDelegateProgressProvider> *progressProvider;
@property (retain, nonatomic, nullable) CKContainer *testContainerOverride;
@end

@implementation OCPersistentCloudKitContainerOptions

- (instancetype)initWithContainer:(CKContainer *)container {
    if (self = [self initWithContainerIdentifier:container.containerIdentifier]) {
        _testContainerOverride = [container retain];
    }
    
    return self;
}

- (instancetype)initWithContainerIdentifier:(NSString *)containerIdentifier {
    if (self = [super init]) {
        _useDeviceToDeviceEncryption = NO;
        _containerIdentifier = [containerIdentifier copy];
        _apsConnectionMachServiceName = nil;
        _databaseScope = CKDatabaseScopePrivate;
        _activityVouchers = [[NSArray alloc] init];
    }
    
    return self;
}

- (void)dealloc {
    [_containerIdentifier release];
    [_apsConnectionMachServiceName release];
    [_testContainerOverride release];
    [_containerOptions release];
    [_operationMemoryThresholdBytes release];
    [_ckAssetThresholdBytes release];
    [_activityVouchers release];;
    [super dealloc];
}

- (BOOL)useEncryptedStorage {
    return self.useDeviceToDeviceEncryption;
}

- (void)setUseEncryptedStorage:(BOOL)useEncryptedStorage {
    self.useDeviceToDeviceEncryption = useEncryptedStorage;
}

- (void)setActivityVouchers:(NSArray *)activityVouchers {
    NSArray *oldActivityVouchers = _activityVouchers;
    if (oldActivityVouchers == activityVouchers) return;
    
    [oldActivityVouchers release];
    
    NSArray *newActivityVouchers;
    if (activityVouchers) {
        // attribute는 copy이지만 -retain
        newActivityVouchers = [activityVouchers retain];
    } else {
        newActivityVouchers = [[NSArray alloc] init];
    }
    
    _activityVouchers = newActivityVouchers;
}

@end
