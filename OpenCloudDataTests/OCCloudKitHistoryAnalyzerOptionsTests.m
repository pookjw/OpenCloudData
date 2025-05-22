//
//  OCCloudKitHistoryAnalyzerOptionsTests.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/5/25.
//

#import <XCTest/XCTest.h>
#import "OpenCloudData/Private/Analyzer/OCCloudKitHistoryAnalyzerOptions.h"
#import "OpenCloudData/Private/Request/OCCloudKitMirroringRequest.h"
#import "OpenCloudData/Helper/_OCDirectMethodResolver.h"
#import <objc/message.h>

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
    
    [_OCDirectMethodResolver OCCloudKitHistoryAnalyzerOptions:options setIncludePrivateTransactions:YES];
    XCTAssertTrue([_OCDirectMethodResolver OCCloudKitHistoryAnalyzerOptions_includePrivateTransactions:options]);
    [_OCDirectMethodResolver OCCloudKitHistoryAnalyzerOptions:options setIncludePrivateTransactions:NO];
    XCTAssertFalse([_OCDirectMethodResolver OCCloudKitHistoryAnalyzerOptions_includePrivateTransactions:options]);
    
    OCCloudKitMirroringRequest *request = [[OCCloudKitMirroringRequest alloc] initWithOptions:nil completionBlock:^(OCCloudKitMirroringResult * _Nonnull result) {}];
    [_OCDirectMethodResolver OCCloudKitHistoryAnalyzerOptions:options setRequest:request];
    [request release];
    XCTAssertNotNil([_OCDirectMethodResolver OCCloudKitHistoryAnalyzerOptions_request:options]);
    XCTAssertNotNil([_OCDirectMethodResolver OCCloudKitHistoryAnalyzerOptions_request:options].description); // check that request is retained
    [_OCDirectMethodResolver OCCloudKitHistoryAnalyzerOptions:options setRequest:nil];
    XCTAssertNil([_OCDirectMethodResolver OCCloudKitHistoryAnalyzerOptions_request:options]);
    
    [options release];
}

- (void)test_copyWithZone {
    OCCloudKitHistoryAnalyzerOptions *options = [OCCloudKitHistoryAnalyzerOptions new];
    [_OCDirectMethodResolver OCCloudKitHistoryAnalyzerOptions:options setIncludePrivateTransactions:YES];
    OCCloudKitMirroringRequest *request = [[OCCloudKitMirroringRequest alloc] initWithOptions:nil completionBlock:^(OCCloudKitMirroringResult * _Nonnull result) {}];
    [_OCDirectMethodResolver OCCloudKitHistoryAnalyzerOptions:options setRequest:request];
    
    OCCloudKitHistoryAnalyzerOptions *copy = [options copy];
    XCTAssertEqual([_OCDirectMethodResolver OCCloudKitHistoryAnalyzerOptions_includePrivateTransactions:options], [_OCDirectMethodResolver OCCloudKitHistoryAnalyzerOptions_includePrivateTransactions:copy]);
    XCTAssertEqualObjects([_OCDirectMethodResolver OCCloudKitHistoryAnalyzerOptions_request:options], [_OCDirectMethodResolver OCCloudKitHistoryAnalyzerOptions_request:copy]);
    
    [options release];
    [request release];
    [copy release];
}

@end
