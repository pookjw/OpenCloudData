//
//  OCCloudKitMirroringRequestOptions.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/1/25.
//

#import "OpenCloudData/Private/OCPersistentCloudKitContainerActivityVoucher.h"
#import <CloudKit/CloudKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OCCloudKitMirroringRequestOptions : NSObject <NSCopying>
@property (retain, nonatomic, nullable) NSArray<OCPersistentCloudKitContainerActivityVoucher *> * vouchers;
@property (retain, nonatomic, null_resettable) CKOperationConfiguration *operationConfiguration;
@property (assign, nonatomic) NSQualityOfService qualityOfService;
@property (assign, nonatomic) BOOL allowsCellularAccess;

- (instancetype)copy;
- (CKOperationConfiguration *)createDefaultOperationConfiguration NS_RETURNS_RETAINED;
- (void)applyToOperation:(__kindof CKOperation *)operation __attribute__((objc_direct));
@end

NS_ASSUME_NONNULL_END
