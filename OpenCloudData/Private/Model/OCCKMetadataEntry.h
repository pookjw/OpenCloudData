//
//  OCCKMetadataEntry.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/10/25.
//

#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface OCCKMetadataEntry : NSManagedObject
+ (NSString *)entityPath;

+ (OCCKMetadataEntry * _Nullable)entryForKey:(NSString *)key fromStore:(__kindof NSPersistentStore *)store inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct));
+ (NSDictionary<NSString *, OCCKMetadataEntry *> * _Nullable)entriesForKeys:(NSArray<NSString *> *)keys fromStore:(__kindof NSPersistentStore *)store inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct));
+ (NSDictionary<NSString *, OCCKMetadataEntry *> * _Nullable)entriesForKeys:(NSArray<NSString *> *)keys onlyFetchingProperties:(NSArray<NSString *> * _Nullable)onlyFetchingProperties fromStore:(__kindof NSPersistentStore *)store inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct));
+ (OCCKMetadataEntry *)insertMetadataEntryWithKey:(NSString *)key stringValue:(NSString * _Nullable)stringValue forStore:(__kindof NSPersistentStore *)store intoManagedObjectContext:(NSManagedObjectContext *)managedObjectContext __attribute__((objc_direct));
+ (OCCKMetadataEntry *)insertMetadataEntryWithKey:(NSString *)key boolValue:(BOOL)boolValue forStore:(__kindof NSPersistentStore *)store intoManagedObjectContext:(NSManagedObjectContext *)managedObjectContext __attribute__((objc_direct));
+ (OCCKMetadataEntry * _Nullable)updateOrInsertMetadataEntryWithKey:(NSString *)key boolValue:(BOOL)boolValue forStore:(__kindof NSPersistentStore *)store intoManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct));
+ (OCCKMetadataEntry * _Nullable)updateOrInsertMetadataEntryWithKey:(NSString *)key stringValue:(NSString * _Nullable)stringValue forStore:(__kindof NSPersistentStore *)store intoManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct));
+ (OCCKMetadataEntry * _Nullable)updateOrInsertMetadataEntryWithKey:(NSString *)key transformedValue:(NSObject<NSSecureCoding> * _Nullable)transformedValue forStore:(__kindof NSPersistentStore *)store intoManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct));
+ (OCCKMetadataEntry * _Nullable)updateOrInsertMetadataEntryWithKey:(NSString *)key integerValue:(NSNumber * _Nullable)integerValue forStore:(__kindof NSPersistentStore *)store intoManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct));

@property (retain, nonatomic, nullable) NSNumber *boolValueNum;
@property (retain, nonatomic) NSString *key;
@property (retain, nonatomic, nullable) NSString *stringValue;
@property (nonatomic) BOOL boolValue;
@property (retain, nonatomic, nullable) NSObject<NSSecureCoding> *transformedValue;
@property (retain, nonatomic, nullable) NSNumber *integerValue;
@property (retain, nonatomic, nullable) NSDate *dateValue;

- (NSString *)descriptionValue __attribute__((objc_direct));
@end

NS_ASSUME_NONNULL_END
