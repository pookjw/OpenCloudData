//
//  NSSQLCore.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/7/25.
//

#import <CoreData/CoreData.h>
#import <OpenCloudData/NSSQLModelProvider.h>
#import <OpenCloudData/NSSQLEntity.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSSQLCore : NSPersistentStore <NSFilePresenter, NSSQLModelProvider>
- (NSManagedObjectID *)newObjectIDForEntity:(NSSQLEntity *)entity pk:(NSInteger)pk;
@end

NS_ASSUME_NONNULL_END
