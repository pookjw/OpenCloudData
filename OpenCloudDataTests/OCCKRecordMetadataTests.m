//
//  OCCKRecordMetadataTests.m
//  OpenCloudDataTests
//
//  Created by Jinwoo Kim on 4/6/25.
//

#import <XCTest/XCTest.h>
#import <CloudKit/CloudKit.h>
#import <OpenCloudData/OCCKRecordMetadata.h>
#import <objc/message.h>
#import <objc/runtime.h>

@interface OCCKRecordMetadataTests : XCTestCase
@end

@implementation OCCKRecordMetadataTests

- (void)test_encodeRecord {
    CKRecord *originalRecord = [OCCKRecordMetadataTests _createRecord];
    
    NSError * _Nullable error = nil;
    
    NSData * _Nullable data = [OCCKRecordMetadata encodeRecord:originalRecord error:&error];
    XCTAssertNil(error);
    XCTAssertNotNil(data);
    
    NSData * _Nullable decompressedData = [data decompressedDataUsingAlgorithm:NSDataCompressionAlgorithmLZFSE error:&error];
    XCTAssertNil(error);
    XCTAssertNotNil(decompressedData);
    [data release];
    
    CKRecord * _Nullable decodedReocrd = [NSKeyedUnarchiver unarchivedObjectOfClass:[CKRecord class] fromData:decompressedData error:&error];
    XCTAssertNil(error);
    XCTAssertNotNil(decodedReocrd);
    
    XCTAssertTrue([decodedReocrd.recordType isEqualToString:originalRecord.recordType]);
    XCTAssertTrue([decodedReocrd.recordID.recordName isEqualToString:originalRecord.recordID.recordName]);
    XCTAssertTrue([decodedReocrd.recordID.zoneID.zoneName isEqualToString:originalRecord.recordID.zoneID.zoneName]);
    XCTAssertTrue([decodedReocrd.recordID.zoneID.ownerName isEqualToString:originalRecord.recordID.zoneID.ownerName]);
}

- (void)test_compareWithPlatform {
    CKRecord *record = [OCCKRecordMetadataTests _createRecord];
    
    NSError * _Nullable error = nil;
    
    NSData * _Nullable data_1 = [OCCKRecordMetadata encodeRecord:record error:&error];
    XCTAssertNil(error);
    XCTAssertNotNil(data_1);
    
    NSData * _Nullable data_2 = ((id (*)(Class, SEL, id, id *))objc_msgSend)(objc_lookUpClass("NSCKRecordMetadata"), sel_registerName("encodeRecord:error:"), record, &error);
    XCTAssertNil(error);
    XCTAssertNotNil(data_2);
    
    XCTAssertTrue([data_1 isEqualToData:data_2]);
    [data_1 release];
    [data_2 release];
}

+ (CKRecord *)_createRecord {
    CKRecordZoneID *zoneID = [[CKRecordZoneID alloc] initWithZoneName:@"Zone Name" ownerName:@"Owner Name"];
    CKRecordID *recordID = [[CKRecordID alloc] initWithRecordName:@"Record Name" zoneID:zoneID];
    [zoneID release];
    CKRecord *record = [[CKRecord alloc] initWithRecordType:@"Record" recordID:recordID];
    [recordID release];
    return [record autorelease];
}

@end
