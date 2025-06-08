//
//  OCCKExportOperation.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 6/8/25.
//

#import "OpenCloudData/Private/Model/OCCKExportOperation.h"
#import "OpenCloudData/Private/Model/OCCKExportMetadata.h"
#import "OpenCloudData/Private/OCCloudKitMetadataModel.h"
#include <objc/runtime.h>

@implementation OCCKExportOperation
@dynamic statusNum;
@dynamic identifier;
@dynamic exportMetadata;
@dynamic objects;

+ (NSString *)entityPath {
    return [NSString stringWithFormat:@"%@/%@", [OCCloudKitMetadataModel ancillaryModelNamespace], NSStringFromClass(objc_lookUpClass("NSCKExportOperation"))];
}

- (int64_t)status {
    return self.statusNum.unsignedIntegerValue;
}

- (void)setStatus:(int64_t)status {
    self.statusNum = @(status);
}

@end
