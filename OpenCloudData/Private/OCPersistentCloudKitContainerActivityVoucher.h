//
//  OCPersistentCloudKitContainerActivityVoucher.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/1/25.
//

#import <CloudKit/CloudKit.h>

NS_ASSUME_NONNULL_BEGIN

#warning TODO

@interface OCPersistentCloudKitContainerActivityVoucher : NSObject <NSCopying>
@property (copy, nonatomic, readonly, nullable) CKOperationConfiguration *operationConfiguration;
@end

NS_ASSUME_NONNULL_END
