//
//  OCCKRecordZoneMetadata.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/5/25.
//

#import <OpenCloudData/OCCKRecordZoneMetadata.h>

@implementation OCCKRecordZoneMetadata
@dynamic hasRecordZoneNum;
@dynamic hasSubscriptionNum;
@dynamic ckRecordZoneName;
@dynamic ckOwnerName;
@dynamic currentChangeToken;
@dynamic database;
@dynamic lastFetchDate;
@dynamic records;
@dynamic mirroredRelationships;
@dynamic queries;
@dynamic supportsFetchChanges;
@dynamic supportsAtomicChanges;
@dynamic supportsRecordSharing;
@dynamic supportsZoneSharing;
@dynamic needsImport;
@dynamic needsRecoveryFromZoneDelete;
@dynamic needsRecoveryFromUserPurge;
@dynamic needsShareUpdate;
@dynamic needsShareDelete;
@dynamic needsRecoveryFromIdentityLoss;
@dynamic needsNewShareInvitation;
@dynamic encodedShareData;

+ (NSSet<CKRecordZoneID *> *)fetchZoneIDsAssignedToObjectsWithIDs:(NSSet<NSManagedObjectID *> *)objectIDs fromStore:(__kindof NSPersistentStore *)store inContext:(NSManagedObjectContext *)context error:(NSError * _Nullable *)error {
    abort();
}

- (BOOL)hasRecordZone {
    return self.hasRecordZoneNum.boolValue;
}

- (void)setHasRecordZone:(BOOL)hasRecordZone {
    self.hasRecordZoneNum = @(hasRecordZone);
}

- (BOOL)hasSubscription {
    return self.hasSubscriptionNum.boolValue;
}

- (void)setHasSubscription:(BOOL)hasSubscription {
    self.hasSubscriptionNum = @(hasSubscription);
}

- (CKRecordZoneID *)createRecordZoneID {
    abort();
}

@end
