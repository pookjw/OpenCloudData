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
            if (error) {
                *error = [_error autorelease];
            }
        }
        
        return nil;
    }
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

@end
