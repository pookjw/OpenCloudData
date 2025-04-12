//
//  NSSQLModel.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/7/25.
//

#import <OpenCloudData/NSStoreMapping.h>
#import <OpenCloudData/NSSQLEntity.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSSQLModel : NSStoreMapping
- (NSSQLEntity * _Nullable)entityNamed:(NSString *)entityName;
@end

NS_ASSUME_NONNULL_END
