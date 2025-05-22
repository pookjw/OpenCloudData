//
//  OCCKMetadataEntry.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/10/25.
//

#import "OpenCloudData/Private/Model/OCCKMetadataEntry.h"
#import "OpenCloudData/Private/OCCloudKitMetadataModel.h"
#import "OpenCloudData/Private/Log.h"
#import <objc/runtime.h>

@implementation OCCKMetadataEntry
@dynamic boolValueNum;
@dynamic key;
@dynamic stringValue;
@dynamic transformedValue;
@dynamic integerValue;
@dynamic dateValue;

+ (NSString *)entityPath {
//    return [NSString stringWithFormat:@"%@/%@", [OCCloudKitMetadataModel ancillaryModelNamespace], NSStringFromClass(self)];
    return [NSString stringWithFormat:@"%@/%@", [OCCloudKitMetadataModel ancillaryModelNamespace], NSStringFromClass(objc_lookUpClass("NSCKMetadataEntry"))];
}

+ (OCCKMetadataEntry *)entryForKey:(NSString *)key fromStore:(__kindof NSPersistentStore *)store inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable *)error {
    /*
     x22 = key
     X21 = store
     x20 = managedObjectContext
     x19 = error
     */
    
    NSDictionary<NSString *, OCCKMetadataEntry *> * _Nullable results = [OCCKMetadataEntry entriesForKeys:@[key] onlyFetchingProperties:nil fromStore:store inManagedObjectContext:managedObjectContext error:error];
    return results[key];
}

+ (NSDictionary<NSString *,OCCKMetadataEntry *> *)entriesForKeys:(NSArray<NSString *> *)keys fromStore:(__kindof NSPersistentStore *)store inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable *)error {
    return [OCCKMetadataEntry entriesForKeys:keys onlyFetchingProperties:nil fromStore:store inManagedObjectContext:managedObjectContext error:error];
}

+ (NSDictionary<NSString *,OCCKMetadataEntry *> *)entriesForKeys:(NSArray<NSString *> *)keys onlyFetchingProperties:(NSArray<NSString *> * _Nullable)onlyFetchingProperties fromStore:(__kindof NSPersistentStore *)store inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable *)error {
    /*
     x24 = keys
     x21 = onlyFetchingProperties
     x23 = store
     x20 = managedObjectContext
     x19 = error
     */
    
    // x22
    NSFetchRequest<OCCKMetadataEntry *> *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[OCCKMetadataEntry entityPath]];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"key IN (%@)", keys];
    fetchRequest.affectedStores = @[store];
    
    if (onlyFetchingProperties.count == 0) {
        fetchRequest.returnsObjectsAsFaults = NO;
    } else {
        fetchRequest.propertiesToFetch = onlyFetchingProperties;
    }
    
    // x20
    NSArray<OCCKMetadataEntry *> * _Nullable results = [managedObjectContext executeFetchRequest:fetchRequest error:error];
    
    // x19
    NSMutableDictionary<NSString *, OCCKMetadataEntry *> *dictionary = [NSMutableDictionary dictionary];
    
    if (results == nil) return dictionary;
    
    // x22
    for (OCCKMetadataEntry *entry in results) {
        NSString *key = entry.key;
        dictionary[key] = entry;
    }
    
    return dictionary;
}

- (BOOL)boolValue {
    return self.boolValueNum.boolValue;
}

- (void)setBoolValue:(BOOL)boolValue {
    self.boolValueNum = @(boolValue);
}

- (NSString *)descriptionValue {
    // x19 = self
    
    if (self.stringValue != nil) {
        return self.stringValue;
    }
    
    if (self.integerValue != nil) {
        return [NSString stringWithFormat:@"%ld", self.integerValue.integerValue];
    }
    
    if (self.boolValueNum != nil) {
        return self.boolValue ? @"YES" : @"NO";
    }
    
    if (self.transformedValue != nil) {
        return self.transformedValue.description;
    }
    
    if (self.dateValue != nil) {
        return self.dateValue.description;
    }
    
    os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData+CloudKit: %s(%d): %@ doesn't know how to handle it's specified value. Please file a bug with this outpout and send to Core Data | New Bugs.", __func__, __LINE__, NSStringFromClass([self class]));
    return self.description;
}

+ (OCCKMetadataEntry *)insertMetadataEntryWithKey:(NSString *)key stringValue:(NSString *)stringValue forStore:(__kindof NSPersistentStore *)store intoManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    OCCKMetadataEntry *entry = [OCCKMetadataEntry _insertMetadataEntryWithKey:key forStore:store intoManagedObjectContext:managedObjectContext];
    entry.stringValue = stringValue;
    return entry;
}

