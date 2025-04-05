//
//  OCCKRecordZoneMetadata.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/5/25.
//

#import <CloudKit/CloudKit.h>
#import <CoreData/CoreData.h>
#import <OpenCloudData/OCCKRecordMetadata.h>
#import <OpenCloudData/OCCKDatabaseMetadata.h>
#import <OpenCloudData/OCCKMirroredRelationship.h>
#import <OpenCloudData/OCCKRecordZoneQuery.h>

NS_ASSUME_NONNULL_BEGIN
// direct method 있음

@interface OCCKRecordZoneMetadata : NSManagedObject
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
