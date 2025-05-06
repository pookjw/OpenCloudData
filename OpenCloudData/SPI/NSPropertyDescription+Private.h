//
//  NSPropertyDescription+Private.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/7/25.
//

#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSPropertyDescription (Private)
- (BOOL)isReadOnly;
@end

NS_ASSUME_NONNULL_END
