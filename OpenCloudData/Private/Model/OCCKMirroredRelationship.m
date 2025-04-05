//
//  OCCKMirroredRelationship.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/6/25.
//

#import <OpenCloudData/OCCKMirroredRelationship.h>
#import <OpenCloudData/OCCloudKitMetadataModel.h>
#import <OpenCloudData/OCCKRecordZoneMetadata.h>
#import <OpenCloudData/Log.h>

@implementation OCCKMirroredRelationship
@dynamic ckRecordID;
@dynamic ckRecordSystemFields;
@dynamic cdEntityName;
@dynamic recordName;
@dynamic relatedEntityName;
@dynamic relatedRecordName;
@dynamic relationshipName;
@dynamic isPending;
@dynamic needsDelete;
@dynamic isUploaded;
@dynamic recordZone;

+ (NSString *)entityPath {
    return [NSString stringWithFormat:@"%@/%@", [OCCloudKitMetadataModel ancillaryModelNamespace], NSStringFromClass(self)];
}

- (CKRecordID *)createRecordID {
    CKRecordZoneID * _Nullable zoneID = [self.recordZone createRecordZoneID];
    if (zoneID == nil) return nil;
    CKRecordID *recordID = [[CKRecordID alloc] initWithRecordName:self.ckRecordID zoneID:zoneID];
    [zoneID release];
    return recordID;
}

- (CKRecordID *)createRecordIDForRecord {
    CKRecordZoneID * _Nullable zoneID = [self.recordZone createRecordZoneID];
    if (zoneID == nil) return nil;
    CKRecordID *recordID = [[CKRecordID alloc] initWithRecordName:self.recordName zoneID:zoneID];
    [zoneID release];
    return recordID;
}

- (CKRecordID *)createRecordIDForRelatedRecord {
    CKRecordZoneID * _Nullable zoneID = [self.recordZone createRecordZoneID];
    if (zoneID == nil) return nil;
    CKRecordID *recordID = [[CKRecordID alloc] initWithRecordName:self.relatedRecordName zoneID:zoneID];
    [zoneID release];
    return recordID;
}

- (BOOL)updateRelationshipValueUsingImportContext:(OCCloudKitImportZoneContext *)importContext andManagedObjectContext:(NSManagedObjectContext *)managedObjectContext isDelete:(BOOL)isDelete error:(NSError * _Nullable *)error {
    // x22 = self
    // x26 = importContext
    // x25 = managedObjectContext
    // x23 = isDelete
    // x19 = error
    
    // x20
    NSManagedObjectModel *managedObjectModel = [managedObjectContext.persistentStoreCoordinator.managedObjectModel retain];
    NSDictionary<NSString *, NSEntityDescription *> *entitiesByName = managedObjectModel.entitiesByName;
    NSDictionary<NSString *, __kindof NSPropertyDescription *> *propertiesByName = entitiesByName[self.cdEntityName].propertiesByName;
    // x24
    NSRelationshipDescription *propertyDescription = propertiesByName[self.relationshipName];
    
    // x21
    CKRecordID *recordIDForRecord = [self createRecordIDForRecord];
    // x22
    CKRecordID *recordIDForRelatedRecord = [self createRecordIDForRelatedRecord];
    
    NSString *entityName = propertyDescription.entity.name;
    
    // x27
    NSManagedObjectID * _Nullable entityObjectID;
    if (importContext == nil) {
        entityObjectID = nil;
    } else {
        entityObjectID = importContext->_recordTypeToRecordIDToObjectID[entityName][recordIDForRecord];
    }
    
    NSString * _Nullable inverseEntityName = propertyDescription.inverseRelationship.entity.name;
    
    // x28
    NSManagedObjectID * _Nullable inverseEntityObjectID;
    if (importContext == nil) {
        inverseEntityObjectID = nil;
    } else {
        inverseEntityObjectID = importContext->_recordTypeToRecordIDToObjectID[inverseEntityName][recordIDForRecord];
    }
    
    
    BOOL result;
    NSError * _Nullable _error;
    
    if ((entityObjectID == nil) || (inverseEntityObjectID == nil)) {
        _error = [NSError errorWithDomain:NSCocoaErrorDomain code:134413 userInfo:nil];
        result = NO;
    } else {
        // x26
        NSManagedObject * _Nullable entityObject = [managedObjectContext objectWithID:entityObjectID];
        // x25
        NSManagedObject * _Nullable inverseEntityObject = [managedObjectContext objectWithID:inverseEntityObjectID];
        // x27
        NSMutableSet * _Nullable propertyValue = [[entityObject valueForKey:propertyDescription.name] mutableCopy];
        if (propertyValue == nil) {
            propertyValue = [[NSMutableSet alloc] init];
        }
        
        if (isDelete) {
            [propertyValue removeObject:inverseEntityObject];
        } else {
            [propertyValue addObject:inverseEntityObject];
        }
        
        [entityObject setValue:propertyValue forKey:propertyDescription.name];
        [propertyValue release];
        
        result = YES;
        _error = nil;
    }
    
    [recordIDForRecord release];
    [recordIDForRelatedRecord release];
    [managedObjectModel release];
    
    if (result) {
        return YES;
    } else {
        if (_error != nil) {
            if (error) *error = _error;
        } else {
            os_log_error(_OCLogGetLogStream(0x11), "CoreData: fault: Illegal attempt to return an error without one in %s:%d\n", __func__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "CoreData: fault: Illegal attempt to return an error without one in %s:%d\n", __func__, __LINE__);
        }
        
        return NO;
    }
}

+ (NSArray *)fetchMirroredRelationshipsMatchingRelatingRecords:(NSArray<CKRecord *> *)records andRelatingRecordIDs:(NSArray<CKRecordID *> *)recordIDs fromStore:(__kindof NSPersistentStore *)store inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable *)error {
    abort();
}

@end
