//
//  OCCloudKitImporterZoneChangedWorkItem.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/15/25.
//

#import <OpenCloudData/OCCloudKitImportRecordsWorkItem.h>
#import <OpenCloudData/OCCloudKitImporterOptions.h>
#import <OpenCloudData/OCCloudKitMirroringImportRequest.h>

NS_ASSUME_NONNULL_BEGIN

#warning TODO

@interface OCCloudKitImporterZoneChangedWorkItem : OCCloudKitImportRecordsWorkItem {
    NSArray<CKRecordZoneID *> *_changedRecordZoneIDs; // 0x98
    NSMutableDictionary<CKRecordZoneID *, CKServerChangeToken *> *_fetchedZoneIDToChangeToken; // 0xa0
    NSMutableDictionary<CKRecordZoneID *, id> *_fetchedZoneIDToMoreComing; // 0xa8
}
- (instancetype)initWithChangedRecordZoneIDs:(NSArray<CKRecordZoneID *> *)recordZoneIDs options:(OCCloudKitImporterOptions *)options request:(OCCloudKitMirroringImportRequest *)request;
@end

NS_ASSUME_NONNULL_END
