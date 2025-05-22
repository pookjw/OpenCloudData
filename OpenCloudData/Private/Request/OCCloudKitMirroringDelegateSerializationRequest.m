//
//  OCCloudKitMirroringDelegateSerializationRequest.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/14/25.
//

#import "OpenCloudData/Private/Request/OCCloudKitMirroringDelegateSerializationRequest.h"
#import "OpenCloudData/SPI/OCSPIResolver.h"
#import "OpenCloudData/Private/Log.h"

@implementation OCCloudKitMirroringDelegateSerializationRequest

- (instancetype)initWithOptions:(OCCloudKitMirroringRequestOptions *)options completionBlock:(void (^)(OCCloudKitMirroringResult * _Nonnull))requestCompletionBlock {
    if (self = [super initWithOptions:options completionBlock:requestCompletionBlock]) {
        _resultType = 0;
        _objectIDsToSerialize = [[OCSPIResolver NSSet_EmptySet] retain];
    }
    
    return self;
}

- (void)dealloc {
    [_objectIDsToSerialize release];
    [super dealloc];
}

- (id)copyWithZone:(struct _NSZone *)zone {
    OCCloudKitMirroringDelegateSerializationRequest *copy = [super copyWithZone:zone];
    copy->_resultType = _resultType;
    copy->_objectIDsToSerialize = [_objectIDsToSerialize retain];
    return copy;
}

- (NSString *)description {
    // self = x19
    // x20
    NSMutableString *result = [NSMutableString stringWithString:[super description]];
    [result appendFormat:@" resultType: %@", [OCCloudKitMirroringDelegateSerializationRequest stringForResultType:_resultType]];
    [result appendFormat:@" resultType: %@", [OCCloudKitMirroringDelegateSerializationRequest stringForResultType:_resultType]];
    [result appendFormat:@"\nobjectIDsToSerialize:\n%@", _objectIDsToSerialize];
    return result;
}

- (void)setObjectIDsToSerialize:(NSSet<NSManagedObjectID *> *)objectIDsToSerialize {
    NSSet<NSManagedObjectID *> *old_objectIDsToSerialize = self->_objectIDsToSerialize;
    if (old_objectIDsToSerialize == objectIDsToSerialize) return;
    
    [old_objectIDsToSerialize release];
    
    if (objectIDsToSerialize != nil) {
        self->_objectIDsToSerialize = [objectIDsToSerialize retain];
    } else {
        self->_objectIDsToSerialize = [[OCSPIResolver NSSet_EmptySet] retain];
    }
}

+ (NSString *)stringForResultType:(OCCloudKitMirroringDelegateSerializationRequestResultType)resultType {
    switch (resultType) {
        case OCCloudKitMirroringDelegateSerializationRequestResultTypeRecordIDs:
            return @"RecordIDs";
        case OCCloudKitMirroringDelegateSerializationRequestResultTypeRecords:
            return @"Records";
        default: {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Unknown result type: %lu\n", resultType);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Unknown result type: %lu\n", resultType);
            return nil;
        }
    }
}

@end
