//
//  OCCloudKitImporterZonePurgedWorkItem.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/16/25.
//

#import "OpenCloudData/Private/Import/WorkItem/OCCloudKitImporterWorkItem.h"
#import "OpenCloudData/Private/Import/OCCloudKitImporterOptions.h"
#import "OpenCloudData/Private/Request/OCCloudKitMirroringImportRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface OCCloudKitImporterZonePurgedWorkItem : OCCloudKitImporterWorkItem {
    CKRecordZoneID *_purgedRecordZoneID; // 0x18
}
- (instancetype)initWithPurgedRecordZoneID:(CKRecordZoneID *)recordZoneID options:(OCCloudKitImporterOptions *)options request:(OCCloudKitMirroringImportRequest *)request;
@end

NS_ASSUME_NONNULL_END
