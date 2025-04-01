//
//  NSPersistentStore+Private.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/1/25.
//

#import <CoreData/CoreData.h>
#import <OpenCloudData/NSPersistentStoreMirroringDelegate.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSPersistentStore (Private)
- (NSObject<NSPersistentStoreMirroringDelegate> * _Nullable)mirroringDelegate;
@end

NS_ASSUME_NONNULL_END
