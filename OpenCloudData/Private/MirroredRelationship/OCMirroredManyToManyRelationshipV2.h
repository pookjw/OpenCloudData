//
//  OCMirroredManyToManyRelationshipV2.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/12/25.
//

#import <OpenCloudData/OCMirroredManyToManyRelationship.h>

NS_ASSUME_NONNULL_BEGIN

#warning TODO

@interface OCMirroredManyToManyRelationshipV2 : OCMirroredManyToManyRelationship
+ (BOOL)_isValidMirroredRelationshipRecord:(CKRecord *)record values:(id<CKRecordKeyValueSetting>)values;
+ (NSArray<NSRelationshipDescription *> *)orderRelationships:(NSArray<NSRelationshipDescription *> *)relationships __attribute__((objc_direct));
- (instancetype)initWithRecordID:(CKRecordID *)recordID forRecordWithID:(CKRecordID *)recordWithID relatedToRecordWithID:(CKRecordID *)relatedToRecordWithID byRelationship:(NSRelationshipDescription *)relationship withInverse:(NSRelationshipDescription *)inverseRelationship andType:(NSUInteger)type;
- (instancetype)initWithRecord:(CKRecord *)record andValues:(id<CKRecordKeyValueSetting>)values withManagedObjectModel:(NSManagedObjectModel *)managedObjectModel andType:(NSUInteger)type;
- (void)populateRecordValues:(id<CKRecordKeyValueSetting>)recordValues;
@end

NS_ASSUME_NONNULL_END
