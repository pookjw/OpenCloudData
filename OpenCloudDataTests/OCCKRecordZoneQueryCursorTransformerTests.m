//
//  OCCKRecordZoneQueryCursorTransformerTests.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/29/25.
//

#import <XCTest/XCTest.h>
#import <OpenCloudData/OCCKRecordZoneQueryCursorTransformer.h>
#import <objc/runtime.h>
#import <objc/message.h>

@interface OCCKRecordZoneQueryCursorTransformerTests : XCTestCase
@end

@implementation OCCKRecordZoneQueryCursorTransformerTests

- (void)test_compareWithPlatform {
    {
        NSArray<Class> *defined = [OCCKRecordZoneQueryCursorTransformer allowedTopLevelClasses];
        XCTAssertNotNil(defined);
        NSArray<Class> *platform = ((id (*)(Class, SEL))objc_msgSend)(objc_lookUpClass("NSCKRecordZoneQueryCursorTransformer"), @selector(allowedTopLevelClasses));
        XCTAssertNotNil(platform);
        XCTAssertTrue([defined isEqualToArray:platform]);
    }
    
    {
        BOOL defined = [OCCKRecordZoneQueryCursorTransformer allowsReverseTransformation];
        BOOL platform = ((BOOL (*)(Class, SEL))objc_msgSend)(objc_lookUpClass("NSCKRecordZoneQueryCursorTransformer"), @selector(allowsReverseTransformation));
        XCTAssertEqual(defined, platform);
    }
    
    {
        Class defined = [OCCKRecordZoneQueryCursorTransformer transformedValueClass];
        Class platform = ((Class (*)(Class, SEL))objc_msgSend)(objc_lookUpClass("NSCKRecordZoneQueryCursorTransformer"), @selector(transformedValueClass));
        XCTAssertEqual(defined, platform);
    }
    
    {
        NSArray<NSString *> *defined = [OCCKRecordZoneQueryCursorTransformer valueTransformerNames];
        XCTAssertNotNil(defined);
        NSArray<NSString *> *platform = ((id (*)(Class, SEL))objc_msgSend)(objc_lookUpClass("NSCKRecordZoneQueryCursorTransformer"), @selector(valueTransformerNames));
        XCTAssertNotNil(platform);
        XCTAssertTrue([defined isEqualToArray:platform]);
    }
}

@end
