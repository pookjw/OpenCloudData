//
//  OCMirroredManyToManyRelationshipV2.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/12/25.
//

#import "OpenCloudData/Private/MirroredRelationship/OCMirroredManyToManyRelationshipV2.h"

@implementation OCMirroredManyToManyRelationshipV2

+ (BOOL)_isValidMirroredRelationshipRecord:(CKRecord *)record values:(id<CKRecordKeyValueSetting>)values {
    /*
     x19 = values
     */
    if (((NSString *)[values objectForKey:@"CD_recordNames"]).length == 0) return NO;
    if (((NSString *)[values objectForKey:@"CD_relationships"]).length == 0) return NO;
    if (((NSString *)[values objectForKey:@"CD_entityNames"]).length == 0) return NO;
    return YES;
}

+ (NSArray<NSRelationshipDescription *> *)orderRelationships:(NSArray<NSRelationshipDescription *> *)relationships {
    // inlined from -[PFMirroredManyToManyRelationshipV2 initWithRecordID:forRecordWithID:relatedToRecordWithID:byRelationship:withInverse:andType:] <+156>~<+204>
    NSMutableArray<NSRelationshipDescription *> *mutable = [relationships mutableCopy];
    
    [mutable sortUsingComparator:^NSComparisonResult(NSRelationshipDescription * _Nonnull obj1, NSRelationshipDescription * _Nonnull obj2) {
        /*
         obj1 = x20
         obj2 = x19
         */
        
        NSString *entityName_1 = obj1.entity.name;
        NSString *entityName_2 = obj2.entity.name;
        NSComparisonResult result_1 = [entityName_1 compare:entityName_2 options:NSCaseInsensitiveSearch];
        if (result_1 != NSOrderedSame) return result_1;
        
        NSString *relationshipName_1 = obj1.name;
        NSString *relationshipName_2 = obj2.name;
        return [relationshipName_1 compare:relationshipName_2 options:NSCaseInsensitiveSearch];
    }];
    
    // <+176>
    NSArray<NSRelationshipDescription *> *copy = [mutable copy];
    [mutable release];
    return [copy autorelease];
}

- (instancetype)initWithRecordID:(CKRecordID *)recordID forRecordWithID:(CKRecordID *)recordWithID relatedToRecordWithID:(CKRecordID *)relatedToRecordWithID byRelationship:(NSRelationshipDescription *)relationship withInverse:(NSRelationshipDescription *)inverseRelationship andType:(NSUInteger)type {
    /*
     recordID = x25
     recordWithID = x24
     relatedToRecordWithID = x23
     relationship = x21
     inverseRelationship = x20
     type = x19
     */
    if (self = [super init]) {
        /*
         self = x22
         */
        // <+176>
        // x27
        NSArray<NSRelationshipDescription *> *relationships = [OCMirroredManyToManyRelationshipV2 orderRelationships:@[relationship, inverseRelationship]];
        
        if (([relationships objectAtIndex:0]) != relationship) {
            [self _setManyToManyRecordID:recordID manyToManyRecordType:@"CDMR" ckRecordID:relatedToRecordWithID relatedCKRecordID:recordWithID relationshipDescription:inverseRelationship inverseRelationshipDescription:relationship type:type];
        } else {
            [self _setManyToManyRecordID:recordID manyToManyRecordType:@"CDMR" ckRecordID:recordWithID relatedCKRecordID:relatedToRecordWithID relationshipDescription:relationship inverseRelationshipDescription:inverseRelationship type:type];
        }
    }
    
    return self;
}

