//
//  OCCloudKitImportZoneContext.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/6/25.
//

#import "OpenCloudData/Private/Import/OCCloudKitImportZoneContext.h"
#import "OpenCloudData/SPI/OCSPIResolver.h"
#import "OpenCloudData/Private/MirroredRelationship/OCMirroredRelationship.h"
#import "OpenCloudData/Private/Log.h"
#import "OpenCloudData/Private/Model/OCCKMirroredRelationship.h"
#import "OpenCloudData/Private/MirroredRelationship/OCMirroredOneToManyRelationship.h"
#import "OpenCloudData/Private/MirroredRelationship/OCMirroredManyToManyRelationship.h"
#import "OpenCloudData/Private/MirroredRelationship/OCMirroredManyToManyRelationshipV2.h"
#import "OpenCloudData/Private/OCCloudKitSerializer.h"
#import "OpenCloudData/Private/Model/OCCKImportOperation.h"
#import "OpenCloudData/SPI/CoreData/NSManagedObjectID+Private.h"
#include <objc/runtime.h>

@implementation OCCloudKitImportZoneContext

- (instancetype)initWithUpdatedRecords:(NSArray<CKRecord *> *)updatedRecords deletedRecordTypeToRecordIDs:(NSDictionary<NSString *,NSArray<CKRecordID *> *> *)deletedRecordTypeToRecordIDs options:(OCCloudKitMirroringDelegateOptions *)options fileBackedFuturesDirectory:(NSString *)fileBackedFuturesDirectory {
    /*
     updatedRecords = x23
     deletedRecordTypeToRecordIDs = x22
     options = x21
     fileBackedFuturesDirectory = x19
     */
    
    if (self = [super init]) {
        // self = x20
        _updatedRecords = [updatedRecords retain];
        _deletedRecordTypeToRecordID = [deletedRecordTypeToRecordIDs retain];
        _recordTypeToUnresolvedRecordIDs = [[NSMutableDictionary alloc] init];
        _mirroringOptions = [options retain];
        
        if (fileBackedFuturesDirectory != nil) {
            if (fileBackedFuturesDirectory.length != 0) {
                _fileBackedFuturesDirectory = [[NSURL alloc] initFileURLWithPath:fileBackedFuturesDirectory];
            }
        }
        
        _metadatasToLink = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)dealloc {
    [_updatedRecords release];
    _updatedRecords = nil;
    
    [_deletedRecordTypeToRecordID release];
    _deletedRecordTypeToRecordID = nil;
    
    [_deletedObjectIDs release];
    _deletedObjectIDs = nil;
    
    [_deletedMirroredRelationshipRecordIDs release];
    _deletedMirroredRelationshipRecordIDs = nil;
    
    [_deletedShareRecordIDs release];
    
    [_modifiedRecords release];
    _modifiedRecords = nil;
    
    [_updatedRelationships release];
    _updatedRelationships = nil;
    
    [_deletedRelationships release];
    _deletedRelationships = nil;
    
    [_recordTypeToRecordIDToObjectID release];
    _recordTypeToRecordIDToObjectID = nil;
    
    [_recordTypeToUnresolvedRecordIDs release];
    _recordTypeToUnresolvedRecordIDs = nil;
    
    [_importOperations release];
    _importOperations = nil;
    
    [_mirroringOptions release];
    _mirroringOptions = nil;
    
    [_fileBackedFuturesDirectory release];
    _fileBackedFuturesDirectory = nil;
    
    [_metadatasToLink release];
    _metadatasToLink = nil;
    
    [super dealloc];
}

- (BOOL)initializeCachesWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext andObservedStore:(NSSQLCore *)observedStore error:(NSError * _Nullable *)error {
    /*
     self = sp, #0x100
     managedObjectConrext = x20
     observedStore = x22
     error = x21
     */
    // sp + 0x418
    NSError * _Nullable _error = nil;
    // sp + 0x28
    NSMutableArray<CKRecord *> *modifiedRecords = [[NSMutableArray alloc] init];
    // sp + 0x110
    NSMutableDictionary<CKRecordType, NSMutableArray<CKRecordID *> *> *recordTypeToRecordID = [[NSMutableDictionary alloc] init];
    // sp + 0xf8
    NSMutableArray<OCMirroredManyToManyRelationship *> *deletedRelationships = [[NSMutableArray alloc] init];
    // sp + 0x20
    NSMutableArray<OCMirroredManyToManyRelationship *> *updatedRelationships = [[NSMutableArray alloc] init];
    // sp + 0x18
    NSMutableSet<CKRecordID *> *deletedMirroredRelationshipRecordIDs = [[NSMutableSet alloc] init];
    // sp + 0x78
    NSMutableSet<CKRecordID *> *deletedShareRecordIDs = [[NSMutableSet alloc] init];
    // sp + 0x98
    NSMutableDictionary<CKRecordType, NSMutableSet<CKRecordID *> *> *dictionary_2 = [[NSMutableDictionary alloc] init];
    // managedObjectContext = sp + 0xd8
    // sp + 0x108
    NSManagedObjectModel *managedObjectModel = [managedObjectContext.persistentStoreCoordinator.managedObjectModel retain];
    // sp + 0x118
    NSMutableSet<NSString *> *entityNames = [[NSMutableSet alloc] init];
    // observedStore = sp + 0xb0
    
    // x19
    NSArray<NSEntityDescription *> *entities;
    if (observedStore.configurationName != nil) {
        entities = [managedObjectModel entitiesForConfiguration:observedStore.configurationName];
    } else {
        entities = managedObjectModel.entitiesByName.allValues;
    }
    
    // error = sp + 0x10
    
    for (NSEntityDescription *entity in entities) {
        [entityNames addObject:entity.name];
    }
    
    // x25
    for (CKRecord *record in _updatedRecords) @autoreleasepool {
        // <+576>
        // x23
        NSString *recordType_1 = record.recordType;
        // x28
        NSString *recordType_2 = record.recordType;
        
        if ([recordType_2 hasPrefix:@"CD_"]) {
            recordType_2 = [recordType_2 substringFromIndex:@"CD_".length];
        }
        if (([recordType_1 hasPrefix:[OCSPIResolver PFCloudKitMirroringDelegateToManyPrefix]]) || ([recordType_1 isEqualToString:@"CDMR"])) {
            // <+684>
            os_log_with_type(_OCLogGetLogStream(0x11), OS_LOG_TYPE_DEFAULT, "OpenCloudData+CloudKit: %s(%d): Updating relationship described by record: %@", __func__, __LINE__, record);
            
            // x23
            id<CKRecordKeyValueSetting> target = record;
            if (self->_mirroringOptions.useDeviceToDeviceEncryption) {
                target = record.encryptedValues;
            }
            
            BOOL result = [OCMirroredRelationship isValidMirroredRelationshipRecord:record values:target];
            if (!result) {
                // <+1084>
                os_log_with_type(_OCLogGetLogStream(0x11), OS_LOG_TYPE_DEFAULT, "OpenCloudData+CloudKit: %s(%d): %@: Skipping invalid mirrored relationship record: %@", __func__, __LINE__, self, record);
                // <+1892>
                continue;
            } else {
                // <+924>
                // x23
                OCMirroredManyToManyRelationship * _Nullable mirroredRelationship = [OCMirroredRelationship mirroredRelationshipWithManyToManyRecord:record values:target andManagedObjectModel:managedObjectModel];
                
                if (mirroredRelationship == nil) {
                    // <+1540>
                    os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData+CloudKit: %s(%d): %@: Failed to serialize many to many relationship from record: %@", __func__, __LINE__, self, record);
                    // <+1892>
                    continue;
                }
                
                NSRelationshipDescription * _Nullable relationshipDescription = mirroredRelationship->_relationshipDescription;
                if (relationshipDescription == nil) {
                    // <+1372>
                    os_log_with_type(_OCLogGetLogStream(0x11), OS_LOG_TYPE_DEFAULT, "OpenCloudData+CloudKit: %s(%d): %@ - Skipping mirrored relationship for unknown relationships: %@", __func__, __LINE__, self, record);
                    // <+1892>
                    continue;
                }
                
                NSRelationshipDescription * _Nullable inverseRelationshipDescription = mirroredRelationship->_inverseRelationshipDescription;
                if (inverseRelationshipDescription == nil) {
                    // <+1372>
                    os_log_with_type(_OCLogGetLogStream(0x11), OS_LOG_TYPE_DEFAULT, "OpenCloudData+CloudKit: %s(%d): %@ - Skipping mirrored relationship for unknown relationships: %@", __func__, __LINE__, self, record);
                    // <+1892>
                    continue;
                }
                
                [updatedRelationships addObject:mirroredRelationship];
                
                /*
                 __95-[PFCloudKitImportZoneContext initializeCachesWithManagedObjectContext:andObservedStore:error:]_block_invoke
                 entityNames = sp + 0x370 = x19 + 0x20
                 dictionary_1 = sp + 0x378 = x19 + 0x28
                 self = sp + 0x380 = x19 + 0x30
                 record = sp + 0x388 = x19 + 0x38
                 */
                [mirroredRelationship.recordTypeToRecordID enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull recordType, NSArray<CKRecordID *> * _Nonnull recordIDArray, BOOL * _Nonnull stop) {
                    /*
                     self = x19
                     recordType = x21
                     recordIDArray = x20
                     */
                    
                    if (![entityNames containsObject:recordType]) {
                        os_log_with_type(_OCLogGetLogStream(0x11), OS_LOG_TYPE_DEFAULT, "OpenCloudData+CloudKit: %s(%d): %@ - Skipping unknown updated relationship record: %@", __func__, __LINE__, self, record);
                        return;
                    }
                    
                    // sp, #0x8
                    NSMutableArray<CKRecordID *> *array = [[recordTypeToRecordID objectForKey:recordType] retain];
                    if (array == nil) {
                        [recordTypeToRecordID setObject:array forKey:recordType];
                    }
                    [array addObjectsFromArray:recordIDArray];
                    [array release];
                }];
                // <+1892>
            }
        } else if ([entityNames containsObject:recordType_2]) {
            // <+1276>
            // x28
            NSMutableArray<CKRecordID *> *array = [[recordTypeToRecordID objectForKey:recordType_1] retain];
            if (array == nil) {
                array = [[NSMutableArray alloc] init];
                [recordTypeToRecordID setObject:array forKey:recordType_1];
            }
            [modifiedRecords addObject:record];
            [array addObject:record.recordID];
            [array release];
            // <+1892>
        } else {
            // <+1708>
            os_log_with_type(_OCLogGetLogStream(0x11), OS_LOG_TYPE_DEFAULT, "OpenCloudData+CloudKit: %s(%d): %@ - Skipping unknown updated record: %@\nIt is not a part of: %@", __func__, __LINE__, self, record, entityNames);
            // <+1892>
        }
    }
    
    // <+1940>
    // sp, #0x38
    BOOL succeed = YES;
    // x24
    for (NSString *recordType in _deletedRecordTypeToRecordID) @autoreleasepool {
        // sp + 0xf0
        NSArray<CKRecordID *> *recordIDs = [_deletedRecordTypeToRecordID objectForKey:recordType];
        
        // sp + 0xc0
        NSString *name_1 = recordType;
        if (![recordType hasPrefix:@"CD_"]) {
            name_1 = [recordType substringFromIndex:@"CD_".length];
        }
        
        // x27
        for (CKRecordID *recordID in recordIDs) {
            os_log_with_type(_OCLogGetLogStream(0x11), OS_LOG_TYPE_DEFAULT, "OpenCloudData+CloudKit: %s(%d): Deleting record with id (%@): %@", __func__, __LINE__, recordType, recordID);
            
            if ([recordType hasPrefix:[OCSPIResolver PFCloudKitMirroringDelegateToManyPrefix]]) {
                // <+2504>
                // x19
                OCMirroredManyToManyRelationship *mirroredRelationship = [OCMirroredManyToManyRelationship mirroredRelationshipWithDeletedRecordType:recordType recordID:recordID andManagedObjectModel:managedObjectModel];
                [deletedRelationships addObject:mirroredRelationship];
                
                /*
                 __95-[PFCloudKitImportZoneContext initializeCachesWithManagedObjectContext:andObservedStore:error:]_block_invoke.10
                 entityNames = sp + 0x2b0 = x20 + 0x20
                 recordTypeToRecordID = sp + 0x2b8 = x20 + 0x28
                 self = sp + 0x2c0 = x20 + 0x30
                 recordID = sp + 0x2c8 = x20 + 0x38
                 */
                [mirroredRelationship.recordTypeToRecordID enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull recordType, NSArray<CKRecordID *> * _Nonnull recordIDs, BOOL * _Nonnull stop) {
                    /*
                     self(block) = x20
                     recordType = x19
                     recordIDs = x21
                     */
                    
                    if (![entityNames containsObject:recordType]) {
                        os_log_with_type(_OCLogGetLogStream(0x11), OS_LOG_TYPE_DEFAULT, "OpenCloudData+CloudKit: %s(%d): %@ - Skipping unknown deleted relationship recordID: %@ - %@", __func__, __LINE__, self, recordType, recordID);
                        return;
                    }
                    
                    // sp, #0x8
                    NSMutableArray<CKRecordID *> *array = [[recordTypeToRecordID objectForKey:recordType] retain];
                    if (array == nil) {
                        array = [[NSMutableArray alloc] init];
                        [recordTypeToRecordID setObject:array forKey:recordType];
                    }
                    
                    [array addObjectsFromArray:recordIDs];
                    [array release];
                }];
                // <+3980>
            } else if ([recordType isEqualToString:@"CDMR"]) {
                // <+2648>
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@", recordID.recordName];
                NSArray<OCCKMirroredRelationship *> * _Nullable fetchedMirroredRelationships = [OCCKMirroredRelationship fetchMirroredRelationshipsMatchingPredicate:predicate fromStore:observedStore inManagedObjectContext:managedObjectContext error:&_error];
                
                if (fetchedMirroredRelationships == nil) {
                    os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData+CloudKit: %s(%d): Import context failed to fetch mirrored relationships during import: %@", __func__, __LINE__, _error);
                    succeed = NO;
                    [_error retain];
                    break;
                }
                
                OCCKMirroredRelationship * _Nullable lastMirroredRelationship = fetchedMirroredRelationships.lastObject;
                if (lastMirroredRelationship == nil) {
                    os_log_with_type(_OCLogGetLogStream(0x11), OS_LOG_TYPE_DEFAULT, "OpenCloudData+CloudKit: %s(%d): %@ - Skipping unknown deleted relationship recordID: %@ - %@", __func__, __LINE__, self, lastMirroredRelationship, recordID);
                    continue;
                }
                
                lastMirroredRelationship.needsDelete = @YES;
                lastMirroredRelationship.isUploaded = @YES;
                
                if (![entityNames containsObject:lastMirroredRelationship.cdEntityName]) {
                    // <+3500>
                    os_log_with_type(_OCLogGetLogStream(0x11), OS_LOG_TYPE_DEFAULT, "OpenCloudData+CloudKit: %s(%d): %@ - Skipping unknown deleted relationship recordID: %@ - %@", __func__, __LINE__, self, lastMirroredRelationship, recordID);
                    continue;
                }
                
                // <+2792>
                // x28
                NSRelationshipDescription *relationshipDescription = [[managedObjectModel.entitiesByName objectForKey:lastMirroredRelationship.cdEntityName].relationshipsByName objectForKey:lastMirroredRelationship.relationshipName];
                // x19
                CKRecordID *recordIDForRecord = [lastMirroredRelationship createRecordIDForRecord];
                // x25
                CKRecordID *recordIDForRelatedRecord = [lastMirroredRelationship createRecordIDForRelatedRecord];
                // x27
                OCMirroredManyToManyRelationshipV2 *mirroredManyToManyRelationship = [[OCMirroredManyToManyRelationshipV2 alloc] initWithRecordID:recordID forRecordWithID:recordIDForRecord relatedToRecordWithID:recordIDForRelatedRecord byRelationship:relationshipDescription withInverse:relationshipDescription.inverseRelationship andType:1];
                [deletedRelationships addObject:mirroredManyToManyRelationship];
                
                {
                    NSRelationshipDescription * _Nullable _relationshipDescription;
                    {
                        if (mirroredManyToManyRelationship == nil) {
                            _relationshipDescription = nil;
                        } else {
                            _relationshipDescription = mirroredManyToManyRelationship->_relationshipDescription;
                        }
                    }
                    
                    // x28
                    NSMutableArray<CKRecordID *> *array = [[recordTypeToRecordID objectForKey:_relationshipDescription.entity.name] retain];
                    if (array == nil) {
                        array = [[NSMutableArray alloc] init];
                        [recordTypeToRecordID setObject:array forKey:_relationshipDescription.entity.name];
                    }
                    
                    CKRecordID *_ckRecordID;
                    {
                        if (mirroredManyToManyRelationship == nil) {
                            _ckRecordID = nil;
                        } else {
                            _ckRecordID = mirroredManyToManyRelationship->_ckRecordID;
                        }
                    }
                    
                    [array addObject:_ckRecordID];
                    [array release];
                }
                
                {
                    NSRelationshipDescription *_inverseRelationshipDescription;
                    {
                        if (mirroredManyToManyRelationship == nil) {
                            _inverseRelationshipDescription = nil;
                        } else {
                            _inverseRelationshipDescription = mirroredManyToManyRelationship->_inverseRelationshipDescription;
                        }
                    }
                    
                    NSMutableArray<CKRecordID *> *array = [[recordTypeToRecordID objectForKey:_inverseRelationshipDescription.entity.name] retain];
                    if (array == nil) {
                        array = [[NSMutableArray alloc] init];
                        [recordTypeToRecordID setObject:array forKey:_inverseRelationshipDescription.entity.name];
                    }
                    
                    CKRecordID *_ckRecordID;
                    {
                        if (mirroredManyToManyRelationship == nil) {
                            _ckRecordID = nil;
                        } else {
                            _ckRecordID = mirroredManyToManyRelationship->_ckRecordID;
                        }
                    }
                    
                    [array addObject:_ckRecordID];
                    [array release];
                }
                
                [mirroredManyToManyRelationship release];
                [recordIDForRecord release];
                [recordIDForRelatedRecord release];
                // <+3980>
            } else if ([entityNames containsObject:name_1]) {
                // <+3248>
                {
                    // x19
                    NSMutableArray<CKRecordID *> *array = [[recordTypeToRecordID objectForKey:recordType] retain];
                    if (array == nil) {
                        array = [[NSMutableArray alloc] init];
                        [recordTypeToRecordID setObject:array forKey:recordType];
                    }
                    [array addObject:recordID];
                    [array release];
                }
                
                {
                    // x19
                    NSMutableSet<CKRecordID *> *set = [[dictionary_2 objectForKey:recordType] retain];
                    if (set == nil) {
                        set = [[NSMutableSet alloc] init];
                        [dictionary_2 setObject:set forKey:recordType];
                    }
                    [set addObject:recordID];
                    [set release];
                }
                // <+3980>
            } else if ([recordType isEqualToString:CKRecordTypeShare]) {
                // original : getCloudKitCKRecordTypeShare
                // <+3428>
                [deletedShareRecordIDs addObject:recordID];
                // <+3980>
            } else {
                os_log_with_type(_OCLogGetLogStream(0x11), OS_LOG_TYPE_DEFAULT, "OpenCloudData+CloudKit: %s(%d): %@ - Skipping unknown deleted record: %@ - %@", __func__, __LINE__, self, recordType, recordID);
                // <+3980>
            }
        }
    }
    
    if (!succeed) {
        [_error autorelease];
        
        if (_error == nil) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        } else {
            if (error != NULL) {
                *error = _error;
            }
        }
        
        [entityNames release];
        [managedObjectModel release];
        [updatedRelationships release];
        [deletedRelationships release];
        [modifiedRecords release];
        [recordTypeToRecordID release];
        [deletedMirroredRelationshipRecordIDs release];
        [dictionary_2 release];
        [deletedShareRecordIDs release];
        return NO;
    }
    
    // <+4312>
    // x20
    NSArray<OCCKMirroredRelationship *> * _Nullable fetchedMirroredRelationships = [OCCKMirroredRelationship fetchMirroredRelationshipsMatchingRelatingRecords:self->_updatedRecords andRelatingRecordIDs:@[] fromStore:observedStore inManagedObjectContext:managedObjectContext error:&_error];
    if (fetchedMirroredRelationships == nil) {
        if (_error == nil) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        } else {
            if (error != NULL) {
                *error = _error;
            }
        }
        
        [entityNames release];
        [managedObjectModel release];
        [updatedRelationships release];
        [deletedRelationships release];
        [modifiedRecords release];
        [recordTypeToRecordID release];
        [deletedMirroredRelationshipRecordIDs release];
        [dictionary_2 release];
        [deletedShareRecordIDs release];
        return NO;
    }
    
    // x24
    for (OCCKMirroredRelationship *mirroredRelationship in fetchedMirroredRelationships) @autoreleasepool {
        // x22
        CKRecordID *recordIDForRecord = [mirroredRelationship createRecordIDForRecord];
        // x23
        CKRecordID *recordIDForRelatedRecord = [mirroredRelationship createRecordIDForRelatedRecord];
        
        {
            // x25
            NSMutableArray<CKRecordID *> *array = [[recordTypeToRecordID objectForKey:mirroredRelationship.cdEntityName] retain];
            if (array == nil) {
                array = [[NSMutableArray alloc] init];
                [recordTypeToRecordID setObject:array forKey:mirroredRelationship.cdEntityName];
            }
            [array addObject:recordIDForRecord];
            [array release];
        }
        
        {
            // x25
            NSMutableArray<CKRecordID *> *array = [[recordTypeToRecordID objectForKey:mirroredRelationship.relatedEntityName] retain];
            if (array == nil) {
                array = [[NSMutableArray alloc] init];
                [recordTypeToRecordID setObject:array forKey:mirroredRelationship.relatedEntityName];
            }
            [array addObject:recordIDForRelatedRecord];
            [array release];
        }
        
        [recordIDForRecord release];
        [recordIDForRelatedRecord release];
    }
    
    // <+4720>
    // sp, #0xe0
    NSMutableDictionary *recordTypeToRecordIDToObjectID = [[NSMutableDictionary alloc] init];
    // sp, #0x80
    NSMutableSet<CKRecordType> *recoedTypes = [[NSMutableSet alloc] initWithArray:recordTypeToRecordID.allKeys];
    
    for (CKRecordType recordType in recoedTypes) {
        // x22
        NSMutableArray<CKRecordID *> *recordIDs = [recordTypeToRecordID objectForKey:recordType];
        // x23
        NSDictionary<CKRecordID *, OCCKRecordMetadata *> * _Nullable mapOfMetadata = [OCCKRecordMetadata createMapOfMetadataMatchingRecords:@[] andRecordIDs:recordIDs inStore:observedStore withManagedObjectContext:managedObjectContext error:&_error];
        
        if (mapOfMetadata == nil) {
            [_error retain];
            [mapOfMetadata release];
            
            if (_error == nil) {
                os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
                os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            } else {
                if (error != NULL) {
                    *error = _error;
                }
            }
            
            [recordTypeToRecordIDToObjectID release];
            [recoedTypes release];
            [entityNames release];
            [managedObjectModel release];
            [updatedRelationships release];
            [deletedRelationships release];
            [modifiedRecords release];
            [recordTypeToRecordID release];
            [deletedMirroredRelationshipRecordIDs release];
            [dictionary_2 release];
            [deletedShareRecordIDs release];
            return NO;
        }
        
        // x25
        for (CKRecordID *recordID in mapOfMetadata) {
            OCCKRecordMetadata *recordMetdata = [mapOfMetadata objectForKey:recordID];
            if (recordMetdata != nil) {
                // x26
                NSManagedObjectID *objectID = [recordMetdata createObjectIDForLinkedRow];
                // <+5092>
                [self addObjectID:objectID toCache:recordTypeToRecordIDToObjectID andRecordID:recordID];
                [objectID release];
            }
        }
        [mapOfMetadata release];
    }
    
    // <+5232>
    NSArray<OCCKImportOperation *> * _Nullable unfinishedImportOperations = [OCCKImportOperation fetchUnfinishedImportOperationsInStore:observedStore withManagedObjectContext:managedObjectContext error:&_error];
    _importOperations = [unfinishedImportOperations retain];
    
    if (unfinishedImportOperations == nil) {
        if (_error == nil) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        } else {
            if (error != NULL) {
                *error = _error;
            }
        }
        
        [recordTypeToRecordIDToObjectID release];
        [recoedTypes release];
        [entityNames release];
        [managedObjectModel release];
        [updatedRelationships release];
        [deletedRelationships release];
        [modifiedRecords release];
        [recordTypeToRecordID release];
        [deletedMirroredRelationshipRecordIDs release];
        [dictionary_2 release];
        [deletedShareRecordIDs release];
        return NO;
    }
    
    for (OCCKImportOperation *importOperation in unfinishedImportOperations) {
        // x20
        for (OCCKImportPendingRelationship *pendingRelationship in importOperation.pendingRelationships) {
            // x21
            NSEntityDescription *entityDescription = [managedObjectModel.entitiesByName objectForKey:pendingRelationship.cdEntityName];
            NSEntityDescription *relatedEntityDescription = [managedObjectModel.entitiesByName objectForKey:pendingRelationship.relatedEntityName];
            
            if ((entityDescription != nil) && (relatedEntityDescription != nil)) {
                // <+5740>
                // x24
                CKRecordType recordType = [OCCloudKitSerializer recordTypeForEntity:entityDescription];
                
                // original : getCloudKitCKRecordZoneIDClass
                // x21
                CKRecordZoneID *zoneID = [[CKRecordZoneID alloc] initWithZoneName:pendingRelationship.recordZoneName ownerName:pendingRelationship.recordZoneOwnerName];
                // original : getCloudKitCKRecordIDClass
                // x25
                CKRecordID *recordID = [[CKRecordID alloc] initWithRecordName:pendingRelationship.recordName zoneID:zoneID];
                
                // original : getCloudKitCKRecordZoneIDClass
                // x23
                CKRecordZoneID *relatedZoneID = [[CKRecordZoneID alloc] initWithZoneName:pendingRelationship.relatedRecordZoneName ownerName:pendingRelationship.relatedRecordZoneOwnerName];
                // original : getCloudKitCKRecordIDClass
                // x22
                CKRecordID *relatedRecordID = [[CKRecordID alloc] initWithRecordName:pendingRelationship.relatedRecordName zoneID:relatedZoneID];
                
                if (![zoneID isEqual:relatedZoneID]) {
                    os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Import is attempting to link objects across zones: %@\n", pendingRelationship);
                    os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Import is attempting to link objects across zones: %@\n", pendingRelationship);
                }
                
                // <+6048>
                [self addUnresolvedRecordID:recordID forRecordType:recordType toCache:self->_recordTypeToUnresolvedRecordIDs];
                // x28
                CKRecordType relatedRecordType = [OCCloudKitSerializer recordTypeForEntity:[managedObjectModel.entitiesByName objectForKey:pendingRelationship.relatedEntityName]];
                [self addUnresolvedRecordID:relatedRecordID forRecordType:relatedRecordType toCache:self->_recordTypeToUnresolvedRecordIDs];
                
                if (([[dictionary_2 objectForKey:recordType] containsObject:recordID]) || ([[dictionary_2 objectForKey:relatedRecordType] containsObject:relatedRecordID])) {
                    [managedObjectContext deleteObject:pendingRelationship];
                }
                
                [recordID release];
                [zoneID release];
                [relatedRecordID release];
                [relatedZoneID release];
            } else {
                // <+5560>
                os_log_with_type(_OCLogGetLogStream(0x11), OS_LOG_TYPE_DEFAULT, "OpenCloudData+CloudKit: %s(%d): Deleting pending relationship because it's entities are no longer in the model: %@", __func__, __LINE__, pendingRelationship);
                
                [managedObjectContext deleteObject:pendingRelationship];
            }
            
        }
    }
    
    _recordTypeToRecordIDToObjectID = [recordTypeToRecordIDToObjectID retain];
    _modifiedRecords = [modifiedRecords copy];
    _deletedRelationships = [deletedRelationships copy];
    _deletedMirroredRelationshipRecordIDs = [deletedMirroredRelationshipRecordIDs copy];
    _deletedShareRecordIDs = [deletedShareRecordIDs copy];
    
    // x20
    NSMutableSet<NSManagedObjectID *> *deletedObjectIDs = [[NSMutableSet alloc] init];
    /*
     __95-[PFCloudKitImportZoneContext initializeCachesWithManagedObjectContext:andObservedStore:error:]_block_invoke.19
     self = sp + 0x140
     deletedObjectIDs = sp + 0x148
     */
    [_deletedRecordTypeToRecordID enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull recordType, NSArray<CKRecordID *> * _Nonnull recordIDs, BOOL * _Nonnull stop) {
        /*
         self(block) = x20
         recordType = x21
         recordIDs = x19
         */
        
        if ([recordType hasPrefix:@"CD_"]) {
            recordType = [recordType substringFromIndex:@"CD_".length];
        }
        // x23
        for (CKRecordID *recordID in recordIDs) {
            NSManagedObjectID *objectID = [[self->_recordTypeToRecordIDToObjectID objectForKey:recordType] objectForKey:recordID];
            if (objectID != nil) {
                [deletedObjectIDs addObject:objectID];
            }
        }
    }];
    
    _deletedObjectIDs = [deletedObjectIDs copy];
    [deletedObjectIDs release];
    [recordTypeToRecordIDToObjectID release];
    [recoedTypes release];
    [entityNames release];
    [managedObjectModel release];
    [updatedRelationships release];
    [deletedRelationships release];
    [modifiedRecords release];
    [recordTypeToRecordID release];
    [deletedMirroredRelationshipRecordIDs release];
    [dictionary_2 release];
    [deletedShareRecordIDs release];
    return YES;
}

