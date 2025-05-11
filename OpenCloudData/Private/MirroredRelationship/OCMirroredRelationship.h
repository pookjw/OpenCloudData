//
//  OCMirroredRelationship.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/12/25.
//

#import <CoreData/CoreData.h>

#warning TODO Unit Testing

NS_ASSUME_NONNULL_BEGIN

@class OCMirroredOneToManyRelationship;
@class OCMirroredManyToManyRelationship;
@class OCMirroredManyToManyRelationshipV2;
@class OCCloudKitImportZoneContext;

@interface OCMirroredRelationship : NSObject
+ (BOOL)isValidMirroredRelationshipRecord:(CKRecord *)record values:(id<CKRecordKeyValueSetting>)values;
+ (OCMirroredOneToManyRelationship *)mirroredRelationshipWithManagedObject:(NSManagedObject *)managedObject withRecordID:(CKRecordID *)recordID relatedToObjectWithRecordID:(CKRecordID *)relatedRecordID byRelationship:(NSRelationshipDescription *)relationship __attribute__((objc_direct));
+ (OCMirroredManyToManyRelationship *)mirroredRelationshipWithManyToManyRecord:(CKRecord *)record values:(id<CKRecordKeyValueSetting>)values andManagedObjectModel:(NSManagedObjectModel *)managedObjectModel __attribute__((objc_direct));
+ (OCMirroredManyToManyRelationship *)mirroredRelationshipWithDeletedRecordType:(CKRecordType)recordType recordID:(CKRecordID *)recordID andManagedObjectModel:(NSManagedObjectModel *)managedObjectModel __attribute__((objc_direct));
- (BOOL)updateRelationshipValueUsingImportContext:(OCCloudKitImportZoneContext *)importContext andManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable * _Nullable)error;
@end

NS_ASSUME_NONNULL_END
