//
//  OCCKRecordZoneQueryCursorTransformer.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/29/25.
//

#import "OpenCloudData/Private/ValueTransformers/OCCKRecordZoneQueryCursorTransformer.h"

@implementation OCCKRecordZoneQueryCursorTransformer

+ (NSArray<Class> *)allowedTopLevelClasses {
    // original : getCloudKitCKQueryCursorClass
    return [[super allowedTopLevelClasses] arrayByAddingObject:[CKQueryCursor class]];
}

+ (Class)transformedValueClass {
    // original : getCloudKitCKQueryCursorClass
    return [CKQueryCursor class];
}

@end
