//
//  NSSQLiteConnection.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/29/25.
//

#import <OpenCloudData/NSSQLCore.h>
#import <OpenCloudData/NSSQLiteAdapter.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSSQLiteConnection : NSObject
- (NSSQLiteAdapter *)adapter;
- (NSArray<NSArray<NSString *> *> *)fetchTableCreationSQL;
@end

NS_ASSUME_NONNULL_END
