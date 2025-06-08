//
//  NSManagedObjectModel+Private.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 6/8/25.
//

#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSManagedObjectModel (Private)
@property (nonatomic, setter=_setModelsReferenceIDOffset:) NSInteger _modelsReferenceIDOffset;
@end

NS_ASSUME_NONNULL_END
