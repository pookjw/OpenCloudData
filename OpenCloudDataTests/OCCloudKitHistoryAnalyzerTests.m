//
//  OCCloudKitHistoryAnalyzerTests.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/6/25.
//

#import <XCTest/XCTest.h>
#import "OpenCloudData/Private/Analyzer/OCCloudKitHistoryAnalyzer.h"

@interface OCCloudKitHistoryAnalyzerContextTests : XCTestCase
@end

@implementation OCCloudKitHistoryAnalyzerContextTests

- (void)test_isPrivateContextName {
    XCTAssertTrue([OCCloudKitHistoryAnalyzer isPrivateContextName:@"NSCloudKitMirroringDelegate.export"]);
    XCTAssertTrue([OCCloudKitHistoryAnalyzer isPrivateContextName:@"NSCloudKitMirroringDelegate.import"]);
    XCTAssertFalse([OCCloudKitHistoryAnalyzer isPrivateContextName:@"Boo"]);
}

@end
