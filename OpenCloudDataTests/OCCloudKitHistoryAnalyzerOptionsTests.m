//
//  OCCloudKitHistoryAnalyzerOptionsTests.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/5/25.
//

#import <XCTest/XCTest.h>
#import <OpenCloudData/OCCloudKitHistoryAnalyzerOptions.h>
#import <OpenCloudData/OCCloudKitMirroringRequest.h>
#import <objc/message.h>
#import <objc/runtime.h>

@interface OCCloudKitHistoryAnalyzerOptionsTests : XCTestCase
@end

@implementation OCCloudKitHistoryAnalyzerOptionsTests

- (void)test_initialization {
    OCCloudKitHistoryAnalyzerOptions *options = [OCCloudKitHistoryAnalyzerOptions new];
    XCTAssertNotNil(options);
    XCTAssertTrue([options class] == objc_lookUpClass("_OCCloudKitHistoryAnalyzerOptions"));
    XCTAssertTrue([options isKindOfClass:objc_lookUpClass("PFHistoryAnalyzerOptions")]);
    [options release];
}

- (void)test_properties {
    OCCloudKitHistoryAnalyzerOptions *options = [OCCloudKitHistoryAnalyzerOptions new];
    
    _OCCloudKitHistoryAnalyzerOptions_setIncludePrivateTransactions_(options, YES);
    XCTAssertTrue(_OCCloudKitHistoryAnalyzerOptions_includePrivateTransactions_(options));
    _OCCloudKitHistoryAnalyzerOptions_setIncludePrivateTransactions_(options, NO);
    XCTAssertFalse(_OCCloudKitHistoryAnalyzerOptions_includePrivateTransactions_(options));
    
    OCCloudKitMirroringRequest *request = [[OCCloudKitMirroringRequest alloc] initWithOptions:nil completionBlock:^(OCCloudKitMirroringResult * _Nonnull result) {}];
    _OCCloudKitHistoryAnalyzerOptions_setRequest_(options, request);
    [request release];
    XCTAssertNotNil(_OCCloudKitHistoryAnalyzerOptions_request(options));
    XCTAssertNotNil(_OCCloudKitHistoryAnalyzerOptions_request(options).description); // check that request is retained
    _OCCloudKitHistoryAnalyzerOptions_setRequest_(options, nil);
    XCTAssertNil(_OCCloudKitHistoryAnalyzerOptions_request(options));
    
    [options release];
}

- (void)test_copyWithZone {
    OCCloudKitHistoryAnalyzerOptions *options = [OCCloudKitHistoryAnalyzerOptions new];
    _OCCloudKitHistoryAnalyzerOptions_setIncludePrivateTransactions_(options, YES);
    OCCloudKitMirroringRequest *request = [[OCCloudKitMirroringRequest alloc] initWithOptions:nil completionBlock:^(OCCloudKitMirroringResult * _Nonnull result) {}];
    _OCCloudKitHistoryAnalyzerOptions_setRequest_(options, request);
    
    OCCloudKitHistoryAnalyzerOptions *copy = [options copy];
    XCTAssertEqual(_OCCloudKitHistoryAnalyzerOptions_includePrivateTransactions_(options), _OCCloudKitHistoryAnalyzerOptions_includePrivateTransactions_(copy));
    XCTAssertEqualObjects(_OCCloudKitHistoryAnalyzerOptions_request(options), _OCCloudKitHistoryAnalyzerOptions_request(copy));
    
    [options release];
    [request release];
    [copy release];
}

@end
