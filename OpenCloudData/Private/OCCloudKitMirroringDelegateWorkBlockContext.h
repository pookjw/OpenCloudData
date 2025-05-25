//
//  OCCloudKitMirroringDelegateWorkBlockContext.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/26/25.
//

#import "OpenCloudData/SPI/CoreData/_PFClassicBackgroundRuntimeVoucher.h"

NS_ASSUME_NONNULL_BEGIN

@interface OCCloudKitMirroringDelegateWorkBlockContext : NSObject {
    @package NSString *_transactionLabel; // 0x8
    @package NSString *_powerAssertionLabel; // 0x10
    _PFClassicBackgroundRuntimeVoucher *_runtimeVoucher; // 0x18
    NSUInteger _powerAssertionID; // 0x20
}
- (instancetype)initWithTransactionLabel:(NSString *)transactionLabel powerAssertionLabel:(NSString *)powerAssertionLabel;
@end

NS_ASSUME_NONNULL_END
