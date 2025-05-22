//
//  _PFBackgroundRuntimeVoucher.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/29/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface _PFBackgroundRuntimeVoucher : NSObject
+ (__kindof _PFBackgroundRuntimeVoucher *)_beginPowerAssertionNamed:(NSString *)assertionName;
+ (void)_endPowerAssertionWithVoucher:(__kindof _PFBackgroundRuntimeVoucher *)voucher;
@end

NS_ASSUME_NONNULL_END
