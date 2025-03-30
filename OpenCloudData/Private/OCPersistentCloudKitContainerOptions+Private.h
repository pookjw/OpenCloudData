//
//  OCPersistentCloudKitContainerOptions+Private.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 3/30/25.
//

#import <OpenCloudData/OCPersistentCloudKitContainerOptions.h>
#import <OpenCloudData/CKContainerOptions.h>
#import <OpenCloudData/OCCloudKitMirroringDelegateProgressProvider.h>

NS_ASSUME_NONNULL_BEGIN

@interface OCPersistentCloudKitContainerOptions (Private)
@property (nonatomic) BOOL useEncryptedStorage;
@property BOOL useDeviceToDeviceEncryption;

// original: (retain, nonatomic)
@property (copy, nonatomic) NSString *apsConnectionMachServiceName;

@property (retain, nonatomic) NSNumber *operationMemoryThresholdBytes;

@property (nonatomic) BOOL automaticallyDownloadFileBackedFutures;
@property (retain, nonatomic) NSNumber *ckAssetThresholdBytes;
@property (retain, nonatomic) CKContainerOptions *containerOptions;
@property (copy, nonatomic) NSArray *activityVouchers;
@property (weak, nonatomic) NSObject<OCCloudKitMirroringDelegateProgressProvider> *progressProvider;
@end

NS_ASSUME_NONNULL_END
