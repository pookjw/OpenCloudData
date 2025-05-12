//
//  OCMirroredManyToManyRelationship.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/12/25.
//

#import <OpenCloudData/OCMirroredRelationship.h>
#import <CloudKit/CloudKit.h>

NS_ASSUME_NONNULL_BEGIN

#warning TODO

@interface OCMirroredManyToManyRelationship : OCMirroredRelationship {
    @package NSUInteger _type; // 0x8
    @package NSRelationshipDescription *_relationshipDescription; // 0x10
    NSRelationshipDescription *_inverseRelationshipDescription; // 0x18
    CKRecordID *_manyToManyRecordID; // 0x20
    CKRecordType _manyToManyRecordType; // 0x28
    @package CKRecordID *_ckRecordID; // 0x30
    @package CKRecordID *_relatedCKRecordID; // 0x38
}
@property (nonatomic, readonly, direct) NSDictionary<NSString *, NSArray<CKRecordID *> *> *recordTypesToRecordIDs;
+ (BOOL)_isValidMirroredRelationshipRecord:(CKRecord *)record values:(id<CKRecordKeyValueSetting>)values;
+ (CKRecordType)ckRecordTypeForOrderedRelationships:(NSArray<NSRelationshipDescription *> *)orderedRelationships __attribute__((objc_direct));
+ (CKRecordType)ckRecordNameForOrderedRecordNames:(NSArray<NSString *> *)orderedRecordNames __attribute__((objc_direct));
- (instancetype _Nullable)initWithRecordID:(CKRecordID *)recordID recordType:(CKRecordType)recordType managedObjectModel:(NSManagedObjectModel *)managedObjectModel andType:(NSUInteger)type;
- (void)_setManyToManyRecordID:(CKRecordID *)manyToManyRecordID manyToManyRecordType:(CKRecordType)recordType ckRecordID:(CKRecordID *)ckRecordID relatedCKRecordID:(CKRecordID *)relatedCKRecordID relationshipDescription:(NSRelationshipDescription *)relationshipDescription inverseRelationshipDescription:(NSRelationshipDescription *)inverseRelationshipDescription type:(NSUInteger)type __attribute__((objc_direct));
@end

NS_ASSUME_NONNULL_END
