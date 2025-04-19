//
//  OCCloudKitExportContext.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/5/25.
//

#import <CoreData/CoreData.h>
#import <OpenCloudData/OCCloudKitExporterOptions.h>
#import <OpenCloudData/NSSQLCore.h>
#import <OpenCloudData/OCCloudKitOperationBatch.h>

NS_ASSUME_NONNULL_BEGIN

@interface OCCloudKitExportContext : NSObject {
    OCCloudKitExporterOptions *_options;
    @package size_t _totalBytes;
    NSUInteger _totalRecords;
    NSUInteger _totalRecordIDs;
    @package NSMutableArray<NSURL *> *_writtenAssetURLs;
}
- (instancetype)initWithOptions:(OCCloudKitExporterOptions *)options;
- (BOOL)processAnalyzedHistoryInStore:(NSSQLCore *)store inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable * _Nullable)error;
- (BOOL)checkForObjectsNeedingExportInStore:(__kindof NSPersistentStore *)store andReturnCount:(NSUInteger *)count withManagedObjectContext:(NSManagedObjectContext * _Nullable)managedObjectContext error:(NSError * _Nullable * _Nullable)error;
- (BOOL)insertRecordMetadataForObjectIDsInBatch:(NSArray<NSManagedObjectID *> *)objectIDs inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext withPendingTransactionNumber:(NSNumber *)transactionNumner error:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct));
- (CKModifyRecordsOperation * _Nullable)newOperationBySerializingDirtyObjectsInStore:(NSSQLCore *)store inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable * _Nullable)error;
- (BOOL)currentBatchExceedsThresholds:(OCCloudKitOperationBatch *)batch __attribute__((objc_direct));
- (BOOL)modifyRecordsOperationFinishedForStore:(NSSQLCore *)store withSavedRecords:(NSArray<CKRecord *> *)savedRecords deletedRecordIDs:(NSArray<CKRecordID *> *)deletedRecordIDs operationError:(NSError * _Nullable)operationError managedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct));
@end

NS_ASSUME_NONNULL_END
