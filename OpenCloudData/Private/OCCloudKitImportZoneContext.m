//
//  OCCloudKitImportZoneContext.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/6/25.
//

#import <OpenCloudData/OCCloudKitImportZoneContext.h>
#import <OpenCloudData/OCSPIResolver.h>
#import <OpenCloudData/PFMirroredRelationship.h>
#import <OpenCloudData/Log.h>
#import <objc/runtime.h>

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
    // sp + 0x28
    NSMutableArray<CKRecord *> *modifiedRecords = [[NSMutableArray alloc] init];
    // sp + 0x110
    NSMutableDictionary *dictionary_1 = [[NSMutableDictionary alloc] init];
    // sp + 0xf8
    NSMutableArray<PFMirroredManyToManyRelationship *> *deletedRelationships = [[NSMutableArray alloc] init];
    // sp + 0x20
    NSMutableArray<PFMirroredManyToManyRelationship *> *updatedRelationships = [[NSMutableArray alloc] init];
    // sp + 0x18
    NSMutableSet<CKRecordID *> *deletedMirroredRelationshipRecordIDs = [[NSMutableSet alloc] init];
    // sp + 0x78
    NSMutableSet<CKRecordID *> *deletedShareRecordIDs = [[NSMutableSet alloc] init];
    // sp + 0x98
    NSMutableDictionary *dictionary_2 = [[NSMutableDictionary alloc] init];
    // managedObjectContext = sp + 0x98
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
            
            BOOL result = [objc_lookUpClass("PFMirroredRelationship") isValidMirroredRelationshipRecord:record values:target];
            if (!result) {
                // <+1084>
                abort();
            } else {
                // <+924>
            }
        } else {
            // <+1260>
            abort();
        }
        
        abort();
    }
    abort();
}

- (void)registerObject:(NSManagedObject *)object forInsertedRecord:(CKRecord *)record withMetadata:(id)metadata {
    abort();
}

- (void)addMirroredRelationshipToLink:(PFMirroredOneToManyRelationship *)mirroredRelationship {
    abort();
}

- (BOOL)linkInsertedObjectsAndMetadataInContext:(NSManagedObjectContext *)context error:(NSError * _Nullable *)error {
    abort();
}

- (BOOL)populateUnresolvedIDsInStore:(NSPersistentStore *)store withManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable *)error {
    abort();
}

@end
