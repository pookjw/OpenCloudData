//
//  NSMergeableTransformableAttributeValue.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/9/25.
//

#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@protocol NSMergeableTransformableAttributeValue <NSObject>
+ (BOOL)supportsMergeableTransformable;
- (void)merge:(id<NSMergeableTransformableAttributeValue>)other;
- (id)computedValue;
@end

NS_ASSUME_NONNULL_END
