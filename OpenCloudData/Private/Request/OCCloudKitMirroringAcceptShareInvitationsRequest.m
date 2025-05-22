//
//  OCCloudKitMirroringAcceptShareInvitationsRequest.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/14/25.
//

#import "OpenCloudData/Private/Request/OCCloudKitMirroringAcceptShareInvitationsRequest.h"
#import "OpenCloudData/SPI/OCSPIResolver.h"

@implementation OCCloudKitMirroringAcceptShareInvitationsRequest

- (instancetype)initWithOptions:(OCCloudKitMirroringRequestOptions *)options completionBlock:(void (^)(OCCloudKitMirroringResult * _Nonnull))requestCompletionBlock {
    if (self = [super initWithOptions:options completionBlock:requestCompletionBlock]) {
        NSArray *emptyArray = [OCSPIResolver NSArray_EmptyArray];
        _shareURLsToAccept = [emptyArray retain];
        _shareMetadatasToAccept = [emptyArray retain];
    }
    
    return self;
}

- (void)dealloc {
    [_shareURLsToAccept release];
    [_shareMetadatasToAccept release];
    [super dealloc];
}

- (NSString *)description {
    NSMutableString *result = [[super description] mutableCopy];
    [result appendFormat:@"\nshareURLs: %@\nshareMetadatas: %@", _shareURLsToAccept, _shareMetadatasToAccept];
    return [result autorelease];
}

- (id)copyWithZone:(struct _NSZone *)zone {
    OCCloudKitMirroringAcceptShareInvitationsRequest *copy = [super copyWithZone:zone];
    copy->_shareURLsToAccept = [_shareURLsToAccept copy];
    copy->_shareMetadatasToAccept = [_shareMetadatasToAccept copy];
    return copy;
}

@end
