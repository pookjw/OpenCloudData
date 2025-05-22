//
//  OCCKRecordZoneMetadata.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/5/25.
//

#import <CloudKit/CloudKit.h>
#import <CoreData/CoreData.h>
#import "OpenCloudData/Private/Model/OCCKRecordMetadata.h"
#import "OpenCloudData/Private/Model/OCCKDatabaseMetadata.h"
#import "OpenCloudData/Private/Model/OCCKMirroredRelationship.h"
#import "OpenCloudData/Private/Model/OCCKRecordZoneQuery.h"

NS_ASSUME_NONNULL_BEGIN

@interface OCCKRecordZoneMetadata : NSManagedObject
+ (OCCKRecordZoneMetadata * _Nullable)zoneMetadataForZoneID:(CKRecordZoneID *)zoneID inDatabaseWithScope:(CKDatabaseScope)databaseScope forStore:(__kindof NSPersistentStore *)store inContext:(NSManagedObjectContext *)context createIfMissing:(BOOL)createIfMissing error:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct));
+ (OCCKRecordZoneMetadata * _Nullable)zoneMetadataForZoneID:(CKRecordZoneID *)zoneID inDatabaseWithScope:(CKDatabaseScope)databaseScope forStore:(__kindof NSPersistentStore *)store inContext:(NSManagedObjectContext *)context error:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct));
+ (NSSet<CKRecordZoneID *> * _Nullable)fetchZoneIDsAssignedToObjectsWithIDs:(NSSet<NSManagedObjectID *> *)objectIDs fromStore:(__kindof NSPersistentStore *)store inContext:(NSManagedObjectContext *)context error:(NSError * _Nullable * _Nullable)error NS_RETURNS_RETAINED;
+ (NSString *)entityPath;

@property (retain, nonatomic, nullable) NSNumber *hasRecordZoneNum;
@property (retain, nonatomic, nullable) NSNumber *hasSubscriptionNum;
@property (retain, nonatomic) NSString *ckRecordZoneName;
@property (retain, nonatomic) NSString *ckOwnerName;
@property (retain, nonatomic, nullable) CKServerChangeToken *currentChangeToken;
@property (retain, nonatomic) OCCKDatabaseMetadata *database;
@property (retain, nonatomic, nullable) NSDate *lastFetchDate;
@property (nonatomic) BOOL hasRecordZone;
@property (nonatomic) BOOL hasSubscription;
@property (retain, nonatomic, nullable) NSSet<OCCKRecordMetadata *> *records;
@property (retain, nonatomic, nullable) NSSet<OCCKMirroredRelationship *> *mirroredRelationships;
@property (retain, nonatomic, nullable) NSSet<OCCKRecordZoneQuery *> *queries;
@property (nonatomic) BOOL supportsFetchChanges;
@property (nonatomic) BOOL supportsAtomicChanges;
@property (nonatomic) BOOL supportsRecordSharing;
@property (nonatomic) BOOL supportsZoneSharing;
@property (nonatomic) BOOL needsImport;
@property (nonatomic) BOOL needsRecoveryFromZoneDelete;
@property (nonatomic) BOOL needsRecoveryFromUserPurge;
@property (nonatomic) BOOL needsShareUpdate;
@property (nonatomic) BOOL needsShareDelete;
@property (nonatomic) BOOL needsRecoveryFromIdentityLoss;
@property (nonatomic) BOOL needsNewShareInvitation;
@property (retain, nonatomic, nullable) NSData *encodedShareData;
- (CKRecordZoneID * _Nullable)createRecordZoneID NS_RETURNS_RETAINED __attribute__((objc_direct));
@end

NS_ASSUME_NONNULL_END
