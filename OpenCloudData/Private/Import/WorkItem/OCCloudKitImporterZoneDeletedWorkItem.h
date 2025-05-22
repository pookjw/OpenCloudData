//
//  OCCloudKitImporterZoneDeletedWorkItem.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/16/25.
//

#import "OpenCloudData/Private/Import/WorkItem/OCCloudKitImporterWorkItem.h"
#import "OpenCloudData/Private/Import/OCCloudKitImporterOptions.h"
#import "OpenCloudData/Private/Request/OCCloudKitMirroringImportRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface OCCloudKitImporterZoneDeletedWorkItem : OCCloudKitImporterWorkItem {
    CKRecordZoneID *_deletedRecordZoneID; // 0x18
}
- (instancetype)initWithDeletedRecordZoneID:(CKRecordZoneID *)recordZoneID options:(OCCloudKitImporterOptions *)options request:(OCCloudKitMirroringImportRequest *)request;
@end

NS_ASSUME_NONNULL_END
