//
//  OCCKImportPendingRelationship.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/28/25.
//

#import <OpenCloudData/OCCKImportPendingRelationship.h>
#import <OpenCloudData/OCCloudKitMetadataModel.h>
#import <OpenCloudData/PFMirroredOneToManyRelationship.h>
#import <OpenCloudData/PFMirroredManyToManyRelationship.h>
#import <CloudKit/CloudKit.h>
#import <objc/runtime.h>

@implementation OCCKImportPendingRelationship
@dynamic recordName;
@dynamic cdEntityName;
@dynamic relatedRecordName;
@dynamic relatedEntityName;
@dynamic relationshipName;
@dynamic recordZoneName;
@dynamic recordZoneOwnerName;
@dynamic relatedRecordZoneName;
@dynamic relatedRecordZoneOwnerName;
@dynamic needsDelete;
@dynamic operation;

+ (NSString *)entityPath {
//    return [NSString stringWithFormat:@"%@/%@", [OCCloudKitMetadataModel ancillaryModelNamespace], NSStringFromClass(self)];
    return [NSString stringWithFormat:@"%@/%@", [OCCloudKitMetadataModel ancillaryModelNamespace], NSStringFromClass(objc_lookUpClass("NSCKImportPendingRelationship"))];
}

+ (OCCKImportPendingRelationship *)insertPendingRelationshipForFailedRelationship:(PFMirroredRelationship *)failedRelationship forOperation:(OCCKImportOperation *)operation inStore:(NSPersistentStore *)store withManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    /*
     failedRelationship = x23
     operation = x21
     store = x19
     managedObjectContext = x20
     */
    
    // x22
    OCCKImportPendingRelationship *result = [NSEntityDescription insertNewObjectForEntityForName:[OCCKImportPendingRelationship entityPath] inManagedObjectContext:managedObjectContext];
    result.needsDelete = @NO;
    
    NSRelationshipDescription * _Nullable relationshipDescription = nil;
    if ([failedRelationship isKindOfClass:objc_lookUpClass("PFMirroredOneToManyRelationship")]) {
        result.needsDelete = @NO;
        
        CKRecordID * _Nullable recordID; // 0xb38
        assert(object_getInstanceVariable(failedRelationship, "_recordID", (void **)&recordID) != NULL);
        result.recordName = recordID.recordName;
        result.recordZoneName = recordID.zoneID.zoneName;
        result.recordZoneOwnerName = recordID.zoneID.ownerName;
        
        // 0xb3c
        assert(object_getInstanceVariable(failedRelationship, "_relationshipDescription", (void **)&relationshipDescription) != NULL);
        result.cdEntityName = relationshipDescription.entity.name;
        
        NSRelationshipDescription * _Nullable inverseRelationshipDescription; // 0xb40
        assert(object_getInstanceVariable(failedRelationship, "_inverseRelationshipDescription", (void **)&inverseRelationshipDescription) != NULL);
        result.relatedEntityName = inverseRelationshipDescription.entity.name;
        
        CKRecordID * _Nullable relatedRecordID; // 0xb44
        assert(object_getInstanceVariable(failedRelationship, "_relatedRecordID", (void **)&relatedRecordID) != NULL);
        result.relatedRecordName = relatedRecordID.recordName;
        
        result.relatedRecordZoneName = recordID.zoneID.zoneName;
        result.relatedRecordZoneOwnerName = recordID.zoneID.ownerName;
    } else if ([failedRelationship isKindOfClass:objc_lookUpClass("PFMirroredManyToManyRelationship")]) {
        NSUInteger type; // 0xb34
        assert(object_getInstanceVariable(failedRelationship, "_type", (void **)&type) != NULL);
        
        result.needsDelete = (type == 1) ? @YES : @NO;
        
        // 0xb1c
        assert(object_getInstanceVariable(failedRelationship, "_relationshipDescription", (void **)relationshipDescription) != NULL);
        result.relatedEntityName = relationshipDescription.entity.name;
        
        CKRecordID *ckRecordID; // 0xb2c
        assert(object_getInstanceVariable(failedRelationship, "_ckRecordID", (void **)&ckRecordID) != NULL);
        result.recordZoneName = ckRecordID.zoneID.zoneName;
        result.recordZoneOwnerName = ckRecordID.zoneID.ownerName;
        
        CKRecordID *relatedCKRecordID; // 0xb30
        assert(object_getInstanceVariable(failedRelationship, "_relatedCKRecordID", (void **)&relatedCKRecordID) != NULL);
        result.relatedRecordName = relatedCKRecordID.recordName;
        result.relatedRecordZoneName = relatedCKRecordID.zoneID.zoneName;
        result.relatedRecordZoneOwnerName = relatedCKRecordID.zoneID.ownerName;
    } else {
        relationshipDescription = nil;
    }
    
    if (relationshipDescription != nil) {
        result.relationshipName = relationshipDescription.name;
    }
    
    result.operation = operation;
    [managedObjectContext assignObject:result toPersistentStore:store];
    
    return result;
}

@end
