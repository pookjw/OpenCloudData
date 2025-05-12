//
//  OCMirroredManyToManyRelationship.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/12/25.
//

#import <OpenCloudData/OCMirroredManyToManyRelationship.h>
#import <OpenCloudData/OCSPIResolver.h>
#import <OpenCloudData/OCCloudKitImportZoneContext.h>
#import <OpenCloudData/Log.h>

@implementation OCMirroredManyToManyRelationship

+ (BOOL)_isValidMirroredRelationshipRecord:(CKRecord *)record values:(id<CKRecordKeyValueSetting>)values {
    /*
     x19 = record
     */
    if (record.recordType.length == 0) return NO;
    return (record.recordID.recordName.length != 0);
}

+ (CKRecordType)ckRecordTypeForOrderedRelationships:(NSArray<NSRelationshipDescription *> *)orderedRelationships {
    /*
     orderedRelationships = x19
     */
    // x19
    NSRelationshipDescription *relationship = orderedRelationships[0];
    // x21
    NSString *entityName = relationship.entity.name;
    NSString *relationshipName = relationship.name;
    
    return [NSString stringWithFormat:@"%@%@_%@", [OCSPIResolver PFCloudKitMirroringDelegateToManyPrefix], entityName, relationshipName];
}

+ (CKRecordType)ckRecordNameForOrderedRecordNames:(NSArray<NSString *> *)orderedRecordNames {
    return [orderedRecordNames componentsJoinedByString:@":"];
}

- (instancetype)initWithRecordID:(CKRecordID *)recordID recordType:(CKRecordType)recordType managedObjectModel:(NSManagedObjectModel *)managedObjectModel andType:(NSUInteger)type {
    /*
     recordID = x22
     recordType = x21
     managedObjectModel = x23
     type = x20
     */
    if (self = [super init]) {
        // self = x19
        // x24
        NSString *PFCloudKitMirroringDelegateToManyPrefix = [OCSPIResolver PFCloudKitMirroringDelegateToManyPrefix];
        NSArray<NSRelationshipDescription *> * _Nullable relationships;
        if (recordType.length > PFCloudKitMirroringDelegateToManyPrefix.length) {
            // x24
            NSArray<NSString *> *components = [[recordType substringFromIndex:PFCloudKitMirroringDelegateToManyPrefix.length] componentsSeparatedByString:@"_"];
            if (components.count == 2) {
                // x23
                NSEntityDescription *entity = [managedObjectModel.entitiesByName objectForKey:[components objectAtIndex:0]];
                if (entity != nil) {
                    NSRelationshipDescription *relationship = [entity.relationshipsByName objectForKey:[components objectAtIndex:1]];
                    if (relationship != nil) {
                        NSRelationshipDescription *inverseRelationship = relationship.inverseRelationship;
                        if (inverseRelationship != nil) {
                            relationships = @[relationship, inverseRelationship];
                        } else {
                            relationships = nil;
                        }
                    } else {
                        relationships = nil;
                    }
                } else {
                    relationships = nil;
                }
            } else {
                relationships = nil;
            }
        } else {
            relationships = nil;
        }
        
        // <+332>
        // x23
        NSRelationshipDescription * _Nullable relationship = [relationships objectAtIndex:0];
        // x24
        NSRelationshipDescription * _Nullable inverseRelationship = [relationships objectAtIndex:1];
        
        if ((relationship != nil) && (inverseRelationship != nil)) {
            // <+384>
            // x25
            NSArray<NSString *> * _Nullable components = [recordID.recordName componentsSeparatedByString:@":"];
            if (components.count != 2) {
                components = nil;
            }
            
            // original : getCloudKitCKRecordIDClass
            // x26
            CKRecordID *_recordID_1 = [[CKRecordID alloc] initWithRecordName:[components objectAtIndex:0] zoneID:recordID.zoneID];
            // x25
            CKRecordID *_recordID_2 = [[CKRecordID alloc] initWithRecordName:[components objectAtIndex:1] zoneID:recordID.zoneID];
            
            [self _setManyToManyRecordID:recordID manyToManyRecordType:recordType ckRecordID:_recordID_1 relatedCKRecordID:_recordID_2 relationshipDescription:relationship inverseRelationshipDescription:inverseRelationship type:type];
            [_recordID_1 release];
            [_recordID_2 release];
        } else {
            [self release];
            self = nil;
        }
    }
    
    return self;
}

- (void)dealloc {
    [_relationshipDescription release];
    _relationshipDescription = nil;
    
    [_inverseRelationshipDescription release];
    _inverseRelationshipDescription = nil;
    
    [_manyToManyRecordID release];
    _manyToManyRecordID = nil;
    
    [_manyToManyRecordType release];
    _manyToManyRecordType = nil;
    
    [_ckRecordID release];
    _ckRecordID = nil;
    
    [_relatedCKRecordID release];
    _relatedCKRecordID = nil;
    
    [super dealloc];
}

- (NSString *)description {
    /*
     self = x19
     */
    // x20
    NSMutableString *result = [[[super description] mutableCopy] autorelease];
    // x23
    CKRecordID *manyToManyRecordID = self->_manyToManyRecordID;
    // x21
    NSString *relationshipEntityName = self->_relationshipDescription.entity.name;
    // x25
    CKRecordID *ckRecordID = self->_ckRecordID;
    // x22
    NSString *relationshipName = self->_relationshipDescription.name;
    NSString *inverseRelationshipEntityName = self->_relationshipDescription.inverseRelationship.entity.name;
    
    [result appendFormat:@" %@-%@:%@-%@-%@:%@", manyToManyRecordID, relationshipEntityName, ckRecordID, relationshipName, inverseRelationshipEntityName, self->_relatedCKRecordID];
    
    return result;
}

