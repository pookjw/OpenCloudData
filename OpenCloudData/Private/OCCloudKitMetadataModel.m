//
//  OCCloudKitMetadataModel.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/6/25.
//

#import <OpenCloudData/OCCloudKitMetadataModel.h>
#import <OpenCloudData/NSSQLCore.h>
#import <OpenCloudData/NSManagedObjectID+Private.h>
#import <OpenCloudData/Log.h>
#import <objc/runtime.h>
@import ellekit;

NSString * const OCCKRecordIDAttributeName = @"ckRecordID";

@implementation OCCloudKitMetadataModel

+ (NSUInteger)ancillaryEntityCount {
    return 14;
}

+ (NSUInteger)ancillaryEntityOffset {
    return 17000;
}

+ (NSString *)ancillaryModelNamespace {
    return @"CloudKit";
}

+ (NSDictionary<NSNumber *, NSSet<NSNumber *> *> *)createMapOfEntityIDToPrimaryKeySetForObjectIDs:(NSObject<NSFastEnumeration> *)objectIDs {
    return [OCCloudKitMetadataModel createMapOfEntityIDToPrimaryKeySetForObjectIDs:objectIDs fromStore:nil];
}

+ (NSDictionary<NSNumber *, NSSet<NSNumber *> *> *)createMapOfEntityIDToPrimaryKeySetForObjectIDs:(NSObject<NSFastEnumeration> *)objectIDs fromStore:(__kindof NSPersistentStore *)store {
    /*
     x20 = objectIDs
     x19 = store
     */
    
    // x21
    NSMutableDictionary<NSNumber *, NSMutableSet<NSNumber *> *> *entityIDToPrimaryKeySet = [[NSMutableDictionary alloc] init];
    
    // x26
    for (NSManagedObjectID *objectID in objectIDs) {
        if (objectID.isTemporaryID) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Somehow got a temporary objectID for export: %s", [objectID.description cStringUsingEncoding:NSUTF8StringEncoding]);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Somehow got a temporary objectID for export: %s", [objectID.description cStringUsingEncoding:NSUTF8StringEncoding]);
            continue;
        }
        
        // x28
        __kindof NSPersistentStore *persistentStore = [objectID.persistentStore retain];
        if (store != nil) {
            if (![persistentStore.identifier isEqualToString:store.identifier]) {
                os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: Somehow got a temporary objectID for export: %s\n", [objectID.description cStringUsingEncoding:NSUTF8StringEncoding]);
                os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Somehow got a temporary objectID for export: %s\n", [objectID.description cStringUsingEncoding:NSUTF8StringEncoding]);
                [persistentStore release];
                continue;
            }
        }
        
        // original : [NSSQLCore class]
        if (![persistentStore isKindOfClass:objc_lookUpClass("NSSQLCore")]) {
            os_log_error(_OCLogGetLogStream(0x11), "CoreData: This method only supports objectIDs from SQLite stores: %s\n", [objectID.description cStringUsingEncoding:NSUTF8StringEncoding]);
            os_log_fault(_OCLogGetLogStream(0x11), "CoreData: fault: This method only supports objectIDs from SQLite stores: %s\n", [objectID.description cStringUsingEncoding:NSUTF8StringEncoding]);
            [persistentStore release];
            continue;
        }
        
        NSSQLCore *sqlCore = (NSSQLCore *)persistentStore;
        // x24
        NSSQLModel *model = sqlCore.model;
        
        const void *image = MSGetImageByName("/System/Library/Frameworks/CoreData.framework/CoreData");
        const void *symbol = MSFindSymbol(image, "__sqlEntityForEntityDescription");
        
        NSSQLEntity * _Nullable entity = ((id (*)(id, id))symbol)(objectID.entity, model);
        if (entity == nil) {
            [persistentStore release];
            continue;
        }
        
        Ivar ivar = object_getInstanceVariable(entity, "_entityID", NULL);
        assert(ivar != NULL);
        uint _entityID = *(uint *)((uintptr_t)entity + ivar_getOffset(ivar));
        // x27
        NSNumber *entityIDNumber = @(_entityID);
        // x26
        NSNumber *referenceData64Number = @([objectID _referenceData64]);
        
        // x24
        NSMutableSet<NSNumber *> *primaryKeySet = [entityIDToPrimaryKeySet[entityIDNumber] retain];
        if (primaryKeySet == nil) {
            primaryKeySet = [[NSMutableSet alloc] init];
            entityIDToPrimaryKeySet[entityIDNumber] = primaryKeySet;
        }
        
        [primaryKeySet addObject:referenceData64Number];
        [primaryKeySet release];
        
        [persistentStore release];
    }
    
    return entityIDToPrimaryKeySet;
}

+ (NSManagedObjectModel *)newMetadataModelForFrameworkVersion:(NSNumber *)version {
    abort();
}

@end
