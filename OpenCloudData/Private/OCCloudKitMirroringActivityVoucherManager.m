//
//  OCCloudKitMirroringActivityVoucherManager.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/22/25.
//

#import "OpenCloudData/Private/OCCloudKitMirroringActivityVoucherManager.h"
#import "OpenCloudData/Private/Log.h"
#import "OpenCloudData/Public/OCPersistentCloudKitContainerEvent.h"

@implementation OCCloudKitMirroringActivityVoucherManager

- (instancetype)init {
    if (self = [super init]) {
        _vouchersByEventType = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)dealloc {
    [_vouchersByEventType release];
    [super dealloc];
}

- (void)addVoucher:(OCPersistentCloudKitContainerActivityVoucher *)voucher {
    NSMutableArray<OCPersistentCloudKitContainerActivityVoucher *> *vouchers = [self _vouchersForEventType:voucher.eventType];
    [vouchers addObject:voucher];
    [vouchers release];
}

- (void)expireVoucher:(OCPersistentCloudKitContainerActivityVoucher *)voucher {
    NSMutableArray<OCPersistentCloudKitContainerActivityVoucher *> *vouchers = [self _vouchersForEventType:voucher.eventType];
    [vouchers removeObject:voucher];
    [vouchers release];
}

- (void)expireVouchersForEventType:(NSInteger)eventType {
    NSMutableArray<OCPersistentCloudKitContainerActivityVoucher *> *vouchers = [self _vouchersForEventType:eventType];
    [vouchers removeAllObjects];
    [vouchers release];
}

- (BOOL)hasVoucherMatching:(id)matching {
    return NO;
}

- (OCPersistentCloudKitContainerActivityVoucher *)usableVoucherForEventType:(NSInteger)eventType {
    /*
     self = x20
     eventType = x19
     */
    if (eventType >= 3) {
        // <+124>
        os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Is there a new event type: %@\n", [OCPersistentCloudKitContainerEvent eventTypeString:eventType]);
        os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Is there a new event type: %@\n", [OCPersistentCloudKitContainerEvent eventTypeString:eventType]);
        return nil;
    }
    
    // <+52>
    return [_vouchersByEventType objectForKey:@(eventType)].lastObject;
}

- (NSUInteger)countVouchers {
    // self = x19
    // x21
    NSUInteger result = 0;
    for (NSNumber *eventTypeNum in _vouchersByEventType) {
        result += [_vouchersByEventType objectForKey:eventTypeNum].count;
    }
    return result;
}

- (NSMutableArray<OCPersistentCloudKitContainerActivityVoucher *> *)_vouchersForEventType:(NSInteger)eventType {
    // x21
    NSMutableArray<OCPersistentCloudKitContainerActivityVoucher *> *vouchers = [[_vouchersByEventType objectForKey:@(eventType)] retain];
    if (vouchers == nil) {
        vouchers = [[NSMutableArray alloc] init];
        [_vouchersByEventType setObject:vouchers forKey:@(eventType)];
    }
    return vouchers;
}

@end
