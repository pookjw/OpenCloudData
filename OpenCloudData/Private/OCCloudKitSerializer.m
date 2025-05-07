//
//  OCCloudKitSerializer.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/12/25.
//

#import <OpenCloudData/OCCloudKitSerializer.h>
#import <OpenCloudData/OCSPIResolver.h>
#import <OpenCloudData/Log.h>
#import <OpenCloudData/OCCKRecordMetadata.h>
#import <OpenCloudData/OCCKRecordZoneMetadata.h>
#import <OpenCloudData/CKRecord+Private.h>
#import <OpenCloudData/NSPropertyDescription+Private.h>
#import <OpenCloudData/OCCloudKitSchemaGenerator.h>
#import <OpenCloudData/_PFRoutines.h>
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
    if (property.isTransient) return NO;
    
    BOOL boolValue = ((NSNumber *)[property.userInfo objectForKey:[OCSPIResolver NSCloudKitMirroringDelegateIgnoredPropertyKey]]).boolValue;
    if (boolValue) return NO;
    
    return YES;
}

+ (size_t)estimateByteSizeOfRecordID:(CKRecordID *)recordID {
    abort();
}

+ (CKRecordType)recordTypeForEntity:(NSEntityDescription *)entity {
    abort();
}

+ (BOOL)isMirroredRelationshipRecordType:(CKRecordType)recordType {
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
        id target;
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
            
            id target;
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
                
                BOOL flag; // 1 = <+1412>, 0 = <+1452>
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
                        // <+1832>
                        abort();
                    }
                }
                
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
        if (evaluatedObject.isTransient) return NO;
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
         */
        [objc_lookUpClass("_PFRoutines") wrapBlockInGuardedAutoreleasePool:^{
            /*
             self(block) = x19
             */
            // x21
            NSString *name = attribute.name;
            // x20
            NSString *key = [@"CD_" stringByAppendingString:attribute.name];
            id representativeValue = [representativeValues objectForKey:name];
            
            if ((attribute.attributeType == NSBinaryDataAttributeType) || (attribute.attributeType == NSTransformableAttributeType)) {
                // <+144>
                abort();
            }
        }];
    }
    
    /*
     _98-[PFCloudKitSerializer newCKRecordsFromObject:fullyMaterializeRecords:includeRelationships:error:]_block_invoke.25
     object = sp + 0xb0
     self = sp + 0xb8
     recordMetadata = sp + 0xc0
     recordID = sp + 0xc8
     zoneID = sp + 0xd0
     managedObjectContext = sp + 0xd8
     array_1 = sp + 0xe0
     record = sp + 0xe8
     _error = sp + 0xf8
     _succeed = sp + 0x100
     */
    [entity.relationshipsByName enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSRelationshipDescription * _Nonnull obj, BOOL * _Nonnull stop) {
#warning TODO
        abort();
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

- (OCCKRecordMetadata * _Nullable)getRecordMetadataForObject:(NSManagedObject *)managedObject inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct)) {
    abort();
}

+ (NSSet<NSManagedObjectID *> *)createSetOfObjectIDsRelatedToObject:(NSManagedObject *)object {
    abort();
}

+ (NSURL *)generateCKAssetFileURLForObjectInStore:(NSPersistentStore *)store {
    abort();
}

+ (BOOL)isVariableLengthAttributeType:(NSAttributeType)attributeType {
    abort();
}

+ (size_t)sizeOfVariableLengthAttribute:(NSAttributeDescription *)attribute withValue:(id)value {
    abort();
}

@end
