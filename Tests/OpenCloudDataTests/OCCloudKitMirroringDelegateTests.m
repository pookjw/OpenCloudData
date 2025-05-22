//
//  OCCloudKitMirroringDelegateTests.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/22/25.
//

#import <XCTest/XCTest.h>
#import "OpenCloudData/Private/OCCloudKitMirroringDelegate.h"

@interface OCCloudKitMirroringDelegateTests : XCTestCase
@property (class, nonatomic, readonly) NSURL *testURL;
@end

@implementation OCCloudKitMirroringDelegateTests

+ (NSURL *)testURL {
    NSURL *tmpURL = [NSURL fileURLWithPath:NSTemporaryDirectory()];
    NSURL *testURL = [[tmpURL URLByAppendingPathComponent:@"OpenCloudDataTests" isDirectory:YES] URLByAppendingPathComponent:[NSString stringWithCString:__func__ encoding:NSUTF8StringEncoding] isDirectory:NO];
    return testURL;
}

+ (BOOL)removeTestURLWithError:(NSError * _Nullable * _Nullable)error {
    return [NSFileManager.defaultManager removeItemAtURL:OCCloudKitMirroringDelegateTests.testURL error:error];
}

+ (void)assertTestURLExists {
    BOOL isDirectory;
    BOOL exists = [NSFileManager.defaultManager fileExistsAtPath:OCCloudKitMirroringDelegateTests.testURL.path isDirectory:&isDirectory];
    XCTAssertTrue(exists);
    XCTAssertTrue(isDirectory);
}

- (BOOL)tearDownWithError:(NSError * _Nullable *)error {
    return [OCCloudKitMirroringDelegateTests removeTestURLWithError:error];
}

- (void)test_createDirectory {
    [OCCloudKitMirroringDelegateTests removeTestURLWithError:NULL];
    
    NSError * _Nullable error = nil;
    BOOL result = [OCCloudKitMirroringDelegate checkAndCreateDirectoryAtURL:OCCloudKitMirroringDelegateTests.testURL wipeIfExists:NO error:&error];
    XCTAssertNil(error);
    XCTAssertTrue(result);
    
    [OCCloudKitMirroringDelegateTests assertTestURLExists];
}

- (void)test_createDirectoryWhenFileExists {
    [OCCloudKitMirroringDelegateTests removeTestURLWithError:NULL];
    
    NSError * _Nullable error = nil;
    BOOL result = [@"Hello World!" writeToURL:OCCloudKitMirroringDelegateTests.testURL atomically:YES encoding:NSUTF8StringEncoding error:&error];
    XCTAssertNil(error);
    XCTAssertTrue(result);
    
    result = [OCCloudKitMirroringDelegate checkAndCreateDirectoryAtURL:OCCloudKitMirroringDelegateTests.testURL wipeIfExists:NO error:&error];
    XCTAssertNil(error);
    XCTAssertTrue(result);
    
    [OCCloudKitMirroringDelegateTests assertTestURLExists];
}

- (void)test_createDirectoryWhenAlreadyExists {
    [OCCloudKitMirroringDelegateTests removeTestURLWithError:NULL];
    
    NSError * _Nullable error = nil;
    BOOL result = [OCCloudKitMirroringDelegate checkAndCreateDirectoryAtURL:OCCloudKitMirroringDelegateTests.testURL wipeIfExists:NO error:&error];
    XCTAssertNil(error);
    XCTAssertTrue(result);
    
    [OCCloudKitMirroringDelegateTests assertTestURLExists];
    
    result = [OCCloudKitMirroringDelegate checkAndCreateDirectoryAtURL:OCCloudKitMirroringDelegateTests.testURL wipeIfExists:NO error:&error];
    XCTAssertNil(error);
    XCTAssertTrue(result);
}

- (void)test_createDirectoryAndWipe {
    [OCCloudKitMirroringDelegateTests removeTestURLWithError:NULL];
    
    NSError * _Nullable error = nil;
    BOOL result = [OCCloudKitMirroringDelegate checkAndCreateDirectoryAtURL:OCCloudKitMirroringDelegateTests.testURL wipeIfExists:NO error:&error];
    XCTAssertNil(error);
    XCTAssertTrue(result);
    
    [OCCloudKitMirroringDelegateTests assertTestURLExists];
    
    NSURL *fileURL = [OCCloudKitMirroringDelegateTests.testURL URLByAppendingPathComponent:@"file" isDirectory:NO];
    result = [@"Hello World!" writeToURL:fileURL atomically:YES encoding:NSUTF8StringEncoding error:&error];
    XCTAssertNil(error);
    XCTAssertTrue(result);
    
    result = [OCCloudKitMirroringDelegate checkAndCreateDirectoryAtURL:OCCloudKitMirroringDelegateTests.testURL wipeIfExists:YES error:&error];
    XCTAssertNil(error);
    XCTAssertTrue(result);
    
    result = [NSFileManager.defaultManager fileExistsAtPath:fileURL.path isDirectory:NULL];
    XCTAssertFalse(result);
}

@end
