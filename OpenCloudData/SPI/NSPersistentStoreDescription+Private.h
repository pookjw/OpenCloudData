//
//  NSPersistentStoreDescription+Private.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/1/25.
//

#import <CoreData/CoreData.h>
#import <OpenCloudData/NSPersistentStoreMirroringDelegate.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSPersistentStoreDescription (Private)
- (NSObject<NSPersistentStoreMirroringDelegate> * _Nullable)mirroringDelegate;
- (void)setMirroringDelegate:(NSObject<NSPersistentStoreMirroringDelegate> * _Nullable)mirroringDelegate;
@end

NS_ASSUME_NONNULL_END
