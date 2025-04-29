//
//  OCCKRecordZoneQueryPredicateTransformerTests.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/29/25.
//

#import <XCTest/XCTest.h>
#import <OpenCloudData/OCCKRecordZoneQueryPredicateTransformer.h>
#import <objc/runtime.h>
#import <objc/message.h>

@interface OCCKRecordZoneQueryPredicateTransformerTests : XCTestCase
@end

@implementation OCCKRecordZoneQueryPredicateTransformerTests

- (void)test_compareWithPlatform {
    {
        NSArray<Class> *defined = [OCCKRecordZoneQueryPredicateTransformer allowedTopLevelClasses];
        XCTAssertNotNil(defined);
        NSArray<Class> *platform = ((id (*)(Class, SEL))objc_msgSend)(objc_lookUpClass("NSCKRecordZoneQueryPredicateTransformer"), @selector(allowedTopLevelClasses));
        XCTAssertNotNil(platform);
        XCTAssertTrue([defined isEqualToArray:platform]);
    }
    
    {
        BOOL defined = [OCCKRecordZoneQueryPredicateTransformer allowsReverseTransformation];
        BOOL platform = ((BOOL (*)(Class, SEL))objc_msgSend)(objc_lookUpClass("NSCKRecordZoneQueryPredicateTransformer"), @selector(allowsReverseTransformation));
        XCTAssertEqual(defined, platform);
    }
    
    {
        Class defined = [OCCKRecordZoneQueryPredicateTransformer transformedValueClass];
        Class platform = ((Class (*)(Class, SEL))objc_msgSend)(objc_lookUpClass("NSCKRecordZoneQueryPredicateTransformer"), @selector(transformedValueClass));
        XCTAssertEqual(defined, platform);
    }
    
    {
        NSArray<NSString *> *defined = [OCCKRecordZoneQueryPredicateTransformer valueTransformerNames];
        XCTAssertNotNil(defined);
        NSArray<NSString *> *platform = ((id (*)(Class, SEL))objc_msgSend)(objc_lookUpClass("NSCKRecordZoneQueryPredicateTransformer"), @selector(valueTransformerNames));
        XCTAssertNotNil(platform);
        XCTAssertTrue([defined isEqualToArray:platform]);
    }
}

@end
