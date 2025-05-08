//
//  XCTestCase+OCCloudKitMetadataValueTransformerTests.m
//  OpenCloudDataTests
//
//  Created by Jinwoo Kim on 4/29/25.
//

#import <XCTest/XCTest.h>
#import <OpenCloudData/OCCloudKitMetadataValueTransformer.h>
#import <OpenCloudData/PFCloudKitMetadataValueTransformer.h>
#import <objc/runtime.h>

@interface OCCloudKitMetadataValueTransformerTests : XCTestCase
@end

@implementation OCCloudKitMetadataValueTransformerTests

- (void)test_compareWithPlatform {
    {
        NSArray<Class> *defined = [OCCloudKitMetadataValueTransformer allowedTopLevelClasses];
        XCTAssertNotNil(defined);
        NSArray<Class> *platform = [objc_lookUpClass("PFCloudKitMetadataValueTransformer") allowedTopLevelClasses];
        XCTAssertNotNil(platform);
        XCTAssertTrue([defined isEqualToArray:platform]);
    }
    
    {
        BOOL defined = [OCCloudKitMetadataValueTransformer allowsReverseTransformation];
        BOOL platform = [objc_lookUpClass("PFCloudKitMetadataValueTransformer") allowsReverseTransformation];
        XCTAssertEqual(defined, platform);
    }
    
    {
        Class defined = [OCCloudKitMetadataValueTransformer transformedValueClass];
        Class platform = [objc_lookUpClass("PFCloudKitMetadataValueTransformer") transformedValueClass];
        XCTAssertEqual(defined, platform);
    }
    
    {
        NSArray<NSString *> *defined = [OCCloudKitMetadataValueTransformer valueTransformerNames];
        XCTAssertNotNil(defined);
        NSArray<NSString *> *platform = [objc_lookUpClass("PFCloudKitMetadataValueTransformer") valueTransformerNames];
        XCTAssertNotNil(platform);
        XCTAssertTrue([defined isEqualToArray:platform]);
    }
}

@end
