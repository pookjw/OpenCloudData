//
//  OCCKRecordMetadata.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/5/25.
//

#import "OpenCloudData/Private/Model/OCCKRecordMetadata.h"
#import "OpenCloudData/Private/OCCloudKitMetadataModel.h"
#import "OpenCloudData/Private/Model/OCCKRecordZoneMetadata.h"
#import "OpenCloudData/SPI/CoreData/NSPersistentStore+Private.h"
#import "OpenCloudData/Private/OCCloudKitMirroringDelegate.h"
#import "OpenCloudData/SPI/CoreData/NSSQLModelProvider.h"
#import "OpenCloudData/SPI/CoreData/NSSQLEntity.h"
#import "OpenCloudData/SPI/CoreData/NSManagedObjectID+Private.h"
#import "OpenCloudData/Private/Log.h"
#import "OpenCloudData/SPI/OCSPIResolver.h"
#import "OpenCloudData/Private/OCCKRecordMetadataReceiptArchive.h"
#import <objc/runtime.h>

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
                result = compressedData;
            }
        }
    }
    
    if (result != nil) {
        return result;
    } else {
        if (_error == nil) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
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
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        } else {
            [_error autorelease];
            if (error) *error = _error;
        }
        
        return nil;
    }
    
    return record;
}

+ (NSString *)entityPath {
//    return [NSString stringWithFormat:@"%@/%@", OCCloudKitMetadataModel.ancillaryModelNamespace, NSStringFromClass(self)];
    return [NSString stringWithFormat:@"%@/%@", [OCCloudKitMetadataModel ancillaryModelNamespace], NSStringFromClass(objc_lookUpClass("NSCKRecordMetadata"))];
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
        os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Attempting to query cloudkit metadata without a mirroring delegate: %@\n", persistentStore);
        os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Attempting to query cloudkit metadata without a mirroring delegate: %@\n", persistentStore);
        databaseScope = 0;
    } else {
        OCCloudKitMirroringDelegateOptions *options = mirroringDelegate->_options;
        databaseScope = options.databaseScope;
    }
    
    // x21
    OCCKRecordMetadata *metadataObject = [NSEntityDescription insertNewObjectForEntityForName:[OCCKRecordMetadata entityPath] inManagedObjectContext:managedObjectContext];
    // x28
    __kindof NSAttributeDescription * _Nullable ckRecordIDDescription = metadataObject.entity.attributesByName[[OCSPIResolver NSCKRecordIDAttributeName]];
    
    __block NSString * _Nullable recordID = nil;
    if (ckRecordIDDescription != nil) {
        [object.managedObjectContext performBlockAndWait:^{
            recordID = [[object valueForKey:[OCSPIResolver NSCKRecordIDAttributeName]] retain];
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
                [object setValue:[OCSPIResolver NSCKRecordIDAttributeName] forKey:recordID];
            }];
        }
    }
    
    [managedObjectContext assignObject:metadataObject toPersistentStore:persistentStore];
    metadataObject.ckRecordName = recordID;
    
    // x19
    NSSQLModel *model = [persistentStore model];
    NSSQLEntity * _Nullable entity = [OCSPIResolver _sqlEntityForEntityDescription:model x1:object.objectID.entity];
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
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        } else {
            if (error) *error = _error;
        }
    }
    
    [recordID release];
    
    return metadataObject;
}

