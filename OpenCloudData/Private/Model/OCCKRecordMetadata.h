//
//  OCCKRecordMetadata.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/5/25.
//

#import <CoreData/CoreData.h>
#import <OpenCloudData/OCCKRecordZoneMoveReceipt.h>
#import <OpenCloudData/NSSQLCore.h>

NS_ASSUME_NONNULL_BEGIN

#warning TODO
// direct method 있음

@class OCCKRecordZoneMetadata;

@interface OCCKRecordMetadata : NSManagedObject
+ (NSData * _Nullable)encodeRecord:(CKRecord *)record error:(NSError * _Nullable * _Nullable)error NS_RETURNS_RETAINED;
+ (CKRecord * _Nullable)recordFromEncodedData:(NSData *)encodedData error:(NSError * _Nullable * _Nullable)error NS_RETURNS_RETAINED;
+ (NSString *)entityPath;
+ (OCCKRecordMetadata * _Nullable)insertMetadataForObject:(NSManagedObject *)object setRecordName:(BOOL)setRecordName inZoneWithID:(CKRecordZoneID *)zoneID recordNamePrefix:(NSString * _Nullable)recordNamePrefix error:(NSError * _Nullable * _Nullable)error;
+ (NSManagedObjectID * _Nullable)createObjectIDForEntityID:(NSNumber *)entityIDNumber primaryKey:(NSNumber *)primaryKeyNumber inSQLCore:(NSSQLCore *)sqlCore NS_RETURNS_RETAINED __attribute__((objc_direct));
+ (NSManagedObjectID * _Nullable)createObjectIDFromMetadataDictionary:(NSDictionary<NSString *, id> *)metadataDictionary inSQLCore:(NSSQLCore *)sqlCore NS_RETURNS_RETAINED __attribute__((objc_direct));

@property (retain, nonatomic) NSString *ckRecordName;
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
@end

NS_ASSUME_NONNULL_END
