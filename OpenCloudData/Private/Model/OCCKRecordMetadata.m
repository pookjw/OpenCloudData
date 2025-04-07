//
//  OCCKRecordMetadata.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/5/25.
//

#import <OpenCloudData/OCCKRecordMetadata.h>
#import <OpenCloudData/OCCloudKitMetadataModel.h>
#import <OpenCloudData/NSPersistentStore+Private.h>
#import <OpenCloudData/OCCloudKitMirroringDelegate.h>
#import <OpenCloudData/NSSQLModelProvider.h>
#import <OpenCloudData/NSSQLEntity.h>
#import <OpenCloudData/NSManagedObjectID+Private.h>
#import <OpenCloudData/Log.h>
#import <objc/runtime.h>
@import ellekit;

@implementation OCCKRecordMetadata
@dynamic ckRecordName;
@dynamic ckRecordSystemFields;
@dynamic encodedRecord;
@dynamic entityId;
@dynamic entityPK;
@dynamic ckShare;
@dynamic recordZone;
@dynamic needsUpload;
@dynamic needsLocalDelete;
@dynamic needsCloudDelete;
@dynamic lastExportedTransactionNumber;
@dynamic pendingExportTransactionNumber;
@dynamic pendingExportChangeTypeNumber;
@dynamic moveReceipts;

+ (NSData *)encodeRecord:(CKRecord *)record error:(NSError * _Nullable *)error {
    /*
     x21 = record
     x19 = error
     */
    
    // sp + 0x8
    NSError * _Nullable _error = nil;
    NSData * _Nullable result = nil;
    @autoreleasepool {
        NSData * _Nullable data = [NSKeyedArchiver archivedDataWithRootObject:record requiringSecureCoding:YES error:&_error];
        if (data == nil) {
            [_error retain];
        } else {
            NSData * _Nullable compressedData = [[data compressedDataUsingAlgorithm:NSDataCompressionAlgorithmLZFSE error:&_error] retain];
            if (data == nil) {
                [_error retain];
            } else {
                result = [compressedData retain];
            }
        }
    }
    
    if (result != nil) {
        return result;
    } else {
        if (_error == nil) {
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __func__, __LINE__);
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __func__, __LINE__);
        } else {
            [_error autorelease];
            if (error) {
                *error = _error;
            }
        }
        
        return nil;
    }
}

+ (CKRecord *)recordFromEncodedData:(NSData *)encodedData error:(NSError * _Nullable *)error {
    /*
     x2 = encodedData
     x19 = error
     */
    
    // x21
    CKRecord * _Nullable record = nil;
    // sp + 0x8
    NSError * _Nullable _error = nil;
    @autoreleasepool {
        // x21
        NSData * _Nullable decompressedData = [encodedData decompressedDataUsingAlgorithm:NSDataCompressionAlgorithmLZFSE error:&_error];
        if (decompressedData == nil) {
            [_error retain];
        } else {
            // original : getCloudKitCKRecordClass
            record = [[NSKeyedUnarchiver unarchivedObjectOfClass:[CKRecord class] fromData:decompressedData error:&_error] retain];
        }
    }
    
    if (record == nil) {
        if (_error == nil) {
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __func__, __LINE__);
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __func__, __LINE__);
        } else {
            [_error autorelease];
            if (error) *error = _error;
        }
        
        return nil;
    }
    
    return record;
}

+ (NSString *)entityPath {
    return [NSString stringWithFormat:@"%@/%@", OCCloudKitMetadataModel.ancillaryModelNamespace, NSStringFromClass(self)];
}

