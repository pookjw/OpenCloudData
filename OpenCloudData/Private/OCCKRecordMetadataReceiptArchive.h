//
//  OCCKRecordMetadataReceiptArchive.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/7/25.
//

#import <OpenCloudData/OCCKRecordZoneMoveReceipt.h>

NS_ASSUME_NONNULL_BEGIN

@interface OCCKRecordMetadataReceiptArchive : NSObject <NSSecureCoding> {
    NSMutableDictionary<CKRecordZoneID *, NSMutableDictionary<NSString * ,NSDictionary<NSString *, id> *> *> *_zoneIDToArchivedReceipts; // 0x8
}
- (instancetype)initWithReceiptsToEncode:(NSSet<OCCKRecordZoneMoveReceipt *> *)moveReceipts;
- (void)enumerateArchivedRecordIDsUsingBlock:(void (^ NS_NOESCAPE)(CKRecordID *recordID, NSDate *movedAt))block;
@end

NS_ASSUME_NONNULL_END
