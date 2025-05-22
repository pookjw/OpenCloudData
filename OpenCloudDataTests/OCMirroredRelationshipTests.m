//
//  OCMirroredRelationshipTests.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/12/25.
//

#import <XCTest/XCTest.h>
#import "OpenCloudData/Private/MirroredRelationship/OCMirroredRelationship.h"
#import "OpenCloudData/SPI/CoreData/MirroredRelationship/PFMirroredRelationship.h"
#import "OpenCloudData/SPI/OCSPIResolver.h"
#import <objc/runtime.h>

@interface OCMirroredRelationshipTests : XCTestCase
@end

@implementation OCMirroredRelationshipTests

- (void)test_isValidMirroredRelationshipRecord_values_ {
    {
        CKRecord *record = [[CKRecord alloc] initWithRecordType:[[OCSPIResolver PFCloudKitMirroringDelegateToManyPrefix] stringByAppendingString:@"Test"]];
        XCTAssertTrue([OCMirroredRelationship isValidMirroredRelationshipRecord:record values:record]);
        XCTAssertTrue([objc_lookUpClass("PFMirroredRelationship") isValidMirroredRelationshipRecord:record values:record]);
        [record release];
    }
    
    {
        CKRecord *record = [[CKRecord alloc] initWithRecordType:@"Test"];
        XCTAssertFalse([OCMirroredRelationship isValidMirroredRelationshipRecord:record values:record]);
        XCTAssertFalse([objc_lookUpClass("PFMirroredRelationship") isValidMirroredRelationshipRecord:record values:record]);
        [record setObject:@"Test" forKey:@"CD_recordNames"];
        [record setObject:@"Test" forKey:@"CD_relationships"];
        [record setObject:@"Test" forKey:@"CD_entityNames"];
        XCTAssertTrue([OCMirroredRelationship isValidMirroredRelationshipRecord:record values:record]);
        XCTAssertTrue([objc_lookUpClass("PFMirroredRelationship") isValidMirroredRelationshipRecord:record values:record]);
        [record release];
    }
}

@end
