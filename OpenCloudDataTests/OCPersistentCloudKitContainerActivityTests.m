//
//  OCPersistentCloudKitContainerActivityTests.m
//  OpenCloudDataTests
//
//  Created by Jinwoo Kim on 3/31/25.
//

#import <XCTest/XCTest.h>
#import "OpenCloudData/Private/OCPersistentCloudKitContainerActivity.h"
#import "OpenCloudData/SPI/CoreData/NSPersistentCloudKitContainerActivity.h"
#include <objc/message.h>

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

- (void)test_compareWithPlatform {
    [self _test_compareWithPlatformWithError:nil];
}

- (void)test_compareWithPlatformWithError {
    NSError *error = [[NSError alloc] initWithDomain:NSURLErrorDomain code:NSURLErrorCannotCreateFile userInfo:nil];
    [self _test_compareWithPlatformWithError:error];
    [error release];
}

- (void)_test_compareWithPlatformWithError:(NSError * _Nullable)error {
    for (NSUInteger activityType = 0; activityType < 5; activityType++) {
        NSUUID *identifier = [NSUUID UUID];
        NSString *storeIdentifier = [NSUUID UUID].UUIDString;
        
        OCPersistentCloudKitContainerActivity *activity = [[OCPersistentCloudKitContainerActivity alloc] _initWithIdentifier:identifier forStore:storeIdentifier activityType:activityType];
        NSPersistentCloudKitContainerActivity *platform = [[objc_lookUpClass("NSPersistentCloudKitContainerActivity") alloc] _initWithIdentifier:identifier forStore:storeIdentifier activityType:activityType];
        
        NSMutableDictionary *dictionary_1 = [activity createDictionaryRepresentation];
        NSMutableDictionary *dictionary_2 = [platform createDictionaryRepresentation];
        
        XCTAssertNotNil(dictionary_1[@"startDate"]);
        [dictionary_1 removeObjectForKey:@"startDate"];
        XCTAssertNotNil(dictionary_2[@"startDate"]);
        [dictionary_2 removeObjectForKey:@"startDate"];
        XCTAssertTrue([dictionary_1 isEqualToDictionary:dictionary_2]);
        
        [activity finishWithError:error];
        [platform finishWithError:error];
        
        NSMutableDictionary *dictionary_3 = [activity createDictionaryRepresentation];
        NSMutableDictionary *dictionary_4 = [platform createDictionaryRepresentation];
        
        XCTAssertNotNil(dictionary_3[@"startDate"]);
        [dictionary_3 removeObjectForKey:@"startDate"];
        XCTAssertNotNil(dictionary_3[@"endDate"]);
        [dictionary_3 removeObjectForKey:@"endDate"];
        
        XCTAssertNotNil(dictionary_4[@"startDate"]);
        [dictionary_4 removeObjectForKey:@"startDate"];
        XCTAssertNotNil(dictionary_4[@"endDate"]);
        [dictionary_4 removeObjectForKey:@"endDate"];
        
        XCTAssertTrue([dictionary_3 isEqualToDictionary:dictionary_4]);
        
        [activity release];
        [platform release];
    }
}

@end