+ (NSManagedObjectID *)createObjectIDForEntityID:(NSNumber *)entityIDNumber primaryKey:(NSNumber *)primaryKeyNumber inSQLCore:(NSSQLCore *)sqlCore {
    /*
     x20 = entityIDNumber
     x21 = primaryKeyNumber
     X19 = sqlCore
     */
    
    // x22
    NSUInteger entityID = entityIDNumber.unsignedIntegerValue;
    // x21
    NSInteger primaryKey = primaryKeyNumber.integerValue;
    
    if (entityID == 0) {
        os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: Cannot create objectID: called before the record has the necessary properties (entityID): %@", entityIDNumber);
        os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Cannot create objectID: called before the record has the necessary properties (entityID): %@", entityIDNumber);
        return nil;
    }
    
    NSSQLEntity * _Nullable sqlEntity = [OCSPIResolver _sqlCoreLookupSQLEntityForEntityID:sqlCore x1:entityID];
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
    /*
     x21 = object
     x20 = context
     x19 = error
     */
    
    // sp + 0x8
    NSError * _Nullable _error = nil;
    // x22
    NSArray<OCCKRecordMetadata *> * _Nullable metadataArray = [OCCKRecordMetadata metadataForObjectIDs:@[object.objectID] inStore:object.objectID.persistentStore withManagedObjectContext:context error:&_error];
    if (metadataArray == nil) {
        if (error) {
            *error = _error;
        }
        return nil;
    }
    
    // x20
    OCCKRecordMetadata * _Nullable lastMetadata = metadataArray.lastObject;
    
    if (metadataArray.count > 1) {
        os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Found more than one instance of NSCKRecordMetadata for object: %s\n%s\n", [object.description cStringUsingEncoding:NSUTF8StringEncoding], [metadataArray.description cStringUsingEncoding:NSUTF8StringEncoding]);
        os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Found more than one instance of NSCKRecordMetadata for object: %s\n%s\n", [object.description cStringUsingEncoding:NSUTF8StringEncoding], [metadataArray.description cStringUsingEncoding:NSUTF8StringEncoding]);
    }
    
    return lastMetadata;
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
            [contextError retain];
            [results release];
            results = nil;
            break;
        }
    }
    
    [entityIDToPrimaryKeySet release];
    
    if (results == nil) {
        if (contextError == nil) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
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

+ (NSDictionary<NSManagedObjectID *, OCCKRecordMetadata *> *)createMapOfMetadataMatchingObjectIDs:(NSArray<NSManagedObjectID *> *)objectIDs inStore:(NSSQLCore *)store inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable *)error {
    /*
     sp + 0x60 = objectIDs
     x23 / sp + 0x58 = store
     x20 / sp + 0x30 = managedObjectContext
     sp + 0x18 = error
     */
    
    // x21
    NSMutableDictionary<NSManagedObjectID *, OCCKRecordMetadata *> *objectIDToRecordMetadata = [[NSMutableDictionary alloc] init];
    
    // sp + 0x148
    NSError * _Nullable contextError = nil;
    
    // x22 / sp + 0x28
    NSFetchRequest<OCCKRecordMetadata *> *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[OCCKRecordMetadata entityPath]];
    fetchRequest.affectedStores = @[store];
    
    // x19
    NSMutableDictionary<NSNumber *, NSMutableDictionary<NSNumber *, NSManagedObjectID *> *> *entityIDToReferenceData64ToObjectID = [[NSMutableDictionary alloc] init];
    // sp + 0x78
    NSMutableDictionary<NSNumber *, NSMutableArray<NSNumber *> *> *entityIDToReferenceData64Array = [[NSMutableDictionary alloc] init];
    
    // x27
    for (NSManagedObjectID *objectID in objectIDs) {
        if (objectID.isTemporaryID) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Somehow got a temporary objectID for export: %s", [objectID.description cStringUsingEncoding:NSUTF8StringEncoding]);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Somehow got a temporary objectID for export: %s", [objectID.description cStringUsingEncoding:NSUTF8StringEncoding]);
            continue;
        }
        
        // x23
        NSSQLModel *model = store.model;
        NSSQLEntity * _Nullable entity = [OCSPIResolver _sqlEntityForEntityDescription:model x1:objectID.entity];
        
        uint _entityID;
        if (entity == nil) {
            _entityID = 0;
        } else {
            Ivar ivar = object_getInstanceVariable(entity, "_entityID", NULL);
            assert(ivar != NULL);
            _entityID = *(uint *)((uintptr_t)entity + ivar_getOffset(ivar));
        }
        // x28
        NSNumber *entityIDNumber = @(_entityID);
        
        // x24
        NSNumber *referenceData64Number = @([objectID _referenceData64]);
        
        // x23
        NSMutableArray<NSNumber *> *referenceData64Array = [entityIDToReferenceData64Array[entityIDNumber] retain];
        if (referenceData64Array == nil) {
            referenceData64Array = [[NSMutableArray alloc] init];
            entityIDToReferenceData64Array[entityIDNumber] = referenceData64Array;
        }
        [referenceData64Array addObject:referenceData64Number];
        [referenceData64Array release];
        
        // x23
        NSMutableDictionary<NSNumber *, NSManagedObjectID *> * referenceData64ToObjectID = [entityIDToReferenceData64ToObjectID[entityIDNumber] retain];
        if (referenceData64ToObjectID == nil) {
            referenceData64ToObjectID = [[NSMutableDictionary alloc] init];
            entityIDToReferenceData64ToObjectID[entityIDNumber] = referenceData64ToObjectID;
        }
        referenceData64ToObjectID[referenceData64Number] = objectID;
        [referenceData64ToObjectID release];
    }
    
    // x22
    for (NSNumber *entityID in entityIDToReferenceData64Array.allKeys) @autoreleasepool {
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"entityId = %@ and entityPK in %@", entityID, entityIDToReferenceData64Array[entityID]];
        fetchRequest.fetchBatchSize = 500;
        
        // x25
        NSArray<OCCKRecordMetadata *> * _Nullable fetchedRecordMetadataArray = [managedObjectContext executeFetchRequest:fetchRequest error:&contextError];
        
        if (fetchedRecordMetadataArray == nil) {
            [contextError retain];
            [objectIDToRecordMetadata release];
            objectIDToRecordMetadata = nil;
            break;
        }
        
        // x24
        for (OCCKRecordMetadata *recordMetadata in fetchedRecordMetadataArray) {
            NSManagedObjectID *objectID = entityIDToReferenceData64ToObjectID[recordMetadata.entityId][recordMetadata.entityPK];
            if (objectID == nil) {
                os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Exporter got record metadata back but doesn't have a corresponding objectID: %s\n", [recordMetadata.description cStringUsingEncoding:NSUTF8StringEncoding]);
                os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Exporter got record metadata back but doesn't have a corresponding objectID: %s\n", [recordMetadata.description cStringUsingEncoding:NSUTF8StringEncoding]);
                continue;
            }
            
            objectIDToRecordMetadata[objectID] = recordMetadata;
        }
    }
    
    if (objectIDToRecordMetadata == nil) {
        if (contextError == nil) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        } else {
            if (error) {
                *error = [[contextError retain] autorelease];
            }
        }
    }
    
    [entityIDToReferenceData64Array release];
    [entityIDToReferenceData64ToObjectID release];
    [contextError release];
    
    return objectIDToRecordMetadata;
}

