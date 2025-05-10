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
#import <OpenCloudData/OCSPIResolver.h>
#import <objc/runtime.h>

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
//    return [NSString stringWithFormat:@"%@/%@", [OCCloudKitMetadataModel ancillaryModelNamespace], NSStringFromClass(self)];
    return [NSString stringWithFormat:@"%@/%@", [OCCloudKitMetadataModel ancillaryModelNamespace], NSStringFromClass(objc_lookUpClass("NSCKMirroredRelationship"))];
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
        _error = [NSError errorWithDomain:NSCocoaErrorDomain code:((entityObjectID == nil) ? 0x20d0c : 0x20d0d) userInfo:nil];
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
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        }
        
        return NO;
    }
}

+ (NSArray<OCCKMirroredRelationship *> *)fetchMirroredRelationshipsMatchingRelatingRecords:(NSArray<CKRecord *> *)records andRelatingRecordIDs:(NSArray<CKRecordID *> *)recordIDs fromStore:(__kindof NSPersistentStore *)store inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable *)error {
    /*
     x24 = records
     x25 = recordIDs
     sp + 0x40 = store
     sp + 0x30 = error
     sp + 0x38 = managedObjectContext
     */
    
    
    // sp + 0x118
    NSError * _Nullable contextError = nil;
    
    // sp + 0x48
    NSMutableArray<OCCKMirroredRelationship *> *relationships = [[NSMutableArray alloc] init];
    
    // x19
    NSMutableDictionary<CKRecordZoneID *, NSMutableSet<NSString *> *> *recordNamesSetByZoneID = [[NSMutableDictionary alloc] init];
    
    // x26
    for (CKRecordID *recordID in recordIDs) {
        // x27
        CKRecordZoneID *zoneID = recordID.zoneID;
        
        // x28
        NSMutableSet<NSString *> *recordNamesSet = [recordNamesSetByZoneID[zoneID] retain];
        
        if (recordNamesSet == nil) {
            recordNamesSet = [[NSMutableSet alloc] init];
            recordNamesSetByZoneID[zoneID] = recordNamesSet;
        }
        
        [recordNamesSet addObject:recordID.recordName];
        [recordNamesSet release];
    }
    
    // x26
    for (CKRecord *record in records) {
        // x27
        NSMutableSet<NSString *> *recordNamesSet = [recordNamesSetByZoneID[record.recordID.zoneID] retain];
        
        if (recordNamesSet == nil) {
            recordNamesSet = [[NSMutableSet alloc] init];
            recordNamesSetByZoneID[record.recordID.zoneID] = recordNamesSet;
        }
        
        [recordNamesSet addObject:record.recordID.recordName];
        [recordNamesSet release];
    }
    
    // x21
    for (CKRecordZoneID *recordZoneID in recordNamesSetByZoneID) @autoreleasepool {
        // x28
        NSFetchRequest<OCCKMirroredRelationship *> *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[OCCKMirroredRelationship entityPath]];
        
        // x22 / sp + 0x8 / sp + x10 / sp
        NSMutableSet<NSString *> *recordNamesSet = recordNamesSetByZoneID[recordZoneID];
        
        // x20 / sp + 0x18
        NSString *zoneName = recordZoneID.zoneName;
        
        // sp + 0x20
        NSString *ownerName = recordZoneID.ownerName;
        
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(ckRecordID IN %@ OR recordName IN %@ OR relatedRecordName IN %@) AND recordZone.ckRecordZoneName = %@ AND recordZone.ckOwnerName = %@", recordNamesSet, recordNamesSet, recordNamesSet, zoneName, ownerName];
        fetchRequest.affectedStores = @[store];
        fetchRequest.relationshipKeyPathsForPrefetching = @[@"recordZone"];
        fetchRequest.returnsObjectsAsFaults = NO;
        
        // x21
        NSArray<OCCKMirroredRelationship *> * _Nullable results = [managedObjectContext executeFetchRequest:fetchRequest error:&contextError];
        if (results != nil) {
            [relationships addObjectsFromArray:results];
        } else {
            [contextError retain];
            [relationships release];
            relationships = nil;
        }
        
        if (results == nil) break;
    }
    
    if (relationships == nil) {
        NSError *_error = [[contextError retain] autorelease];
        
        if (_error == nil) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        } else if (error) {
            *error = _error;
        }
    }
    
    [contextError release];
    contextError = nil;
    [recordNamesSetByZoneID release];
    
    return [relationships autorelease];
}