+ (OCCKMetadataEntry *)insertMetadataEntryWithKey:(NSString *)key boolValue:(BOOL)boolValue forStore:(__kindof NSPersistentStore *)store intoManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    OCCKMetadataEntry *entry = [OCCKMetadataEntry _insertMetadataEntryWithKey:key forStore:store intoManagedObjectContext:managedObjectContext];
    entry.boolValue = boolValue;
    return entry;
}

+ (OCCKMetadataEntry *)_insertMetadataEntryWithKey:(NSString *)key forStore:(__kindof NSPersistentStore *)store intoManagedObjectContext:(NSManagedObjectContext *)managedObjectContext __attribute__((objc_direct)) {
    OCCKMetadataEntry *entry = [NSEntityDescription insertNewObjectForEntityForName:[OCCKMetadataEntry entityPath] inManagedObjectContext:managedObjectContext];
    entry.key = key;
    [managedObjectContext assignObject:entry toPersistentStore:store];
    return entry;
}

+ (OCCKMetadataEntry *)updateOrInsertMetadataEntryWithKey:(NSString *)key boolValue:(BOOL)boolValue forStore:(__kindof NSPersistentStore *)store intoManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable *)error {
    return [OCCKMetadataEntry _updateOrInsertMetadataEntryWithKey:key
                                                valueSettingBlock:^(OCCKMetadataEntry *entry) {
        entry.boolValue = boolValue;
    }
                                                         forStore:store
                                         intoManagedObjectContext:managedObjectContext
                                                            error:error];
}

+ (OCCKMetadataEntry *)updateOrInsertMetadataEntryWithKey:(NSString *)key stringValue:(NSString *)stringValue forStore:(__kindof NSPersistentStore *)store intoManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable *)error {
    return [OCCKMetadataEntry _updateOrInsertMetadataEntryWithKey:key
                                                valueSettingBlock:^(OCCKMetadataEntry *entry) {
        entry.stringValue = stringValue;
    }
                                                         forStore:store
                                         intoManagedObjectContext:managedObjectContext
                                                            error:error];
}

+ (OCCKMetadataEntry *)updateOrInsertMetadataEntryWithKey:(NSString *)key transformedValue:(NSObject<NSSecureCoding> *)transformedValue forStore:(__kindof NSPersistentStore *)store intoManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable *)error {
    return [OCCKMetadataEntry _updateOrInsertMetadataEntryWithKey:key
                                                valueSettingBlock:^(OCCKMetadataEntry *entry) {
        entry.transformedValue = transformedValue;
    }
                                                         forStore:store
                                         intoManagedObjectContext:managedObjectContext
                                                            error:error];
}

+ (OCCKMetadataEntry *)updateOrInsertMetadataEntryWithKey:(NSString *)key integerValue:(NSNumber *)integerValue forStore:(__kindof NSPersistentStore *)store intoManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable *)error {
    return [OCCKMetadataEntry _updateOrInsertMetadataEntryWithKey:key
                                                valueSettingBlock:^(OCCKMetadataEntry *entry) {
        entry.integerValue = integerValue;
    }
                                                         forStore:store
                                         intoManagedObjectContext:managedObjectContext
                                                            error:error];
}

+ (OCCKMetadataEntry *)_updateOrInsertMetadataEntryWithKey:(NSString *)key valueSettingBlock:(void (^ NS_NOESCAPE)(OCCKMetadataEntry *entry))valueSettingBlock forStore:(__kindof NSPersistentStore *)store intoManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable *)error __attribute__((objc_direct)) {
    /*
     x24 = key
     x20 = valueSettingBlock
     x23 = store
     x22 = managedObjectContext
     x19 = error
     */
    
    // sp + 0x8
    NSError * _Nullable _error = nil;
    
    // x21
    OCCKMetadataEntry * _Nullable entry = [OCCKMetadataEntry entryForKey:key fromStore:store inManagedObjectContext:managedObjectContext error:&_error];
    if (entry == nil) {
        entry = [OCCKMetadataEntry _insertMetadataEntryWithKey:key forStore:store intoManagedObjectContext:managedObjectContext];
        
        if (entry == nil) {
            if (_error == nil) {
                os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
                os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            } else {
                if (error) *error = _error;
            }
            
            return nil;
        }
    }
    
    valueSettingBlock(entry);
    
    return entry;
}

@end