+ (OCCKRecordMetadata *)metadataForRecord:(CKRecord *)record inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext fromStore:(__kindof NSPersistentStore *)store error:(NSError * _Nullable *)error {
    /*
     x24 = record
     x22 = managedObjectContext
     x21 = store
     x19 = error
     */
    
    // sp + 0x18
    NSError * _Nullable contextError = nil;
    
    OCCKRecordMetadata * _Nullable result = nil;
    @autoreleasepool {
        // x23
        NSFetchRequest<OCCKRecordMetadata *> *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[OCCKRecordMetadata entityPath]];
        
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"ckRecordName = %@ and recordZone.ckRecordZoneName = %@ and recordZone.ckOwnerName = %@", record.recordID.recordName, record.recordID.zoneID.zoneName, record.recordID.zoneID.ownerName];
        fetchRequest.affectedStores = @[store];
        
        // x25
        NSArray<OCCKRecordMetadata *> * _Nullable fetchedRecordMetadataArray = [managedObjectContext executeFetchRequest:fetchRequest error:&contextError];
        if (fetchedRecordMetadataArray == nil) {
            result = nil;
            [contextError retain];
        } else {
            result = [fetchedRecordMetadataArray.lastObject retain];
            if (fetchedRecordMetadataArray.count > 1) {
                os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Found more than one instance of NSCKRecordMetadata for record: %s\n%s\n", [record.description cStringUsingEncoding:NSUTF8StringEncoding], [fetchedRecordMetadataArray.description cStringUsingEncoding:NSUTF8StringEncoding]);
                os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Found more than one instance of NSCKRecordMetadata for record: %s\n%s\n", [record.description cStringUsingEncoding:NSUTF8StringEncoding], [fetchedRecordMetadataArray.description cStringUsingEncoding:NSUTF8StringEncoding]);
            }
            
            if (result == nil) {
                result = [NSEntityDescription insertNewObjectForEntityForName:[OCCKRecordMetadata entityPath] inManagedObjectContext:managedObjectContext];
                result.ckRecordName = record.recordID.recordName;
                [managedObjectContext assignObject:result toPersistentStore:store];
                [result retain];
            }
        }
    }
    
    if (contextError != nil) {
        NSError *_error = [contextError autorelease];
        
        // result가 되어야 할 것 같은데, assembly를 보면 sp + x18의 -autorelease 값을 검사하고 있음
        if (_error == nil) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        } else {
            if (error) *error = _error;
        }
    }
    
    return [result autorelease];
}

+ (NSArray<OCCKRecordMetadata *> *)metadataForRecordIDs:(NSArray<CKRecordID *> *)recordIDs fromStore:(__kindof NSPersistentStore *)store inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable *)error {
    /*
     sp + 0x38 = recordIDs
     x19 / sp + 0x48 = store
     sp + 0x40 = managedObjectContext
     sp + 0x20 = error
     */
    
    // x24
    OCCloudKitMirroringDelegate * _Nullable mirroringDelegate = (OCCloudKitMirroringDelegate *)store.mirroringDelegate;
    if (mirroringDelegate == nil) {
        os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Attempting to query cloudkit metadata without a mirroring delegate: %@\n", store);
        os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Attempting to query cloudkit metadata without a mirroring delegate: %@\n", store);
    }
    
    // sp + 0xd8
    NSError * _Nullable _error = nil;
    
    // x20
    NSMutableDictionary<CKRecordZoneID *, NSMutableSet<NSString *> *> *zoneIDToRecordNamesSet = [[NSMutableDictionary alloc] init];
    // x21
    NSMutableDictionary<CKRecordZoneID *, NSManagedObjectID *> *zoneIDToZoneMetadataObjectID = [[NSMutableDictionary alloc] init];
    
    // sp + 0x30
    BOOL success = YES;
    
    // x28
    for (CKRecordID *recordID in recordIDs) @autoreleasepool {
        // x27
        CKRecordZoneID *zoneID = recordID.zoneID;
        
        // x22
        NSMutableSet<NSString *> *recordNamesSet = [zoneIDToRecordNamesSet[zoneID] retain];
        if (recordNamesSet == nil) {
            recordNamesSet = [[NSMutableSet alloc] init];
            zoneIDToRecordNamesSet[zoneID] = recordNamesSet;
        }
        [recordNamesSet addObject:recordID.recordName];
        [recordNamesSet release];
        
        if (zoneIDToZoneMetadataObjectID[zoneID] == nil) {
            if (mirroringDelegate == nil) break; // TODO <+496>
            
            OCCKRecordZoneMetadata * _Nullable zoneMetadata = [OCCKRecordZoneMetadata zoneMetadataForZoneID:zoneID inDatabaseWithScope:mirroringDelegate->_options.databaseScope forStore:store error:&_error];
            
            if (zoneMetadata == nil) {
                [_error retain];
                success = NO;
                break;
            } else {
                _error = nil;
                zoneIDToZoneMetadataObjectID[zoneID] = zoneMetadata.objectID;
            }
        }
    }
    
    [_error autorelease];
    
    if (!success) {
        [zoneIDToZoneMetadataObjectID release];
        [zoneIDToRecordNamesSet release];
        
        if (_error == nil) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        } else {
            if (error) *error = _error;
        }
        
        return nil;
    }
    
    // x19 / sp + 0x38
    NSMutableArray<OCCKRecordMetadata *> *results = [[NSMutableArray alloc] initWithCapacity:recordIDs.count];
    
    success = YES;
    
    // x24
    for (CKRecordZoneID *zoneID in zoneIDToRecordNamesSet.allKeys) @autoreleasepool {
        // x27
        NSManagedObjectID *objectID = zoneIDToZoneMetadataObjectID[zoneID];
        // x28
        NSMutableSet<NSString *> *recordNamesSet = zoneIDToRecordNamesSet[zoneID];
        
        if ((objectID == nil) || (recordNamesSet == nil)) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Invalid query for record metadata (by recordIDs): %@ returned no metadata or record names\n", zoneID);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Invalid query for record metadata (by recordIDs): %@ returned no metadata or record names\n", zoneID);
        }
        
        // x24
        NSFetchRequest<OCCKRecordMetadata *> *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[OCCKRecordMetadata entityPath]];
        fetchRequest.affectedStores = @[store];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"recordZone = %@ AND ckRecordName in %@", objectID, recordNamesSet];
        
        NSArray<OCCKRecordMetadata *> * _Nullable fetchedRecordMetadataArray = [managedObjectContext executeFetchRequest:fetchRequest error:&_error];
        if (fetchedRecordMetadataArray == nil) {
            [_error retain];
            success = NO;
            break;
        } else {
            _error = nil;
            [results addObjectsFromArray:fetchedRecordMetadataArray];
        }
    }
    
    if (!success) {
        [zoneIDToZoneMetadataObjectID release];
        [zoneIDToRecordNamesSet release];
        [results release];
        
        if (_error == nil) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        } else {
            if (error) *error = _error;
        }
        
        return nil;
    }
    
    // x19
    NSArray<OCCKRecordMetadata *> *copy = [[results mutableCopy] autorelease];
    [zoneIDToZoneMetadataObjectID release];
    [zoneIDToRecordNamesSet release];
    [results release];
    
    return copy;
}

