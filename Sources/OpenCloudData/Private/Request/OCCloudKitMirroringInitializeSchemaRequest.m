//
//  OCCloudKitMirroringInitializeSchemaRequest.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/1/25.
//

#import "OpenCloudData/Private/Request/OCCloudKitMirroringInitializeSchemaRequest.h"

@implementation OCCloudKitMirroringInitializeSchemaRequest

- (id)copyWithZone:(struct _NSZone *)zone {
    __kindof OCCloudKitMirroringInitializeSchemaRequest *copy = [super copyWithZone:zone];
    copy->_schemaInitializationOptions = _schemaInitializationOptions;
    return copy;
}

@end
