//
//  NSMergeableTransformableStringAttributeValue.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/9/25.
//

#import <OpenCloudData/NSMergeableTransformableAttributeValue.h>

NS_ASSUME_NONNULL_BEGIN

@protocol NSMergeableTransformableStringAttributeValue <NSMergeableTransformableAttributeValue>
- (void)appendString:(NSString *)aString;
- (void)insertString:(NSString *)aString atIndex:(NSInteger)index;
- (void)setString:(NSString *)aString;
- (void)removeSubrange:(NSRange)subrange;
- (void)replaceSubrange:(NSRange)subrange withString:(NSString *)aString;
@end

NS_ASSUME_NONNULL_END
