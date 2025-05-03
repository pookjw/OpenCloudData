//
//  NSSQLCore.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/7/25.
//

#import <CoreData/CoreData.h>
#import <OpenCloudData/NSSQLModelProvider.h>
#import <OpenCloudData/NSSQLEntity.h>
#import <OpenCloudData/NSSQLiteAdapter.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSSQLCore : NSPersistentStore <NSFilePresenter, NSSQLModelProvider>
- (NSManagedObjectID *)newObjectIDForEntity:(NSSQLEntity *)entity pk:(NSInteger)pk;
- (NSDictionary<NSString *, NSSQLModel *> * _Nullable)ancillarySQLModels;
- (void)setAncillarySQLModels:(NSDictionary<NSString *, NSSQLEntity *> * _Nullable)ancillarySQLModels;
- (NSSQLiteAdapter *)adapter;
@end

NS_ASSUME_NONNULL_END