- (void)registerObject:(NSManagedObject *)object forInsertedRecord:(CKRecord *)record withMetadata:(OCCKRecordMetadata *)metadata {
    /*
     self = x19
     object = x21
     record = x22
     metadata = x20
     */
    [self addObjectID:object.objectID toCache:_recordTypeToRecordIDToObjectID andRecordID:record.recordID];
    // x22
    _OCCKInsertedMetadataLink *metadataLink = [[_OCCKInsertedMetadataLink alloc] initWithRecordMetadata:metadata insertedObject:object];
    os_log_with_type(_OCLogGetLogStream(0x11), OS_LOG_TYPE_DEFAULT, "CoreData+CloudKit: %s(%d): Linking %@ to %@", __func__, __LINE__, object.objectID, metadata);
    [self->_metadatasToLink addObject:metadataLink];
    [metadataLink release];
}

- (void)addMirroredRelationshipToLink:(OCMirroredRelationship *)mirroredRelationship {
    /*
     self = x19
     mirroredRelationship = x20
     */
    [_updatedRelationships addObject:mirroredRelationship];
    
    if ([mirroredRelationship isKindOfClass:[OCMirroredOneToManyRelationship class]]) {
        // <+68>
        OCMirroredOneToManyRelationship *casted = (OCMirroredOneToManyRelationship *)mirroredRelationship;
        /*
         __61-[PFCloudKitImportZoneContext addMirroredRelationshipToLink:]_block_invoke
         self = sp + 0x48
         */
        [casted.recordTypesToRecordIDs enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull recordType, NSArray<CKRecordID *> * _Nonnull recordIDs, BOOL * _Nonnull stop) {
            /*
             self(block) = x21
             recordType = x20
             recordIDs = x19
             */
            // x23
            for (CKRecordID *recordID in recordIDs) {
                NSManagedObjectID * _Nullable objectID = [[self->_recordTypeToRecordIDToObjectID objectForKey:recordType] objectForKey:recordID];
                if (objectID != nil) continue;
                // x24
                NSMutableArray<CKRecordID *> *unresolvedRecordIDs = [[self->_recordTypeToUnresolvedRecordIDs objectForKey:recordType] retain];
                if (unresolvedRecordIDs == nil) {
                    unresolvedRecordIDs = [[NSMutableArray alloc] init];
                    [self->_recordTypeToUnresolvedRecordIDs setObject:unresolvedRecordIDs forKey:recordType];
                }
                [unresolvedRecordIDs addObject:recordID];
                [unresolvedRecordIDs release];
            }
        }];
    } else if ([mirroredRelationship isKindOfClass:[OCMirroredManyToManyRelationship class]]) {
        // <+160>
        OCMirroredManyToManyRelationship *casted = (OCMirroredManyToManyRelationship *)mirroredRelationship;
        /*
         __61-[PFCloudKitImportZoneContext addMirroredRelationshipToLink:]_block_invoke_2
         self = sp + 0x20
         */
        [casted.recordTypeToRecordID enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull recordType, NSArray<CKRecordID *> * _Nonnull recordIDs, BOOL * _Nonnull stop) {
            /*
             self(block) = x21
             recordType = x20
             recordIDs = x19
             */
            // x23
            for (CKRecordID *recordID in recordIDs) {
                NSManagedObjectID * _Nullable objectID = [[self->_recordTypeToRecordIDToObjectID objectForKey:recordType] objectForKey:recordID];
                if (objectID != nil) continue;
                // x24
                NSMutableArray<CKRecordID *> *unresolvedRecordIDs = [[self->_recordTypeToUnresolvedRecordIDs objectForKey:recordType] retain];
                if (unresolvedRecordIDs == nil) {
                    unresolvedRecordIDs = [[NSMutableArray alloc] init];
                    [self->_recordTypeToUnresolvedRecordIDs setObject:unresolvedRecordIDs forKey:recordType];
                }
                [unresolvedRecordIDs addObject:recordID];
                [unresolvedRecordIDs release];
            }
        }];
    }
}

