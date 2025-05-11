//
//  OCMirroredManyToManyRelationship.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/12/25.
//

#import <OpenCloudData/OCMirroredManyToManyRelationship.h>
#import <OpenCloudData/OCSPIResolver.h>

@implementation OCMirroredManyToManyRelationship

+ (BOOL)_isValidMirroredRelationshipRecord:(CKRecord *)record values:(id<CKRecordKeyValueSetting>)values {
    /*
     x19 = record
     */
    if (record.recordType.length == 0) return NO;
    return (record.recordID.recordName.length != 0);
}

- (instancetype)initWithRecordID:(CKRecordID *)recordID recordType:(CKRecordType)recordType managedObjectModel:(NSManagedObjectModel *)managedObjectModel andType:(NSUInteger)type {
    abort();
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
    abort();
}

- (BOOL)updateRelationshipValueUsingImportContext:(OCCloudKitImportZoneContext *)importContext andManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable *)error {
    abort();
}

- (NSDictionary<NSString *, NSArray<CKRecordID *> *> *)recordTypesToRecordIDs {
    abort();
}

- (CKRecordType)ckRecordTypeForOrderedRelationships:(NSArray<NSRelationshipDescription *> *)orderedRelationships {
    abort();
}

- (CKRecordType)ckRecordNameForOrderedRecordNames:(NSArray<NSString *> *)orderedRecordNames {
    abort();
}

- (void)_setManyToManyRecordID:(CKRecordID *)manyToManyRecordID manyToManyRecordType:(CKRecordType)recordType ckRecordID:(CKRecordID *)ckRecordID relatedCKRecordID:(CKRecordID *)relatedCKRecordID relationshipDescription:(NSRelationshipDescription *)relationshipDescription inverseRelationshipDescription:(NSRelationshipDescription *)inverseRelationshipDescription type:(NSUInteger)type __attribute__((objc_direct)) {
    abort();
}

@end
