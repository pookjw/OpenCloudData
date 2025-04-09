//
//  OCCKRecordZoneMoveReceipt.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/6/25.
//

#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

#warning TODO

@class OCCKRecordMetadata;

@interface OCCKRecordZoneMoveReceipt : NSManagedObject
+ (NSString *)entityPath;

@property (retain, nonatomic) NSString *recordName;
@property (retain, nonatomic) NSString *zoneName;
@property (retain, nonatomic) NSString *ownerName;
@property (nonatomic) BOOL needsCloudDelete;
@property (retain, nonatomic) NSDate *movedAt;
@property (retain, nonatomic) OCCKRecordMetadata *recordMetadata;

- (CKRecordID *)createRecordIDForMovedRecord NS_RETURNS_RETAINED;
+ (NSArray<OCCKRecordZoneMoveReceipt *> * _Nullable)moveReceiptsMatchingRecordIDs:(NSArray<CKRecordID *> *)recordIDs inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext persistentStore:(__kindof NSPersistentStore *)persistentStore error:(NSError * _Nullable * _Nullable)error;
@end

NS_ASSUME_NONNULL_END
