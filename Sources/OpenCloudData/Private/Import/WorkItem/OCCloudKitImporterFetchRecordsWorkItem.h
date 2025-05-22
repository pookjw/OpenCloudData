//
//  OCCloudKitImporterFetchRecordsWorkItem.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/15/25.
//

#import "OpenCloudData/Private/Import/WorkItem/OCCloudKitImportRecordsWorkItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface OCCloudKitImporterFetchRecordsWorkItem : OCCloudKitImportRecordsWorkItem {
    NSMutableArray<NSManagedObjectID *> *_updatedObjectIDs; // 0x98
    NSMutableDictionary<NSManagedObjectID *, NSError *> *_failedObjectIDsToError; // 0xa0
    NSMutableDictionary<CKRecordID *, NSManagedObjectID *> *_recordIDToObjectID; // 0xa8
    NSMutableDictionary<CKOperationID, __kindof CKOperation *> *_operationsToExecute; // 0xb0
}
- (void)fetchFinishedForRecord:(CKRecord * _Nullable)record withID:(CKRecordID * _Nullable)recordID error:(NSError * _Nullable)error __attribute__((objc_direct));
@end

NS_ASSUME_NONNULL_END
