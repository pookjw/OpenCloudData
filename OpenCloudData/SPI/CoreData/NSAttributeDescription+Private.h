//
//  NSAttributeDescription+Private.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/7/25.
//

#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSAttributeDescription (Private)
+ (NSString *)stringForAttributeType:(NSAttributeType)attributeType;
@property (nonatomic) BOOL isFileBackedFuture;
@property (nonatomic, readonly) BOOL usesMergeableStorage;
@end

NS_ASSUME_NONNULL_END
