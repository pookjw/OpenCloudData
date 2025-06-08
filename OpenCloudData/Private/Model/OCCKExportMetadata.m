//
//  OCCKExportMetadata.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 6/8/25.
//

#import "OpenCloudData/Private/Model/OCCKExportMetadata.h"
#import "OpenCloudData/Private/OCCloudKitMetadataModel.h"
#include <objc/runtime.h>

@implementation OCCKExportMetadata
@dynamic exportedAt;
@dynamic historyToken;
@dynamic identifier;
@dynamic operations;

+ (NSString *)entityPath {
    return [NSString stringWithFormat:@"%@/%@", [OCCloudKitMetadataModel ancillaryModelNamespace], NSStringFromClass(objc_lookUpClass("NSCKExportMetadata"))];
}
@end
