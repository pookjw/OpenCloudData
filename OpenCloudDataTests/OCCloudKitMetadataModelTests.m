//
//  OCCloudKitMetadataModelTests.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 6/10/25.
//

#import <XCTest/XCTest.h>
#import "OpenCloudData/Private/OCCloudKitMetadataModel.h"
#import "OpenCloudData/SPI/OCSPIResolver.h"
#include <objc/runtime.h>

@interface OCCloudKitMetadataModelTests : XCTestCase
@end

@implementation OCCloudKitMetadataModelTests

- (void)test {
    NSEntityDescription *entity_1 = [[NSEntityDescription alloc] init];
    entity_1.name = @"Entity1";
    
    NSEntityDescription *entity_2 = [[NSEntityDescription alloc] init];
    entity_2.name = @"Entity2";
    
    
    [OCSPIResolver _PFModelUtilities_addRelationships_toPropertiesOfEntity:objc_lookUpClass("_PFModelUtilities")
                                                                        x1:@{
        @"database": @[
            @100, // maxCount
            entity_1,
            @"recordZones",
            @(NSNullifyDeleteRule), // deleteRule
            @YES, // isOptional
        ]
    }
                                                                        x2:entity_2];
    
    NSLog(@"%@", [entity_2.properties.firstObject _ivarDescription]);
    
    [entity_1 release];
    [entity_2 release];
}

@end
