//
//  OCCloudKitSerializer.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/12/25.
//

#import <OpenCloudData/OCCloudKitSerializer.h>
#import <OpenCloudData/OCSPIResolver.h>
#import <OpenCloudData/Log.h>
#import <OpenCloudData/OCCKRecordZoneMetadata.h>
#import <OpenCloudData/CKRecord+Private.h>
#import <OpenCloudData/NSPropertyDescription+Private.h>
#import <OpenCloudData/OCCloudKitSchemaGenerator.h>
#import <OpenCloudData/_PFRoutines.h>
#import <OpenCloudData/_PFExternalReferenceData.h>
#import <OpenCloudData/NSAttributeDescription+Private.h>
#import <OpenCloudData/_NSCloudKitDataFileBackedFuture.h>
#import <OpenCloudData/PFMirroredManyToManyRelationshipV2.h>
#import <OpenCloudData/OCCloudKitImportZoneContext.h>
#import <OpenCloudData/NSManagedObjectID+Private.h>
#import <OpenCloudData/_PFEvanescentData.h>
#import <OpenCloudData/CKEncryptedData.h>
#import <OpenCloudData/NSObject+NSKindOfAdditions.h>
#import <objc/runtime.h>

CK_EXTERN NSString * _Nullable CKDatabaseScopeString(CKDatabaseScope);

// 0xc60
static CKRecordZoneID *zoneID_1;
// 0xc68
static CKRecordZoneID *zoneID_2;

@implementation OCCloudKitSerializer

+ (void)initialize {
    if (self == [OCCloudKitSerializer class]) {
        static dispatch_once_t onceToken;
        /*
         __34+[PFCloudKitSerializer initialize]_block_invoke
         */
        dispatch_once(&onceToken, ^{
            [objc_lookUpClass("_PFRoutines") class];
        });
    }
}

+ (void)_invalidateStaticCaches {
    [zoneID_1 release];
    zoneID_1 = nil;
    [zoneID_2 release];
    zoneID_2 = nil;
}

+ (CKRecordZoneID *)defaultRecordZoneIDForDatabaseScope:(CKDatabaseScope)databaseScope {
    /*
     databaseScope = x19
     */
    
    /*
     __60+[PFCloudKitSerializer defaultRecordZoneIDForDatabaseScope:]_block_invoke
     */
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // original : getCloudKitCKRecordZoneIDClass, getCloudKitCKCurrentUserDefaultName
        zoneID_1 = [[CKRecordZoneID alloc] initWithZoneName:@"com.apple.coredata.cloudkit.zone" ownerName:CKCurrentUserDefaultName];
        // original : getCloudKitCKRecordZoneIDClass, getCloudKitCKRecordZoneDefaultName
        zoneID_2 = [[CKRecordZoneID alloc] initWithZoneName:CKRecordZoneDefaultName ownerName:CKCurrentUserDefaultName];
    });
    
    if (databaseScope == CKDatabaseScopePublic) {
        // <+80>
        return [zoneID_2 retain];
    } else if (databaseScope == CKDatabaseScopePrivate) {
        // <+68>
        return [zoneID_1 retain];
    } else {
        // <+128>
        os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Unable to provide a default CKRecordZoneID for database scope: %@\n", CKDatabaseScopeString(databaseScope));
        os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Unable to provide a default CKRecordZoneID for database scope: %@\n", CKDatabaseScopeString(databaseScope));
        return nil;
    }
}

+ (BOOL)shouldTrackProperty:(NSPropertyDescription *)property {
    if (property.transient) return NO;
    
    BOOL boolValue = ((NSNumber *)[property.userInfo objectForKey:[OCSPIResolver NSCloudKitMirroringDelegateIgnoredPropertyKey]]).boolValue;
    if (boolValue) return NO;
    
    return YES;
}

+ (size_t)estimateByteSizeOfRecordID:(CKRecordID *)recordID {
    /*
     recordID = x19
     */
    return recordID.zoneID.zoneName.length + recordID.recordName.length + 0x18;
}

+ (CKRecordType)recordTypeForEntity:(NSEntityDescription *)entity {
    /*
     entity = x20
     */
    BOOL _isImmutable;
    {
        if (entity == nil) {
            _isImmutable = NO;
        } else {
            Ivar ivar = object_getInstanceVariable(entity, "_isImmutable", NULL);
            assert(ivar != NULL);
            _isImmutable = *(BOOL *)((uintptr_t)entity + ivar_getOffset(ivar));
        }
    }
    
    // x21
    NSEntityDescription *targetEntity;
    if (_isImmutable) {
        assert(object_getInstanceVariable(entity, "_rootentity", (void **)&targetEntity) != NULL);
    } else {
        targetEntity = entity;
        while (YES) {
            NSEntityDescription *superentity = targetEntity.superentity;
            if (superentity != nil) {
                targetEntity = superentity;
            } else {
                break;
            }
        }
    }
    
    return [@"CD_" stringByAppendingString:targetEntity.name];
}

+ (BOOL)isMirroredRelationshipRecordType:(CKRecordType)recordType {
    /*
     recordType = x19
     */
    if ([recordType hasPrefix:[OCSPIResolver PFCloudKitMirroringDelegateToManyPrefix]]){
        return YES;
    }
    if ([recordType isEqualToString:@"CDMR"]) {
        return YES;
    }
    return NO;
}

+ (NSSet<NSManagedObjectID *> *)createSetOfObjectIDsRelatedToObject:(NSManagedObject *)object {
    /*
     object = x21
     */
    // x19
    NSMutableSet<NSManagedObjectID *> *set_1 = [[NSMutableSet alloc] init];
    // x20
    NSMutableArray<NSManagedObject *> *array = [[NSMutableArray alloc] initWithObjects:object, nil];
    // x21
    NSMutableSet<NSManagedObjectID *> *set_2 = [[NSMutableSet alloc] initWithObjects:object.objectID, nil];
    
    do {
        // x22 / sp + 0x30
        NSManagedObject *_object = [[array objectAtIndex:0] retain];
        [array removeObjectAtIndex:0];
        [set_1 addObject:_object.objectID];
        // sp + 0x28
        NSEntityDescription *_entity = _object.entity;
        
        @autoreleasepool {
            // x23
            for (NSString *name in _entity.relationshipsByName) @autoreleasepool {
                NSRelationshipDescription *relationship = [_entity.relationshipsByName objectForKey:name];
                // x25
                BOOL isToMany = relationship.isToMany;
                // x28
                id value = [_object valueForKey:name];
                
                if (isToMany) {
                    // <+364>
                    // x25
                    for (NSManagedObject *refObject in (NSSet *)value) {
                        if (!([set_1 containsObject:refObject.objectID]) && !([set_2 containsObject:refObject.objectID])) {
                            [array addObject:refObject];
                            [set_2 addObject:refObject.objectID];
                        }
                    }
                    // <+564>
                } else {
                    if (value != nil) {
                        // <+572>
                        NSManagedObject *refObject = (NSManagedObject *)value;
                        if (!([set_1 containsObject:refObject.objectID]) && !([set_2 containsObject:refObject.objectID])) {
                            [array addObject:refObject];
                            [set_2 addObject:refObject.objectID];
                        }
                    }
                }
            }
        }
        
        // x23
        NSManagedObjectContext *managedObjectContext = _object.managedObjectContext;
        [managedObjectContext refreshObject:_object mergeChanges:managedObjectContext.hasChanges];
        [_object release];
    } while (array.count != 0);
    
    [array release];
    [set_2 release];
    return set_1;
}

+ (NSURL *)generateCKAssetFileURLForObjectInStore:(NSPersistentStore *)store {
    /*
     store = x19
     */
    NSURL *storageURL = [OCCloudKitSerializer assetStorageDirectoryURLForStore:store];
    NSString *name = [NSString stringWithFormat:@"%@.fxd", [NSUUID UUID].UUIDString];
    return [storageURL URLByAppendingPathComponent:name isDirectory:NO];
}

+ (NSURL *)assetStorageDirectoryURLForStore:(NSPersistentStore *)store {
    /*
     store = x19
     */
    BOOL isInMemoryStore = [OCSPIResolver _PFRoutines__isInMemoryStore_:objc_lookUpClass("_PFRoutines") x1:store];
    if (isInMemoryStore) {
        // x21
        NSString *tempDir =  NSTemporaryDirectory();
        NSString *filePath = [[tempDir stringByAppendingPathComponent:store.identifier] stringByAppendingPathComponent:@"inMemory_store_ckAssets"];
        return [NSURL fileURLWithPath:filePath];
    }
    
    // x19
    NSURL *url_1 = store.URL;
    // x20
    NSString *name_1 = url_1.lastPathComponent.stringByDeletingPathExtension;
    // x19
    NSURL *url_2 = [url_1 URLByDeletingLastPathComponent];
    NSString *name_2 = [NSString stringWithFormat:@"%@_ckAssets", name_1];
    return [url_2 URLByAppendingPathComponent:name_2];
}

