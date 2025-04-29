//
//  OCCKImportOperation.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/29/25.
//

#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface OCCKImportOperation : NSManagedObject
@property (retain, nonatomic, nullable) NSDate *importDate;
@property (retain, nonatomic, nullable) NSUUID *operationUUID;
@property (retain, nonatomic, nullable) NSData *changeTokenBytes;
@property (retain, nonatomic, nullable) NSSet *pendingRelationships;
+ (NSString *)entityPath __attribute__((objc_direct));
+ (NSArray<OCCKImportOperation *> * _Nullable)fetchUnfinishedImportOperationsInStore:(NSPersistentStore *)store withManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct));
+ (OCCKImportOperation * _Nullable)fetchOperationWithIdentifier:(NSUUID *)identifier fromStore:(NSPersistentStore *)store inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct));
+ (BOOL)purgeFinishedImportOperationsInStore:(NSPersistentStore *)store withManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct));
@end

NS_ASSUME_NONNULL_END
