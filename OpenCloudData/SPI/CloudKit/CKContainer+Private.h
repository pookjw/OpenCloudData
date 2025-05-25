//
//  CKContainer+Private.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/27/25.
//

#import "OpenCloudData/SPI/CloudKit/CKContainerOptions.h"
#import "OpenCloudData/SPI/CloudKit/CKContainerID.h"

NS_ASSUME_NONNULL_BEGIN

@interface CKContainer (Private)
@property (copy, nonatomic, readonly) CKContainerID *containerID;
- (instancetype)initWithContainerID:(CKContainerID *)containerID options:(CKContainerOptions *)options;
@end

NS_ASSUME_NONNULL_END