+ (BOOL)isVariableLengthAttributeType:(NSAttributeType)attributeType {
    switch (attributeType) {
        case NSStringAttributeType:
        case NSBinaryDataAttributeType:
        case NSURIAttributeType:
        case NSTransformableAttributeType:
        case NSCompositeAttributeType:
            return YES;
        default:
            return NO;
    }
}

+ (size_t)sizeOfVariableLengthAttribute:(NSAttributeDescription *)attribute withValue:(id _Nullable)value {
    /*
     attribute = x20
     value = x19
     */
    if (value == nil) {
        return 0;
    }
    
    NSAttributeType attributeType = attribute.attributeType;
    
    switch (attributeType) {
        case NSStringAttributeType:
        case NSURIAttributeType:
            return ((NSString *)value).length;
        case NSBinaryDataAttributeType:
        case NSTransformableAttributeType:
        case NSCompositeAttributeType:
        {
            if ([value isKindOfClass:objc_lookUpClass("_NSDataFileBackedFuture")]) {
                return ((_NSDataFileBackedFuture *)value).fileSize;
            } else {
                return ((NSData *)value).length;
            }
        }
        default:
            return 0;
    }
}

+ (NSString *)mtmKeyForObjectWithRecordName:(NSString *)recordName relatedToObjectWithRecordName:(NSString *)relatedToObjectWithRecordName byRelationship:(NSRelationshipDescription *)relationship withInverse:(NSRelationshipDescription *)inverseRelationship {
    /*
     recordName = x21
     relatedToObjectWithRecordName = x20
     relationship = x19
     inverseRelationship = x22
     */
    /*
     __111+[PFCloudKitSerializer mtmKeyForObjectWithRecordName:relatedToObjectWithRecordName:byRelationship:withInverse:]_block_invoke
     */
    // x22
    NSArray<NSRelationshipDescription *> *relationships = [@[relationship, inverseRelationship] sortedArrayUsingComparator:^NSComparisonResult(NSRelationshipDescription * _Nonnull obj1, NSRelationshipDescription* _Nonnull obj2) {
        /*
         obj1 = x20
         obj2 = x19
         */
        NSEntityDescription *entity_1 = obj1.entity;
        if (entity_1 == nil) {
            return NSOrderedSame;
        }
        
        BOOL _isImmutable_1;
        {
            Ivar ivar = object_getInstanceVariable(entity_1, "_isImmutable", NULL);
            assert(ivar != NULL);
            _isImmutable_1 = *(BOOL *)((uintptr_t)entity_1 + ivar_getOffset(ivar));
        }
        
        // x21
        NSEntityDescription *targetEntity_1;
        if (_isImmutable_1) {
            assert(object_getInstanceVariable(entity_1, "_rootentity", (void **)&targetEntity_1) != NULL);
        } else {
            targetEntity_1 = entity_1;
            while (YES) {
                NSEntityDescription *superentity = targetEntity_1.superentity;
                if (superentity != nil) {
                    targetEntity_1 = superentity;
                } else {
                    break;
                }
            }
        }
        
        
       NSEntityDescription *entity_2 = obj2.entity;
       if (entity_2 == nil) {
           return NSOrderedSame;
       }
       
       BOOL _isImmutable_2;
       {
           Ivar ivar = object_getInstanceVariable(entity_2, "_isImmutable", NULL);
           assert(ivar != NULL);
           _isImmutable_2 = *(BOOL *)((uintptr_t)entity_2 + ivar_getOffset(ivar));
       }
       
       // x22
       NSEntityDescription *targetEntity_2;
       if (_isImmutable_2) {
           assert(object_getInstanceVariable(entity_2, "_rootentity", (void **)&targetEntity_2) != NULL);
       } else {
           targetEntity_2 = entity_2;
           while (YES) {
               NSEntityDescription *superentity = targetEntity_2.superentity;
               if (superentity != nil) {
                   targetEntity_2 = superentity;
               } else {
                   break;
               }
           }
       }
        
        return [targetEntity_1.name compare:targetEntity_2.name options:NSCaseInsensitiveSearch];
    }];
    
    NSEntityDescription *firstRelationshipEntity = relationships[0].entity;
    // x24
    NSString * _Nullable firstName;
    if (firstRelationshipEntity != nil) {
        BOOL _isImmutable;
        {
            Ivar ivar = object_getInstanceVariable(firstRelationshipEntity, "_isImmutable", NULL);
            assert(ivar != NULL);
            _isImmutable = *(BOOL *)((uintptr_t)firstRelationshipEntity + ivar_getOffset(ivar));
        }
        
        // x24
        NSEntityDescription *targetEntityDescription;
        if (_isImmutable) {
            assert(object_getInstanceVariable(firstRelationshipEntity, "_rootentity", (void **)&targetEntityDescription) != NULL);
        } else {
            targetEntityDescription = firstRelationshipEntity;
            while (YES) {
                NSEntityDescription *superentity = targetEntityDescription.superentity;
                if (superentity != nil) {
                    targetEntityDescription = superentity;
                } else {
                    break;
                }
            }
        }
        
        firstName = targetEntityDescription.name;
    } else {
        firstName = nil;
    }
    
    // x24
    NSString *string_1 = [NSString stringWithFormat:@"%@%@_%@", [OCSPIResolver PFCloudKitMirroringDelegateToManyPrefix], firstName, relationships[0].name];
    // x23
    NSMutableArray *array = [[NSMutableArray alloc] init];
    // x19
    for (NSRelationshipDescription *_relationship in relationships) {
        if (relationship == _relationship) {
            [array addObject:recordName];
        } else {
            [array addObject:relatedToObjectWithRecordName];
        }
    }
    NSString *string_2 = [array componentsJoinedByString:@":"];
    NSString *string_3 = [NSString stringWithFormat:@"%@:%@", string_1, string_2];
    [array release];
    return string_3;
}

+ (NSString *)applyCDPrefixToName:(NSString *)name {
    return [@"CD_" stringByAppendingString:name];
}

+ (BOOL)isPrivateAttribute:(NSAttributeDescription *)attribute {
    abort();
}

- (instancetype)initWithMirroringOptions:(OCCloudKitMirroringDelegateOptions *)mirroringOptions metadataCache:(OCCloudKitMetadataCache *)metadataCache recordNamePrefix:(NSString *)recordNamePrefix {
    /*
     mirroringOptions = x21
     metadataCache = x19
     recordNamePrefix = x22
     */
    if (self = [super init]) {
        _manyToManyRecordNameToRecord = [[NSMutableDictionary alloc] init];
        _recordNamePrefix = [recordNamePrefix copy];
        _mirroringOptions = [mirroringOptions retain];
        _writtenAssetURLs = [[NSMutableArray alloc] init];
        _metadataCache = [metadataCache retain];
    }
    
    return self;
}

- (void)dealloc {
    [_manyToManyRecordNameToRecord release];
    _manyToManyRecordNameToRecord = nil;
    
    [_recordNamePrefix release];
    _recordNamePrefix = nil;
    
    [_mirroringOptions release];
    _mirroringOptions = nil;
    
    [_writtenAssetURLs release];
    _writtenAssetURLs = nil;
    
    [_metadataCache release];
    _metadataCache = nil;
    
    // _recordZone은 없음
    
    [super dealloc];
}

