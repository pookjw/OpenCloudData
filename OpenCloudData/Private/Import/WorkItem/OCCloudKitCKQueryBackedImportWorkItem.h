//
//  OCCloudKitCKQueryBackedImportWorkItem.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/15/25.
//

#import <OpenCloudData/OCCloudKitImportRecordsWorkItem.h>
#import <OpenCloudData/OCCloudKitImporterOptions.h>
#import <OpenCloudData/OCCloudKitMirroringImportRequest.h>

NS_ASSUME_NONNULL_BEGIN

#warning TODO

@interface OCCloudKitCKQueryBackedImportWorkItem : OCCloudKitImportRecordsWorkItem {
    CKRecordType _recordType; // 0x98
    NSDate *_maxModificationDate; // 0xa0
    CKQueryCursor *_queryCursor; // 0xa8
    CKRecordZoneID *_zoneIDToQuery; // 0xb0
}
@property (retain, nonatomic, readonly, direct) CKRecordZoneID *zoneIDToQuery;
- (instancetype)initForRecordType:(CKRecordType)recordType withOptions:(OCCloudKitImporterOptions *)options request:(OCCloudKitMirroringImportRequest *)request;
@end

NS_ASSUME_NONNULL_END
