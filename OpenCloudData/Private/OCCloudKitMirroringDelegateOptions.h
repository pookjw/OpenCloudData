//
//  OCCloudKitMirroringDelegateOptions.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/1/25.
//

#import <OpenCloudData/OCCloudKitMirroringDelegateProgressProvider.h>
#import <OpenCloudData/CKContainerOptions.h>
#import <CloudKit/CloudKit.h>
#import <OpenCloudData/OCPersistentCloudKitContainerActivityVoucher.h>

NS_ASSUME_NONNULL_BEGIN

#warning TODO Nullale

@interface OCCloudKitMirroringDelegateOptions : NSObject <NSCopying>
@property (weak, nonatomic) NSObject<OCCloudKitMirroringDelegateProgressProvider> *progressProvider;

// original : (retain, nonatomic)
@property (copy, nonatomic) CKOperationConfiguration *defaultOperationConfiguration;

// original : (retain, nonatomic)
@property (copy, nonatomic) NSString *containerIdentifier;
@property (retain, nonatomic) NSNumber *ckAssetThresholdBytes;
@property (nonatomic) BOOL initializeSchema;

// original : (retain, nonatomic)
@property (copy, nonatomic) CKContainerOptions *containerOptions;
@property (nonatomic) BOOL useEncryptedStorage;
@property (nonatomic) BOOL useDeviceToDeviceEncryption;
@property (retain, nonatomic) NSNumber *operationMemoryThresholdBytes;
@property (nonatomic) BOOL automaticallyDownloadFileBackedFutures;
@property (nonatomic) BOOL automaticallyScheduleImportAndExportOperations;
@property (nonatomic) BOOL preserveLegacyRecordMetadataBehavior;

// original : (retain, nonatomic)
@property (copy, nonatomic) NSString *apsConnectionMachServiceName;
@property (nonatomic) CKDatabaseScope databaseScope;

// original : (retain, nonatomic)
@property (copy, nonatomic, null_resettable) NSArray<OCPersistentCloudKitContainerActivityVoucher *> *activityVouchers;

- (instancetype)initWithCloudKitContainerOptions:(CKContainerOptions *)containerOptions;
- (instancetype)initWithContainerIdentifier:(NSString *)containerIdentifier;
@end

NS_ASSUME_NONNULL_END
