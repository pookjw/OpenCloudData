//
//  _OCCKInsertedMetadataLink.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/13/25.
//

#import "OpenCloudData/Private/Model/OCCKRecordMetadata.h"

NS_ASSUME_NONNULL_BEGIN

@interface _OCCKInsertedMetadataLink : NSObject {
    @package OCCKRecordMetadata *_recordMetadata; // 0x8
    @package NSManagedObject *_insertedObject; // 0x10
}
- (instancetype)initWithRecordMetadata:(OCCKRecordMetadata *)recordMetadata insertedObject:(NSManagedObject *)insertedObject __attribute__((objc_direct));
@end

NS_ASSUME_NONNULL_END
