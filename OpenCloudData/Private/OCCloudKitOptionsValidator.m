//
//  OCCloudKitOptionsValidator.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/23/25.
//

#import "OpenCloudData/Private/OCCloudKitOptionsValidator.h"
#import "OpenCloudData/Private/Log.h"
#import "OpenCloudData/SPI/Foundation/NSObject+NSKindOfAdditions.h"
#include <objc/runtime.h>

@implementation OCCloudKitOptionsValidator

- (void)dealloc {
    [_parsedOptions release];
    [super dealloc];
}

- (BOOL)validateOptions:(OCCloudKitMirroringDelegateOptions *)delegateOptions andStoreOptions:(NSDictionary<NSString *,NSObject *> *)storeOptions error:(NSError * _Nullable *)error {
    /*
     delegateOptions = x20
     storeOptions = x21
     error = x19
     */
    os_log_with_type(_OCLogGetLogStream(0x11), OS_LOG_TYPE_DEFAULT, "OpenCloudData+CloudKit: %s(%d): Validating options: %@\nstoreOptions: %@", __func__, __LINE__, delegateOptions, storeOptions);
    
    NSString * _Nullable reason = nil;
    NSString * _Nullable containerIdentifier = delegateOptions.containerIdentifier;
    if (delegateOptions.containerIdentifier == nil) {
        // <+564>
        reason = @"A container identifier is required for the CloudKit integration.";
    } else {
        if (![containerIdentifier isNSString__]) {
            // <+628>
        } else {
            if (containerIdentifier.length == 0) {
                // <+728>
                // original : @"NSCloudKitMirroringDelegateOptions.containerIdentifier only accepts values of type '%@'. The following is not a valid value:\n%@"
                reason = [NSString stringWithFormat:@"OCCloudKitMirroringDelegateOptions.containerIdentifier only accepts values of type '%@'. The following is not a valid value:\n%@", NSStringFromClass([NSString class]), containerIdentifier];
            } else {
                if ([storeOptions objectForKey:NSPersistentHistoryTrackingKey] == nil) {
                    // <+1072>
                    reason = [NSString stringWithFormat:@"%@ is required for the CloudKit integration.", NSPersistentHistoryTrackingKey];
                } else {
                    CKContainerOptions *containerOptions = delegateOptions.containerOptions; 
                    if (containerOptions != nil) {
                        // <+320>
                        // original : getCloudKitCKContainerOptionsClass
                        if (![delegateOptions isKindOfClass:[CKContainerOptions class]]) {
                            // <+1300>
                            // original : @"NSCloudKitMirroringDelegateOptions.containerOptions only accepts values of type '%@'. The following is not a valid value:\n%@", getCloudKitCKContainerOptionsClass
                            reason = [NSString stringWithFormat:@"OCCloudKitMirroringDelegateOptions.containerOptions only accepts values of type '%@'. The following is not a valid value:\n%@", NSStringFromClass([CKContainerOptions class]), containerOptions];
                        }
                    }
                    
                    if (reason == nil) {
                        // <+360>
                        NSNumber *ckAssetThresholdBytes = delegateOptions.ckAssetThresholdBytes;
                        if (ckAssetThresholdBytes != nil) {
                            // <+372>
                            if (![ckAssetThresholdBytes isNSNumber__]) {
                                // <+1548>
                                // original : @"The value for 'NSCloudKitMirroringDelegateOptions.ckAssetThresholdBytes' must be an instance of '%@'. The following value is invalid: %@"
                                reason = [NSString stringWithFormat:@"The value for 'OCCloudKitMirroringDelegateOptions.ckAssetThresholdBytes' must be an instance of '%@'. The following value is invalid: %@", NSStringFromClass([NSNumber class]), ckAssetThresholdBytes];
                            } else {
                                if (ckAssetThresholdBytes.integerValue <= 99) {
                                    // <+2140>
                                    // original : @"The value for 'NSCloudKitMirroringDelegateOptions.ckAssetThresholdBytes' must be at least %@ bytes. The following value is invalid: %@"
                                    reason = [NSString stringWithFormat:@"The value for 'OCCloudKitMirroringDelegateOptions.ckAssetThresholdBytes' must be at least %@ bytes. The following value is invalid: %@", @(100), ckAssetThresholdBytes];
                                }
                            }
                        }
                        
                        if (reason == nil) {
                            // <+400>
                            NSNumber *operationMemoryThresholdBytes = delegateOptions.operationMemoryThresholdBytes;
                            if (operationMemoryThresholdBytes == nil) {
                                // <+2420>
                                return YES;
                            } else {
                                // <+412>
                                if (![operationMemoryThresholdBytes isNSNumber__]) {
                                    // <+1892>
                                    // original : @"The value for 'NSCloudKitMirroringDelegateOptions.operationMemoryThresholdBytes' must be an instance of '%@'. The following value is invalid: %@"
                                    reason = [NSString stringWithFormat:@"The value for 'OCCloudKitMirroringDelegateOptions.operationMemoryThresholdBytes' must be an instance of '%@'. The following value is invalid: %@", NSStringFromClass([NSNumber class]), operationMemoryThresholdBytes];
                                } else {
                                    // <+424>
                                    if (operationMemoryThresholdBytes.longLongValue >= @(2097152LL).longLongValue) {
                                        // <+2388>
                                        if (operationMemoryThresholdBytes.longLongValue <= delegateOptions.ckAssetThresholdBytes.longLongValue) {
                                            // <+2428>
                                            // original : @"The value for 'NSCloudKitMirroringDelegateOptions.operationMemoryThresholdBytes', %@, must be larger than the value of 'NSCloudKitMirroringDelegateOptions.ckAssetThresholdBytes', %@."
                                            reason = [NSString stringWithFormat:@"The value for 'OCCloudKitMirroringDelegateOptions.operationMemoryThresholdBytes', %@, must be larger than the value of 'NSCloudKitMirroringDelegateOptions.ckAssetThresholdBytes', %@.", delegateOptions.ckAssetThresholdBytes, operationMemoryThresholdBytes];
                                        } else {
                                            return YES;
                                        }
                                    } else {
                                        // <+460>
                                        // original : @"The value for 'NSCloudKitMirroringDelegateOptions.operationMemoryThresholdBytes' must be at least %@ bytes. The following value is invalid: %@"
                                        reason = [NSString stringWithFormat:@"The value for 'OCCloudKitMirroringDelegateOptions.operationMemoryThresholdBytes' must be at least %@ bytes. The following value is invalid: %@", @(2097152LL), operationMemoryThresholdBytes];
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    NSError *_error = [NSError errorWithDomain:NSCocoaErrorDomain code:134060 userInfo:@{
        NSLocalizedFailureReasonErrorKey: reason
    }];
    
    if (_error == nil) {
        os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
    } else {
        if (error != NULL) {
            *error = _error;
        }
    }
    return NO;
}

@end
