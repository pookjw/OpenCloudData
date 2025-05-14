//
//  OCCloudKitMirroringDelegateSetupRequestOptions.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/14/25.
//

#import <OpenCloudData/OCCloudKitMirroringDelegateSetupRequestOptions.h>

@implementation OCCloudKitMirroringDelegateSetupRequestOptions

- (id)copyWithZone:(struct _NSZone *)zone {
    return [self copy];
}

- (instancetype)copy {
    OCCloudKitMirroringDelegateSetupRequestOptions *copy = [super copy];
    
    if (copy) {
        if (_fromNotification) {
            copy->_fromNotification = _fromNotification;
        }
    }
    
    return copy;
}

- (CKOperationConfiguration *)createDefaultOperationConfiguration {
    // original : getCloudKitCKOperationConfigurationClass
    return [[CKOperationConfiguration alloc] init];
}

@end