- (instancetype)initWithRecord:(CKRecord *)record andValues:(id<CKRecordKeyValueSetting>)values withManagedObjectModel:(NSManagedObjectModel *)managedObjectModel andType:(NSUInteger)type {
    /*
     record = x22
     values = x24
     managedObjectModel = x21
     type = x19
     */
    if (self = [super init]) {
        // self = x20
        // x25
        NSString *_recordNames = [values objectForKey:@"CD_recordNames"];
        // x23 / x26
        NSArray<NSString *> * _Nullable recordNames = [_recordNames componentsSeparatedByString:@":"];
        if (recordNames.count != 2) {
            recordNames = nil;
        }
        
        // x25
        NSString *_relationships = [values objectForKey:@"CD_relationships"];
        // x23
        NSArray<NSString *> * _Nullable relationships = [_relationships componentsSeparatedByString:@":"];
        if (relationships.count != 2) {
            relationships = nil;
        }
        
        // x24
        NSString *_entityNames = [values objectForKey:@"CD_entityNames"];
        // x24 / x25
        NSArray<NSString *> *entityNames = [_entityNames componentsSeparatedByString:@":"];
        if (entityNames.count != 2) {
            entityNames = nil;
        }
        
        // <+280>
        // original : getCloudKitCKRecordIDClass
        // x24
        CKRecordID *recordID_1 = [[CKRecordID alloc] initWithRecordName:[recordNames objectAtIndex:0] zoneID:record.recordID.zoneID];
        // x26
        CKRecordID *recordID_2 = [[CKRecordID alloc] initWithRecordName:[recordNames objectAtIndex:1] zoneID:record.recordID.zoneID];
        // x27
        CKRecordID *recordID_3 = record.recordID;
        // x22
        CKRecordType recordType = record.recordType;
        // x28
        NSRelationshipDescription *relationshipDescription = [[managedObjectModel.entitiesByName objectForKey:[entityNames objectAtIndex:0]].relationshipsByName objectForKey:[relationships objectAtIndex:0]];
        NSRelationshipDescription *inverseRelationshipDescription = [[managedObjectModel.entitiesByName objectForKey:[entityNames objectAtIndex:1]].relationshipsByName objectForKey:[relationships objectAtIndex:1]];
        [self _setManyToManyRecordID:recordID_3 manyToManyRecordType:recordType ckRecordID:recordID_1 relatedCKRecordID:recordID_2 relationshipDescription:relationshipDescription inverseRelationshipDescription:inverseRelationshipDescription type:type];
        [recordID_1 release];
        [recordID_2 release];
    }
    
    return self;
}

- (void)populateRecordValues:(id<CKRecordKeyValueSetting>)recordValues {
    /*
     self = x20
     recordValues = x19
     */
    // sp + 0x28
    NSString *recordName = self->_ckRecordID.recordName;
    // sp + 0x30
    NSString *relatedRecordName = self->_relatedCKRecordID.recordName;
    // x22
    NSArray<NSString *> *recordNames = @[recordName, relatedRecordName];
    NSString *joinedRecordNames = [recordNames componentsJoinedByString:@":"];
    [recordValues setObject:joinedRecordNames forKey:@"CD_recordNames"];
    
    // sp + 0x18
    NSString *relationshipName = self->_relationshipDescription.name;
    // sp + 0x20
    NSString *inverseRelationshipName = self->_inverseRelationshipDescription.name;
    // x22
    NSArray<NSString *> *relationshipNames = @[relationshipName, inverseRelationshipName];
    NSString *joinedRelationshipNames = [relationshipNames componentsJoinedByString:@":"];
    [recordValues setObject:joinedRelationshipNames forKey:@"CD_relationships"];
    
    // sp + 0x8
    NSString *relationshipEntityName = self->_relationshipDescription.entity.name;
    // sp + 0x10
    NSString *inverseRelationshipEntityName = self->_inverseRelationshipDescription.entity.name;
    // x20
    NSArray<NSString *> *relationshipEntityNames = @[relationshipEntityName, inverseRelationshipEntityName];
    NSString *joinedRelationshipEntityNames = [relationshipEntityNames componentsJoinedByString:@":"];
    [recordValues setObject:joinedRelationshipEntityNames forKey:@"CD_entityNames"];
}

@end
