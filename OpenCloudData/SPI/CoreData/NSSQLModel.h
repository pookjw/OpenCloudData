//
//  NSSQLModel.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/7/25.
//

#import "OpenCloudData/SPI/CoreData/NSStoreMapping.h"
#import "OpenCloudData/SPI/CoreData/NSSQLEntity.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSSQLModel : NSStoreMapping
- (NSSQLEntity * _Nullable)entityNamed:(NSString *)entityName;
- (NSSQLEntity * _Nullable)entityForID:(uint)entityId;
- (instancetype)initWithManagedObjectModel:(NSManagedObjectModel *)managedObjectModel;
@end

NS_ASSUME_NONNULL_END
