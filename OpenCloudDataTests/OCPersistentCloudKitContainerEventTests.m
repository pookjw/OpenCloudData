//
//  OCPersistentCloudKitContainerEventTests.m
//  OpenCloudDataTests
//
//  Created by Jinwoo Kim on 3/31/25.
//

#import <XCTest/XCTest.h>
#import <OpenCloudData/OCPersistentCloudKitContainerEvent.h>
#import <objc/message.h>
#import <objc/runtime.h>

@interface OCPersistentCloudKitContainerEventTests : XCTestCase
@end

@implementation OCPersistentCloudKitContainerEventTests

- (void)test_compareEventTypeStringWithPlatform {
    for (NSInteger type = 0; type < 3; type++) {
        NSString *eventType = [OCPersistentCloudKitContainerEvent eventTypeString:type];
        XCTAssertNotNil(eventType);
        
        NSString *platform = ((id (*)(Class, SEL, NSInteger))objc_msgSend)(objc_lookUpClass("NSPersistentCloudKitContainerEvent"), sel_registerName("eventTypeString:"), type);
        XCTAssertNotNil(platform);
        
        XCTAssertTrue([eventType isEqualToString:platform]);
    }
}

- (void)test_initWithCKEvent {
    // TODO
}

@end
