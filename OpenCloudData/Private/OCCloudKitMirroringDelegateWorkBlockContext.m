//
//  OCCloudKitMirroringDelegateWorkBlockContext.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/26/25.
//

#import "OpenCloudData/Private/OCCloudKitMirroringDelegateWorkBlockContext.h"
#include <objc/runtime.h>

@implementation OCCloudKitMirroringDelegateWorkBlockContext

- (instancetype)initWithTransactionLabel:(NSString *)transactionLabel powerAssertionLabel:(NSString *)powerAssertionLabel {
    /*
     transactionLabel = x21
     powerAssertionLabel = x19
     */
    if (self = [super init]) {
        _transactionLabel = [transactionLabel retain];
        _powerAssertionLabel = [powerAssertionLabel retain];
        _runtimeVoucher = [objc_lookUpClass("_PFClassicBackgroundRuntimeVoucher") _beginPowerAssertionNamed:powerAssertionLabel];
    }
    
    return self;
}

- (void)dealloc {
    [objc_lookUpClass("_PFClassicBackgroundRuntimeVoucher") _endPowerAssertionWithVoucher:_runtimeVoucher];
    [_transactionLabel release];
    [_powerAssertionLabel release];
    [super dealloc];
}

@end
