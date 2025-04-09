//
//  OCCKRecordZoneMetadata.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/5/25.
//

#import <OpenCloudData/OCCKRecordZoneMetadata.h>
#import <OpenCloudData/OCCloudKitMetadataModel.h>
#import <OpenCloudData/OCCKDatabaseMetadata.h>
#import <OpenCloudData/Log.h>

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

+ (OCCKRecordZoneMetadata *)zoneMetadataForZoneID:(CKRecordZoneID *)zoneID inDatabaseWithScope:(CKDatabaseScope)databaseScope forStore:(__kindof NSPersistentStore *)store inContext:(NSManagedObjectContext *)context error:(NSError * _Nullable *)error {
    return [OCCKRecordZoneMetadata zoneMetadataForZoneID:zoneID inDatabaseWithScope:databaseScope forStore:store inContext:context createIfMissing:YES error:error];
}

+ (OCCKRecordZoneMetadata *)zoneMetadataForZoneID:(CKRecordZoneID *)zoneID inDatabaseWithScope:(CKDatabaseScope)databaseScope forStore:(__kindof NSPersistentStore *)store inContext:(NSManagedObjectContext *)context createIfMissing:(BOOL)createIfMissing error:(NSError * _Nullable *)error {
    /*
     x21 = zoneID
     X23 = databaseScope
     X19 = store
     x20 = context
     sp + 0x2c = createIfMissing
     x22 = error
     */
    
    // original : getCloudKitCKRecordZoneDefaultName
    if ((![zoneID.zoneName isEqualToString:@"com.apple.coredata.cloudkit.zone"]) || ([zoneID.zoneName isEqualToString:CKRecordZoneDefaultName])) {
        os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to work with the core-data or default zone in the shared database: %@\n", self);
        os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to work with the core-data or default zone in the shared database: %@\n", self);
    }
    
    NSFetchRequest<OCCKRecordZoneMetadata *> *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[OCCKRecordZoneMetadata entityPath]];
    fetchRequest.affectedStores = @[store];
    // x27
    NSString *zoneName = zoneID.zoneName;
    // x28
    NSString *ownerName = zoneID.ownerName;
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"%K = %@ AND %K = %@ AND database.databaseScopeNum = %@", @"ckRecordZoneName", zoneName, @"ckOwnerName", ownerName, @(databaseScope)];
    
    // x25
    NSArray<OCCKRecordZoneMetadata *> * _Nullable fetchedRecordZoneMetadataArray = [context executeFetchRequest:fetchRequest error:error];
    
    // x25
    OCCKRecordZoneMetadata * _Nullable result;
    if (fetchedRecordZoneMetadataArray != nil) {
        if (fetchedRecordZoneMetadataArray.count > 1) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Multiple zone entires discovered for a single record zone: %@\n%@\n", zoneID, fetchedRecordZoneMetadataArray);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Multiple zone entires discovered for a single record zone: %@\n%@\n", zoneID, fetchedRecordZoneMetadataArray);
        }
        
        result = fetchedRecordZoneMetadataArray.lastObject;
    } else {
        result = nil;
    }
    
    if ((result == nil) && createIfMissing) {
        OCCKDatabaseMetadata * _Nullable database = [OCCKDatabaseMetadata databaseMetadataForScope:databaseScope forStore:store inContext:context error:error];
        
        if (database == nil) {
            result = nil;
        } else {
            result = [NSEntityDescription insertNewObjectForEntityForName:[OCCKRecordZoneMetadata entityPath] inManagedObjectContext:context];
            result.ckRecordZoneName = zoneID.zoneName;
            result.ckOwnerName = zoneID.ownerName;
            result.database = database;
            [context assignObject:result toPersistentStore:store];
        }
    }
    
    return result;
}

+ (NSSet<CKRecordZoneID *> *)fetchZoneIDsAssignedToObjectsWithIDs:(NSSet<NSManagedObjectID *> *)objectIDs fromStore:(__kindof NSPersistentStore *)store inContext:(NSManagedObjectContext *)context error:(NSError * _Nullable *)error {
    abort();
}

+ (NSString *)entityPath {
    return [NSString stringWithFormat:@"%@/%@", OCCloudKitMetadataModel.ancillaryModelNamespace, NSStringFromClass(self)];
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
    // x19 = self
    
    if ((self.ckRecordZoneName == nil) || (self.ckOwnerName == nil)) {
        os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: createRecordZoneID called before object has an owner name and zone name: %@", self);
        os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: createRecordZoneID called before object has an owner name and zone name: %@", self);
        return nil;
    }
    
    return [[CKRecordZoneID alloc] initWithZoneName:self.ckRecordZoneName ownerName:self.ckOwnerName];
}

@end