+ (NSArray<OCCKMirroredRelationship *> *)fetchPendingMirroredRelationshipsInStore:(__kindof NSPersistentStore *)store withManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable *)error {
    /*
     x21 = store
     x19 = managedObjectContext
     x20 = error
     */
    
    // sp + 0x8
    NSError * _Nullable contextError = nil;
    
    // x22
    NSFetchRequest<OCCKMirroredRelationship *> *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[OCCKMirroredRelationship entityPath]];
    
    fetchRequest.affectedStores = @[store];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"isPending == 1"];
    
    // x19
    NSArray<OCCKMirroredRelationship *> * _Nullable results = [managedObjectContext executeFetchRequest:fetchRequest error:&contextError];
    
    if (results == nil) {
        if (contextError == nil) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        } else if (error) {
            *error = contextError;
        }
    }
    
    return results;
}

+ (OCCKMirroredRelationship *)mirroredRelationshipForManyToMany:(PFMirroredManyToManyRelationship *)manyToManyRelationship inStore:(__kindof NSPersistentStore *)store withManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable *)error {
    /*
     x19 = manyToManyRelationship
     x23 = store
     x21 = managedObjectContext
     x20 = error
     */
    
    // x22
    NSFetchRequest<OCCKMirroredRelationship *> *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[OCCKMirroredRelationship entityPath]];
    
    fetchRequest.affectedStores = @[store];
    
    NSString * _Nullable recordName;
    if (manyToManyRelationship != nil) {
        CKRecordID * _Nullable _manyToManyRecordID;
        assert(object_getInstanceVariable(manyToManyRelationship, "_manyToManyRecordID", (void **)&_manyToManyRecordID) != NULL);
        recordName = _manyToManyRecordID.recordName;
    } else {
        recordName = nil;
    }
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"ckRecordID = %@", recordName];
    
    NSArray<OCCKMirroredRelationship *> * _Nullable results = [managedObjectContext executeFetchRequest:fetchRequest error:error];
    if (results == nil) return nil;
    
    if (results.count > 2) {
        os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Found more than one mirrored relationship matching a many to many: %@\n%@\n", manyToManyRelationship, results);
        os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Found more than one mirrored relationship matching a many to many: %@\n%@\n", manyToManyRelationship, results);
    }
    
    return results.lastObject;
}

