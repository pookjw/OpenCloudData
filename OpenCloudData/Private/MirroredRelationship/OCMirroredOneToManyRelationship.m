//
//  OCMirroredOneToManyRelationship.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/12/25.
//

#import <OpenCloudData/OCMirroredOneToManyRelationship.h>
#import <OpenCloudData/OCCloudKitImportZoneContext.h>
#import <OpenCloudData/Log.h>

@implementation OCMirroredOneToManyRelationship

- (instancetype)initWithManagedObject:(NSManagedObject *)managedObject withRecordName:(CKRecordID *)recordName relatedToRecordWithRecordName:(CKRecordID *)relatedRecordName byRelationship:(NSRelationshipDescription *)relationship {
    /*
     managedObject = x23
     recordName = x22
     relatedRecordName = x19
     relationship = x21
     */
    if (self = [super init]) {
        // self = x20
        if ([recordName.zoneID isEqual:relatedRecordName.zoneID]) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Attempting to link objects across zones via one-to-many relationship '%@': %@ / %@\n%@\n", relationship.name, recordName, relatedRecordName, managedObject);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Attempting to link objects across zones via one-to-many relationship '%@': %@ / %@\n%@\n", relationship.name, recordName, relatedRecordName, managedObject);
        }
        
        _recordID = [recordName retain];
        _relationshipDescription = [relationship retain];
        _inverseRelationshipDescription = [relationship.inverseRelationship retain];
        _relatedRecordID = [relatedRecordName retain];
    }
    
    return self;
}

- (void)dealloc {
    [_recordID release];
    _recordID = nil;
    
    [_relationshipDescription release];
    _relationshipDescription = nil;
    
    [_inverseRelationshipDescription release];
    _inverseRelationshipDescription = nil;
    
    [_relatedRecordID release];
    _relatedRecordID = nil;
    
    [super dealloc];
}

- (BOOL)updateRelationshipValueUsingImportContext:(OCCloudKitImportZoneContext *)importContext andManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable *)error {
    /*
     self = x19
     importContext = x24
     managedObjectContext = x23
     error = x20
     */
    /*
     offsets
     x26 = _recordID
     x27 = _relationshipDescription
     x28 = _relatedRecordID
     0xb40 = _inverseRelationshipDescription
     */
    
    // x22
    NSManagedObjectID * _Nullable objectID;
    if (importContext != nil) {
        objectID = [[importContext->_recordTypeToRecordIDToObjectID objectForKey:_relationshipDescription.entity.name] objectForKey:_recordID];
    } else {
        objectID = nil;
    }
    
    if (objectID == nil) {
        os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Import context cache is stale. To-one mirrored relationship source object has gone missing: %@ - %@\n", _recordID, _relationshipDescription);
        os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Import context cache is stale. To-one mirrored relationship source object has gone missing: %@ - %@\n", _recordID, _relationshipDescription);
        
        NSError *_error = [NSError errorWithDomain:NSCocoaErrorDomain code:134412 userInfo:nil];
        if (error != NULL) *error = _error;
        return NO;
    }
    
    // x21
    NSManagedObject *managedObject = [managedObjectContext objectWithID:objectID];
    
    // x25
    CKRecordID * _Nullable relatedRecordID = self->_relatedRecordID;
    if (relatedRecordID == nil) {
        [managedObject setValue:nil forKey:self->_relationshipDescription.name];
        os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d", __func__, __LINE__);
        os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d", __func__, __LINE__);
        return NO;
    }
    
    NSManagedObjectID * _Nullable relatedObjectID;
    if (importContext != nil) {
        relatedObjectID = [[importContext->_recordTypeToRecordIDToObjectID objectForKey:_inverseRelationshipDescription.entity.name] objectForKey:relatedRecordID];
    } else {
        relatedObjectID = nil;
    }
    // x20
    NSManagedObject *relatedManagedObject = [managedObjectContext objectWithID:relatedObjectID];
    
    // managedObjectContext = sp + 0x8
    os_log_with_type(_OCLogGetLogStream(0x11), OS_LOG_TYPE_DEFAULT, "OpenCloudData+CloudKit: %s(%d): Linking object with record name %@ to %@ via %@ on %@->%@", __func__, __LINE__, self->_recordID, self->_relatedRecordID, _relationshipDescription.name, objectID, relatedManagedObject.objectID);
    
    [managedObject setValue:relatedManagedObject forKey:self->_relationshipDescription.name];
    return YES;
}

- (NSDictionary<NSString *, NSArray<CKRecordID *> *> *)recordTypesToRecordIDs {
    /*
     self = x19
     */
    // x21
    NSMutableArray<CKRecordID *> *array_1 = [[NSMutableArray alloc] initWithObjects:self->_recordID, nil];
    // x20
    NSMutableDictionary<NSString *, NSMutableArray<CKRecordID *> *> *result = [[NSMutableDictionary alloc] init];
    
    [result setObject:array_1 forKey:self->_relationshipDescription.entity.name];
    [array_1 release];
    
    // x21
    NSMutableArray<CKRecordID *> *array_2 = [[result objectForKey:self->_inverseRelationshipDescription.entity.name] retain];
    if (array_2 == nil) {
        array_2 = [[NSMutableArray alloc] initWithObjects:self->_relatedRecordID, nil];
        [result setObject:array_2 forKey:self->_inverseRelationshipDescription.entity.name];
    }
    [array_2 release];
    
    return [result autorelease];
}

@end
