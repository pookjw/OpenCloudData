//
//  OCCloudKitImporterFetchRecordsWorkItem.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/15/25.
//

#import <OpenCloudData/OCCloudKitImportRecordsWorkItem.h>

NS_ASSUME_NONNULL_BEGIN

#warning TODO

@interface OCCloudKitImporterFetchRecordsWorkItem : OCCloudKitImportRecordsWorkItem {
    NSMutableArray<CKRecordID *> *_updatedObjectIDs; // 0x98
    NSMutableDictionary<NSManagedObjectID *, NSError *> *_failedObjectIDsToError; // 0xa0
    NSMutableDictionary<CKRecordID *, NSManagedObjectID *> *_recordIDToObjectID; // 0xa8
    NSMutableDictionary *_operationsToExecute; // 0xb0
}

@end

NS_ASSUME_NONNULL_END
