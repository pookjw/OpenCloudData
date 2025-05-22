//
//  OCCKRecordMetadata.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/5/25.
//

#import <CoreData/CoreData.h>
#import "OpenCloudData/Private/Model/OCCKRecordZoneMoveReceipt.h"
#import "OpenCloudData/SPI/CoreData/NSSQLCore.h"

NS_ASSUME_NONNULL_BEGIN

@class OCCKRecordZoneMetadata;

@interface OCCKRecordMetadata : NSManagedObject
+ (NSData * _Nullable)encodeRecord:(CKRecord *)record error:(NSError * _Nullable * _Nullable)error NS_RETURNS_RETAINED;
+ (CKRecord * _Nullable)recordFromEncodedData:(NSData *)encodedData error:(NSError * _Nullable * _Nullable)error NS_RETURNS_RETAINED;
+ (NSString *)entityPath;
+ (OCCKRecordMetadata * _Nullable)insertMetadataForObject:(NSManagedObject *)object setRecordName:(BOOL)setRecordName inZoneWithID:(CKRecordZoneID *)zoneID recordNamePrefix:(NSString * _Nullable)recordNamePrefix error:(NSError * _Nullable * _Nullable)error;
+ (NSManagedObjectID * _Nullable)createObjectIDForEntityID:(NSNumber *)entityIDNumber primaryKey:(NSNumber *)primaryKeyNumber inSQLCore:(NSSQLCore *)sqlCore NS_RETURNS_RETAINED __attribute__((objc_direct));
+ (NSManagedObjectID * _Nullable)createObjectIDFromMetadataDictionary:(NSDictionary<NSString *, id> *)metadataDictionary inSQLCore:(NSSQLCore *)sqlCore NS_RETURNS_RETAINED __attribute__((objc_direct));
+ (OCCKRecordMetadata * _Nullable)metadataForObject:(NSManagedObject *)object inManagedObjectContext:(NSManagedObjectContext *)context error:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct));
+ (NSArray<OCCKRecordMetadata *> * _Nullable)metadataForObjectIDs:(NSArray<NSManagedObjectID *> *)objectIDs inStore:(__kindof NSPersistentStore *)store withManagedObjectContext:(NSManagedObjectContext *)context error:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct));
+ (NSDictionary<NSManagedObjectID *, OCCKRecordMetadata *> * _Nullable)createMapOfMetadataMatchingObjectIDs:(NSArray<NSManagedObjectID *> *)objectIDs inStore:(NSSQLCore *)store inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable * _Nullable)error NS_RETURNS_RETAINED __attribute__((objc_direct));
+ (OCCKRecordMetadata * _Nullable)metadataForRecord:(CKRecord *)record inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext fromStore:(__kindof NSPersistentStore *)store error:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct));
+ (NSArray<OCCKRecordMetadata *> * _Nullable)metadataForRecordIDs:(NSArray<CKRecordID *> *)recordIDs fromStore:(__kindof NSPersistentStore *)store inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct));
+ (NSDictionary<CKRecordID *, OCCKRecordMetadata *> * _Nullable)createMapOfMetadataMatchingRecords:(NSArray<CKRecord *> *)records andRecordIDs:(NSArray<CKRecordID *> *)recordIDs inStore:(__kindof NSPersistentStore *)store withManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable * _Nullable)error NS_RETURNS_RETAINED __attribute__((objc_direct));
+ (BOOL)purgeRecordMetadataWithRecordIDs:(NSArray<CKRecordID *> *)recordIDs inStore:(__kindof NSPersistentStore *)store withManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct));
+ (NSNumber * _Nullable)countRecordMetadataInStore:(__kindof NSPersistentStore *)store matchingPredicate:(NSPredicate *)predicate withManagedObjectContext:(NSManagedObjectContext * _Nullable)managedObjectContext error:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct));
+ (NSSet<NSManagedObjectID *> * _Nullable)batchUpdateMetadataMatchingEntityIdsAndPKs:(NSDictionary<NSNumber *, NSSet<NSNumber *> *> *)entityIdsAndPKs withUpdates:(NSDictionary<NSString *, id> *)updates inStore:(__kindof NSPersistentStore *)store withManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct));
+ (void)enumerateRecordMetadataDictionariesMatchingObjectIDs:(NSArray<NSManagedObjectID *> *)objectIDs withProperties:(NSArray<NSString *> *)properties inStore:(NSSQLCore *)store withManagedObjectContext:(NSManagedObjectContext *)managedObjectContext block:(void (^ NS_NOESCAPE)(NSDictionary<NSString *, id> * _Nullable results, NSError * _Nullable error, BOOL *stop))block __attribute__((objc_direct));

@property (retain, nonatomic) NSString *ckRecordName; // Model 상에서는 isOptional = 0이지만 -createRecordID에서는 nil 확인을 하고 있음
@property (retain, nonatomic, nullable) NSData *ckRecordSystemFields;
@property (retain, nonatomic, nullable) NSData *encodedRecord;
@property (retain, nonatomic) NSNumber *entityId;
@property (retain, nonatomic) NSNumber *entityPK;
@property (retain, nonatomic, nullable) NSData *ckShare;
@property (retain, nonatomic) OCCKRecordZoneMetadata *recordZone;
@property (nonatomic) BOOL needsUpload;
@property (nonatomic) BOOL needsLocalDelete;
@property (nonatomic) BOOL needsCloudDelete;
@property (retain, nonatomic, nullable) NSNumber *lastExportedTransactionNumber;
@property (retain, nonatomic, nullable) NSNumber *pendingExportTransactionNumber;
@property (retain, nonatomic, nullable) NSNumber *pendingExportChangeTypeNumber;
@property (retain, nonatomic, nullable) NSSet<OCCKRecordZoneMoveReceipt *> *moveReceipts;

- (CKRecordID * _Nullable)createRecordID NS_RETURNS_RETAINED __attribute__((objc_direct));
- (CKRecord * _Nullable)createRecordFromSystemFields NS_RETURNS_RETAINED;
- (NSManagedObjectID * _Nullable)createObjectIDForLinkedRow NS_RETURNS_RETAINED __attribute__((objc_direct));
- (NSData * _Nullable)createEncodedMoveReceiptData:(NSError * _Nullable * _Nullable)error;
- (BOOL)mergeMoveReceiptsWithData:(NSData *)data error:(NSError * _Nullable * _Nullable)error;
@end

NS_ASSUME_NONNULL_END
