//
//  OCCloudKitExporterOptions.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/5/25.
//

#import <OpenCloudData/OCCloudKitExporterOptions.h>

@implementation OCCloudKitExporterOptions

- (instancetype)initWithDatabase:(CKDatabase *)database options:(OCCloudKitMirroringDelegateOptions *)options {
    if (self = [super init]) {
        _database = [database retain];
        _options = [options retain];
        _perOperationBytesThreshold = 1572864UL;
        _perOperationObjectThreshold = 400;
    }
    
    return self;
}

- (void)dealloc {
    [_database release];
    [_options release];
    [super dealloc];
}

- (id)copy {
    OCCloudKitExporterOptions *copy = [[OCCloudKitExporterOptions alloc] initWithDatabase:_database options:_options];
    
    if (copy) {
        copy->_perOperationObjectThreshold = _perOperationObjectThreshold;
        copy->_perOperationBytesThreshold = _perOperationBytesThreshold;
    }
    
    return copy;
}

- (id)copyWithZone:(struct _NSZone *)zone {
    return [self copy];
}

@end