+ (OCCKRecordMetadata *)insertMetadataForObject:(NSManagedObject *)object setRecordName:(BOOL)setRecordName inZoneWithID:(CKRecordZoneID *)zoneID recordNamePrefix:(NSString *)recordNamePrefix error:(NSError * _Nullable *)error {
    /*
     x20 = object
     x26 = setRecordName
     x23 = zoneID
     x27 = recordNamePrefix
     sp + 0x10 = error
     */
    
    // x22
    NSManagedObjectContext *managedObjectContext = object.managedObjectContext;
    // x24
    __kindof NSPersistentStore<NSSQLModelProvider> *persistentStore = (__kindof NSPersistentStore<NSSQLModelProvider> *)object.objectID.persistentStore;
    
    // original : NSCloudKitMirroringDelegate *
    OCCloudKitMirroringDelegate *mirroringDelegate = (OCCloudKitMirroringDelegate *)persistentStore.mirroringDelegate;
    
    // x25
    CKDatabaseScope databaseScope;
    if (mirroringDelegate == nil) {
        os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Attempting to query cloudkit metadata without a mirroring delegate: %@\n", persistentStore);
        os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: Attempting to query cloudkit metadata without a mirroring delegate: %@\n", persistentStore);
        databaseScope = 0;
    } else {
        OCCloudKitMirroringDelegateOptions *options = mirroringDelegate->_options;
        databaseScope = options.databaseScope;
    }
    
    // x21
    OCCKRecordMetadata *metadataObject = [NSEntityDescription insertNewObjectForEntityForName:[OCCKRecordMetadata entityPath] inManagedObjectContext:managedObjectContext];
    // x28
    __kindof NSAttributeDescription * _Nullable ckRecordIDDescription = metadataObject.entity.attributesByName[OCCKRecordIDAttributeName];
    
    __block NSString * _Nullable recordID = nil;
    if (ckRecordIDDescription != nil) {
        [object.managedObjectContext performBlockAndWait:^{
            recordID = [[object valueForKey:OCCKRecordIDAttributeName] retain];
        }];
    }
    
    if (recordID == nil) {
        if (recordNamePrefix.length == 0) {
            recordID = [[[NSUUID UUID] UUIDString] retain];
        } else {
            // x19 / sp + 0x8
            NSString *name = object.entity.name;
            // sp
            NSString *UUIDString = [[NSUUID UUID] UUIDString];
            recordID = [[recordNamePrefix stringByAppendingFormat:@"%@_%@", UUIDString, name] retain];
        }
        
        if ((ckRecordIDDescription != nil) && (setRecordName)) {
            [managedObjectContext performBlockAndWait:^{
                [object setValue:OCCKRecordIDAttributeName forKey:recordID];
            }];
        }
    }
    
    [managedObjectContext assignObject:metadataObject toPersistentStore:persistentStore];
    metadataObject.ckRecordName = recordID;
    
    // x19
    NSSQLModel *model = [persistentStore model];
    
    const void *image = MSGetImageByName("/System/Library/Frameworks/CoreData.framework/CoreData");
    const void *symbol = MSFindSymbol(image, "__sqlEntityForEntityDescription");
    
    NSSQLEntity * _Nullable entity = ((id (*)(id, id))symbol)(object.objectID.entity, model);
    uint _entityID;
    if (entity == nil) {
        _entityID = 0;
    } else {
        Ivar ivar = object_getInstanceVariable(entity, "_entityID", NULL);
        assert(ivar != NULL);
        _entityID = *(uint *)((uintptr_t)entity + ivar_getOffset(ivar));
    }
    metadataObject.entityId = @(_entityID);
    metadataObject.entityPK = @([object.objectID _referenceData64]);
    
    // sp + 0x78
    NSError * _Nullable _error = nil;
    OCCKRecordZoneMetadata * _Nullable recordZone = [OCCKRecordZoneMetadata zoneMetadataForZoneID:zoneID inDatabaseWithScope:databaseScope forStore:persistentStore inContext:managedObjectContext error:&_error];
    metadataObject.recordZone = recordZone;
    
    if (metadataObject.recordZone == nil) {
        [managedObjectContext deleteObject:metadataObject];
        os_log_error(_OCLogGetLogStream(0x11), "CoreData+CloudKit: %s(%d): Failed to get a metadata zone while creating metadata for object: %@\n%@", __func__, __LINE__, object, _error);
        metadataObject = nil;
    }
    
    if (metadataObject == nil) {
        if (_error == nil) {
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __func__, __LINE__);
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __func__, __LINE__);
        } else {
            if (error) *error = _error;
        }
    }
    
    return metadataObject;
}

