//
//  OCPersistentCloudKitContainer+Sharing.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/1/25.
//

#import <OpenCloudData/OpenCloudData.h>

NS_ASSUME_NONNULL_BEGIN

#warning TODO
@interface OCPersistentCloudKitContainer (Sharing)
- (nullable NSDictionary<NSManagedObjectID *, CKShare *> *)fetchSharesMatchingObjectIDs:(NSArray<NSManagedObjectID *> *)objectIDs error:(NSError **)error;
@end

NS_ASSUME_NONNULL_END
