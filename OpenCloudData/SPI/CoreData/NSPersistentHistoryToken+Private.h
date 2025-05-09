//
//  NSPersistentHistoryToken.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/10/25.
//

#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSPersistentHistoryToken (Private)
- (NSDictionary<NSString *, NSNumber *> *)storeTokens;
@end

NS_ASSUME_NONNULL_END
