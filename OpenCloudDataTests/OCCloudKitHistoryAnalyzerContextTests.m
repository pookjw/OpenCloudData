//
//  OCCloudKitHistoryAnalyzerContextTests.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/6/25.
//

#import <XCTest/XCTest.h>
#import <OpenCloudData/OCCloudKitHistoryAnalyzerContext.h>


@interface OCCloudKitHistoryAnalyzerContextTests : XCTestCase
@end

@implementation OCCloudKitHistoryAnalyzerContextTests

- (void)test_isPrivateContextName {
    XCTAssertTrue([OCCloudKitHistoryAnalyzerContext isPrivateContextName:@"NSCloudKitMirroringDelegate.export"]);
    XCTAssertTrue([OCCloudKitHistoryAnalyzerContext isPrivateContextName:@"NSCloudKitMirroringDelegate.import"]);
    XCTAssertFalse([OCCloudKitHistoryAnalyzerContext isPrivateContextName:@"Boo"]);
}

@end