+ (NSDictionary<CKRecordID *, OCCKRecordMetadata *> *)createMapOfMetadataMatchingRecords:(NSArray<CKRecord *> *)records andRecordIDs:(NSArray<CKRecordID *> *)recordIDs inStore:(__kindof NSPersistentStore *)store withManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable *)error {
    /*
     sp + 0x40 = records
     x27 = recordIDs
     x19 = store
     sp + 0x50 = managedObjectContext
     sp + 0x30 = error
     */
    
    
    OCCloudKitMirroringDelegate * _Nullable mirroringDelegate = (OCCloudKitMirroringDelegate *)store.mirroringDelegate;
    
    // sp + 0x48
    CKDatabaseScope databaseScope;
    if (mirroringDelegate == nil) {
        os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Attempting to query cloudkit metadata without a mirroring delegate: %@\n", store);
        os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Attempting to query cloudkit metadata without a mirroring delegate: %@\n", store);
        databaseScope = 0;
    } else {
        databaseScope = mirroringDelegate->_options.databaseScope;
    }
    
    // sp + 0x168
    NSError * _Nullable _error = nil;
    
    // x19 (result)
    NSMutableDictionary<CKRecordID *, OCCKRecordMetadata *> *recordIDToRecordMetadata = [[NSMutableDictionary alloc] init];
    // x20
    NSMutableDictionary<CKRecordZoneID *, NSMutableSet<NSString *> *> *zoneIDToRecordNamesSet = [[NSMutableDictionary alloc] init];
    // x21
    NSMutableDictionary<CKRecordZoneID *, NSManagedObjectID *> *zoneIDToRecordZoneMetadataObjectID = [[NSMutableDictionary alloc] init];
    
    // x25
    for (CKRecordID *recordID in recordIDs) {
        // x22
        CKRecordZoneID *zoneID = recordID.zoneID;
        
        // x23
        NSMutableSet<NSString *> *recordNamesSet = [zoneIDToRecordNamesSet[zoneID] retain];
        if (recordNamesSet == nil) {
            recordNamesSet = [[NSMutableSet alloc] init];
            zoneIDToRecordNamesSet[zoneID] = recordNamesSet;
        }
        [recordNamesSet addObject:recordID.recordName];
        [recordNamesSet release];
        
        if (zoneIDToRecordZoneMetadataObjectID[zoneID] == nil) {
            OCCKRecordZoneMetadata * _Nullable recordZoneMetadata = [OCCKRecordZoneMetadata zoneMetadataForZoneID:zoneID inDatabaseWithScope:databaseScope forStore:store inContext:managedObjectContext error:&_error];
            if (recordZoneMetadata == nil) {
                if (_error == nil) {
                    os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
                    os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
                } else {
                    if (error) *error = _error;
                }
                
                [zoneIDToRecordZoneMetadataObjectID release];
                [zoneIDToRecordNamesSet release];
                [recordIDToRecordMetadata release];
                
                return nil;
            }
            
            zoneIDToRecordZoneMetadataObjectID[zoneID] = recordZoneMetadata.objectID;
        }
    }
    
    // x28
    for (CKRecord *record in records) {
        CKRecordZoneID *zoneID = record.recordID.zoneID;
        
        // x25
        NSMutableSet<NSString *> *recordNamesSet = [zoneIDToRecordNamesSet[zoneID] retain];
        if (recordNamesSet == nil) {
            recordNamesSet = [[NSMutableSet alloc] init];
            zoneIDToRecordNamesSet[zoneID] = recordNamesSet;
        }
        [recordNamesSet addObject:record.recordID.recordName];
        [recordNamesSet release];
        
        if (zoneIDToRecordZoneMetadataObjectID[zoneID] == nil) {
            OCCKRecordZoneMetadata * _Nullable recordZoneMetadata = [OCCKRecordZoneMetadata zoneMetadataForZoneID:zoneID inDatabaseWithScope:databaseScope forStore:store inContext:managedObjectContext error:&_error];
            if (recordZoneMetadata == nil) {
                if (_error == nil) {
                    os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
                    os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
                } else {
                    if (error) *error = _error;
                }
                
                [zoneIDToRecordZoneMetadataObjectID release];
                [zoneIDToRecordNamesSet release];
                [recordIDToRecordMetadata release];
                
                return nil;
            }
            
            zoneIDToRecordZoneMetadataObjectID[zoneID] = recordZoneMetadata.objectID;
        }
    }
    
    // 원래 없는 값
    BOOL succeed = YES;
    // x25
    for (CKRecordZoneID *zoneID in zoneIDToRecordNamesSet.allKeys) @autoreleasepool {
        // x22
        NSManagedObjectID *objectID = zoneIDToRecordZoneMetadataObjectID[zoneID];
        // x28
        NSMutableSet<NSString *> *recordNamesSet = zoneIDToRecordNamesSet[zoneID];
        
        if ((objectID == nil) || (recordNamesSet == nil)) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Invalid query for record metadata (by recordIDs): %@ returned no metadata or record names\n", zoneID);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Invalid query for record metadata (by recordIDs): %@ returned no metadata or record names\n", zoneID);
        }
        
        NSFetchRequest<OCCKRecordMetadata *> *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[OCCKRecordMetadata entityPath]];
        fetchRequest.affectedStores = @[store];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"recordZone = %@ AND ckRecordName in %@", objectID, recordNamesSet];
        
        // x22
        NSArray<OCCKRecordMetadata *> * _Nullable fetchedRecordMetadataArray = [managedObjectContext executeFetchRequest:fetchRequest error:&_error];
        if (fetchedRecordMetadataArray != nil) {
            // x28
            for (OCCKRecordMetadata *recordMetadata in fetchedRecordMetadataArray) {
                // x23
                CKRecordID *recordID = [recordMetadata createRecordID];
                recordIDToRecordMetadata[recordID] = recordMetadata;
                [recordID release];
            }
        } else {
            [_error retain];
            succeed = NO;
            break;
        }
    }
    
    NSDictionary<CKRecordID *, OCCKRecordMetadata *> * _Nullable copy;
    if (succeed) {
        copy = [recordIDToRecordMetadata copy];
    } else {
        if (_error == nil) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        } else {
            [_error retain];
            if (error) *error = [[_error retain] autorelease];
        }
        
        copy = nil;
    }
    
    [zoneIDToRecordZoneMetadataObjectID release];
    [zoneIDToRecordNamesSet release];
    [recordIDToRecordMetadata release];
    
    return copy;
}