- (BOOL)updateRelationshipValueUsingImportContext:(OCCloudKitImportZoneContext *)importContext andManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable *)error {
    /*
     self = x19
     importContext = x23
     managedObjectContext = x21
     error = x20
     */
    // x22
    CKRecordID *ckRecordID = self->_ckRecordID;
    // x22
    NSManagedObjectID * _Nullable objectID;
    if (importContext == nil) {
        objectID = nil;
    } else {
        objectID = [[importContext->_recordTypeToRecordIDToObjectID objectForKey:self->_relationshipDescription.entity.name] objectForKey:ckRecordID];
    }
    
    // x24
    CKRecordID *relatedCKRecordID = self->_relatedCKRecordID;
    // x23
    NSManagedObjectID * _Nullable relatedObjectID;
    if (importContext == nil) {
        relatedObjectID = nil;
    } else {
        relatedObjectID = [[importContext->_recordTypeToRecordIDToObjectID objectForKey:self->_inverseRelationshipDescription.entity.name] objectForKey:relatedCKRecordID];
    }
    
    if (objectID.temporaryID || relatedObjectID.temporaryID) {
        os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Got temporary objectIDs back during import where we should have permanent ones: %@ / %@\n", objectID, relatedObjectID);
        os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Got temporary objectIDs back during import where we should have permanent ones: %@ / %@\n", objectID, relatedObjectID);
    }
    
    if ((objectID == nil) || (relatedObjectID == nil)) {
        NSError * _error = [NSError errorWithDomain:NSCocoaErrorDomain code:(objectID == nil) ? 134413 : 134412 userInfo:nil];
        if (error != NULL) {
            *error = _error;
        }
        return NO;
    }
    
    // <+252>
    // x22
    NSManagedObject *managedObject = [managedObjectContext objectWithID:objectID];
    // x21
    NSManagedObject *relatedManatedObject = [managedObjectContext objectWithID:relatedObjectID];
    
    // x20
    NSMutableSet *set = [[managedObject valueForKey:self->_relationshipDescription.name] mutableCopy];
    
    NSUInteger type = self->_type;
    if (type == 1) {
        // <+576>
        [set removeObject:relatedManatedObject];
        // <+588>
    } else if (type != 0) {
        // <+616>
        os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: New many to many relationship type?: %@\n", self);
        os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: New many to many relationship type?: %@\n", self);
        [set release];
        return YES;
    } else {
        // <+352>
        if (set == nil) {
            set = [[NSMutableSet alloc] init];
        }
        
        [set addObject:relatedManatedObject];
        // <+588>
    }
    
    // <+588>
    [managedObject setValue:set forKey:self->_relationshipDescription.name];
    [set release];
    
    return YES;
}

- (NSDictionary<NSString *, NSArray<CKRecordID *> *> *)recordTypeToRecordID {
    /*
     self = x19
     */
    // x21
    NSMutableArray<CKRecordID *> *recordIDs = [[NSMutableArray alloc] initWithObjects:self->_ckRecordID, nil];
    // x20
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    [dictionary setObject:recordIDs forKey:self->_relationshipDescription.entity.name];
    [recordIDs release];
    
    // x21
    recordIDs = [[dictionary objectForKey:self->_inverseRelationshipDescription.entity.name] retain];
    if (recordIDs == nil) {
        recordIDs = [[NSMutableArray alloc] initWithObjects:self->_relatedCKRecordID, nil];
        [dictionary setObject:recordIDs forKey:self->_inverseRelationshipDescription.entity.name];
    }
    [recordIDs release];
    
    return [dictionary autorelease];
}

- (void)_setManyToManyRecordID:(CKRecordID *)manyToManyRecordID manyToManyRecordType:(CKRecordType)recordType ckRecordID:(CKRecordID *)ckRecordID relatedCKRecordID:(CKRecordID *)relatedCKRecordID relationshipDescription:(NSRelationshipDescription *)relationshipDescription inverseRelationshipDescription:(NSRelationshipDescription *)inverseRelationshipDescription type:(NSUInteger)type {
    /*
     self = x20
     manyToManyRecordID = x26
     recordType = x25
     ckRecordID = x22
     relatedCKRecordID = x21
     relationshipDescription = x24
     inverseRelationshipDescription = x23
     type = x19
     */
    
    if (!([manyToManyRecordID.zoneID isEqual:ckRecordID.zoneID]) || !([manyToManyRecordID.zoneID isEqual:relatedCKRecordID.zoneID])) {
        os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Attempt to link objects across zones: MTM `%@` is attempting to relate `%@` and `%@`\n", manyToManyRecordID, ckRecordID, relatedCKRecordID);
        os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Attempt to link objects across zones: MTM `%@` is attempting to relate `%@` and `%@`\n", manyToManyRecordID, ckRecordID, relatedCKRecordID);
    }
    
    // <+200>
    self->_manyToManyRecordID = [manyToManyRecordID retain];
    self->_manyToManyRecordType = [recordType retain];
    self->_relationshipDescription = [relationshipDescription retain];
    self->_inverseRelationshipDescription = [inverseRelationshipDescription retain];
    self->_ckRecordID = [ckRecordID retain];
    self->_relatedCKRecordID = [relatedCKRecordID retain];
    self->_type = type;
}

@end
