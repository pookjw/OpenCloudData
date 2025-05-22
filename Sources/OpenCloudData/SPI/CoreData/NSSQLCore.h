//
//  NSSQLCore.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/7/25.
//

#import <CoreData/CoreData.h>
#import "OpenCloudData/SPI/CoreData/NSSQLModelProvider.h"
#import "OpenCloudData/SPI/CoreData/NSSQLEntity.h"
#import "OpenCloudData/SPI/CoreData/NSSQLiteAdapter.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSSQLCore : NSPersistentStore <NSFilePresenter, NSSQLModelProvider>
- (NSManagedObjectID *)newObjectIDForEntity:(NSSQLEntity *)entity pk:(NSInteger)pk;
- (NSDictionary<NSString *, NSSQLModel *> * _Nullable)ancillarySQLModels;
- (void)setAncillarySQLModels:(NSDictionary<NSString *, NSSQLEntity *> * _Nullable)ancillarySQLModels;
- (NSSQLiteAdapter *)adapter;
- (NSString * _Nullable)fileBackedFuturesDirectory;
@end

NS_ASSUME_NONNULL_END