+ (BOOL)purgeRecordMetadataWithRecordIDs:(NSArray<CKRecordID *> *)recordIDs inStore:(__kindof NSPersistentStore *)store withManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable *)error {
    /*
     x22 = recordIDs
     x23 = store
     x21 = managedObjectContext
     sp + 0x18 = error
     */
    
    // sp + 0xf8
    NSError * _Nullable contextError = nil;
    
    // x20
    NSMutableDictionary<CKRecordZoneID *, NSMutableSet<NSString *> *> *zoneIDToRecordNamesSet = [[NSMutableDictionary alloc] init];
    
    // x25
    for (CKRecordID *recordID in recordIDs) {
        // x26
        NSMutableSet<NSString *> *recordNamesSet = [zoneIDToRecordNamesSet[recordID.zoneID] retain];
        if (recordNamesSet == nil) {
            recordNamesSet = [[NSMutableSet alloc] init];
            zoneIDToRecordNamesSet[recordID.zoneID] = recordNamesSet;
        }
        
        [recordNamesSet addObject:recordID.recordName];
        [recordNamesSet release];
    }
    
    NSFetchRequest<OCCKRecordMetadata *> *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[OCCKRecordMetadata entityPath]];
    fetchRequest.affectedStores = @[store];
    
    BOOL succeed = YES;
    // x26
    for (CKRecordZoneID *zoneID in zoneIDToRecordNamesSet) @autoreleasepool {
        // x27
        NSMutableSet<NSString *> *recordNamesSet = zoneIDToRecordNamesSet[zoneID];
        // x19
        NSString *zoneName = zoneID.zoneName;
        
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"((recordZone.ckRecordZoneName = %@) AND (recordZone.ckOwnerName = %@) AND (ckRecordName IN %@)) OR (needsCloudDelete = 1 AND needsUpload = 0)", zoneName, zoneID.ownerName, recordNamesSet];
        
        // x26
        NSArray<OCCKRecordMetadata *> * _Nullable fetchedRecordMetadataArray = [managedObjectContext executeFetchRequest:fetchRequest error:&contextError];
        
        if (fetchedRecordMetadataArray == nil) {
            succeed = NO;
            [contextError retain];
            break;
        }
        
        for (OCCKRecordMetadata *recordMetadata in fetchedRecordMetadataArray) {
            [managedObjectContext deleteObject:recordMetadata];
        }
    }
    
    if (!succeed) {
        [contextError autorelease];
        
        if (contextError == nil) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        } else {
            if (error) *error = contextError;
        }
    }
    
    [zoneIDToRecordNamesSet release];
    
    return succeed;
}

