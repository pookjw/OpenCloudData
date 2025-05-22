//
//  OCCloudKitMirroringExportProgressRequest.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/14/25.
//

#import "OpenCloudData/Private/Request/OCCloudKitMirroringExportProgressRequest.h"
#import "OpenCloudData/SPI/OCSPIResolver.h"

@implementation OCCloudKitMirroringExportProgressRequest

- (instancetype)initWithOptions:(OCCloudKitMirroringRequestOptions *)options completionBlock:(void (^)(OCCloudKitMirroringResult * _Nonnull))requestCompletionBlock {
    if (self = [super initWithOptions:options completionBlock:requestCompletionBlock]) {
        _objectIDsToFetch = [[OCSPIResolver NSSet_EmptySet] retain];
    }
    
    return self;
}

- (void)dealloc {
    [_objectIDsToFetch release];
    [super dealloc];
}

- (id)copyWithZone:(struct _NSZone *)zone {
    OCCloudKitMirroringExportProgressRequest *copy = [super copyWithZone:zone];
    [copy->_objectIDsToFetch release];
    copy->_objectIDsToFetch = [_objectIDsToFetch retain];
    return copy;
}

- (void)setObjectIDsToFetch:(NSSet<NSManagedObjectID *> *)objectIDsToFetch {
    NSSet<NSManagedObjectID *> *old_objectIDsToFetch = _objectIDsToFetch;
    if (old_objectIDsToFetch == objectIDsToFetch) return;
    
    [old_objectIDsToFetch release];
    if (objectIDsToFetch != nil) {
        self->_objectIDsToFetch = [objectIDsToFetch copy];
    } else {
        self->_objectIDsToFetch = [[OCSPIResolver NSSet_EmptySet] retain];
    }
}

@end
