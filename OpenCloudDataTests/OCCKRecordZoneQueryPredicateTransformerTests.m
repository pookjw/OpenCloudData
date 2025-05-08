//
//  OCCKRecordZoneQueryPredicateTransformerTests.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/29/25.
//

#import <XCTest/XCTest.h>
#import <OpenCloudData/OCCKRecordZoneQueryPredicateTransformer.h>
#import <OpenCloudData/NSCKRecordZoneQueryPredicateTransformer.h>
#import <objc/runtime.h>

@interface OCCKRecordZoneQueryPredicateTransformerTests : XCTestCase
@end

@implementation OCCKRecordZoneQueryPredicateTransformerTests

- (void)test_compareWithPlatform {
    {
        NSArray<Class> *defined = [OCCKRecordZoneQueryPredicateTransformer allowedTopLevelClasses];
        XCTAssertNotNil(defined);
        NSArray<Class> *platform = [objc_lookUpClass("NSCKRecordZoneQueryPredicateTransformer") allowedTopLevelClasses];
        XCTAssertNotNil(platform);
        XCTAssertTrue([defined isEqualToArray:platform]);
    }
    
    {
        BOOL defined = [OCCKRecordZoneQueryPredicateTransformer allowsReverseTransformation];
        BOOL platform = [objc_lookUpClass("NSCKRecordZoneQueryPredicateTransformer") allowsReverseTransformation];
        XCTAssertEqual(defined, platform);
    }
    
    {
        Class defined = [OCCKRecordZoneQueryPredicateTransformer transformedValueClass];
        Class platform = [objc_lookUpClass("NSCKRecordZoneQueryPredicateTransformer") transformedValueClass];
        XCTAssertEqual(defined, platform);
    }
    
    {
        NSArray<NSString *> *defined = [OCCKRecordZoneQueryPredicateTransformer valueTransformerNames];
        XCTAssertNotNil(defined);
        NSArray<NSString *> *platform = [objc_lookUpClass("NSCKRecordZoneQueryPredicateTransformer") valueTransformerNames];
        XCTAssertNotNil(platform);
        XCTAssertTrue([defined isEqualToArray:platform]);
    }
}

@end
