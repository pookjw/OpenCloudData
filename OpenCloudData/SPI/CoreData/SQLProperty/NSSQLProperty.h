//
//  NSSQLProperty.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/2/25.
//

#import <OpenCloudData/NSSQLEntity.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSSQLProperty : NSObject
- (NSString * _Nullable)columnName;
- (NSSQLEntity * _Nullable)entity;
@end

NS_ASSUME_NONNULL_END
