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
    /*
     x20 = objectIDs
     sp + 0x30 = store
     sp + 0x28 = context
     x19 = error
     */
    
    // sp + 0xd8
    NSError * _Nullable contextError = nil;
    
    // sp + 0x48
    NSMutableSet<CKRecordZoneID *> *results = [[NSMutableSet alloc] init];
    
    // sp + 0x38
    NSDictionary<NSNumber *, NSSet<NSNumber *> *> *entityIDToPrimaryKeySet = [OCCloudKitMetadataModel createMapOfEntityIDToPrimaryKeySetForObjectIDs:objectIDs];
    
    // x26
    for (NSNumber *entityIDNumber in entityIDToPrimaryKeySet) {
        // x27
        NSSet<NSNumber *> *primaryKeySet = entityIDToPrimaryKeySet[entityIDNumber];
        
        NSFetchRequest<OCCKRecordMetadata *> *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[OCCKRecordMetadata entityPath]];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"entityId = %@ and entityPK IN %@", entityIDNumber, primaryKeySet];
        fetchRequest.resultType = NSDictionaryResultType;
        fetchRequest.propertiesToFetch = @[@"recordZone.ckRecordZoneName", @"recordZone.ckOwnerName"];
        fetchRequest.propertiesToGroupBy = @[@"recordZone.ckRecordZoneName", @"recordZone.ckOwnerName"];
        fetchRequest.affectedStores = @[store];
        
        // x25
        NSArray<NSDictionary<NSString *, id> *> * _Nullable dictionaries = [context executeFetchRequest:fetchRequest error:&contextError];
        if (dictionaries == nil) {
            if (contextError == nil) {
                os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __func__, __LINE__);
                os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __func__, __LINE__);
            } else {
                if (error) *error = contextError;
            }
            
            [results release];
            results = nil;
            break;
        } else {
            // x27
            for (NSDictionary<NSString *, id> *dictionary in dictionaries) {
                // original : getCloudKitCKRecordZoneIDClass
                // x20
                CKRecordZoneID *zoneID = [[CKRecordZoneID alloc] initWithZoneName:dictionary[@"recordZone.ckRecordZoneName"] ownerName:dictionary[@"recordZone.ckOwnerName"]];
                [results addObject:zoneID];
                [zoneID release];
            }
        }
    }
    
    [entityIDToPrimaryKeySet release];
    
    return results;
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
