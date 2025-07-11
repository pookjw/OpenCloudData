//
//  NSSQLiteConnection.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/29/25.
//

#import "OpenCloudData/SPI/CoreData/NSSQLCore.h"
#import "OpenCloudData/SPI/CoreData/NSSQLiteAdapter.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSSQLiteConnection : NSObject
- (NSSQLiteAdapter * _Nullable)adapter;
- (NSArray<NSArray<NSString *> *> *)fetchTableCreationSQL;
@end

NS_ASSUME_NONNULL_END
