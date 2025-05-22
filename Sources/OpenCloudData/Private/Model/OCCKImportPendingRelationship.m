//
//  OCCKImportPendingRelationship.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/28/25.
//

#import "OpenCloudData/Private/Model/OCCKImportPendingRelationship.h"
#import "OpenCloudData/Private/OCCloudKitMetadataModel.h"
#import "OpenCloudData/Private/MirroredRelationship/OCMirroredOneToManyRelationship.h"
#import "OpenCloudData/Private/MirroredRelationship/OCMirroredManyToManyRelationship.h"
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

+ (OCCKImportPendingRelationship *)insertPendingRelationshipForFailedRelationship:(OCMirroredRelationship *)failedRelationship forOperation:(OCCKImportOperation *)operation inStore:(NSPersistentStore *)store withManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
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
    if ([failedRelationship isKindOfClass:[OCMirroredOneToManyRelationship class]]) {
        OCMirroredOneToManyRelationship *casted = (OCMirroredOneToManyRelationship *)failedRelationship;
        result.needsDelete = @NO;
        
        CKRecordID * _Nullable recordID = casted->_recordID; // 0xb38
        result.recordName = recordID.recordName;
        result.recordZoneName = recordID.zoneID.zoneName;
        result.recordZoneOwnerName = recordID.zoneID.ownerName;
        
        // 0xb3c
        relationshipDescription = casted->_relationshipDescription;
        result.cdEntityName = relationshipDescription.entity.name;
        
        NSRelationshipDescription * _Nullable inverseRelationshipDescription = casted->_inverseRelationshipDescription; // 0xb40
        result.relatedEntityName = inverseRelationshipDescription.entity.name;
        
        CKRecordID * _Nullable relatedRecordID = casted->_relatedRecordID; // 0xb44
        result.relatedRecordName = relatedRecordID.recordName;
        
        result.relatedRecordZoneName = recordID.zoneID.zoneName;
        result.relatedRecordZoneOwnerName = recordID.zoneID.ownerName;
    } else if ([failedRelationship isKindOfClass:[OCMirroredManyToManyRelationship class]]) {
        OCMirroredManyToManyRelationship *casted = (OCMirroredManyToManyRelationship *)failedRelationship;
        
        NSUInteger type = casted->_type; // 0xb34
        result.needsDelete = (type == 1) ? @YES : @NO;
        
        // 0xb1c
        relationshipDescription = casted->_relationshipDescription;
        result.relatedEntityName = relationshipDescription.entity.name;
        
        CKRecordID *ckRecordID = casted->_ckRecordID; // 0xb2c
        result.recordZoneName = ckRecordID.zoneID.zoneName;
        result.recordZoneOwnerName = ckRecordID.zoneID.ownerName;
        
        CKRecordID *relatedCKRecordID = casted->_relatedCKRecordID; // 0xb30
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
