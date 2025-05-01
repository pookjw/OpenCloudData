//
//  NSSQLEntity.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/7/25.
//

#import <OpenCloudData/NSStoreMapping.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSSQLEntity : NSStoreMapping
- (NSEntityDescription *)entityDescription;
- (NSArray<NSRelationshipDescription *> *)manyToManyRelationships;
- (NSString *)tableName;
- (NSString *)name;
@end

NS_ASSUME_NONNULL_END