- (NSArray<CKRecord *> *)newCKRecordsFromObject:(NSManagedObject *)object fullyMaterializeRecords:(BOOL)fullyMaterializeRecords includeRelationships:(BOOL)includeRelationships error:(NSError * _Nullable *)error {
    /*
     self = sp, #0x80
     object = x24
     includeRelationships = x19
     fullyMaterializeRecords = sp, #0x8c
     error = sp, #0x30
     */
    // sp, #0x240
    __block BOOL _succeed = YES;
    // sp, #0x210
    __block NSError * _Nullable _error = nil;
    // sp, #0x48
    NSManagedObjectContext *managedObjectContext = [object.managedObjectContext retain];
    // sp, #0x58
    NSMutableArray *array_1 = [[NSMutableArray alloc] init];
    // sp, #0x50
    NSEntityDescription *entity = [object.entity retain];
    // sp, #0x40
    NSSQLCore *persistentStore = (NSSQLCore *)[object.objectID.persistentStore retain];
    // sp, #0x60
    OCCKRecordMetadata * _Nullable recordMetadata = [self getRecordMetadataForObject:object inManagedObjectContext:object.managedObjectContext error:&_error];
    
    if (recordMetadata == nil) {
        _succeed = NO;
        [_error retain];
        
        if (_error == nil) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        } else {
            if (error != NULL) {
                *error = [[_error retain] autorelease];
            }
        }
        [array_1 release];
        [managedObjectContext release];
        [entity release];
        [_error release];
        [persistentStore release];
        return nil;
    }
    
    // sp, #0x68
    CKRecordZoneID *zoneID = [recordMetadata.recordZone createRecordZoneID];
    
    // sp, #0x78
    CKRecord * _Nullable record;
    if (recordMetadata.encodedRecord.length != 0) {
        OCCloudKitArchivingUtilities *archivingUtilities;
        {
            OCCloudKitMirroringDelegateOptions * _Nullable mirroringOptions = self->_mirroringOptions;
            if (mirroringOptions == nil) {
                archivingUtilities = nil;
            } else {
                archivingUtilities = mirroringOptions->_archivingUtilities;
            }
        }
        record = [archivingUtilities recordFromEncodedData:recordMetadata.encodedRecord error:&_error];
        if (record == nil) {
            _succeed = NO;
            [_error retain];
            
            if (_error == nil) {
                os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
                os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            } else {
                if (error != NULL) {
                    *error = [[_error retain] autorelease];
                }
            }
            
            [array_1 release];
            [managedObjectContext release];
            [entity release];
            [_error release];
            [persistentStore release];
            return nil;
        }
    } else {
        record = [recordMetadata createRecordFromSystemFields];
    }
    
    // sp, #0x70
    CKRecordID *recordID;
    if (record != nil) {
        recordID = [record.recordID retain];
    } else {
        // <+668>
        // x19
        recordID = [recordMetadata createRecordID];
        // original : getCloudKitCKRecordClass
        record = [[CKRecord alloc] initWithRecordType:[OCCloudKitSerializer recordTypeForEntity:entity] recordID:recordID];
    }
    
    // <+800>
    // x19
    NSString *entityName = entity.name;
    // x20
    NSString *entityNameKey = [@"CD_" stringByAppendingString:@"entityName"];
    
    {
        id<CKRecordKeyValueSetting> target;
        if (self->_mirroringOptions.useDeviceToDeviceEncryption) {
            target = record.encryptedValues;
        } else {
            target = record;
        }
        [target setObject:entityName forKey:entityNameKey];
    }
    
    if ((recordMetadata.moveReceipts.count != 0) || fullyMaterializeRecords) {
        // <+980>
        if (!fullyMaterializeRecords) {
            // x19
            NSData *moveReceiptData = [@"Some sample move receipt data." dataUsingEncoding:NSUTF8StringEncoding];
            // x20
            NSString *moveReceiptKey = [@"CD_" stringByAppendingString:@"moveReceipt"];
            
            id<CKRecordKeyValueSetting> target;
            if (self->_mirroringOptions.useDeviceToDeviceEncryption) {
                target = record.encryptedValues;
            } else {
                target = record;
            }
            [target setObject:moveReceiptData forKey:moveReceiptKey];
            
            NSURL *url = [OCCloudKitSerializer generateCKAssetFileURLForObjectInStore:object.objectID.persistentStore];
            
            BOOL result = [moveReceiptData writeToURL:url options:0 error:&_error];
            if (!result) {
                // <+1580>
                os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData+CloudKit: %s(%d): Failed to write CKAsset data for '%@' on '%@' backing record '%@'.\n%@", __func__, __LINE__, @"moveReceipt", object.objectID, record, _error);
                _succeed = NO;
                [_error retain];
                // <+2148>
            } else {
                [self->_writtenAssetURLs addObject:url];
                
                // original : getCloudKitCKAssetClass
                // x19
                CKAsset *ckAsset = [[[CKAsset alloc] initWithFileURL:url] autorelease];
                [record setObject:ckAsset forKey:[[@"CD_" stringByAppendingString:@"moveReceipt"] stringByAppendingString:@"_ckAsset"]];
            }
            // fin
        } else {
            // <+1280>
            // x22
            NSData *encodedMoveReceiptData = [recordMetadata createEncodedMoveReceiptData:&_error];
            
            if (encodedMoveReceiptData == nil) {
                _succeed = NO;
                [_error retain];
                [encodedMoveReceiptData release];
                // <+2148>
            } else {
                // x19
                size_t ckAssetThresholdBytes = self->_mirroringOptions.ckAssetThresholdBytes.unsignedIntegerValue;
                
                BOOL flag; // 1 = <+1412>/<+1832>, 0 = <+1452>
                if (ckAssetThresholdBytes == 0) {
                    flag = YES;
                } else {
                    if (encodedMoveReceiptData.length > ckAssetThresholdBytes) {
                        flag = NO;
                    } else {
                        flag = YES;
                    }
                }
                
                if (flag) {
                    // <+1412>
                    ckAssetThresholdBytes = encodedMoveReceiptData.length;
                    
                    if ((ckAssetThresholdBytes + record.size) < 0xaae61) {
                        flag = YES;
                    } else {
                        flag = NO;
                    }
                }
                
                if (!flag) {
                    // <+1452>
                    // x19
                    NSURL *url = [OCCloudKitSerializer generateCKAssetFileURLForObjectInStore:object.objectID.persistentStore];
                    BOOL result = [encodedMoveReceiptData writeToURL:url options:0 error:&_error];
                    
                    if (!result) {
                        // <+1580>
                        os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData+CloudKit: %s(%d): Failed to write CKAsset data for '%@' on '%@' backing record '%@'.\n%@", __func__, __LINE__, @"moveReceipt", object.objectID, record, _error);
                        _succeed = NO;
                        [_error retain];
                        [encodedMoveReceiptData release];
                        // <+2148>
                    }
                    
                    [self->_writtenAssetURLs addObject:url];
                    // original : getCloudKitCKAssetClass
                    CKAsset *ckAsset = [[[CKAsset alloc] initWithFileURL:url] autorelease];
                    [record setObject:ckAsset forKey: [[@"CD_" stringByAppendingString:@"moveReceipt"] stringByAppendingString:@"_ckAsset"]];
                    [encodedMoveReceiptData release];
                    // <+2148>
                } else {
                    // <+1832>
                    // x19
                    NSString *name = [@"CD_" stringByAppendingString:@"moveReceipt"];
                    
                    id<CKRecordKeyValueSetting> target;
                    if (self->_mirroringOptions.useDeviceToDeviceEncryption) {
                        target = record.encryptedValues;
                    } else {
                        target = record;
                    }
                    [target setObject:encodedMoveReceiptData forKey:name];
                    [encodedMoveReceiptData release];
                    // <+2148>
                }
                // fin
            }
            // fin
        }
        // fin
    }
    
    // <+2148>
    // x21
    NSMutableArray<NSAttributeDescription *> *attributes = [[NSMutableArray alloc] initWithArray:entity.attributesByName.allValues];
    // ___98-[PFCloudKitSerializer newCKRecordsFromObject:fullyMaterializeRecords:includeRelationships:error:]_block_invoke
    [attributes filterUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSAttributeDescription * _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        /*
         evaluatedObject = x19
         */
        if (evaluatedObject.transient) return NO;
        return !evaluatedObject.isReadOnly;
    }]];
    // x22
    NSMutableDictionary<NSString *, id> *representativeValues = [[NSMutableDictionary alloc] initWithCapacity:attributes.count];
    
    // x27
    for (NSAttributeDescription *attribute in attributes) @autoreleasepool {
        @try {
            // x19
            NSString *name = attribute.name;
            // x23
            id _Nullable value = [object valueForKey:name];
            
            // x23
            id _Nullable representativeValue;
            if ((attribute.attributeType == NSTransformableAttributeType) || (attribute.attributeType == NSCompositeAttributeType)) {
                // <+2496>
                if (value == nil) {
                    if (!fullyMaterializeRecords) {
                        continue;
                    } else {
                        representativeValue = [OCCloudKitSchemaGenerator representativeValueFor:value];
                    }
                } else {
                    representativeValue = [[OCSPIResolver _PFRoutines_retainedEncodeObjectValue_forTransformableAttribute_:objc_lookUpClass("_PFRoutines") x1:value x2:attribute] autorelease];
                }
            } else if (attribute.attributeType == NSUUIDAttributeType) {
                representativeValue = ((NSUUID *)value).UUIDString;
            } else if (attribute.attributeType == NSURIAttributeType) {
                representativeValue = ((NSURL *)value).absoluteString;
            } else {
                representativeValue = value;
            }
            
            // <+2612>
            [representativeValues setObject:representativeValue forKey:name];
        } @catch (NSException *exception) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData+CloudKit: %s(%d): Failed to generate records for object: %@ due to exception: %@", __func__, __LINE__, object, exception);
            _succeed = NO;
#warning TODO Error Leak
            _error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:134420 userInfo:@{@"NSUnderlyingException": exception}];
            // break 안함
        }
    }
    
    // <+2992>
    if (!_succeed) {
        if (_error == nil) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: Object serialization failed but did not set an error: %@", object);
        }
        // <+3956>
        [attributes release];
        [representativeValues release];
        [recordID release];
        [record release];
        [zoneID release];
        
        if (_error == nil) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        } else {
            if (error != NULL) {
                *error = [[_error retain] autorelease];
            }
        }
        
        [array_1 release];
        [managedObjectContext release];
        [_error release];
        [entity release];
        [persistentStore release];
        return nil;
    }
    
    /*
     __98-[PFCloudKitSerializer newCKRecordsFromObject:fullyMaterializeRecords:includeRelationships:error:]_block_invoke.18
     representativeValues = sp + 0x1c8 = x20 + 0x20
     */
    [attributes sortUsingComparator:^NSComparisonResult(NSAttributeDescription * _Nonnull obj1, NSAttributeDescription * _Nonnull obj2) {
        /*
         self(block) = x20
         obj1 = x21
         obj2 = x19
         */
        // w22
        BOOL isVariableLengthAttributeType_1 = [OCCloudKitSerializer isVariableLengthAttributeType:obj1.attributeType];
        BOOL isVariableLengthAttributeType_2 = [OCCloudKitSerializer isVariableLengthAttributeType:obj2.attributeType];
        
        if (!isVariableLengthAttributeType_1 || isVariableLengthAttributeType_2) {
            if (isVariableLengthAttributeType_1 && isVariableLengthAttributeType_2) {
                id value_1 = [representativeValues objectForKey:obj1.name];
                size_t size_1 = [OCCloudKitSerializer sizeOfVariableLengthAttribute:obj1 withValue:value_1];
                id value_2 = [representativeValues objectForKey:obj2.name];
                size_t size_2 = [OCCloudKitSerializer sizeOfVariableLengthAttribute:obj2 withValue:value_2];
                
                return [@(size_1) compare:@(size_2)];
            } else {
                return isVariableLengthAttributeType_2 ? NSOrderedAscending : NSOrderedSame;
            }
        } else {
            return NSOrderedDescending;
        }
    }];
    
    // representativeValues = x28
    // record = x25
    
    // x20
    for (NSAttributeDescription *attribute in attributes) {
        if (![OCCloudKitSerializer shouldTrackProperty:attribute]) continue;
        
        /*
         __98-[PFCloudKitSerializer newCKRecordsFromObject:fullyMaterializeRecords:includeRelationships:error:]_block_invoke_2
         attribute = sp + 0x120 = x19 + 0x20
         representativeValues = sp + 0x128 = x19 + 0x28
         self = sp + 0x130 = x19 + 0x30
         record = sp + 0x138 = x19 + 0x38
         object = sp + 0x140 = x19 + 0x40
         _succeed = sp + 0x148 = x19 + 0x48
         _error = sp + 0x150 = x19 + 0x50
         fullyMaterializeRecords = sp + 0x158 = x19 + 0x58
         */
        [objc_lookUpClass("_PFRoutines") wrapBlockInGuardedAutoreleasePool:^{
            /*
             self(block) = x19
             */
            // x21
            NSString *name = attribute.name;
            // x20
            NSString *key = [@"CD_" stringByAppendingString:name];
            // x22
            id _Nullable representativeValue = [representativeValues objectForKey:name];
            
            // x23
            id _Nullable x23;
            
            if ((attribute.attributeType == NSBinaryDataAttributeType) || (attribute.attributeType == NSTransformableAttributeType)) {
                // <+144>
                // x23
                size_t ckAssetThresholdBytes = self->_mirroringOptions.ckAssetThresholdBytes.unsignedIntegerValue;
                // x24
                NSString *key_2 = [[@"CD_" stringByAppendingString:name] stringByAppendingString:@"_ckAsset"];
                
                if (representativeValue == nil) {
                    [record setObject:nil forKey:key_2];
                    x23 = nil;
                    // <+1916>
                } else {
                    // x22
                    NSData *_data;
                    if ([representativeValue isKindOfClass:objc_lookUpClass("_PFExternalReferenceData")]) {
                        _data = [NSData dataWithBytes:((_PFExternalReferenceData *)representativeValue).bytes length:(NSUInteger)((_PFExternalReferenceData *)representativeValue).length];
                    } else {
                        _data = representativeValue;
                    }
                    
                    BOOL flag = NO; // 1 = <+1100> / 0 = <+444>
                    if (!attribute.isFileBackedFuture && (ckAssetThresholdBytes == 0) && !fullyMaterializeRecords) {
                        // <+328>
                        if ((record.size + _data.length) <= 0xaae60) {
                            flag = YES;
                        }
                        // fin
                    }
                    
                    // <+368>
                    if (!attribute.isFileBackedFuture && (_data.length < ckAssetThresholdBytes) && !fullyMaterializeRecords) {
                        // <+404>
                        if ((record.size + _data.length) <= 0xaae60) {
                            flag = YES;
                        }
                        // fin
                    }
                    
                    if (!flag) {
                        // <+444>
                        if (fullyMaterializeRecords) {
                            id<CKRecordKeyValueSetting> target;
                            if ([self shouldEncryptValueForAttribute:attribute]) {
                                target = record;
                            } else {
                                target = record.encryptedValues;
                            }
                            [target setObject:_data forKey:key];
                            x23 = _data;
                        } else {
                            x23 = nil;
                        }
                        
                        // <+836>
                        // x26
                        NSURL *toURL = [OCCloudKitSerializer generateCKAssetFileURLForObjectInStore:object.objectID.persistentStore];
                        // sp + 0x8
                        NSError * _Nullable __error = nil;
                        
                        if (attribute.isFileBackedFuture) {
                            // x25
                            NSURL * _Nullable fromURL = [((_NSDataFileBackedFuture *)_data).fileURL retain];
                            if (fromURL == nil) {
                                [fromURL release];
                                return;
                            }
                            
                            BOOL result = [NSFileManager.defaultManager copyItemAtURL:fromURL toURL:toURL error:&__error];
                            if (!result) {
                                // <+1336>
                                os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData+CloudKit: %s(%d): Failed to copy CKAsset data for '%@' on '%@' backing record '%@'.\n%@", __func__, __LINE__, name, object.objectID, record, __error);
                                [fromURL release];
                                // error 방출 없음
                                return;
                            }
                            
                            [self->_writtenAssetURLs addObject:toURL];
                            // original : getCloudKitCKAssetClass
                            CKAsset *ckAsset = [[[CKAsset alloc] initWithFileURL:toURL] autorelease];
                            [record setObject:ckAsset forKey:key_2];
                            // <+1012>
                            x23 = [OCSPIResolver _NSDataFileBackedFuture__storeMetadata:(_NSDataFileBackedFuture *)_data];
                            [fromURL release];
                        } else {
                            // <+1028>
                            BOOL result = [_data writeToURL:toURL options:0 error:&__error];
                            if (!result) {
                                // <+1124>
                                os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData+CloudKit: %s(%d): Failed to copy CKAsset data for '%@' on '%@' backing record '%@'.\n%@", __func__, __LINE__, name, object.objectID, record, __error);
                                _succeed = NO;
                                _error = [__error retain];
                                // <+1916>
                            } else {
                                [self->_writtenAssetURLs addObject:toURL];
                                // original : getCloudKitCKAssetClass
                                CKAsset *ckAsset = [[[CKAsset alloc] initWithFileURL:toURL] autorelease];
                                [record setObject:ckAsset forKey:key_2];
                                // <+1916>
                            }
                            // fin
                        }
                        // fin
                    } else {
                        // <+1100>
                        [record setObject:nil forKey:key_2];
                        x23 = representativeValue;
                        // <+1916>
                    }
                    // fin
                }
                // <+1916>
            } else if ((attribute.attributeType == NSStringAttributeType) || (attribute.attributeType == NSURIAttributeType)) {
                // <+568>
                // x23
                size_t ckAssetThresholdBytes = self->_mirroringOptions.ckAssetThresholdBytes.unsignedIntegerValue;
                // x24
                NSString *key_2 = [[@"CD_" stringByAppendingString:name] stringByAppendingString:@"_ckAsset"];
                
                if (representativeValue != nil) {
                    BOOL flag = NO; // 1 = <+1100> / 0 = <+704>/<+768>
                    if ((ckAssetThresholdBytes == 0) && !fullyMaterializeRecords) {
                        if ((record.size + ((NSString *)representativeValue).length) <= 0xaae60) {
                            flag = YES;
                        }
                    }
                    
                    if (!flag) {
                        // <+704>
                        if ((((NSString *)representativeValue).length > ckAssetThresholdBytes) && !fullyMaterializeRecords) {
                            if ((record.size + ((NSString *)representativeValue).length) <= 0xaae60) {
                                flag = YES;
                            }
                        }
                    }
                    
                    if (!flag) {
                      // <+768>
                        if (fullyMaterializeRecords) {
                            // <+776>
                            id<CKRecordKeyValueSetting> target;
                            if ([self shouldEncryptValueForAttribute:attribute]) {
                                target = record;
                            } else {
                                target = record.encryptedValues;
                            }
                            [target setObject:representativeValue forKey:key];
                            x23 = representativeValue;
                        } else {
                            x23 = nil;
                        }
                        
                        // <+1540>
                        // x25
                        NSURL *url = [OCCloudKitSerializer generateCKAssetFileURLForObjectInStore:object.objectID.persistentStore];
                        NSError * _Nullable __error = nil;
                        NSData *__data = [((NSString *)representativeValue) dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
                        BOOL result = [__data writeToURL:url options:0 error:&__error];
                        
                        if (!result) {
                            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData+CloudKit: %s(%d): Failed to write CKAsset data for '%@' on '%@' backing record '%@'.\n%@", __func__, __LINE__, name, object.objectID, record.recordID, __error);
                            _succeed = NO;
                            _error = [__error retain];
                            // <+1916>
                        } else {
                            [self->_writtenAssetURLs addObject:url];
                            // original : getCloudKitCKAssetClass
                            CKAsset *ckAsset = [[[CKAsset alloc] initWithFileURL:url] autorelease];
                            [record setObject:ckAsset forKey:key_2];
                            // <+1916>
                        }
                    } else {
                        // <+1100>
                        [record setObject:nil forKey:key_2];
                        x23 = representativeValue;
                        // <+1916>
                    }
                } else {
                    // <+1296>
                    id<CKRecordKeyValueSetting> target;
                    if ([self shouldEncryptValueForAttribute:attribute]) {
                        target = record;
                    } else {
                        target = record.encryptedValues;
                    }
                    [target setObject:nil forKey:key_2];
                    x23 = nil;
                    // <+1916>
                }
            } else {
                // <+1116>
                x23 = representativeValue;
                // <+1916>
            }
            
            // <+1916>
            id<CKRecordKeyValueSetting> target;
            if ([self shouldEncryptValueForAttribute:attribute]) {
                target = record;
            } else {
                target = record.encryptedValues;
            }
            [target setObject:x23 forKey:key];
        }];
    }
    
    /*
     __98-[PFCloudKitSerializer newCKRecordsFromObject:fullyMaterializeRecords:includeRelationships:error:]_block_invoke.25
     object = sp + 0xb0 = x21 + 0x20
     self = sp + 0xb8 = x21 + 0x28
     recordMetadata = sp + 0xc0 = x21 + 0x30
     recordID = sp + 0xc8 = x21 + 0x38
     zoneID = sp + 0xd0 = x21 + 0x40
     managedObjectContext = sp + 0xd8 = x21 + 0x48
     array_1 = sp + 0xe0 = x21 + 0x50
     record = sp + 0xe8 = x21 + 0x58
     _error = sp + 0xf8 = x21 + 0x60
     _succeed = sp + 0x100 = x21 + 0x68
     */
    [entity.relationshipsByName enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull name, NSRelationshipDescription * _Nonnull relationship, BOOL * _Nonnull stop) {
        /*
         self(block) = x21
         name = x23 = sp + 0x20
         relationship = x24 = sp + 0x48
         stop = x22 = sp + 0x18
         */
        
        if (![OCCloudKitSerializer shouldTrackProperty:relationship]) return;
        
        // sp + 0x28
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        // sp + 0x58
        NSRelationshipDescription *inverseRelationship = relationship.inverseRelationship;
        
        if (!relationship.isToMany || !inverseRelationship.isToMany) {
            // <+1884>
            if (relationship.isToMany) {
                // <+2128>
                [pool release];
                return;
            }
            // x20
            NSManagedObject *childRef = [object valueForKey:name];
            
            OCCKRecordMetadata * _Nullable _recordMetadata = [self getRecordMetadataForObject:childRef inManagedObjectContext:childRef.managedObjectContext error:&_error];
            if (_recordMetadata == nil) {
                _succeed = NO;
                [_error retain];
                [pool release];
                return;
            }
            
            // self = x22
            // x19
            NSString *ckRecordName = _recordMetadata.ckRecordName;
            // x20
            NSString *key = [@"CD_" stringByAppendingString:name];
            
            id<CKRecordKeyValueSetting> target;
            if (self->_mirroringOptions.useDeviceToDeviceEncryption) {
                target = record.encryptedValues;
            } else {
                target = record;
            }
            [target setObject:ckRecordName forKey:key];
            
            // <+2128>
            [pool release];
            return;
        }
        
        // sp + 0x38
        NSSet<NSManagedObject *> *refObjects = [object valueForKey:name];
        // sp + 0x40
        NSMutableSet *mtmKeySet = [[NSMutableSet alloc] init];
        
        // x25
        for (NSManagedObject *refObject in refObjects) @autoreleasepool {
            // <+328>
            // x19
            OCCKRecordMetadata * _Nullable _recordMetadata = [self getRecordMetadataForObject:refObject inManagedObjectContext:object.managedObjectContext error:&_error];
            if (recordMetadata == nil) {
                _succeed = NO;
                [_error retain];
                break;
            }
            // x23
            NSString *mtmKey = [OCCloudKitSerializer mtmKeyForObjectWithRecordName:recordMetadata.ckRecordName relatedToObjectWithRecordName:_recordMetadata.ckRecordName byRelationship:relationship withInverse:inverseRelationship];
            [mtmKeySet addObject:mtmKey];
            
            // x20
            OCCKMirroredRelationship * _Nullable mirroredRelationship;
            OCCloudKitMetadataCache * _Nullable metadataCache = self->_metadataCache;
            // w26
            BOOL flag;
            if (metadataCache != nil) {
                mirroredRelationship = [[metadataCache->_zoneIDToMtmKeyToMirroredRelationship objectForKey:recordID.zoneID] objectForKey:mtmKey];
                flag = NO;
            } else {
                mirroredRelationship = nil;
                flag = YES;
            }
            
            if (mirroredRelationship != nil) {
                BOOL isUploaded = mirroredRelationship.isUploaded.boolValue;
                if (isUploaded) {
                    break;
                }
            }
            
            // <+512>
            // x27
            CKRecord * _Nullable _record = [[self->_manyToManyRecordNameToRecord objectForKey:mtmKey] retain];
            if (_record != nil) {
                [_record release];
                break;
            }
            
            // <+544>
            // x20
            NSString * _Nullable ckRecordID = mirroredRelationship.ckRecordID;
            if (ckRecordID.length == 0) {
                ckRecordID = [[NSUUID UUID] UUIDString];
            }
            // original : getCloudKitCKRecordIDClass
            // x22
            CKRecordID *recordID_1 = [[CKRecordID alloc] initWithRecordName:ckRecordID zoneID:zoneID];
            // sp + 0x30
            CKRecordID *recordID_2 = [recordMetadata createRecordID];
            // x20
            CKRecordID *recordID_3 = [_recordMetadata createRecordID];
            // x25
            PFMirroredManyToManyRelationshipV2 *pfRelationship = [[objc_lookUpClass("PFMirroredManyToManyRelationshipV2") alloc] initWithRecordID:recordID_1 forRecordWithID:recordID_2 relatedToRecordWithID:recordID_3 byRelationship:relationship withInverse:refObject.entity.relationshipsByName[inverseRelationship.name] andType:0];
            
            if (flag) {
                // x26
                OCCKMirroredRelationship *_mirroredRelationship = [OCCKMirroredRelationship insertMirroredRelationshipForManyToMany:pfRelationship inZoneWithMetadata:recordMetadata.recordZone inStore:object.objectID.persistentStore withManagedObjectContext:managedObjectContext];
                _mirroredRelationship.isUploaded = @NO;
                _mirroredRelationship.needsDelete = @NO;
                _mirroredRelationship.isPending = @NO;
            }
            
            // <+864>
            if (!([recordID_1.zoneID isEqual:recordID_2.zoneID]) || !([recordID_1.zoneID isEqual:recordID_3.zoneID])) {
                os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Serializer is attempting to link relationships across zones: %@ - %@ / %@\n", recordID_1, recordID, recordID_3);
                os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Serializer is attempting to link relationships across zones: %@ - %@ / %@\n", recordID_1, recordID, recordID_3);
            }
            
            // <+984>
            // original : getCloudKitCKRecordClass
            // x27
            _record = [[CKRecord alloc] initWithRecordType:@"CDMR" recordID:recordID_1];
            [array_1 addObject:_record];
            
            id<CKRecordKeyValueSetting> target;
            if (self->_mirroringOptions.useDeviceToDeviceEncryption) {
                target = _record.encryptedValueStore;
            } else {
                target = _record;
            }
            
            [pfRelationship populateRecordValues:target];
            [self->_manyToManyRecordNameToRecord setObject:_record forKey:mtmKey];
            
            [pfRelationship release];
            [recordID_1 release];
            [recordID_2 release];
            [recordID_3 release];
            [_record release];
        }
        
        // <+1348>
        if (!_succeed) {
            *stop = YES;
        }
        
        // x19
        NSMutableDictionary<NSManagedObjectID *, NSMutableDictionary<NSString *, NSMutableSet<NSString *> *> *> *objectIDToRelationshipNameToExistingMTMKeys;
        {
            // x19
            OCCloudKitMetadataCache * _Nullable metadataCache = self->_metadataCache;
            if (metadataCache == nil) {
                objectIDToRelationshipNameToExistingMTMKeys = nil;
            } else {
                objectIDToRelationshipNameToExistingMTMKeys = metadataCache->_objectIDToRelationshipNameToExistingMTMKeys;
            }
        }
        
        // x19
        NSMutableSet<NSString *> *oldMTMKeys = [[[objectIDToRelationshipNameToExistingMTMKeys objectForKey:object.objectID] objectForKey:name] mutableCopy];
        [oldMTMKeys minusSet:mtmKeySet];
        // x27
        for (NSString *oldKey in oldMTMKeys) {
            // x23
            OCCloudKitMetadataCache * _Nullable metadataCache = self->_metadataCache;
            // x28
            OCCKMirroredRelationship * _Nullable __mirroredRelationship;
            if (metadataCache == nil) {
                __mirroredRelationship = nil;
            } else {
                __mirroredRelationship = [[metadataCache->_zoneIDToMtmKeyToMirroredRelationship objectForKey:recordID.zoneID] objectForKey:oldKey];
            }
            
            if ((__mirroredRelationship == nil) || !([__mirroredRelationship isKindOfClass:[OCCKMirroredRelationship class]])) {
                os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Failed to look up cached mirrored relationship for mtmKey: %@\n", oldKey);
                os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Failed to look up cached mirrored relationship for mtmKey: %@\n", oldKey);
            }
            
            __mirroredRelationship.needsDelete = @YES;
            __mirroredRelationship.isUploaded = @NO;
            __mirroredRelationship.isPending = @NO;
        }
        
        [oldMTMKeys release];
        [mtmKeySet release];
        [pool release];
    }];
    
    if (record == nil) {
        os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: Supposedly serialization succeeded but there's no record: %@", _error);
    } else {
        os_log_with_type(_OCLogGetLogStream(0x11), OS_LOG_TYPE_DEFAULT, "OpenCloudData+CloudKit: %s(%d): Serializer has finished creating record: %@\nModified Fields: %@", __func__, __LINE__, record, self->_mirroringOptions.useDeviceToDeviceEncryption ? record.encryptedValueStore.changedKeys : record.changedKeys);
        [array_1 addObject:record];
    }
    
    [attributes release];
    [representativeValues release];
    [recordID release];
    [record release];
    [zoneID release];
    [managedObjectContext release];
    [_error release];
    [entity release];
    [persistentStore release];
    return array_1;
}