+ (NSNumber *)countRecordMetadataInStore:(__kindof NSPersistentStore *)store matchingPredicate:(NSPredicate *)predicate withManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable *)error {
    /*
     x23 = store
     X22 = predicate
     x20 = managedObjectCotext
     x19 = error
     */
    
    // x21
    NSFetchRequest<OCCKRecordMetadata *> *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[OCCKRecordMetadata entityPath]];
    
    fetchRequest.resultType = NSCountResultType;
    fetchRequest.affectedStores = @[store];
    
    NSInteger count;
    
    if (managedObjectContext == nil) {
        count = 0;
    } else {
        count = [OCSPIResolver NSManagedObjectContext__countForFetchRequest__error_:managedObjectContext x1:fetchRequest x2:error];
        
        if (count == NSNotFound) {
            return nil;
        }
    }
    
    return [NSNumber numberWithUnsignedInteger:count];
}

+ (NSSet<NSManagedObjectID *> *)batchUpdateMetadataMatchingEntityIdsAndPKs:(NSDictionary<NSNumber *,NSSet<NSNumber *> *> *)entityIdsAndPKs withUpdates:(NSDictionary<NSString *,id> *)updates inStore:(__kindof NSPersistentStore *)store withManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable *)error {
    /*
     x22 = entityIdsAndPKs
     x25 = updates
     x23 = store
     x24 = managedObjectContext
     x21 = error
     */
    
    // sp + 0x80
    __block NSError * _Nullable contextError = nil;
    // sp + 0x98
    __block BOOL succeed = YES;
    
    // x20 (result)
    NSMutableSet<NSManagedObjectID *> *results = [[NSMutableSet alloc] init];
    
    // x19
    NSBatchUpdateRequest *batchUpdateRequest = [[NSBatchUpdateRequest alloc] initWithEntityName:[OCCKRecordMetadata entityPath]];
    batchUpdateRequest.affectedStores = @[store];
    batchUpdateRequest.propertiesToUpdate = updates;
    batchUpdateRequest.resultType = NSUpdatedObjectIDsResultType;
    
    /*
     x19 = sp + 0x20
     x24 = sp + 0x28
     x23 = sp + 0x30
     x20 = sp + 0x38
     x20 == sp
     */
    [entityIdsAndPKs enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull entityID, NSSet<NSNumber *> * _Nonnull entityPKs, BOOL * _Nonnull stop) {
        @autoreleasepool { // 왜 있지
            batchUpdateRequest.predicate = [NSPredicate predicateWithFormat:@"entityId = %@ AND entityPK IN %@", entityID, entityPKs];
            NSBatchUpdateResult * _Nullable requestResult = [managedObjectContext executeRequest:batchUpdateRequest error:&contextError];
            // x22
            NSArray<NSManagedObjectID *> * _Nullable result = requestResult.result;
            if (result == nil) {
                *stop = YES;
                [contextError retain];
                succeed = NO;
                return;
            }
            
            // x23
            NSFetchRequest<OCCKRecordMetadata *> *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[OCCKRecordMetadata entityPath]];
            fetchRequest.predicate = [NSPredicate predicateWithFormat:@"SELF IN %@", result];
            fetchRequest.propertiesToFetch = @[@"entityId", @"entityPK"];
            fetchRequest.affectedStores = @[store];
            fetchRequest.returnsObjectsAsFaults = NO;
            
            // x21
            NSArray<OCCKRecordMetadata *> * _Nullable fetchedRecordMetadataArray = [managedObjectContext executeFetchRequest:fetchRequest error:&contextError];
            if (fetchedRecordMetadataArray == nil) {
                *stop = YES;
                [contextError retain];
                succeed = NO;
                return;
            }
            
            for (OCCKRecordMetadata *recordMetadata in fetchedRecordMetadataArray) {
                NSManagedObjectID *objectID = [recordMetadata createObjectIDForLinkedRow];
                [results addObject:objectID];
                [objectID release];
            }
        }
    }];
    
    if (!succeed) {
        [results release];
        
        if (contextError == nil) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        } else if (error) {
            *error = [[contextError retain] autorelease];
        }
        
        results = nil;
    }
    
    [batchUpdateRequest release];
    return [results autorelease];
}

