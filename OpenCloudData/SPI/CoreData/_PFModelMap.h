//
//  _PFModelMap.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/29/25.
//

#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface _PFModelMap : NSObject
+ (NSArray<Class> *)ancillaryModelFactoryClasses;
@end

NS_ASSUME_NONNULL_END
