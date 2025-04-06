//
//  NSManagedObjectID+Private.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/7/25.
//

#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSManagedObjectID (Private)
- (long long)_referenceData64;
@end

NS_ASSUME_NONNULL_END