+ (void)enumerateRecordMetadataDictionariesMatchingObjectIDs:(NSArray<NSManagedObjectID *> *)objectIDs withProperties:(NSArray<NSString *> *)properties inStore:(NSSQLCore *)store withManagedObjectContext:(NSManagedObjectContext *)managedObjectContext block:(void (^ NS_NOESCAPE)(NSDictionary<NSString *,id> * _Nullable, NSError * _Nullable, BOOL * _Nonnull))block {
    /*
     x20 / sp + 0x20 = objectIDs
     sp + 0x18 = properties
     x22 = store
     sp + 0x28 = managedObjectContext
     x19 = block
     */
    
    // x21
    NSMutableDictionary<NSNumber *, NSMutableSet<NSNumber *> *> *entityIDToReferenceData64Set = [[NSMutableDictionary alloc] init];
    
    // x26
    for (NSManagedObjectID *objectID in objectIDs) {
        // x28
        NSSQLModel *model = store.model;
        NSSQLEntity * _Nullable entity = [OCSPIResolver _sqlEntityForEntityDescription:model x1:objectID.entity];
        uint _entityID;
        if (entity == nil) {
            _entityID = 0;
        } else {
            Ivar ivar = object_getInstanceVariable(entity, "_entityID", NULL);
            assert(ivar != NULL);
            _entityID = *(uint *)((uintptr_t)entity + ivar_getOffset(ivar));
        }
        // x27
        NSNumber *entityIDNumber = @(_entityID);
        // x26
        NSNumber *referenceData64Number = @([objectID _referenceData64]);
        
        // x28
        NSMutableSet<NSNumber *> *referenceData64Set = [entityIDToReferenceData64Set[entityIDNumber] retain];
        if (referenceData64Set == nil) {
            referenceData64Set = [[NSMutableSet alloc] init];
            entityIDToReferenceData64Set[entityIDNumber] = referenceData64Set;
        }
        [referenceData64Set addObject:referenceData64Number];
        [referenceData64Set release];
    }
    
    // x22
    NSMutableArray<NSString *> *array = [[NSMutableArray alloc] init];
    BOOL found = NO;
    
    // x26
    for (NSString *property in properties) {
        [array addObject:property];
        found = [property isEqualToString:@"objectID"] | found;
    }
    
    if (!found) [array addObject:@"objectID"];
    
    NSError * _Nullable error = nil;
    // x27
    for (NSNumber *entityIDNumber in entityIDToReferenceData64Set) @autoreleasepool {
        NSFetchRequest<OCCKRecordMetadata *> *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[OCCKRecordMetadata entityPath]];
        fetchRequest.resultType = NSDictionaryResultType;
        fetchRequest.fetchBatchSize = 1000;
        fetchRequest.propertiesToFetch = array;
        
        NSMutableSet<NSNumber *> *referenceData64Set = entityIDToReferenceData64Set[entityIDNumber];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"entityId = %@ AND entityPK IN %@", entityIDNumber, referenceData64Set];
        
        // sp + 0x78
        NSError * _Nullable _error = nil;
        // x27
        NSArray<NSDictionary<NSString *, id> *> * _Nullable dictionaries = [managedObjectContext executeFetchRequest:fetchRequest error:&_error];
        if (dictionaries == nil) {
            if (error == nil) error = [_error retain];
            continue;
        }
        
        // sp + 0x77
        BOOL stop = NO;
        for (NSDictionary<NSString *, id> *dictionary in dictionaries) {
            block(dictionary, nil, &stop);
            if (stop) break;
        }
        if (stop) break;
    }
    
    // 아무것도 안하는듯?
    [error autorelease];
    [entityIDToReferenceData64Set release];
    [array release];
}

- (CKRecordID *)createRecordID {
    // x19 = self
    
    CKRecordID * _Nullable result;
    if (self.recordZone == nil) {
        result = nil;
    } else {
        // x20
        CKRecordZoneID * _Nullable recordZoneID = [self.recordZone createRecordZoneID];
        if (recordZoneID == nil) {
            result = nil;
        } else {
            if (self.ckRecordName == nil) {
                result = nil;
            } else {
                // original : getCloudKitCKRecordIDClass
                result = [[CKRecordID alloc] initWithRecordName:self.ckRecordName zoneID:recordZoneID];
            }
        }
        [recordZoneID release];
    }
    
    if (result == nil) {
        os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: createRecordID called before the record has the necessary properties: %@\n", self);
        os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: createRecordID called before the record has the necessary properties: %@\n", self);
    }
    
    return result;
}

- (CKRecord *)createRecordFromSystemFields {
    // x21 = self
    
    // x19
    NSData * _Nullable ckRecordSystemFields = self.ckRecordSystemFields;
    if (ckRecordSystemFields == nil) {
        os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: NCKRecordMetadata: System fields record name doesn't match row: %@\n%@\n%@\n", self.ckRecordName, nil, self);
        os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: NCKRecordMetadata: System fields record name doesn't match row: %@\n%@\n%@\n", self.ckRecordName, nil, self);
        return nil;
    }
    
    // x19
    NSKeyedUnarchiver * _Nullable unarchiver = [[NSKeyedUnarchiver alloc] initForReadingFromData:ckRecordSystemFields error:NULL];
    // x20
    CKRecord *record = [[CKRecord alloc] initWithCoder:unarchiver];
    // x22
    NSString *ckRecordName = self.ckRecordName;
    
    if (![ckRecordName isEqualToString:record.recordID.recordName]) {
        os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: NCKRecordMetadata: System fields record name doesn't match row: %@\n%@\n%@\n", self.ckRecordName, record, self);
        os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: NCKRecordMetadata: System fields record name doesn't match row: %@\n%@\n%@\n", self.ckRecordName, record, self);
        [record release];
        [unarchiver finishDecoding];
        [unarchiver release];
        return nil;
    }
    
    if (![record.recordType hasPrefix:@"CD_"]) {
        os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: NSCKRecordMetadata: System fields record type doesn't match new schema: %@\n%@\n%@", self.ckRecordName, record.recordID, self);
        os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: NSCKRecordMetadata: System fields record type doesn't match new schema: %@\n%@\n%@", self.ckRecordName, record.recordID, self);
        [record release];
        [unarchiver finishDecoding];
        [unarchiver release];
        return nil;
    }
    
    [unarchiver finishDecoding];
    [unarchiver release];
    
    return record;
}

