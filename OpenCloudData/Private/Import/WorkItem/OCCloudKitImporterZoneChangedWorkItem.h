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

@interface OCCloudKitImporterZoneChangedWorkItem : OCCloudKitImportRecordsWorkItem
- (instancetype)initWithChangedRecordZoneIDs:(NSArray<CKRecordZoneID *> *)recordZoneIDs options:(OCCloudKitImporterOptions *)options request:(OCCloudKitMirroringImportRequest *)request;
@end

NS_ASSUME_NONNULL_END
