//
//  OCCKRecordZoneMoveReceipt.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/6/25.
//

#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@class OCCKRecordMetadata;

@interface OCCKRecordZoneMoveReceipt : NSManagedObject
+ (NSNumber * _Nullable)countMoveReceiptsInStore:(__kindof NSPersistentStore *)store matchingPredicate:(NSPredicate *)predicate withManagedObjectContext:(NSManagedObjectContext * _Nullable)managedObjectContext error:(NSError * _Nullable * _Nullable)error;
+ (NSString *)entityPath;
+ (NSArray<OCCKRecordZoneMoveReceipt *> * _Nullable)moveReceiptsMatchingRecordIDs:(NSArray<CKRecordID *> *)recordIDs inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext persistentStore:(__kindof NSPersistentStore *)persistentStore error:(NSError * _Nullable * _Nullable)error;

@property (retain, nonatomic) NSString *recordName;
@property (retain, nonatomic) NSString *zoneName;
@property (retain, nonatomic) NSString *ownerName;
@property (nonatomic) BOOL needsCloudDelete;
@property (retain, nonatomic) NSDate *movedAt;
@property (retain, nonatomic) OCCKRecordMetadata *recordMetadata;

- (CKRecordID *)createRecordIDForMovedRecord NS_RETURNS_RETAINED;
@end

NS_ASSUME_NONNULL_END
