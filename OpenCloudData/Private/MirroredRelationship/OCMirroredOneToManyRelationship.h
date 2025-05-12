//
//  OCMirroredOneToManyRelationship.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/12/25.
//

#import <OpenCloudData/OCMirroredRelationship.h>
#import <CloudKit/CloudKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OCMirroredOneToManyRelationship : OCMirroredRelationship {
    @package NSRelationshipDescription *_relationshipDescription; // 0x8
    @package NSRelationshipDescription *_inverseRelationshipDescription; // 0x10
    @package CKRecordID *_relatedRecordID; // 0x18
    @package CKRecordID *_recordID; // 0x20
}
@property (nonatomic, readonly, direct) NSDictionary<NSString *, NSArray<CKRecordID *> *> *recordTypesToRecordIDs;
- (instancetype)initWithManagedObject:(NSManagedObject *)managedObject withRecordName:(CKRecordID *)recordName relatedToRecordWithRecordName:(CKRecordID *)relatedRecordName byRelationship:(NSRelationshipDescription *)relationship;
@end

NS_ASSUME_NONNULL_END
