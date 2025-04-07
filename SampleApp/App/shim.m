//
//  shim.m
//  SampleApp
//
//  Created by Jinwoo Kim on 4/6/25.
//

#import "shim.h"
#import <CloudKit/CloudKit.h>
#import <CoreData/CoreData.h>
#import <objc/message.h>
#import <objc/runtime.h>

void sa_shim(void) {
    CKRecordZoneID *zoneID = [[CKRecordZoneID alloc] initWithZoneName:@"Zone Name" ownerName:@"Owner Name"];
    CKRecordID *recordID = [[CKRecordID alloc] initWithRecordName:@"Record Name" zoneID:zoneID];
    [zoneID release];
    CKRecord *record = [[CKRecord alloc] initWithRecordType:@"Record" recordID:recordID];
    [recordID release];
    
    NSError * _Nullable error = nil;
    NSData * _Nullable data = ((id (*)(Class, SEL, id, id *))objc_msgSend)(objc_lookUpClass("NSCKRecordMetadata"), sel_registerName("encodeRecord:error:"), record, &error);
    assert(error == nil);
    assert(data != nil);
    
    CKRecord * _Nullable decodedRecord = ((id (*)(Class, SEL, id, id *))objc_msgSend)(objc_lookUpClass("NSCKRecordMetadata"), sel_registerName("recordFromEncodedData:error:"), data, &error);
    [data release];
    assert(error == nil);
    assert(decodedRecord != nil);
    
    assert([decodedRecord.recordType isEqualToString:record.recordType]);
    assert([decodedRecord.recordID.recordName isEqualToString:record.recordID.recordName]);
    assert([decodedRecord.recordID.zoneID.zoneName isEqualToString:record.recordID.zoneID.zoneName]);
    assert([decodedRecord.recordID.zoneID.ownerName isEqualToString:record.recordID.zoneID.ownerName]);
    [record release];
    [decodedRecord release];
}
