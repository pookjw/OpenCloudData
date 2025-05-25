//
//  OCCloudKitMirroringActivityVoucherManager.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/22/25.
//

#import "OpenCloudData/Private/OCPersistentCloudKitContainerActivityVoucher.h"

NS_ASSUME_NONNULL_BEGIN

#warning TODO

@interface OCCloudKitMirroringActivityVoucherManager : NSObject {
    NSMutableDictionary<NSNumber *, NSMutableArray<OCPersistentCloudKitContainerActivityVoucher *> *> *_vouchersByEventType; // 0x8
}
@property (nonatomic, readonly) NSUInteger countVouchers;
- (void)addVoucher:(OCPersistentCloudKitContainerActivityVoucher *)voucher;
- (void)expireVoucher:(OCPersistentCloudKitContainerActivityVoucher *)voucher;
- (void)expireVouchersForEventType:(NSInteger)eventType;
- (BOOL)hasVoucherMatching:(id)matching;
- (OCPersistentCloudKitContainerActivityVoucher * _Nullable)usableVoucherForEventType:(NSInteger)eventType;
- (NSMutableArray<OCPersistentCloudKitContainerActivityVoucher *> *)_vouchersForEventType:(NSInteger)eventType NS_RETURNS_RETAINED __attribute__((objc_direct));
@end

NS_ASSUME_NONNULL_END
