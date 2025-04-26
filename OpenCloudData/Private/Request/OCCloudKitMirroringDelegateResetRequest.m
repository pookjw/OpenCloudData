//
//  OCCloudKitMirroringDelegateResetRequest.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/26/25.
//

#import <OpenCloudData/OCCloudKitMirroringDelegateResetRequest.h>

@implementation OCCloudKitMirroringDelegateResetRequest

- (instancetype)initWithError:(NSError *)error completionBlock:(void (^)(OCCloudKitMirroringResult * _Nonnull))requestCompletionBlock {
    if ([super initWithOptions:nil completionBlock:requestCompletionBlock]) {
        _causedByError = [error retain];
    }
    
    return self;
}

- (void)dealloc {
    [_causedByError release];
    [super dealloc];
}

- (id)copyWithZone:(struct _NSZone *)zone {
    OCCloudKitMirroringDelegateResetRequest *copy = [super copyWithZone:zone];
    copy->_causedByError = [_causedByError retain];
    return copy;
}

@end
