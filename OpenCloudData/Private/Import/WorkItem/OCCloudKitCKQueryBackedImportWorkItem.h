//
//  OCCloudKitCKQueryBackedImportWorkItem.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/15/25.
//

#import "OpenCloudData/Private/Import/WorkItem/OCCloudKitImportRecordsWorkItem.h"
#import "OpenCloudData/Private/Import/OCCloudKitImporterOptions.h"
#import "OpenCloudData/Private/Request/OCCloudKitMirroringImportRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface OCCloudKitCKQueryBackedImportWorkItem : OCCloudKitImportRecordsWorkItem {
    CKRecordType _recordType; // 0x98
    NSDate *_maxModificationDate; // 0xa0
    CKQueryCursor *_queryCursor; // 0xa8
    CKRecordZoneID *_zoneIDToQuery; // 0xb0
}
@property (retain, nonatomic, readonly, direct) CKRecordZoneID *zoneIDToQuery;
- (instancetype)initForRecordType:(CKRecordType)recordType withOptions:(OCCloudKitImporterOptions *)options request:(OCCloudKitMirroringImportRequest *)request;
- (CKQueryOperation * _Nullable)newCKQueryOperationFromMetadataInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct));
- (void)queryOperationFinishedWithCursor:(CKQueryCursor * _Nullable)cursor error:(NSError * _Nullable)error completion:(void (^ _Nullable)(OCCloudKitMirroringResult * _Nonnull))completion __attribute__((objc_direct));
@end

NS_ASSUME_NONNULL_END
