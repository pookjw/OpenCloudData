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
#import <OpenCloudData/OCCloudKitMirroringResult.h>
#import <OpenCloudData/OCCloudKitMirroringRequest.h>

NS_ASSUME_NONNULL_BEGIN

@interface OCCloudKitImportRecordsWorkItem : OCCloudKitImporterWorkItem <OCCloudKitSerializerDelegate> {
    NSMutableDictionary<NSString *, NSURL *> *_assetPathToSafeSaveURL; // 0x18
    NSUUID *_importOperationIdentifier; // 0x20
    NSMutableArray<CKRecord *> *_updatedRecords; // 0x28
    size_t _totalOperationBytes; // 0x30
    OCCloudKitFetchedAssetBytesMetric *_fetchedAssetBytesMetric; // 0x38
    @package OCCloudKitFetchedRecordBytesMetric *_fetchedRecordBytesMetric; // 0x40
    NSMutableDictionary<CKRecordType, NSMutableArray<CKRecordID *> *> *_recordTypeToDeletedRecordID; // 0x48
    NSMutableArray<CKRecordID *> *_allRecordIDs; // 0x50
    NSMutableArray<NSError *> *_encounteredErrors; // 0x58
    NSMutableArray<OCMirroredRelationship *> *_failedRelationships; // 0x60
    NSMutableArray<OCCloudKitMirroringResult *> *_incrementalResults; // 0x68
    NSMutableArray<CKRecordID *> *_unknownItemRecordIDs; // 0x70
    NSMutableDictionary<CKRecordZoneID *, CKShare *> *_updatedShares; // 0x78
    size_t _currentOperationBytes; // 0x80
    NSUInteger _countUpdatedRecords; // 0x88
    NSUInteger _countDeletedRecords; // 0x90
}
@property (retain, nonatomic, readonly, direct) NSUUID *importOperationIdentifier;

- (void)addUpdatedRecord:(CKRecord *)record;
- (BOOL)applyAccumulatedChangesToStore:(NSSQLCore *)store inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext withStoreMonitor:(OCCloudKitStoreMonitor *)monitor madeChanges:(BOOL *)madeChanges error:(NSError * _Nullable * _Nullable)error;
- (BOOL)commitMetadataChangesWithContext:(NSManagedObjectContext *)managedObjectContext forStore:(NSSQLCore *)store error:(NSError * _Nullable * _Nullable)error;
- (OCCloudKitMirroringResult *)createMirroringResultForRequest:(OCCloudKitMirroringRequest *)request storeIdentifier:(NSString *)storeIdentifier success:(BOOL)success madeChanges:(BOOL)madeChanges error:(NSError * _Nullable)error NS_RETURNS_RETAINED;
- (NSDictionary<NSString *, NSArray<NSAttributeDescription *> *> * _Nullable)entityNameToAttributesToUpdate;
- (NSDictionary<NSString *, NSArray<NSRelationshipDescription *> *> * _Nullable)entityNameToRelationshipsToUpdate;
- (void)executeImportOperationsAndAccumulateRecordsWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext completion:(void (^)(OCCloudKitMirroringResult * _Nonnull))completion;

- (BOOL)updateMetadataForAccumulatedChangesInContext:(NSManagedObjectContext *)managedObjectContext inStore:(NSSQLCore *)store error:(NSError * _Nullable * _Nullable)error;

- (void)checkAndApplyChangesIfNeeded:(CKServerChangeToken * _Nullable)token __attribute__((objc_direct));
- (BOOL)checkForActiveImportOperationInStore:(NSSQLCore *)store inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct));
- (void)removeDownloadedAssetFiles __attribute__((objc_direct));
@end

NS_ASSUME_NONNULL_END