+ (NSManagedObjectID *)createObjectIDForEntityID:(NSNumber *)entityIDNumber primaryKey:(NSNumber *)primaryKeyNumber inSQLCore:(NSSQLCore *)sqlCore {
    /*
     x20 = entityIDNumber
     x21 = primaryKeyNumber
     X19 = sqlCore
     */
    
    // x22
    unsigned long entityID = entityIDNumber.unsignedIntegerValue;
    // x21
    NSInteger primaryKey = primaryKeyNumber.integerValue;
    
    if (entityID == 0) {
        os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: Cannot create objectID: called before the record has the necessary properties (entityID): %@", entityIDNumber);
        os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Cannot create objectID: called before the record has the necessary properties (entityID): %@", entityIDNumber);
        return nil;
    }
    
    const void *image = MSGetImageByName("/System/Library/Frameworks/CoreData.framework/CoreData");
    const void *symbol = MSFindSymbol(image, "__sqlCoreLookupSQLEntityForEntityID");
    
    NSSQLEntity * _Nullable sqlEntity = ((id (*)(id, unsigned long))symbol)(sqlCore, entityID);
    if (sqlEntity == nil) {
        os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: Cannot create objectID. Unable to find entity with id '%@' in store '%@'", entityIDNumber, sqlCore);
        os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Cannot create objectID. Unable to find entity with id '%@' in store '%@'", entityIDNumber, sqlCore);
        return nil;
    }
    
    if (primaryKey < 1) {
        os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: Cannot create objectID: called before the record has the necessary properties (primaryKey): %@ / %@", primaryKeyNumber, sqlCore);
        os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Cannot create objectID: called before the record has the necessary properties (primaryKey): %@ / %@", primaryKeyNumber, sqlCore);
        return nil;
    }
    
    return [sqlCore newObjectIDForEntity:sqlEntity pk:primaryKey];
}

+ (NSManagedObjectID *)createObjectIDFromMetadataDictionary:(NSDictionary<NSString *,id> *)metadataDictionary inSQLCore:(NSSQLCore *)sqlCore {
    return [OCCKRecordMetadata createObjectIDForEntityID:metadataDictionary[@"entityId"] primaryKey:metadataDictionary[@"entityPK"] inSQLCore:sqlCore];
}

+ (OCCKRecordMetadata *)metadataForObject:(NSManagedObject *)object inManagedObjectContext:(NSManagedObjectContext *)context error:(NSError * _Nullable *)error {
    abort();
}

+ (NSArray<OCCKRecordMetadata *> *)metadataForObjectIDs:(NSArray<NSManagedObjectID *> *)objectIDs inStore:(__kindof NSPersistentStore *)store withManagedObjectContext:(NSManagedObjectContext *)context error:(NSError * _Nullable *)error {
    /*
     x19 = objectIDs
     x24 = store
     x22 = context
     sp + 0x10 = error
     */
    
    // sp + 0x68
    NSError * _Nullable contextError = nil;
    
    // sp + 0x18
    NSDictionary<NSNumber *, NSSet<NSNumber *> *> *entityIDToPrimaryKeySet = [OCCloudKitMetadataModel createMapOfEntityIDToPrimaryKeySetForObjectIDs:objectIDs];
    
    // x19
    NSMutableArray<OCCKRecordMetadata *> *results = [[NSMutableArray alloc] init];
    // x23
    NSFetchRequest<OCCKRecordMetadata *> *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[OCCKRecordMetadata entityPath]];
    fetchRequest.affectedStores = @[store];
    
    // x28
    for (NSNumber *entityID in entityIDToPrimaryKeySet.allKeys) @autoreleasepool {
        NSSet<NSNumber *> *primaryKeySet = entityIDToPrimaryKeySet[entityID];
        
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"entityId = %@ and entityPK in %@", entityID, primaryKeySet];
        fetchRequest.fetchBatchSize = 500;
        
        // x28
        NSArray<OCCKRecordMetadata *> * _Nullable fetchedObjects = [context executeFetchRequest:fetchRequest error:&contextError];
        if (fetchedObjects != nil) {
            [results addObjectsFromArray:fetchedObjects];
        } else {
            // break 호출 및 contextError, results 검사가 없음
            // Error가 여러 번 발생하면 NSError에 Leak이 발생할 것
            [contextError retain];
            [results release];
            results = nil;
        }
    }
    
    [entityIDToPrimaryKeySet release];
    
    if (results == nil) {
        if (contextError == nil) {
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __func__, __LINE__);
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __func__, __LINE__);
        } else {
            if (error) {
                *error = [[contextError retain] autorelease];
            }
        }
    }
    
    [contextError release];
    contextError = nil;
    
    return [results autorelease];
}

@end