- (OCCKRecordMetadata * _Nullable)getRecordMetadataForObject:(NSManagedObject *)managedObject inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable * _Nullable)error {
    /*
     self = x21
     managedObject = x20
     managedObjectContext = x23
     error = x19
     */
    // sp + 0x8
    NSError * _Nullable _error = nil;
    OCCloudKitMetadataCache * _Nullable metadataCache = self->_metadataCache;
    
    // x22
    OCCKRecordMetadata * _Nullable recordMetadata;
    if (metadataCache != nil) {
        NSMutableDictionary<NSManagedObjectID *, OCCKRecordMetadata *> *objectIDToRecordMetadata = metadataCache->_objectIDToRecordMetadata;
        recordMetadata = [objectIDToRecordMetadata objectForKey:managedObject.objectID];
    } else {
        recordMetadata = nil;
    }
    
    if (recordMetadata == nil) {
        recordMetadata = [OCCKRecordMetadata metadataForObject:managedObject inManagedObjectContext:managedObjectContext error:&_error];
    }
    
    if (recordMetadata != nil) {
        [metadataCache registerRecordMetadata:recordMetadata forObject:managedObject];
        return recordMetadata;
    }
    
    // <+204>
    if (_error != nil) {
        os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData+CloudKit: %s(%d): Failed to get a metadata zone: %@", __func__, __LINE__, _error);
        if (error != NULL) {
            *error = _error;
        }
        return nil;
    }
    
    // x23
    CKRecordZoneID *zoneID = [OCCloudKitSerializer defaultRecordZoneIDForDatabaseScope:self->_mirroringOptions.databaseScope];
    recordMetadata = [OCCKRecordMetadata insertMetadataForObject:managedObject setRecordName:self->_mirroringOptions.preserveLegacyRecordMetadataBehavior inZoneWithID:zoneID recordNamePrefix:self->_recordNamePrefix error:&_error];
    recordMetadata.needsUpload = YES;
    [zoneID release];
    
    if (recordMetadata != nil) {
        [metadataCache registerRecordMetadata:recordMetadata forObject:managedObject];
        return recordMetadata;
    } else {
        os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData+CloudKit: %s(%d): Failed to get a metadata zone: %@", __func__, __LINE__, _error);
        if (_error == nil) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        } else {
            if (error != NULL) {
                *error = _error;
            }
        }
        return nil;
    }
}

