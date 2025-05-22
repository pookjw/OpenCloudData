//
//  OCCloudKitMirroringResetMetadataRequest.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/14/25.
//

#import "OpenCloudData/Private/Request/OCCloudKitMirroringResetMetadataRequest.h"

@implementation OCCloudKitMirroringResetMetadataRequest

- (id)copyWithZone:(struct _NSZone *)zone {
    OCCloudKitMirroringResetMetadataRequest *copy = [super copyWithZone:zone];
    copy->_objectIDsToReset = [_objectIDsToReset retain];
    return copy;
}

- (void)dealloc {
    [_objectIDsToReset release];
    _objectIDsToReset = nil;
    
    [super dealloc];
}

@end