- (NSManagedObjectID *)createObjectIDForLinkedRow {
    // x19 = self
    // x21
    NSNumber *entityId = self.entityId;
    // x22
    NSNumber *entityPK = self.entityPK;
    
    return [OCCKRecordMetadata createObjectIDForEntityID:entityId primaryKey:entityPK inSQLCore:(NSSQLCore *)self.objectID.persistentStore];
}

- (NSData *)createEncodedMoveReceiptData:(NSError * _Nullable *)error {
    /*
     self = x19
     error = x20
     */
    // sp + 0x8
    NSError * _Nullable _error = nil;
    // x19
    NSData * _Nullable data;
    @autoreleasepool {
        // x22
        OCCKRecordMetadataReceiptArchive *archive = [[OCCKRecordMetadataReceiptArchive alloc] initWithReceiptsToEncode:self.moveReceipts];
        data = [[NSKeyedArchiver archivedDataWithRootObject:archive requiringSecureCoding:YES error:&_error] retain];
        
        if (data == nil) {
            [_error retain];
        }
        [archive release];
    }
    
    if (data != nil) {
        return [data autorelease];
    } else {
        if (_error == nil) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        } else {
            if (error) {
                *error = [[_error retain] autorelease];
            }
        }
        [_error release];
        return nil;
    }
}

- (BOOL)mergeMoveReceiptsWithData:(NSData *)data error:(NSError * _Nullable *)error {
    /*
     self = x21
     data = x22
     error = x23
     */
    // sp, #0x98
    NSError * _Nullable _error = nil;
    // x19
    NSPersistentStore *persistentStore = [self.objectID.persistentStore retain];
    // x20
    NSManagedObjectContext *managedObjectContext = [self.managedObjectContext retain];
    
    if (persistentStore == nil) {
        os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to merge move receipts before assigning a record metadata to a store: %@\n", self);
        os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to merge move receipts before assigning a record metadata to a store: %@\n", self);
    }
    
    BOOL result;
    @autoreleasepool {
        // x22
        OCCKRecordMetadataReceiptArchive * _Nullable receiptArchive = [[NSKeyedUnarchiver unarchivedObjectOfClass:[OCCKRecordMetadataReceiptArchive class] fromData:data error:&_error] retain];
        if (receiptArchive == nil) {
            result = NO;
            [_error retain];
        } else {
            /*
             persistentStore = sp + 0x8
             managedObjectContext = x19
             */
            // x23
            NSMutableSet<CKRecordID *> *recordIDs = [[NSMutableSet alloc] init];
            // x25
            NSSet<OCCKRecordZoneMoveReceipt *> *moveReceipts = self.moveReceipts;
            
            for (OCCKRecordZoneMoveReceipt *moveReceipt in moveReceipts) {
                // x27
                CKRecordID *recordID = [moveReceipt createRecordIDForMovedRecord];
                [recordIDs addObject:recordID];
                [recordID release];
            }
            
            /*
             __54-[NSCKRecordMetadata mergeMoveReceiptsWithData:error:]_block_invoke
             recordIDs = sp + 0x30 = x20 + 0x20
             managedObjectContext = sp + 0x38 = x20 + 0x28
             self = sp + 0x40 = x20 + 0x30
             persistentStore = sp + 0x48 = x20 + 0x38
             */
            [receiptArchive enumerateArchivedRecordIDsUsingBlock:^(CKRecordID * _Nonnull recordID, NSDate * _Nonnull movedAt) {
                /*
                 self(block) = x20
                 recordID = x19
                 movedAt = x22
                 */
                if ([recordIDs containsObject:recordID]) return;
                
                // x21
                OCCKRecordZoneMoveReceipt *moveReceipt = [NSEntityDescription insertNewObjectForEntityForName:[OCCKRecordZoneMoveReceipt entityPath] inManagedObjectContext:managedObjectContext];
                moveReceipt.recordMetadata = self;
                moveReceipt.movedAt = movedAt;
                moveReceipt.needsCloudDelete = NO;
                moveReceipt.zoneName = recordID.zoneID.zoneName;
                moveReceipt.ownerName = recordID.zoneID.ownerName;
                moveReceipt.recordName = recordID.recordName;
                
                [managedObjectContext assignObject:moveReceipt toPersistentStore:persistentStore];
                [recordIDs addObject:recordID];
            }];
            
            [recordIDs release];
            [receiptArchive release];
            result = YES;
        }
    }
    
    if (!result) {
        if (_error == nil) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        } else {
            if (error) {
                *error = [[_error retain] autorelease];
            }
        }
    }
    
    [persistentStore release];
    [_error release];
    [managedObjectContext release];
    return result;
}

@end
