//
//  OCCKExportedObject.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 6/8/25.
//

#import "OpenCloudData/Private/Model/OCCKExportedObject.h"
#import "OpenCloudData/Private/Model/OCCKExportOperation.h"
#import "OpenCloudData/Private/OCCloudKitMetadataModel.h"
#include <objc/runtime.h>

@implementation OCCKExportedObject
@dynamic changeTypeNum;
@dynamic typeNum;
@dynamic ckRecordName;
@dynamic zoneName;
@dynamic operation;

+ (NSString *)entityPath {
    return [NSString stringWithFormat:@"%@/%@", [OCCloudKitMetadataModel ancillaryModelNamespace], NSStringFromClass(objc_lookUpClass("NSCKExportedObject"))];
}

- (void)setType:(int64_t)type {
    self.typeNum = @(type);
}

- (int64_t)type {
    return self.typeNum.unsignedIntegerValue;
}

- (int64_t)changeType {
    return self.changeTypeNum.unsignedIntegerValue;
}

- (void)setChangeType:(int64_t)changeType {
    self.changeTypeNum = @(changeType);
}

@end
