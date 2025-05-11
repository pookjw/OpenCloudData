//
//  OCMirroredManyToManyRelationshipV2.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/12/25.
//

#import "OCMirroredManyToManyRelationshipV2.h"

@implementation OCMirroredManyToManyRelationshipV2

+ (BOOL)_isValidMirroredRelationshipRecord:(CKRecord *)record values:(id<CKRecordKeyValueSetting>)values {
    abort();
}

- (instancetype)initWithRecordID:(CKRecordID *)recordID forRecordWithID:(CKRecordID *)recordWithID relatedToRecordWithID:(CKRecordID *)relatedToRecordWithID byRelationship:(NSRelationshipDescription *)relationship withInverse:(NSRelationshipDescription *)inverseRelationship andType:(NSUInteger)type {
    abort();
}

- (instancetype)initWithRecord:(CKRecord *)record andValues:(id<CKRecordKeyValueSetting>)values withManagedObjectModel:(NSManagedObjectModel *)managedObjectModel andType:(NSUInteger)type {
    abort();
}

- (void)populateRecordValues:(id<CKRecordKeyValueSetting>)recordValues {
    abort();
    
}

@end
