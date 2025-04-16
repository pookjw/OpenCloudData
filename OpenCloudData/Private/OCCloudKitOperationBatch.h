//
//  OCCloudKitOperationBatch.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/15/25.
//

#import <CloudKit/CloudKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OCCloudKitOperationBatch : NSObject {
    @package NSMutableSet<CKRecordID *> *_deletedRecordIDs;
    NSMutableDictionary<CKRecordType, NSMutableSet<CKRecordID *> *> *_recordTypeToDeletedRecordID;
    NSMutableArray<CKRecord *> *_records;
    @package NSMutableSet<CKRecordID *> *_recordIDs;
    size_t _sizeInBytes;
}
- (void)addRecord:(CKRecord *)record __attribute__((objc_direct));
- (void)addDeletedRecordID:(CKRecordID *)deletedRecordID forRecordOfType:(CKRecordType)recordType __attribute__((objc_direct));
@end

NS_ASSUME_NONNULL_END