- (BOOL)shouldEncryptValueForAttribute:(NSAttributeDescription *)attribute {
    /*
     attribute = x19
     */
    if (self->_mirroringOptions.useDeviceToDeviceEncryption) return YES;
    
    NSNumber * _Nullable number = (NSNumber *)[attribute.userInfo objectForKey:[OCSPIResolver NSPersistentCloudKitContainerEncryptedAttributeKey]];
    if (number != nil) return number.boolValue;
    
    return attribute.allowsCloudEncryption;
}

- (BOOL)applyUpdatedRecords:(NSArray<CKRecord *> *)updatedRecords deletedRecordIDs:(NSDictionary<NSString *,NSArray<CKRecordID *> *> *)deletedRecordIDs toStore:(NSSQLCore *)store inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext onlyUpdatingAttributes:(NSDictionary<NSString *, NSArray<NSAttributeDescription *> *> *)onlyUpdatingAttributes andRelationships:(NSDictionary<NSString *, NSArray<NSRelationshipDescription *> *> *)relationships madeChanges:(BOOL *)madeChanges error:(NSError * _Nullable *)error {
    // x29, #-0x60
    __block BOOL _succeed = YES;
    // sp, #0x70
    __block NSError * _Nullable _error = nil;
    
    /*
     __150-[PFCloudKitSerializer applyUpdatedRecords:deletedRecordIDs:toStore:inManagedObjectContext:onlyUpdatingAttributes:andRelationships:madeChanges:error:]_block_invoke
     managedObjectContext = sp + 0x20 = x19 + 0x20
     self = sp + 0x28 = x19 + 0x28
     store = sp + 0x30 = x19 + 0x30
     updatedRecords = sp + 0x38 = x19 + 0x38
     deletedRecordIDs = sp + 0x40 = x19 + 0x40
     onlyUpdatingAttributes = sp + 0x48 = x19 + 0x48
     relationships = sp + 0x50 = x19 + 0x50
     _error = sp + 0x58 = x19 + 0x58
     _succeed = sp + 0x60 = x19 + 0x60
     madeChanges = sp + 0x68 = x19 + 0x68
     */
    [managedObjectContext performBlockAndWait:^{
        /*
         self(block) = x19 / sp, #0x158
         */
        // sp + 0x78
        NSManagedObjectModel *managedObjectModel = [managedObjectContext.persistentStoreCoordinator.managedObjectModel retain];
        // sp + 0xa8
        NSMutableDictionary<NSString *, NSEntityDescription *> *entityDescriptions = [[NSMutableDictionary alloc] init];
        // sp + 0x98
        NSObject<OCCloudKitSerializerDelegate> * _Nullable delegate = [self->_delegate retain];
        
        /*
         __150-[PFCloudKitSerializer applyUpdatedRecords:deletedRecordIDs:toStore:inManagedObjectContext:onlyUpdatingAttributes:andRelationships:madeChanges:error:]_block_invoke_2
         entityDescriptions = sp + 0x408
         */
        [[managedObjectModel entitiesForConfiguration:store.configurationName] enumerateObjectsUsingBlock:^(NSEntityDescription * _Nonnull entity, NSUInteger idx, BOOL * _Nonnull stop) {
            [entityDescriptions setObject:entity forKey:entity.name];
        }];
        // x19 // sp, #0x108
        OCCloudKitImportZoneContext *importZoneContext = [[OCCloudKitImportZoneContext alloc] initWithUpdatedRecords:updatedRecords deletedRecordTypeToRecordIDs:deletedRecordIDs options:self->_mirroringOptions fileBackedFuturesDirectory:store.fileBackedFuturesDirectory];
        
        BOOL result = [importZoneContext initializeCachesWithManagedObjectContext:managedObjectContext andObservedStore:store error:&_error];
        if (!result) {
            [_error retain];
            _succeed = NO;
            [managedObjectModel release];
            [entityDescriptions release];
            [importZoneContext release];
            [delegate release];
            return;
        }
        
        // <+320>
        NSArray<CKRecord *> *modifiedRecords;
        if (importZoneContext == nil) {
            modifiedRecords = nil;
        } else {
            modifiedRecords = importZoneContext->_modifiedRecords;
        }
        // sp + 0x118
        for (CKRecord *modifiedRecord in modifiedRecords) @autoreleasepool {
            // x19
            NSString *key = @"entityName";
            if (![modifiedRecord.recordType hasPrefix:@"CD_"]) {
                key = [@"CD_" stringByAppendingString:@"entityName"];
            }
            // self = x20
            id<CKRecordKeyValueSetting> target;
            if (self->_mirroringOptions.useDeviceToDeviceEncryption) {
                if ([key hasSuffix:@"_ckAsset"]) {
                    // name은 entityName 또는 CD_entityName일 것이기에 안 불릴 것. 아마 무언가 inline된 것 같음
                    target = modifiedRecord;
                } else {
                    target = modifiedRecord.encryptedValues;
                }
            } else {
                target = modifiedRecord;
            }
            
            // <+712>
            // x19
            NSString *name = [target objectForKey:key];
            
            if (name == nil) {
                name = modifiedRecord.recordType;
                if ([key hasPrefix:@"CD_"]) {
                    name = [name substringFromIndex:@"CD_".length];
                }
            }
            NSEntityDescription *entityDescription = [entityDescriptions objectForKey:name];
            if (entityDescription == nil) {
                // <+1040>
                os_log_with_type(_OCLogGetLogStream(0x11), OS_LOG_TYPE_DEFAULT, "OpenCloudData+CloudKit: %s(%d): Skipping record because its entity '%@' is no longer in the managed object model's configured entities: %@\n%@", __func__, __LINE__, name, modifiedRecord, entityDescriptions.allKeys);
                continue;
            }
            // sp + 0xf8
            OCCKRecordMetadata * _Nullable recordMetadata = [OCCKRecordMetadata metadataForRecord:modifiedRecord inManagedObjectContext:managedObjectContext fromStore:store error:&_error];
            if (recordMetadata == nil) {
                // <+1228>
                _succeed = NO;
                [_error retain];
                break;
            }
            // x20
            OCCKRecordZoneMetadata * _Nullable recordZoneMetadata = recordMetadata.recordZone;
            if (recordZoneMetadata == nil) {
                // <+880>
                OCCloudKitMetadataCache * _Nullable metadataCache = self->_metadataCache;
                if (metadataCache == nil) {
                    recordZoneMetadata = nil;
                } else {
                    recordZoneMetadata = [metadataCache->_recordZoneIDToZoneMetadata objectForKey:modifiedRecord.recordID.zoneID];
                }
                
                if (metadataCache == nil) {
                    recordZoneMetadata = [OCCKRecordZoneMetadata zoneMetadataForZoneID:modifiedRecord.recordID.zoneID inDatabaseWithScope:self->_mirroringOptions.databaseScope forStore:store inContext:managedObjectContext error:&_error];
                    if (recordMetadata == nil) {
                        // <+1264>
                        _succeed = NO;
                        [_error retain];
                        break;
                    }
                    
                    // <+1016>
                    [self->_metadataCache cacheZoneMetadata:recordZoneMetadata];
                    // <+1300>
                }
                // <+1300>
                recordMetadata.recordZone = recordZoneMetadata;
                // <+1336>
            }
            
            // <+1336>
            CKRecordID *modifiedRecordID = modifiedRecord.recordID;
            
            NSMutableDictionary<CKRecordType, NSMutableDictionary<CKRecordID *, NSManagedObjectID *> *> * _Nullable recordTypeToRecordIDToObjectID;
            {
                if (importZoneContext == nil) {
                    recordTypeToRecordIDToObjectID = nil;
                } else {
                    recordTypeToRecordIDToObjectID = importZoneContext->_recordTypeToRecordIDToObjectID;
                }
            }
            
            // sp + 0x140
            NSManagedObject * _Nullable managedObject = nil;
            if (recordTypeToRecordIDToObjectID != nil) {
                // modifiedRecordID = x20
                // x20
                NSManagedObjectID * _Nullable objectID = [[recordTypeToRecordIDToObjectID objectForKey:name] objectForKey:modifiedRecordID];
                if (objectID != nil) {
                    managedObject = [managedObjectContext objectWithID:objectID];
                    // x19
                    NSSQLModel *model = store.model;
                    NSSQLEntity * _Nullable sqlEntity = [OCSPIResolver _sqlEntityForEntityDescription:model x1:objectID.entity];
                    // <+1472>
                    uint _entityID;
                    {
                        if (sqlEntity == nil) {
                            _entityID = 0;
                        } else {
                            Ivar ivar = object_getInstanceVariable(sqlEntity, "_entityID", NULL);
                            assert(ivar != NULL);
                            _entityID = *(uint *)((uintptr_t)sqlEntity + ivar_getOffset(ivar));
                        }
                    }
                    
                    if ((recordMetadata.entityId.longValue != _entityID) || ([objectID _referenceData64] != recordMetadata.entityPK.integerValue)) {
                        // <+1536>
                        os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Record metadata doesn't match row: %@\n%@", objectID, recordMetadata);
                        os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Record metadata doesn't match row: %@\n%@", objectID, recordMetadata);
                    }
                    // <1704>
                }
            }
            
            if (managedObject == nil) {
                // <+1656>
                managedObject = [NSEntityDescription insertNewObjectForEntityForName:name inManagedObjectContext:managedObjectContext];
                [importZoneContext registerObject:managedObject forInsertedRecord:modifiedRecord withMetadata:recordMetadata];
            }
            
            // <+1704>
            // x20
            NSArray<NSAttributeDescription *> * _Nullable _onlyUpdatingAttributes;
            if (onlyUpdatingAttributes != nil) {
                _onlyUpdatingAttributes = [onlyUpdatingAttributes objectForKey:managedObject.entity.name];
                if (_onlyUpdatingAttributes == nil) {
                    _onlyUpdatingAttributes = @[];
                }
            } else {
                _onlyUpdatingAttributes = nil;
            }
            // sp + 0x120
            NSArray * _Nullable _relationships;
            if (relationships != nil) {
                _relationships = [relationships objectForKey:managedObject.entity.name];
                if (_relationships == nil) {
                    _relationships = @[];
                }
            } else {
                _relationships = nil;
            }
            
            BOOL result = [self updateAttributes:_onlyUpdatingAttributes andRelationships:_relationships onManagedObject:managedObject fromRecord:modifiedRecord withRecordMetadata:recordMetadata importContext:importZoneContext error:&_error];
            abort();
        }
        abort();
    }];
    
    if (!_succeed) {
        if (_error == nil) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        } else {
            if (error != NULL) {
                *error = [[_error retain] autorelease];
            }
        }
    }
    [_error release];
    return _succeed;
}

