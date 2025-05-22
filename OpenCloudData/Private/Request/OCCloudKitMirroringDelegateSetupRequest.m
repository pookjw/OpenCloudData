//
//  OCCloudKitMirroringDelegateSetupRequest.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/14/25.
//

#import "OpenCloudData/Private/Request/OCCloudKitMirroringDelegateSetupRequest.h"
#import "OpenCloudData/Private/Request/OCCloudKitMirroringDelegateSetupRequestOptions.h"

@implementation OCCloudKitMirroringDelegateSetupRequest

- (OCCloudKitMirroringRequestOptions *)createDefaultOptions {
    return [[OCCloudKitMirroringDelegateSetupRequestOptions alloc] init];
}

@end