- (BOOL)linkInsertedObjectsAndMetadataInContext:(NSManagedObjectContext *)context error:(NSError * _Nullable *)error {
    /*
     self = x20
     context = x22
     error = x19
     */
    // sp, #0x98
    NSError * _Nullable _error = nil;
    
    BOOL result = [context obtainPermanentIDsForObjects:context.insertedObjects.allObjects error:&_error];
    if (!result) {
        if (_error == nil) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        } else {
            if (error != NULL) {
                *error = _error;
            }
        }
        return NO;
    }
    // x23
    for (_OCCKInsertedMetadataLink *metadataLink in _metadatasToLink) {
        // x19
        NSManagedObjectID *objectID = metadataLink->_insertedObject.objectID;
        
        if (objectID.temporaryID) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Found temporary objectID for metadata link: %@\n%@\n%@\n%@\n", objectID, metadataLink, context.insertedObjects, _error);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Found temporary objectID for metadata link: %@\n%@\n%@\n%@\n", objectID, metadataLink, context.insertedObjects, _error);
            
            _error = [NSError errorWithDomain:NSCocoaErrorDomain code:134410 userInfo:@{
                NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"Found temporary objectID for metadata link: %@\n%@\n%@", objectID, metadataLink, context.insertedObjects]
            }];
            // break 없음
            continue;
        }
        
        // <+436>
        OCCKRecordMetadata * _Nullable recordMetadata;
        {
            if (metadataLink == nil) {
                recordMetadata = nil;
            } else {
                recordMetadata = metadataLink->_recordMetadata;
            }
        }
        recordMetadata.entityPK = @([objectID _referenceData64]);
        
        NSSQLEntity * _Nullable sqlEntity = [OCSPIResolver _sqlEntityForEntityDescription:[((NSSQLCore *)objectID.persistentStore) model] x1:objectID.entity];
        
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
        recordMetadata.entityId = @(_entityID);
        // x26
        CKRecordID *recordID = [recordMetadata createRecordID];
        [self addObjectID:objectID toCache:self->_recordTypeToRecordIDToObjectID andRecordID:recordID];
        [recordID release];
    }
    
    return YES;
}

