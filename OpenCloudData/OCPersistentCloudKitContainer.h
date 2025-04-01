//
//  OCPersistentCloudKitContainer.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 3/30/25.
//

#import <CoreData/CoreData.h>
#import <CloudKit/CloudKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, OCPersistentCloudKitContainerSchemaInitializationOptions) {
    OCPersistentCloudKitContainerSchemaInitializationOptionsNone = 0,
    
    /*
     Validate the model, and generate the records, but don't actually upload them to
     CloudKit. This option is useful for unit testing to ensure your managed object model
     is valid for use with CloudKit.
     */
    OCPersistentCloudKitContainerSchemaInitializationOptionsDryRun = 1 << 1,
    
    /*
     Causes the generated records to be logged to console.
     */
    OCPersistentCloudKitContainerSchemaInitializationOptionsPrintSchema = 1 << 2
};

NS_SWIFT_SENDABLE
@interface OCPersistentCloudKitContainer : NSPersistentContainer
- (BOOL)initializeCloudKitSchemaWithOptions:(OCPersistentCloudKitContainerSchemaInitializationOptions)options
                                      error:(NSError **)error;
- (nullable CKRecord *)recordForManagedObjectID:(NSManagedObjectID *)managedObjectID;
- (NSDictionary<NSManagedObjectID *, CKRecord *> *)recordsForManagedObjectIDs:(NSArray<NSManagedObjectID *> *)managedObjectIDs;
- (nullable CKRecordID *)recordIDForManagedObjectID:(NSManagedObjectID *)managedObjectID;
- (NSDictionary<NSManagedObjectID *, CKRecordID *> *)recordIDsForManagedObjectIDs:(NSArray<NSManagedObjectID *> *)managedObjectIDs;
- (BOOL)canUpdateRecordForManagedObjectWithID:(NSManagedObjectID *)objectID NS_SWIFT_NAME(canUpdateRecord(forManagedObjectWith:));
- (BOOL)canDeleteRecordForManagedObjectWithID:(NSManagedObjectID *)objectID NS_SWIFT_NAME(canDeleteRecord(forManagedObjectWith:));
- (BOOL)canModifyManagedObjectsInStore:(NSPersistentStore *)store;
@end

NS_ASSUME_NONNULL_END
