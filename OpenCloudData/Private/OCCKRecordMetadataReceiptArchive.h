//
//  OCCKRecordMetadataReceiptArchive.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/7/25.
//

#import <OpenCloudData/OCCKRecordZoneMoveReceipt.h>

NS_ASSUME_NONNULL_BEGIN

#warning TODO

@interface OCCKRecordMetadataReceiptArchive : NSObject <NSSecureCoding>
- (instancetype)initWithReceiptsToEncode:(NSSet<OCCKRecordZoneMoveReceipt *> *)moveReceipts;
@end

NS_ASSUME_NONNULL_END
