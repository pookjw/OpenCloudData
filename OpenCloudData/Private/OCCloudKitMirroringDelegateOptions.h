//
//  OCCloudKitMirroringDelegateOptions.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/1/25.
//

#import <CloudKit/CloudKit.h>
#import <OpenCloudData/OCCloudKitMirroringDelegateProgressProvider.h>
#import <OpenCloudData/CKContainerOptions.h>
#import <OpenCloudData/OCPersistentCloudKitContainerActivityVoucher.h>
#import <OpenCloudData/OCCloudKitArchivingUtilities.h>
#import <OpenCloudData/OCCloudKitMetricsClient.h>
#import <OpenCloudData/OCPersistentCloudKitContainerOptions.h>
#import <OpenCloudData/CKScheduler.h>
#import <OpenCloudData/CKNotificationListener.h>
#import <OpenCloudData/OCCloudKitMetricsClient.h>
#import <OpenCloudData/OCCloudKitContainerProvider.h>
#import <OpenCloudData/OCCloudKitStoreMonitorProvider.h>
#import <OpenCloudData/OCCloudKitMetadataPurger.h>

NS_ASSUME_NONNULL_BEGIN

@interface OCCloudKitMirroringDelegateOptions : NSObject <NSCopying> {
    BOOL _initializeSchema; // 0x8
    BOOL _useDeviceToDeviceEncryption; // 0x9
    BOOL _automaticallyDownloadFileBackedFutures; // 0xa
    BOOL _automaticallyScheduleImportAndExportOperations; // 0xb
    BOOL _skipCloudKitSetup; // 0xc
    BOOL _useDaemon; // 0xd
    BOOL _useTestDaemon; // 0xe
    BOOL _preserveLegacyRecordMetadataBehavior; // 0xf
    BOOL _bypassSchedulerActivityForInitialImport; // 0x10
    BOOL _bypassDasdRateLimiting; // 0x11
    @package BOOL _test_useLegacySavePolicy; // 0x12
    
    NSString *_containerIdentifier; // 0x18
    NSNumber * _Nullable _ckAssetThresholdBytes; // 0x20
    NSNumber * _Nullable _operationMemoryThresholdBytes; // 0x28
    CKContainerOptions * _Nullable _containerOptions; // 0x30
    CKScheduler * _Nullable _scheduler; // 0x38
    CKNotificationListener * _Nullable _notificationListener; // 0x40
    @package OCCloudKitMetricsClient *_metricsClient; // 0x48
    OCCloudKitContainerProvider *_containerProvider; // 0x50
    OCCloudKitStoreMonitorProvider *_storeMonitorProvider; // 0x58
    OCCloudKitMetadataPurger *_metadataPurger; // 0x60
    NSString * _Nullable _apsConnectionMachServiceName; // 0x68
    CKOperationConfiguration * _Nullable _defaultOperationConfiguration; // 0x70
    CKDatabaseScope _databaseScope; // 0x78
    __weak NSObject<OCCloudKitMirroringDelegateProgressProvider> *_progressProvider; // 0x80
    @package OCCloudKitArchivingUtilities *_archivingUtilities; // 0x88
    NSArray<OCPersistentCloudKitContainerActivityVoucher *> *_activityVouchers; // 0x90
}
@property (weak, nonatomic) NSObject<OCCloudKitMirroringDelegateProgressProvider> *progressProvider;
@property (retain, nonatomic) CKOperationConfiguration *defaultOperationConfiguration;
@property (retain, nonatomic) NSString *containerIdentifier;
@property (retain, nonatomic) NSNumber *ckAssetThresholdBytes;
@property (nonatomic) BOOL initializeSchema;
@property (retain, nonatomic) CKContainerOptions *containerOptions;
@property (nonatomic) BOOL useEncryptedStorage;
@property (nonatomic) BOOL useDeviceToDeviceEncryption;
@property (retain, nonatomic) NSNumber *operationMemoryThresholdBytes;
@property (nonatomic) BOOL automaticallyDownloadFileBackedFutures;
@property (nonatomic) BOOL automaticallyScheduleImportAndExportOperations;
@property (nonatomic) BOOL preserveLegacyRecordMetadataBehavior;
@property (retain, nonatomic) NSString *apsConnectionMachServiceName;
@property (nonatomic) CKDatabaseScope databaseScope;
@property (retain, nonatomic, readonly, direct) OCCloudKitArchivingUtilities *archivingUtilities;
@property (retain, nonatomic, null_resettable) NSArray<OCPersistentCloudKitContainerActivityVoucher *> *activityVouchers;

- (instancetype)initWithCloudKitContainerOptions:(OCPersistentCloudKitContainerOptions *)containerOptions;
- (instancetype)initWithContainerIdentifier:(NSString *)containerIdentifier;
@end

NS_ASSUME_NONNULL_END