+ (OCCKMirroredRelationship *)insertMirroredRelationshipForManyToMany:(PFMirroredManyToManyRelationship *)manyToManyRelationship inZoneWithMetadata:(OCCKRecordZoneMetadata *)metadata inStore:(__kindof NSPersistentStore *)store withManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    /*
     x21 = manyToManyRelationship
     x19 = metadata
     x23 = store
     x22 = managedObjectContext
     */
    
    OCCKMirroredRelationship *object = [NSEntityDescription insertNewObjectForEntityForName:[OCCKMirroredRelationship entityPath] inManagedObjectContext:managedObjectContext];
    
    [managedObjectContext assignObject:object toPersistentStore:store];
    
    NSString * _Nullable ckRecordID;
    if (manyToManyRelationship != nil) {
        CKRecordID * _Nullable _manyToManyRecordID;
        assert(object_getInstanceVariable(manyToManyRelationship, "_manyToManyRecordID", (void **)&_manyToManyRecordID) != NULL);
        ckRecordID = _manyToManyRecordID.recordName;
    } else {
        ckRecordID = nil;
    }
    object.ckRecordID = ckRecordID;
    
    NSString * _Nullable cdEntityName;
    if (manyToManyRelationship != nil) {
        NSRelationshipDescription * _Nullable _relationshipDescription;
        assert(object_getInstanceVariable(manyToManyRelationship, "_relationshipDescription", (void **)&_relationshipDescription) != NULL);
        cdEntityName = _relationshipDescription.entity.name;
    } else {
        cdEntityName = nil;
    }
    object.cdEntityName = cdEntityName;
    
    NSString * _Nullable recordName;
    if (manyToManyRelationship != nil) {
        CKRecordID * _Nullable _ckRecordID;
        assert(object_getInstanceVariable(manyToManyRelationship, "_ckRecordID", (void **)&_ckRecordID) != NULL);
        recordName = _ckRecordID.recordName;
    } else {
        recordName = nil;
    }
    object.recordName = recordName;
    
    
    NSString * _Nullable relatedEntityName;
    if (manyToManyRelationship != nil) {
        NSRelationshipDescription * _Nullable _inverseRelationshipDescription;
        assert(object_getInstanceVariable(manyToManyRelationship, "_inverseRelationshipDescription", (void **)&_inverseRelationshipDescription) != NULL);
        relatedEntityName = _inverseRelationshipDescription.entity.name;
    } else {
        relatedEntityName = nil;
    }
    object.relatedEntityName = relatedEntityName;
    
    
    NSString * _Nullable relatedRecordName;
    if (manyToManyRelationship != nil) {
        CKRecordID * _Nullable _relatedCKRecordID;
        assert(object_getInstanceVariable(manyToManyRelationship, "_relatedCKRecordID", (void **)&_relatedCKRecordID) != NULL);
        relatedRecordName = _relatedCKRecordID.recordName;
    } else {
        relatedRecordName = nil;
    }
    object.relatedRecordName = relatedRecordName;
    
    NSString * _Nullable relationshipName;
    if (manyToManyRelationship != nil) {
        NSRelationshipDescription * _Nullable _relationshipDescription;
        assert(object_getInstanceVariable(manyToManyRelationship, "_relationshipDescription", (void **)&_relationshipDescription) != NULL);
        relationshipName = _relationshipDescription.name;
    } else {
        relationshipName = nil;
    }
    object.relationshipName = relationshipName;
    
    object.isPending = @(NO);
    object.isUploaded = @(NO);
    object.needsDelete = @(NO);
    object.recordZone = metadata;
    
    return object;
}

+ (BOOL)purgeMirroredRelationshipsWithRecordIDs:(NSArray<CKRecordID *> *)recordIDs fromStore:(__kindof NSPersistentStore *)store withManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable *)error {
    /*
     X22 = recordIDs
     X23 = store
     x21 = managedObjectContext
     sp + 0x18 = error
     */
    
    // sp + 0x128
    NSError * _Nullable contextError = nil;
    BOOL hasError = NO;
    
    // x20
    NSMutableDictionary<CKRecordZoneID *, NSMutableSet<NSString *> *> *recordNamesSetByZoneID = [[NSMutableDictionary alloc] init];
    
    for (CKRecordID *recordID in recordIDs) {
        CKRecordZoneID *zoneID = recordID.zoneID;
        
        // x26
        NSMutableSet<NSString *> *recordNamesSet = [recordNamesSetByZoneID[zoneID] retain];
        if (recordNamesSet == nil) {
            recordNamesSet = [[NSMutableSet alloc] init];
            recordNamesSetByZoneID[recordID.zoneID] = recordNamesSet;
        }
        
        [recordNamesSet addObject:recordID.recordName];
        [recordNamesSet release];
    }
    
    NSFetchRequest<OCCKMirroredRelationship *> *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[OCCKMirroredRelationship entityPath]];
    fetchRequest.affectedStores = @[store];
    
    // x27
    for (CKRecordZoneID *zoneID in recordNamesSetByZoneID) {
        NSMutableSet<NSString *> *recordNamesSet = recordNamesSetByZoneID[zoneID];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"((recordZone.ckRecordZoneName = %@) AND (recordZone.ckOwnerName = %@) AND (ckRecordID IN %@))", zoneID.zoneName, zoneID.ownerName, recordNamesSet];
        
        // x25
        NSArray<OCCKMirroredRelationship *> * _Nullable relationships = [managedObjectContext executeFetchRequest:fetchRequest error:&contextError];
        if (relationships == nil) {
            hasError = YES;
            break;
        }
        
        for (OCCKMirroredRelationship *relationship in relationships) {
            [managedObjectContext deleteObject:relationship];
        }
    }
    
    if (!hasError) {
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(needsDelete = 1 AND isUploaded = 1)"];
        // x22
        NSArray<OCCKMirroredRelationship *> * _Nullable relationships = [managedObjectContext executeFetchRequest:fetchRequest error:&contextError];
        if (relationships == nil) {
            hasError = YES;
        } else {
            for (OCCKMirroredRelationship *relationship in relationships) {
                [managedObjectContext deleteObject:relationship];
            }
        }
    }
    
    [recordNamesSetByZoneID release];
    
    if (hasError) {
        if (contextError == nil) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        } else {
            if (error) *error = contextError;
        }
        
        return NO;
    } else {
        return YES;
    }
}

