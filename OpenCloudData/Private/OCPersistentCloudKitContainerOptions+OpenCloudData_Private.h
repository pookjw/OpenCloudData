//
//  OCPersistentCloudKitContainerOptions+OpenCloudData_Private.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 3/30/25.
//

#import <CloudKit/CloudKit.h>
#import "OpenCloudData/Public/OCPersistentCloudKitContainerOptions.h"
#import "OpenCloudData/SPI/CloudKit/CKContainerOptions.h"
#import "OpenCloudData/Private/OCCloudKitMirroringDelegateProgressProvider.h"
#import "OpenCloudData/Private/OCPersistentCloudKitContainerActivityVoucher.h"

NS_ASSUME_NONNULL_BEGIN

@interface OCPersistentCloudKitContainerOptions (OpenCloudData_Private)
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

- (instancetype)initWithContainer:(CKContainer *)container;
@end

NS_ASSUME_NONNULL_END
