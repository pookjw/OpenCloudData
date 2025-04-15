//
//  OCCloudKitOperationBatch.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/15/25.
//

#import <OpenCloudData/OCCloudKitOperationBatch.h>
#import <OpenCloudData/CKRecord+Private.h>
#import <OpenCloudData/OCCloudKitSerializer.h>

@implementation OCCloudKitOperationBatch

- (instancetype)init {
    if (self = [super init]) {
        _sizeInBytes = 0;
        _recordTypeToDeletedRecordID = [[NSMutableDictionary alloc] init];
        _records = [[NSMutableArray alloc] init];
        _deletedRecordIDs = [[NSMutableSet alloc] init];
        _recordIDs = [[NSMutableSet alloc] init];
    }
    
    return self;
}

- (void)dealloc {
    [_recordTypeToDeletedRecordID release];
    [_records release];
    [_deletedRecordIDs release];
    [_recordIDs release];
    [super dealloc];
}

- (void)addRecord:(CKRecord *)record {
    /*
     self = x20
     record = x19
     */
    
    _sizeInBytes += record.size;
    [_records addObject:record];
    [_recordIDs addObject:record.recordID];
}

- (void)addDeletedRecordID:(CKRecordID *)deletedRecordID forRecordOfType:(CKRecordType)recordType {
    /*
     self = x21
     deletecRecordID = x19
     recordType = x20
     */
    
    [_deletedRecordIDs addObject:deletedRecordID];
    _sizeInBytes += [OCCloudKitSerializer estimateByteSizeOfRecordID:deletedRecordID];
    
    NSMutableSet<CKRecordID *> *deletedRecordIDs = [_recordTypeToDeletedRecordID[recordType] retain];
    if (deletedRecordIDs == nil) {
        deletedRecordIDs = [[NSMutableSet alloc] init];
        _recordTypeToDeletedRecordID[recordType] = deletedRecordIDs;
    }
    [deletedRecordIDs addObject:deletedRecordID];
    [deletedRecordIDs release];
}

@end
