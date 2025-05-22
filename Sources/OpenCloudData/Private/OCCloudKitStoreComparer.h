//
//  OCCloudKitStoreComparer.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/22/25.
//

#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

#warning TODO

@interface OCCloudKitStoreComparer : NSObject
@property (nonatomic) BOOL onlyCompareSharedZones;
- (instancetype)initWithStore:(__kindof NSPersistentStore *)store otherStore:(__kindof NSPersistentStore *)otherStore;
- (BOOL)ensureContentsMatch:(NSError * _Nullable * _Nullable)error;
@end

NS_ASSUME_NONNULL_END
