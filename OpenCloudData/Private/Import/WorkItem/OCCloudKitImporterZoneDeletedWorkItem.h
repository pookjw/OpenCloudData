//
//  OCCloudKitImporterZoneDeletedWorkItem.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/16/25.
//

#import <OpenCloudData/OCCloudKitImporterWorkItem.h>
#import <OpenCloudData/OCCloudKitImporterOptions.h>
#import <OpenCloudData/OCCloudKitMirroringImportRequest.h>

NS_ASSUME_NONNULL_BEGIN

@interface OCCloudKitImporterZoneDeletedWorkItem : OCCloudKitImporterWorkItem
- (instancetype)initWithDeletedRecordZoneID:(CKRecordZoneID *)recordZoneID options:(OCCloudKitImporterOptions *)options request:(OCCloudKitMirroringImportRequest *)request;
@end

NS_ASSUME_NONNULL_END
