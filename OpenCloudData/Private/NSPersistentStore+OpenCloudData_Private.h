//
//  NSPersistentStore+OpenCloudData_Private.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/1/25.
//

#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSPersistentStore (OpenCloudData_Private)
- (BOOL)oc_isCloudKitEnabled;
@end

NS_ASSUME_NONNULL_END