+ (NSSet<CKRecordID *> *)markRelationshipsForDeletedRecordIDs:(NSArray<CKRecordID *> *)deletedRecordIDs inStore:(__kindof NSPersistentStore *)store withManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable *)error {
    /*
     x23 = deletedRecordIDs
     X24 = store
     sp + 0x40 = managedObjectContext
     x19 = error
     */
    
    // sp + 0x118
    NSError * _Nullable contextError = nil;
    
    if (deletedRecordIDs.count != 0) {
        // x19
        NSMutableSet<CKRecordID *> *recordIDsSet = [[NSMutableSet alloc] init];
        // x20
        NSMutableDictionary<CKRecordZoneID *, NSMutableSet<NSString *> *> *recordNamesSetByZoneID = [[NSMutableDictionary alloc] init];
        
        // x21
        for (CKRecordID *deletedRecordID in deletedRecordIDs) {
            NSMutableSet<NSString *> *recordNamesSet = [recordNamesSetByZoneID[deletedRecordID.zoneID] retain];
            if (recordNamesSet == nil) {
                recordNamesSet = [[NSMutableSet alloc] init];
                recordNamesSetByZoneID[deletedRecordID.zoneID] = recordNamesSet;
            }
            
            [recordNamesSet addObject:deletedRecordID.recordName];
            [recordNamesSet release];
        }
        
        NSFetchRequest<OCCKMirroredRelationship *> *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[OCCKMirroredRelationship entityPath]];
        fetchRequest.affectedStores = @[store];
        
        // x28
        for (CKRecordZoneID *zoneID in recordNamesSetByZoneID) {
            // x21
            NSMutableSet<NSString *> *recordNamesSet = recordNamesSetByZoneID[zoneID];
            
            fetchRequest.predicate = [NSPredicate predicateWithFormat:@"((recordZone.ckRecordZoneName = %@) AND (recordZone.ckOwnerName = %@) AND ((recordName IN %@) OR (relatedRecordName IN %@))) OR needsDelete = 1", zoneID.zoneName, zoneID.ownerName, recordNamesSet, recordNamesSet];
            
            // x28
            NSArray<OCCKMirroredRelationship *> * _Nullable relationships = [managedObjectContext executeFetchRequest:fetchRequest error:&contextError];
            if (relationships == nil) {
                if (contextError == nil) {
                    os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
                    os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
                } else {
                    if (error) {
                        *error = contextError;
                    }
                }
                
                [recordIDsSet release];
                [recordNamesSetByZoneID release];
                return nil;
            }
            
            // x25
            for (OCCKMirroredRelationship *relationship in relationships) {
                CKRecordID *recordID = [relationship createRecordID];
                [recordIDsSet addObject:recordID];
                [recordID release];
                
                relationship.needsDelete = @(YES);
                relationship.isUploaded = @(NO);
            }
        }
        
        NSSet<CKRecordID *> *result = [[recordIDsSet copy] autorelease];
        [recordIDsSet release];
        [recordNamesSetByZoneID release];
        return result;
    } else {
        return [NSSet set];
    }
}

