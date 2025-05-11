//
//  OCMirroredRelationship.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/12/25.
//

#import <OpenCloudData/OCMirroredRelationship.h>
#import <OpenCloudData/OCSPIResolver.h>
#import <OpenCloudData/OCMirroredOneToManyRelationship.h>
#import <OpenCloudData/OCMirroredManyToManyRelationship.h>
#import <OpenCloudData/OCMirroredManyToManyRelationshipV2.h>
#import <OpenCloudData/OCCloudKitImportZoneContext.h>

FOUNDATION_EXTERN void NSRequestConcreteImplementation(id self, SEL _cmd, Class absClass);

@implementation OCMirroredRelationship

+ (BOOL)isValidMirroredRelationshipRecord:(CKRecord *)record values:(id<CKRecordKeyValueSetting>)values {
    /*
     record = x20
     values = x19
     */
    
    Class _class = ([record.recordType hasPrefix:[OCSPIResolver PFCloudKitMirroringDelegateToManyPrefix]]) ? [OCMirroredManyToManyRelationship class] : [OCMirroredManyToManyRelationshipV2 class];
    
    return [_class _isValidMirroredRelationshipRecord:record values:values];
}

+ (OCMirroredOneToManyRelationship *)mirroredRelationshipWithManagedObject:(NSManagedObject *)managedObject withRecordID:(CKRecordID *)recordID relatedToObjectWithRecordID:(CKRecordID *)relatedRecordID byRelationship:(NSRelationshipDescription *)relationship {
    return [[[OCMirroredOneToManyRelationship alloc] initWithManagedObject:managedObject withRecordName:recordID relatedToRecordWithRecordName:relatedRecordID byRelationship:relationship] autorelease];
}

+ (OCMirroredManyToManyRelationship *)mirroredRelationshipWithManyToManyRecord:(CKRecord *)record values:(id<CKRecordKeyValueSetting>)values andManagedObjectModel:(NSManagedObjectModel *)managedObjectModel {
    /*
     record = x20
     values = x21
     managedObjectModel = x19
     */
    
    if ([record.recordType hasPrefix:[OCSPIResolver PFCloudKitMirroringDelegateToManyPrefix]]) {
        return [[[OCMirroredManyToManyRelationship alloc] initWithRecordID:record.recordID recordType:record.recordType managedObjectModel:managedObjectModel andType:0] autorelease];
    } else {
        return [[[OCMirroredManyToManyRelationshipV2 alloc] initWithRecord:record andValues:values withManagedObjectModel:managedObjectModel andType:0] autorelease];
    }
}

+ (OCMirroredManyToManyRelationship *)mirroredRelationshipWithDeletedRecordType:(CKRecordType)recordType recordID:(CKRecordID *)recordID andManagedObjectModel:(NSManagedObjectModel *)managedObjectModel {
    return [[[OCMirroredManyToManyRelationship alloc] initWithRecordID:recordID recordType:recordType managedObjectModel:managedObjectModel andType:1] autorelease];
}

- (BOOL)updateRelationshipValueUsingImportContext:(OCCloudKitImportZoneContext *)importContext andManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable *)error {
    NSRequestConcreteImplementation(self, _cmd, [OCMirroredRelationship class]);
    return NO;
}

@end
