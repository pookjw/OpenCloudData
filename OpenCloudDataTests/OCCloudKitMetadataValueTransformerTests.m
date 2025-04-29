//
//  XCTestCase+OCCloudKitMetadataValueTransformerTests.m
//  OpenCloudDataTests
//
//  Created by Jinwoo Kim on 4/29/25.
//

#import <XCTest/XCTest.h>
#import <OpenCloudData/OCCloudKitMetadataValueTransformer.h>
#import <objc/runtime.h>
#import <objc/message.h>

@interface OCCloudKitMetadataValueTransformerTests : XCTestCase
@end

@implementation OCCloudKitMetadataValueTransformerTests

- (void)test_compareWithPlatform {
    {
        NSArray<Class> *defined = [OCCloudKitMetadataValueTransformer allowedTopLevelClasses];
        XCTAssertNotNil(defined);
        NSArray<Class> *platform = ((id (*)(Class, SEL))objc_msgSend)(objc_lookUpClass("PFCloudKitMetadataValueTransformer"), @selector(allowedTopLevelClasses));
        XCTAssertNotNil(platform);
        XCTAssertTrue([defined isEqualToArray:platform]);
    }
    
    {
        BOOL defined = [OCCloudKitMetadataValueTransformer allowsReverseTransformation];
        BOOL platform = ((BOOL (*)(Class, SEL))objc_msgSend)(objc_lookUpClass("PFCloudKitMetadataValueTransformer"), @selector(allowsReverseTransformation));
        XCTAssertEqual(defined, platform);
    }
    
    {
        Class defined = [OCCloudKitMetadataValueTransformer transformedValueClass];
        Class platform = ((Class (*)(Class, SEL))objc_msgSend)(objc_lookUpClass("PFCloudKitMetadataValueTransformer"), @selector(transformedValueClass));
        XCTAssertEqual(defined, platform);
    }
    
    {
        NSArray<NSString *> *defined = [OCCloudKitMetadataValueTransformer valueTransformerNames];
        XCTAssertNotNil(defined);
        NSArray<NSString *> *platform = ((id (*)(Class, SEL))objc_msgSend)(objc_lookUpClass("PFCloudKitMetadataValueTransformer"), @selector(valueTransformerNames));
        XCTAssertNotNil(platform);
        XCTAssertTrue([defined isEqualToArray:platform]);
    }
}

@end
