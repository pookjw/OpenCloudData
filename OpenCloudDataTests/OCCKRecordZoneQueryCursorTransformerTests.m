//
//  OCCKRecordZoneQueryCursorTransformerTests.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/29/25.
//

#import <XCTest/XCTest.h>
#import "OpenCloudData/Private/ValueTransformers/OCCKRecordZoneQueryCursorTransformer.h"
#import "OpenCloudData/SPI/CoreData/ValueTransformers/NSCKRecordZoneQueryCursorTransformer.h"
#import <objc/runtime.h>

@interface OCCKRecordZoneQueryCursorTransformerTests : XCTestCase
@end

@implementation OCCKRecordZoneQueryCursorTransformerTests

- (void)test_compareWithPlatform {
    {
        NSArray<Class> *defined = [OCCKRecordZoneQueryCursorTransformer allowedTopLevelClasses];
        XCTAssertNotNil(defined);
        NSArray<Class> *platform = [objc_lookUpClass("NSCKRecordZoneQueryCursorTransformer") allowedTopLevelClasses];
        XCTAssertNotNil(platform);
        XCTAssertTrue([defined isEqualToArray:platform]);
    }
    
    {
        BOOL defined = [OCCKRecordZoneQueryCursorTransformer allowsReverseTransformation];
        BOOL platform = [objc_lookUpClass("NSCKRecordZoneQueryCursorTransformer") allowsReverseTransformation];
        XCTAssertEqual(defined, platform);
    }
    
    {
        Class defined = [OCCKRecordZoneQueryCursorTransformer transformedValueClass];
        Class platform = [objc_lookUpClass("NSCKRecordZoneQueryCursorTransformer") transformedValueClass];
        XCTAssertEqual(defined, platform);
    }
    
    {
        NSArray<NSString *> *defined = [OCCKRecordZoneQueryCursorTransformer valueTransformerNames];
        XCTAssertNotNil(defined);
        NSArray<NSString *> *platform = [objc_lookUpClass("NSCKRecordZoneQueryCursorTransformer") valueTransformerNames];
        XCTAssertNotNil(platform);
        XCTAssertTrue([defined isEqualToArray:platform]);
    }
}

@end
