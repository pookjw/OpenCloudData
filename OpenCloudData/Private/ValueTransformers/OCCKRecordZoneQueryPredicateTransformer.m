//
//  OCCKRecordZoneQueryPredicateTransformer.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/29/25.
//

#import "OpenCloudData/Private/ValueTransformers/OCCKRecordZoneQueryPredicateTransformer.h"

@implementation OCCKRecordZoneQueryPredicateTransformer

+ (NSArray<Class> *)allowedTopLevelClasses {
    return [[super allowedTopLevelClasses] arrayByAddingObject:[NSPredicate class]];
}

+ (Class)transformedValueClass {
    return [NSPredicate class];
}

@end
