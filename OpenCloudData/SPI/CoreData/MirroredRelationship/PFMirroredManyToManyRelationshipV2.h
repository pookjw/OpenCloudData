//
//  PFMirroredManyToManyRelationshipV2.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/6/25.
//

#import "OpenCloudData/SPI/CoreData/MirroredRelationship/PFMirroredManyToManyRelationship.h"

NS_ASSUME_NONNULL_BEGIN

@interface PFMirroredManyToManyRelationshipV2 : PFMirroredManyToManyRelationship
- (instancetype)initWithRecordID:(CKRecordID *)recordID forRecordWithID:(CKRecordID *)recordWithID relatedToRecordWithID:(CKRecordID *)relatedToRecordWithID byRelationship:(NSRelationshipDescription *)relationship withInverse:(NSRelationshipDescription *)inverseRelationship andType:(NSUInteger)type;
- (void)populateRecordValues:(id<CKRecordKeyValueSetting>)recordValues;
@end

NS_ASSUME_NONNULL_END
