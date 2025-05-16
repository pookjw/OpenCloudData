//
//  OCCloudKitImportDatabaseContext.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/15/25.
//

#import <CloudKit/CloudKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OCCloudKitImportDatabaseContext : NSObject {
    @package NSMutableSet<CKRecordZoneID *> *_changedRecordZoneIDs; // 0x8
    @package NSMutableSet<CKRecordZoneID *> *_deletedRecordZoneIDs; // 0x10
    @package NSMutableSet<CKRecordZoneID *> *_purgedRecordZoneIDs; // 0x18
    @package NSMutableSet<CKRecordZoneID *> *_userResetEncryptedDataZoneIDs; // 0x20
    @package CKServerChangeToken *_updatedChangeToken; // 0x28
}
@property (nonatomic, readonly, direct) BOOL hasWorkToDo;
@property (retain, nonatomic, readonly) NSMutableSet<CKRecordZoneID *> *changedRecordZoneIDs;
@property (retain, nonatomic, readonly) NSMutableSet<CKRecordZoneID *> *deletedRecordZoneIDs;
@property (retain, nonatomic, readonly) NSMutableSet<CKRecordZoneID *> *purgedRecordZoneIDs;
@property (retain, nonatomic, readonly) NSMutableSet<CKRecordZoneID *> *userResetEncryptedDataZoneIDs;
@property (retain, nonatomic, nullable, direct) CKServerChangeToken *updatedChangeToken;
@end

NS_ASSUME_NONNULL_END
