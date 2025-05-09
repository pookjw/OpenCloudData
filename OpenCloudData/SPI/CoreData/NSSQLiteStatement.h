//
//  NSSQLiteStatement.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/29/25.
//

#import <CoreData/CoreData.h>
#import <OpenCloudData/NSSQLEntity.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSSQLiteStatement : NSObject
- (NSString *)sqlString;
- (instancetype)initWithEntity:(NSSQLEntity * _Nullable)entity sqlString:(NSString *)sqlString;
@end

NS_ASSUME_NONNULL_END