- (BOOL)populateUnresolvedIDsInStore:(NSPersistentStore *)store withManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable *)error {
    /*
     managedObjectContext = x8
     error = x19
     */
    // x29 - #0x50
    __block BOOL _succeed = YES;
    // sp, #0x50
    __block NSError * _Nullable _error = nil;
    
    /*
     __91-[PFCloudKitImportZoneContext populateUnresolvedIDsInStore:withManagedObjectContext:error:]_block_invoke
     self = sp + 0x28 = x20 + 0x20
     store = sp + 0x30 = x20 + 0x28
     managedObjectContext = sp + 0x38 = x20 + 0x30
     _error = sp + 0x40 = x20 + 0x38
     _succeed = sp + 0x48 = x20 + 0x40
     */
    [managedObjectContext performBlockAndWait:^{
        /*
         self(block) = x20
         */
        os_log_with_type(_OCLogGetLogStream(0x11), OS_LOG_TYPE_DEFAULT, "OpenCloudData+CloudKit: %s(%d): Populating unresolved relationships:\n%@", __func__, __LINE__, self->_recordTypeToUnresolvedRecordIDs);
        
        // sp + 0x8
        NSMutableSet<CKRecordType> *set = [[NSMutableSet alloc] initWithArray:self->_recordTypeToUnresolvedRecordIDs.allKeys];
        
        for (CKRecordType recordType in set) @autoreleasepool {
            // x24
            NSMutableArray<CKRecordID *> *recordIDs = [self->_recordTypeToUnresolvedRecordIDs objectForKey:recordType];
            // x25
            NSDictionary<CKRecordID *, OCCKRecordMetadata *> * _Nullable map = [OCCKRecordMetadata createMapOfMetadataMatchingRecords:@[] andRecordIDs:recordIDs inStore:store withManagedObjectContext:managedObjectContext error:&_error];
            
            if (map == nil) {
                _succeed = NO;
                [_error retain];
                [map release];
                break;
            }
            
            // x27
            for (CKRecordID *recordID in recordIDs) {
                // x28
                OCCKRecordMetadata * _Nullable recordMetadata = [map objectForKey:recordID];
                if (recordMetadata == nil) continue;
                if (recordMetadata.inserted) continue;
                // x28
                NSManagedObjectID *_objectID = [recordMetadata createObjectIDForLinkedRow];
                [self addObjectID:_objectID toCache:self->_recordTypeToRecordIDToObjectID andRecordID:recordID];
                [_objectID release];
            }
            
            [map release];
        }
        
        [set release];
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

- (void)addObjectID:(NSManagedObjectID *)objectID toCache:(NSMutableDictionary<CKRecordType, NSMutableDictionary<CKRecordID *, NSManagedObjectID *> *> *)cache andRecordID:(CKRecordID *)recordID {
    /*
     self = x22
     objectID = x21
     cache = x20
     recordID = x19
     */
    // x23
    
    NSEntityDescription * _Nullable entity = objectID.entity;
    NSString * _Nullable name = entity.name;
    
    do {
        [self addObjectID:objectID toCache:cache forRecordWithType:name andUniqueIdentifier:recordID];
        entity = entity.superentity;
        name = entity.name;
    } while (name != nil);
}

- (void)addObjectID:(NSManagedObjectID *)objectID toCache:(NSMutableDictionary<CKRecordType, NSMutableDictionary<CKRecordID *, NSManagedObjectID *> *> *)cache forRecordWithType:(CKRecordType)recordType andUniqueIdentifier:(CKRecordID *)uniqueIdentifier {
    /*
     objectID = x20
     cache = x22
     recordType = x21
     uniqueIdentifier = x19
     */
    
    // sp + 0x8
    NSMutableDictionary<CKRecordID *, NSManagedObjectID *> *dictionary = [[cache objectForKey:recordType] retain];
    if (dictionary == nil) {
        dictionary = [[NSMutableDictionary alloc] init];
        [cache setObject:dictionary forKey:recordType];
    }
    [dictionary setObject:objectID forKey:uniqueIdentifier];
    [dictionary release];
}

- (void)addUnresolvedRecordID:(CKRecordID *)recordID forRecordType:(CKRecordType)recordType toCache:(NSMutableDictionary<CKRecordType, NSMutableArray<CKRecordID *> *> *)cache {
    /*
     recordID = x19
     recordType = x20
     cache = x21
     */
    // sp + 0x8
    NSMutableArray<CKRecordID *> *array = [[cache objectForKey:recordType] retain];
    if (array == nil) {
        array = [[NSMutableArray alloc] init];
        [cache setObject:array forKey:recordType];
    }
    [array addObject:recordID];
    [array release];
}

@end