+ (BOOL)updateMirroredRelationshipsMatchingRecords:(NSArray<CKRecord *> *)records forStore:(__kindof NSPersistentStore *)store withManagedObjectContext:(NSManagedObjectContext *)managedObjectContext usingBlock:(BOOL (^ NS_NOESCAPE)(OCCKMirroredRelationship * _Nonnull, CKRecord * _Nonnull, NSError * _Nullable * _Nullable))block error:(NSError * _Nullable *)error {
    /*
     x24 = records
     x21 = store
     x19 = managedObjectContext
     x22 = block
     x20 = error
     */
    
    // sp, #0xf8
    NSError * _Nullable _error = nil;
    // sp, #0x28
    NSArray<OCCKMirroredRelationship *> * _Nullable fetchedRelationships = [OCCKMirroredRelationship fetchMirroredRelationshipsMatchingRelatingRecords:records andRelatingRecordIDs:@[] fromStore:store inManagedObjectContext:managedObjectContext error:&_error];
    
    if (fetchedRelationships == nil) {
        if (_error == nil) {
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        } else {
            if (error) *error = _error;
        }
        
        return NO;
    }
    
    // x22
    NSMutableSet<CKRecordID *> *recordIDs = [[NSMutableSet alloc] init];
    // x21 / sp + 0x10
    NSMutableDictionary<CKRecordID *, CKRecord *> *recodsByRecordID = [[NSMutableDictionary alloc] init];
    
    // x28
    for (CKRecord *record in records) {
        if ([record.recordType isEqualToString:@"CDMR"]) {
            recodsByRecordID[record.recordID] = record;
            [recordIDs addObject:record.recordID];
        } else {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Attempted to update a mirrored relationship with a non-mirrored-relationship record: %@\n", record);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Attempted to update a mirrored relationship with a non-mirrored-relationship record: %@\n", record);
        }
    }
    
    //x24
    NSMutableDictionary<CKRecordID *, OCCKMirroredRelationship *> *relationshipsByRecordID = [[NSMutableDictionary alloc] init];
    
    // x25
    for (OCCKMirroredRelationship *relationship in fetchedRelationships) {
        // original : getCloudKitCKRecordZoneIDClass
        // x26
        CKRecordZoneID *zoneID = [[CKRecordZoneID alloc] initWithZoneName:relationship.recordZone.ckRecordZoneName ownerName:relationship.recordZone.ckOwnerName];
        
        // original : getCloudKitCKRecordZoneIDClass
        // x27
        CKRecordID *recordID = [[CKRecordID alloc] initWithRecordName:relationship.ckRecordID zoneID:zoneID];
        
        relationshipsByRecordID[recordID] = relationship;
        [recordIDs addObject:recordID];
        
        [recordID release];
        [zoneID release];
    }
    
    // x21
    BOOL succeed = NO;
    
    // x23
    for (CKRecordID *recordID in recordIDs) {
        // x25
        OCCKMirroredRelationship *relationship = relationshipsByRecordID[recordID];
        CKRecord *record = recodsByRecordID[recordID];
        
        BOOL result = block(relationship, record, &_error);
        if (!result) break;
        succeed = YES;
    }
    
    [recordIDs release];
    [relationshipsByRecordID release];
    [recodsByRecordID release];
    
    if (!succeed) {
        if (_error != nil) {
            if (error) *error = _error;
        } else {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        }
        
        return NO;
    }
    
    return YES;
}

+ (NSArray<OCCKMirroredRelationship *> *)fetchMirroredRelationshipsMatchingPredicate:(NSPredicate *)predicate fromStore:(__kindof NSPersistentStore *)store inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable *)error {
    NSFetchRequest<OCCKMirroredRelationship *> *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[OCCKMirroredRelationship entityPath]];
    fetchRequest.affectedStores = @[store];
    fetchRequest.fetchBatchSize = 1000;
    fetchRequest.predicate = predicate;
    return [managedObjectContext executeFetchRequest:fetchRequest error:error];
}

+ (NSNumber *)countMirroredRelationshipsInStore:(__kindof NSPersistentStore *)store matchingPredicate:(NSPredicate *)predicate withManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable *)error {
    NSFetchRequest<OCCKMirroredRelationship *> *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[OCCKMirroredRelationship entityPath]];
    fetchRequest.predicate = predicate;
    fetchRequest.resultType = NSCountResultType;
    fetchRequest.affectedStores = @[store];
    
    NSInteger count;
    
    if (managedObjectContext == nil) {
        count = 0;
    } else {
        count = [OCSPIResolver NSManagedObjectContext__countForFetchRequest__error_:managedObjectContext x1:fetchRequest x2:error];
        
        if (count == NSNotFound) {
            return nil;
        }
    }
    
    return [NSNumber numberWithUnsignedInteger:count];
}

@end
