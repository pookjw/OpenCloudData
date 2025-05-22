//
//  OCCloudKitImporterZoneChangedWorkItem.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/15/25.
//

#import "OpenCloudData/Private/Import/WorkItem/OCCloudKitImportRecordsWorkItem.h"
#import "OpenCloudData/Private/Import/OCCloudKitImporterOptions.h"
#import "OpenCloudData/Private/Request/OCCloudKitMirroringImportRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface OCCloudKitImporterZoneChangedWorkItem : OCCloudKitImportRecordsWorkItem {
    NSArray<CKRecordZoneID *> *_changedRecordZoneIDs; // 0x98
    NSMutableDictionary<CKRecordZoneID *, CKServerChangeToken *> *_fetchedZoneIDToChangeToken; // 0xa0
    NSMutableDictionary<CKRecordZoneID *, NSNumber *> *_fetchedZoneIDToMoreComing; // 0xa8
}
- (instancetype)initWithChangedRecordZoneIDs:(NSArray<CKRecordZoneID *> *)recordZoneIDs options:(OCCloudKitImporterOptions *)options request:(OCCloudKitMirroringImportRequest *)request;
@end

NS_ASSUME_NONNULL_END
