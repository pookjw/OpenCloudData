//
//  OCCloudKitImportRecordsWorkItem.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/15/25.
//

#import <OpenCloudData/OCCloudKitImporterWorkItem.h>
#import <OpenCloudData/OCCloudKitFetchedRecordBytesMetric.h>
#import <OpenCloudData/OCCloudKitFetchedAssetBytesMetric.h>
#import <OpenCloudData/OCCloudKitSerializer.h>

NS_ASSUME_NONNULL_BEGIN

#warning TODO

@interface OCCloudKitImportRecordsWorkItem : OCCloudKitImporterWorkItem <OCCloudKitSerializerDelegate> {
    NSMutableDictionary<NSString *, NSURL *> *_assetPathToSafeSaveURL; // 0x18
    NSUUID *_importOperationIdentifier; // 0x20
    NSMutableArray<CKRecord *> *_updatedRecords; // 0x28
    size_t _totalOperationBytes; // 0x30
    OCCloudKitFetchedAssetBytesMetric *_fetchedAssetBytesMetric; // 0x38
    @package OCCloudKitFetchedRecordBytesMetric *_fetchedRecordBytesMetric; // 0x40
    NSMutableDictionary<CKRecordType, CKRecordID *> *_recordTypeToDeletedRecordID; // 0x48
    NSMutableArray<CKRecordID *> *_allRecordIDs; // 0x50
    NSMutableArray<NSError *> *_encounteredErrors; // 0x58
    NSMutableArray<NSRelationshipDescription *> *_failedRelationships; // 0x60
    NSMutableArray *_incrementalResults; // 0x68
    NSMutableArray<CKRecordID *> *_unknownItemRecordIDs; // 0x70
    NSMutableDictionary *_updatedShares; // 0x78
    size_t _currentOperationBytes; // 0x80
    NSUInteger _countUpdatedRecords; // 0x88
    NSUInteger _countDeletedRecords; // 0x90
}

@end

NS_ASSUME_NONNULL_END
