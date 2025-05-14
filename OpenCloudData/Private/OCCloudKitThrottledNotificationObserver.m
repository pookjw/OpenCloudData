//
//  OCCloudKitThrottledNotificationObserver.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/22/25.
//

#import <OpenCloudData/OCCloudKitThrottledNotificationObserver.h>
#import <OpenCloudData/Log.h>
#import <OpenCloudData/_PFClassicBackgroundRuntimeVoucher.h>
#include <stdatomic.h>

@implementation OCCloudKitThrottledNotificationObserver

- (instancetype)initWithLabel:(NSString *)label handlerBlock:(void (^)(NSString * _Nonnull))handlerBlock {
    /*
     label = x21
     handlerBlock = x19
     */
    
    if (self = [super init]) {
        // self = x20
        _notificationStalenessInterval = 10;
        
        int zero = 0;
        __atomic_store(&_notificationIteration, &zero, __ATOMIC_RELEASE);
        
        _label = [label retain];
        // original : @"CoreData: %@"
        _assertionLabel = [[NSString alloc] initWithFormat:@"OpenCloudData: %@", _label];
        _notificationHandlerBlock = [handlerBlock copy];
    }
    
    return self;
}

- (void)dealloc {
    [_notificationHandlerBlock release];
    _notificationHandlerBlock = nil;
    
    [_label release];
    [_assertionLabel release];
    _assertionLabel = nil;
    
    [super dealloc];
}

- (void)noteRecievedNotification:(NSNotification *)notification {
    /*
     self = x19
     */
    // x20
    NSNotificationName notificationName = notification.name;
    
    int notificationIteration;
    __atomic_load(&_notificationIteration, &notificationIteration, __ATOMIC_SEQ_CST);
    os_log_with_type(_OCLogGetLogStream(0x11), OS_LOG_TYPE_DEFAULT, "OpenCloudData+CloudKit: %s(%d): %@: Got: %@ - %d", __func__, __LINE__, self, notificationName, notificationIteration);
    
    __atomic_add_fetch(&_notificationIteration, 1, __ATOMIC_ACQ_REL);
    if (notificationIteration != 0) {
        os_log_with_type(_OCLogGetLogStream(0x11), OS_LOG_TYPE_DEFAULT, "OpenCloudData+CloudKit: %s(%d): %@ - Already scheduled a block to respond to '%@', %d notifications since.", __func__, __LINE__, self, notificationName, notificationIteration);
    } else {
        // x21
        __kindof _PFBackgroundRuntimeVoucher *voucher = [_PFClassicBackgroundRuntimeVoucher _beginPowerAssertionNamed:self->_assertionLabel];
        
        /*
         __68-[PFCloudKitThrottledNotificationObserver noteRecievedNotification:]_block_invoke
         self = sp + 0x28 = x19 + 0x20
         notificationName = sp + 0x30 = x19 + 0x28
         voucher = sp + 0x38 = x19 + 0x30
         */
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self->_notificationStalenessInterval * NSEC_PER_SEC)), dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
            /*
             self(block) = x19
             */
            int notificationIteration = 0;
            __atomic_exchange(&_notificationIteration, &notificationIteration, &notificationIteration, __ATOMIC_ACQ_REL);
            os_log_with_type(_OCLogGetLogStream(0x11), OS_LOG_TYPE_DEFAULT, "OpenCloudData+CloudKit: %s(%d): %@: Executing '%@' block for '%@' clearing %d iterations.", __func__, __LINE__, self, self->_label, notificationName, notificationIteration);
            
            void (^notificationHandlerBlock)(NSString *assertionLabel) = _notificationHandlerBlock;
            if (notificationHandlerBlock == nil) {
                os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: No notification handler block specified. Dropping: %@\n", notificationName);
                os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: No notification handler block specified. Dropping: %@\n", notificationName);
            } else {
                notificationHandlerBlock(self->_assertionLabel);
            }
            
            [_PFClassicBackgroundRuntimeVoucher _endPowerAssertionWithVoucher:voucher];
        });
    }
}

@end
