//
//  OCCloudKitSerializerTests.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/6/25.
//

#import <XCTest/XCTest.h>
#import <OpenCloudData/OCCloudKitSerializer.h>
#import <objc/runtime.h>
#import <objc/message.h>

@interface OCCloudKitSerializerTests : XCTestCase
@end

@implementation OCCloudKitSerializerTests

- (void)test_defaultRecordZoneIDForDatabaseScope {
    CKRecordZoneID *publicRecordZoneID_platform = ((id (*)(Class, SEL, CKDatabaseScope))objc_msgSend)(objc_lookUpClass("PFCloudKitSerializer"), @selector(defaultRecordZoneIDForDatabaseScope:), CKDatabaseScopePublic);
    CKRecordZoneID *publicRecordZoneID_impl = [OCCloudKitSerializer defaultRecordZoneIDForDatabaseScope:CKDatabaseScopePublic];
    XCTAssertEqual(publicRecordZoneID_platform, publicRecordZoneID_impl);
    [publicRecordZoneID_platform release];
    [publicRecordZoneID_impl release];
    
    CKRecordZoneID *privateRecordZoneID_platform = ((id (*)(Class, SEL, CKDatabaseScope))objc_msgSend)(objc_lookUpClass("PFCloudKitSerializer"), @selector(defaultRecordZoneIDForDatabaseScope:), CKDatabaseScopePrivate);
    CKRecordZoneID *privateRecordZoneID_impl = [OCCloudKitSerializer defaultRecordZoneIDForDatabaseScope:CKDatabaseScopePrivate];
    XCTAssertEqual(privateRecordZoneID_platform, privateRecordZoneID_impl);
    [privateRecordZoneID_platform release];
    [privateRecordZoneID_impl release];
}

@end
