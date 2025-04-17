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

NS_ASSUME_NONNULL_BEGIN

#warning TODO Nullale

@interface OCCloudKitMirroringDelegateOptions : NSObject <NSCopying> {
    @package OCCloudKitArchivingUtilities *_archivingUtilities; // 0x88
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
@property (retain, nonatomic, null_resettable) NSArray<OCPersistentCloudKitContainerActivityVoucher *> *activityVouchers;

- (instancetype)initWithCloudKitContainerOptions:(CKContainerOptions *)containerOptions;
- (instancetype)initWithContainerIdentifier:(NSString *)containerIdentifier;
@end

NS_ASSUME_NONNULL_END
