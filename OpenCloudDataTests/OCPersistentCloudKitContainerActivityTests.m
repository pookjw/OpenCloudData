//
//  OCPersistentCloudKitContainerActivityTests.m
//  OpenCloudDataTests
//
//  Created by Jinwoo Kim on 3/31/25.
//

#import <XCTest/XCTest.h>
#import <OpenCloudData/OCPersistentCloudKitContainerActivity.h>

@interface OCPersistentCloudKitContainerActivityTests : XCTestCase

@end

@implementation OCPersistentCloudKitContainerActivityTests

- (void)test_createDictionaryRepresentation {
    [self _test_createDictionaryRepresentationWithError:nil];
}

- (void)test_createDictionaryRepresentationWithError {
    NSError *error = [[NSError alloc] initWithDomain:NSURLErrorDomain code:NSURLErrorCannotCreateFile userInfo:nil];
    [self _test_createDictionaryRepresentationWithError:error];
    [error release];
}

- (void)_test_createDictionaryRepresentationWithError:(NSError * _Nullable)error {
    for (NSUInteger activityType = 0; activityType < 5; activityType++) {
        NSUUID *identifier = [NSUUID UUID];
        NSString *storeIdentifier = [NSUUID UUID].UUIDString;
        
        OCPersistentCloudKitContainerActivity *activity = [[OCPersistentCloudKitContainerActivity alloc] _initWithIdentifier:identifier forStore:storeIdentifier activityType:activityType];
        
        NSDictionary *dictionary_1 = [activity createDictionaryRepresentation];
        XCTAssertTrue([dictionary_1[@"identifier"] isEqual:identifier]);
        XCTAssertTrue([dictionary_1[@"storeIdentifier"] isEqualToString:storeIdentifier]);
        XCTAssertNil(dictionary_1[@"parentActivityIdentifier"]);
        XCTAssertTrue([dictionary_1[@"activityType"] isEqualToString:[OCPersistentCloudKitContainerActivityTests _stringFromActivityType:activityType]]);
        XCTAssertNotNil(dictionary_1[@"startDate"]);
        XCTAssertNil(dictionary_1[@"endDate"]);
        XCTAssertNil(dictionary_1[@"error"]);
        XCTAssertFalse(((NSNumber *)dictionary_1[@"succeeded"]).boolValue);
        XCTAssertFalse(((NSNumber *)dictionary_1[@"finished"]).boolValue);
        
        [activity finishWithError:error];
        
        NSDictionary *dictionary_2 = [activity createDictionaryRepresentation];
        XCTAssertTrue([dictionary_2[@"identifier"] isEqual:identifier]);
        XCTAssertTrue([dictionary_2[@"storeIdentifier"] isEqualToString:storeIdentifier]);
        XCTAssertNil(dictionary_2[@"parentActivityIdentifier"]);
        XCTAssertTrue([dictionary_2[@"activityType"] isEqualToString:[OCPersistentCloudKitContainerActivityTests _stringFromActivityType:activityType]]);
        XCTAssertNotNil(dictionary_2[@"startDate"]);
        XCTAssertNotNil(dictionary_2[@"endDate"]);
        
        if (error == nil) {
            XCTAssertNil(dictionary_1[@"error"]);
        } else {
            XCTAssertTrue([dictionary_2[@"error"] isEqual:error]);
        }
        
        if (error == nil) {
            XCTAssertTrue(((NSNumber *)dictionary_2[@"succeeded"]).boolValue);
        } else {
            XCTAssertFalse(((NSNumber *)dictionary_2[@"succeeded"]).boolValue);
        }
        
        XCTAssertTrue(((NSNumber *)dictionary_2[@"finished"]).boolValue);
    }
}

+ (NSString *)_stringFromActivityType:(NSUInteger)activityType {
    switch (activityType) {
        case 0:
            return @"event";
        case 1:
            return @"cloudkit-operation";
        case 2:
            return @"history-analysis";
        case 3:
            return @"record-serialization";
        case 4:
            return @"setup-phase";
        default:
            return nil;
    }
}

@end