- (BOOL)updateAttributes:(NSArray<NSAttributeDescription *> *)attributes andRelationships:(NSArray<NSRelationshipDescription *> *)relationships onManagedObject:(NSManagedObject *)managedObject fromRecord:(CKRecord *)record withRecordMetadata:(OCCKRecordMetadata *)recordMetadata importContext:(OCCloudKitImportZoneContext *)importContext error:(NSError * _Nullable *)error {
    // inlined from __150-[PFCloudKitSerializer applyUpdatedRecords:deletedRecordIDs:toStore:inManagedObjectContext:onlyUpdatingAttributes:andRelationships:madeChanges:error:]_block_invoke <+1828>~<+7232>
    /*
     self = sp + 0x130
     attributes = x20
     relationships = sp + 0x120
     managedObject = sp + 0x140
     record = sp + 0x118
     recordMetadata = sp + 0xf8
     importContext = sp + 0x108
     _error = x21
     */
    
    if (managedObject.isInserted && self->_mirroringOptions.preserveLegacyRecordMetadataBehavior && ([managedObject.entity.attributesByName objectForKey:[OCSPIResolver NSCKRecordIDAttributeName]] != nil)) {
        [managedObject setValue:record.recordID.recordName forKey:[OCSPIResolver NSCKRecordIDAttributeName]];
    }
    
    // sp, #0x498
    NSError * _Nullable _error = nil;
    
    // <+1952>
    OCCloudKitArchivingUtilities * _Nullable archivingUtilities;
    {
        OCCloudKitMirroringDelegateOptions * _Nullable mirroringOptions = self->_mirroringOptions;
        if (mirroringOptions == nil) {
            archivingUtilities = nil;
        } else {
            archivingUtilities = mirroringOptions->_archivingUtilities;
        }
    }
    // x19
    NSData * _Nullable encodedRecord = [archivingUtilities encodeRecord:record error:&_error];
    if (encodedRecord != nil) {
        recordMetadata.encodedRecord = encodedRecord;
        recordMetadata.ckRecordSystemFields = nil;
    }
    [encodedRecord release];
    // sp, #0x104
    BOOL hasCDPrefix = [record.recordType hasPrefix:@"CD_"];
    
    if (encodedRecord == nil) {
        if (_error == nil) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        } else {
            // null 확인 없음
            *error = _error;
        }
        return NO;
    }
    
    // <+2044>
    if (attributes == nil) {
        attributes = managedObject.entity.attributesByName.allValues;
    }
    // x27
    for (NSAttributeDescription *attributeDescription in attributes) {
        if (!([OCCloudKitSerializer isPrivateAttribute:attributeDescription]) && !attributeDescription.transient && attributeDescription.isReadOnly && !(((NSNumber *)[attributeDescription.userInfo objectForKey:[OCSPIResolver NSCloudKitMirroringDelegateIgnoredPropertyKey]]).boolValue)) {
            // <+2244>
            // x24
            NSString *_name_1 = attributeDescription.name;
            // x20
            NSString *_name_2 = attributeDescription.name;
            if (hasCDPrefix) {
                _name_2 = [@"CD_" stringByAppendingString:_name_1];
            }
            
            // <+2316>
            id<CKRecordKeyValueSetting> target = record;
            if ([self shouldEncryptValueForAttribute:attributeDescription]) {
                if (![_name_2 hasPrefix:@"_ckAsset"]) {
                    target = record.encryptedValues;
                }
            }
            
            // <+2400>
            // x20
            id value = [target objectForKey:_name_2];
            // x22
            id _Nullable resultValue = [value retain];
            if (value != nil) {
                // sp + 0x110
                NSObject<OCCloudKitSerializerDelegate> * _Nullable delegate = [self->_delegate retain];
                
                if ((attributeDescription.attributeType == NSBinaryDataAttributeType) || (attributeDescription.attributeType == NSTransformableAttributeType) || (attributeDescription.attributeType == NSCompositeAttributeType)) {
                    // <+2504>
                    if (attributeDescription.isFileBackedFuture) {
                        // original : getCloudKitCKAssetClass
                        if ([value isKindOfClass:[CKAsset class]]) {
                            // <+2556>
                            // x23
                            CKAsset * _Nullable _ckAsset = [value retain];
                            // x20
                            NSString *_name_3;
                            if (hasCDPrefix) {
                                _name_3 = [@"CD_" stringByAppendingString:_name_1];
                            } else {
                                _name_3 = _name_1;
                            }
                            
                            id<CKRecordKeyValueSetting> target = record;
                            if ([self shouldEncryptValueForAttribute:attributeDescription]) {
                                if (![_name_3 hasPrefix:@"_ckAsset"]) {
                                    target = record.encryptedValues;
                                }
                            }
                            // x26
                            id _value_1 = [[target objectForKey:_name_3] retain];
                            
                            if (_value_1 != nil) {
                                // <+3300>
                                if (_ckAsset != nil)  {
                                    // x20
                                    NSURL * _Nullable safeSaveURL = [delegate cloudKitSerializer:self safeSaveURLForAsset:_ckAsset];
                                    if (safeSaveURL == nil) {
                                        // <+4172>
                                        abort();
                                    }
                                    
                                    NSURL * _Nullable fileBackedFuturesDirectory;
                                    {
                                        if (importContext == nil) {
                                            fileBackedFuturesDirectory = nil;
                                        } else {
                                            fileBackedFuturesDirectory = importContext->_fileBackedFuturesDirectory;
                                        }
                                    }
                                    // x20
                                    _NSCloudKitDataFileBackedFuture *futureData = [[objc_lookUpClass("_NSCloudKitDataFileBackedFuture") alloc] initWithStoreMetadata:_value_1 directory:fileBackedFuturesDirectory originalFileURL:safeSaveURL];
                                    // <+4224>
                                    // fin
                                } else {
                                    // <+3844>
                                    NSURL * _Nullable fileBackedFuturesDirectory;
                                    {
                                        if (importContext == nil) {
                                            fileBackedFuturesDirectory = nil;
                                        } else {
                                            fileBackedFuturesDirectory = importContext->_fileBackedFuturesDirectory;
                                        }
                                    }
                                    // x20
                                    _NSCloudKitDataFileBackedFuture *futureData = [[objc_lookUpClass("_NSCloudKitDataFileBackedFuture") alloc] initWithStoreMetadata:_value_1 directory:fileBackedFuturesDirectory];
                                    // <+4224>
                                    // fin
                                }
                                // <+4224>
                                abort();
                            } else {
                                // <+4328>
                                abort();
                            }
                            
                            abort();
                        } else {
                            // <+3196>
                            abort();
                        }
                        abort();
                    } else {
                        // <+3100>
                        // original : getCloudKitCKAssetClass
                        if ([value isKindOfClass:[CKAsset class]]) {
                            // x25
                            NSURL * _Nullable safeSaveURL = [delegate cloudKitSerializer:self safeSaveURLForAsset:value];
                            // x23 = value
                            // x25
                            _PFEvanescentData * _Nullable evanescentData = [[objc_lookUpClass("_PFEvanescentData") alloc] initWithURL:safeSaveURL];
                            if (evanescentData == nil) {
                                // <+3940>
                                abort();
                            }
                            
                            [value release];
                            resultValue = evanescentData;
                            // x22 = evanescentData
                            // <+4104>
                            // fin
                        } else if ([value isKindOfClass:[CKEncryptedData class]]) {
                            // <+3404>
                            [value release];
                            // x25
                            NSData *_data = [((CKEncryptedData *)value).data retain];
                            resultValue = _data;
                            os_log_with_type(_OCLogGetLogStream(0x11), OS_LOG_TYPE_DEFAULT, "OpenCloudData+CloudKit: %s(%d): %@ encountered CKEncryptedData blob on record (%@): %@", __func__, __LINE__, self, _name_1, record);
                            // <+4104>
                            // fin
                        } else {
                            // <+3656>
                            if ([value isNSData__]) {
                                // <+4104>
                            } else {
                                os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData+CloudKit: %s(%d): Unknown value class (%@) for attribute:\n%@", __func__, __LINE__, [value class], attributeDescription);
                                // <+4104>
                            }
                            // fin
                        }
                        // <+4104>
                        abort();
                    }
                    abort();
                } else if (attributeDescription.attributeType == NSUUIDAttributeType) {
                    // <+3620>
                    [value release];
                    NSUUID * _Nullable uuid = [[NSUUID alloc] initWithUUIDString:value];
                    if (uuid == nil) {
                        os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData+CloudKit: %s(%d): Failed to initialize NSUUID from CKRecord with value: %@\n%@", __func__, __LINE__, value, record);
                    } else {
                        resultValue = uuid;
                    }
                    // <+4336>
                    // fin
                } else {
                    // <+4732>
                    abort();
                }
                abort();
            } else {
                // <+2688>
                if ([OCCloudKitSerializer isVariableLengthAttributeType:attributeDescription.attributeType]) {
                    // <+2728>
                    NSString *key = _name_1;
                    if (hasCDPrefix) {
                        key = [@"CD_" stringByAppendingString:_name_1];
                    }
                    key = [key stringByAppendingString:@"_ckAsset"];
                    
                    // x20
                    CKAsset * _Nullable _ckAsset = [record objectForKey:key];
                    // <+2836>
                    
                    if (_ckAsset == nil) {
                        // <+2840>
                        // fin
                    } else {
                        // <+2440>
                        abort();
                    }
                    // fin
                }
                // <+2840>
                if (!attributeDescription.transient) {
                    // x20
                    OCCloudKitMetadataCache * _Nullable metadataCache = self->_metadataCache;
                    NSManagedObjectID *objectID = managedObject.objectID;
                    if (metadataCache == nil) {
                        [managedObject setValue:attributeDescription.defaultValue forKey:_name_1];
                    } else if (![[metadataCache->_objectIDToChangedPropertyKeys objectForKey:objectID] containsObject:_name_1]) {
                        [managedObject setValue:attributeDescription.defaultValue forKey:_name_1];
                    } else {
                        os_log_with_type(_OCLogGetLogStream(0x11), OS_LOG_TYPE_DEFAULT, "OpenCloudData+CloudKit: %s(%d): Importer is rejecting updated value for '%@' on '%@' because there are pending local edits that haven't been exported yet.", __func__, __LINE__, _name_1, managedObject.objectID);
                    }
                }
                // <+3916>
                [resultValue release];
                resultValue = nil;
                // <+4692>
                abort();
            }
            abort();
        }
        // <+4716>
        abort();
    }
    // <+6228>
    abort();
}

@end
