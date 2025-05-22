//
//  NSSQLBlockRequestContext.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/13/25.
//

#import "OpenCloudData/SPI/CoreData/NSSQLStoreRequestContext.h"
#import "OpenCloudData/SPI/CoreData/NSSQLCore.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSSQLBlockRequestContext : NSSQLStoreRequestContext
- (instancetype)initWithBlock:(void (^)(NSSQLStoreRequestContext *context))block context:(NSManagedObjectContext * _Nullable)context sqlCore:(NSSQLCore *)sqlCore;
@end

NS_ASSUME_NONNULL_END
