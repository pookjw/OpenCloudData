//
//  OCCloudKitMetadataModel.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/6/25.
//

#import "OpenCloudData/Private/OCCloudKitMetadataModel.h"
#import "OpenCloudData/SPI/CoreData/NSSQLCore.h"
#import "OpenCloudData/SPI/CoreData/NSManagedObjectID+Private.h"
#import "OpenCloudData/Private/Log.h"
#import "OpenCloudData/SPI/CoreData/_PFModelMap.h"
#import "OpenCloudData/Private/ValueTransformers/OCCloudKitMetadataValueTransformer.h"
#import "OpenCloudData/Private/ValueTransformers/OCCKRecordZoneQueryCursorTransformer.h"
#import "OpenCloudData/Private/ValueTransformers/OCCKRecordZoneQueryPredicateTransformer.h"
#import "OpenCloudData/SPI/CoreData/NSPersistentStore+Private.h"
#import "OpenCloudData/Private/NSPersistentStore+OpenCloudData_Private.h"
#import "OpenCloudData/SPI/CoreData/_PFClassicBackgroundRuntimeVoucher.h"
#import "OpenCloudData/Private/OCCloudKitMirroringDelegate.h"
#import "OpenCloudData/Private/Migration/OCCloudKitMetadataModelMigrator.h"
#import "OpenCloudData/SPI/CoreData/NSSQLModel.h"
#import "OpenCloudData/SPI/CoreData/NSSQLiteStatement.h"
#import "OpenCloudData/SPI/OCSPIResolver.h"
#import "OpenCloudData/SPI/CoreData/NSManagedObjectModel+Private.h"
#import "OpenCloudData/Private/Model/OCCKExportMetadata.h"
#import "OpenCloudData/Private/Model/OCCKMirroredRelationship.h"
#import "OpenCloudData/Private/Model/OCCKImportOperation.h"
#import "OpenCloudData/Private/Model/OCCKRecordZoneMetadata.h"
#import "OpenCloudData/Private/Model/OCCKMetadataEntry.h"
#import "OpenCloudData/SPI/OCSPIResolver.h"
#include <objc/runtime.h>

NSString * const OCCKRecordZoneQueryCursorTransformerName = @"com.pookjw.openclouddata.cloudkit.query.cursor";
NSString * const OCCKRecordZoneQueryPredicateTransformerName = @"com.pookjw.openclouddata.cloudkit.predicate";

NSArray<Class> * (*_oc_PFModelMap_ancillaryModelFactoryClasses_original)(Class self, SEL _cmd);
NSArray<Class> * _oc_PFModelMap_ancillaryModelFactoryClasses_custom(Class self, SEL _cmd) {
    NSArray<Class> *result = _oc_PFModelMap_ancillaryModelFactoryClasses_original(self, _cmd);
    return [result arrayByAddingObject:[OCCloudKitMetadataModel class]];
}

@implementation OCCloudKitMetadataModel

+ (void)load {
    Method method = class_getClassMethod(objc_lookUpClass("_PFModelMap"), @selector(ancillaryModelFactoryClasses));
    assert(method != NULL);
    _oc_PFModelMap_ancillaryModelFactoryClasses_original = (typeof(_oc_PFModelMap_ancillaryModelFactoryClasses_original))method_getImplementation(method);
    method_setImplementation(method, (IMP)_oc_PFModelMap_ancillaryModelFactoryClasses_custom);
}

+ (void)initialize {
    if (self == [OCCloudKitMetadataModel class]) {
        {
            OCCloudKitMetadataValueTransformer *valueTransformer = [[OCCloudKitMetadataValueTransformer alloc] init];
            // original : @"com.apple.CoreData.cloudkit.metadata.transformer"
            [NSValueTransformer setValueTransformer:valueTransformer forName:@"com.pookjw.OpenCloudData.cloudkit.metadata.transformer"];
            [valueTransformer release];
        }
        
        {
            OCCKRecordZoneQueryCursorTransformer *valueTransformer = [[OCCKRecordZoneQueryCursorTransformer alloc] init];
            // original : NSCKRecordZoneQueryCursorTransformerName (com.apple.coredata.cloudkit.query.cursor)
            [NSValueTransformer setValueTransformer:valueTransformer forName:OCCKRecordZoneQueryCursorTransformerName];
            [valueTransformer release];
        }
        
        {
            OCCKRecordZoneQueryPredicateTransformer *valueTransformer = [[OCCKRecordZoneQueryPredicateTransformer alloc] init];
            // original : NSCKRecordZoneQueryPredicateTransformerName (com.apple.coredata.cloudkit.predicate)
            [NSValueTransformer setValueTransformer:valueTransformer forName:OCCKRecordZoneQueryPredicateTransformerName];
            [valueTransformer release];
        }
    }
}

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
                os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Somehow got a temporary objectID for export: %s\n", [objectID.description cStringUsingEncoding:NSUTF8StringEncoding]);
                os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Somehow got a temporary objectID for export: %s\n", [objectID.description cStringUsingEncoding:NSUTF8StringEncoding]);
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
        NSSQLEntity * _Nullable entity = [OCSPIResolver _sqlEntityForEntityDescription:model x1:objectID.entity];
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

+ (BOOL)checkAndRepairSchemaOfStore:(NSPersistentStore *)store withManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable *)error {
    /*
     store = x22
     managedObjectContext = x21
     error = x19
     */
    
    NSError * _Nullable _error = nil;
    
    // x20
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [store _persistentStoreCoordinator];
    if ((persistentStoreCoordinator == nil) || store.isReadOnly) {
        return YES;
    }
    
    if (!store.oc_isCloudKitEnabled) {
        return YES;
    }
    
    // original : @"OpenCloudData: CloudKit Metadata Model Migration"
    // x20
    _PFClassicBackgroundRuntimeVoucher *voucher = [objc_lookUpClass("_PFBackgroundRuntimeVoucher") _beginPowerAssertionNamed:@"CoreData: CloudKit Metadata Model Migration"];
    
    // x24
    OCCloudKitMirroringDelegate * _Nullable mirroringDelegate = (OCCloudKitMirroringDelegate *)store.mirroringDelegate;
    
    CKDatabaseScope databaseScope;
    OCCloudKitMetricsClient * _Nullable metricsClient;
    {
        if (mirroringDelegate == nil) {
            databaseScope = 0;
            metricsClient = nil;
        } else {
            OCCloudKitMirroringDelegateOptions * _Nullable options = mirroringDelegate->_options;
            databaseScope = options.databaseScope;
            metricsClient = options->_metricsClient;
        }
    }
    
    // x21
    OCCloudKitMetadataModelMigrator *migrator = [[OCCloudKitMetadataModelMigrator alloc] initWithStore:store metadataContext:managedObjectContext databaseScope:databaseScope metricsClient:metricsClient];
    // x22(w22)
    BOOL result = [migrator checkAndPerformMigrationIfNecessary:&_error];
    [objc_lookUpClass("_PFBackgroundRuntimeVoucher") _endPowerAssertionWithVoucher:voucher];
    [migrator release];
    
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
    
    return YES;
}

+ (NSManagedObjectModel *)identifyModelForStore:(NSPersistentStore *)store withConnection:(NSSQLiteConnection *)connection hasOldMetadataTables:(BOOL *)hasOldMetadataTables {
    /*
     hasOldMetadataTables = x20 / sp, #0x68
     connection = sp + 0x28
     */
    
    NSManagedObjectModel * _Nullable result = nil;
    // sp + 0x8
    @autoreleasepool {
        // x19 / sp + 0x10
        NSMutableArray<NSManagedObjectModel *> *models = [[NSMutableArray alloc] init];
        {
            NSManagedObjectModel *model = [OCCloudKitMetadataModel _newMetadataModelV16];
            [models addObject:model];
            [model release];
        }
        {
            NSManagedObjectModel *model = [OCCloudKitMetadataModel _newMetadataModelV15];
            [models addObject:model];
            [model release];
        }
        {
            NSManagedObjectModel *model = [OCCloudKitMetadataModel _newMetadataModelV14];
            [models addObject:model];
            [model release];
        }
        {
            NSManagedObjectModel *model = [OCCloudKitMetadataModel _newMetadataModelV13];
            [models addObject:model];
            [model release];
        }
        {
            NSManagedObjectModel *model = [OCCloudKitMetadataModel _newMetadataModelV12];
            [models addObject:model];
            [model release];
        }
        {
            NSManagedObjectModel *model = [OCCloudKitMetadataModel _newMetadataModelV11];
            [models addObject:model];
            [model release];
        }
        {
            NSManagedObjectModel *model = [OCCloudKitMetadataModel _newMetadataModelV10];
            [models addObject:model];
            [model release];
        }
        {
            NSManagedObjectModel *model = [OCCloudKitMetadataModel _newMetadataModelV9];
            [models addObject:model];
            [model release];
        }
        {
            NSManagedObjectModel *model = [OCCloudKitMetadataModel _newMetadataModelV8];
            [models addObject:model];
            [model release];
        }
        {
            NSManagedObjectModel *model = [OCCloudKitMetadataModel _newMetadataModelV7];
            [models addObject:model];
            [model release];
        }
        {
            NSManagedObjectModel *model = [OCCloudKitMetadataModel _newMetadataModelV6];
            [models addObject:model];
            [model release];
        }
        {
            NSManagedObjectModel *model = [OCCloudKitMetadataModel _newMetadataModelV5];
            [models addObject:model];
            [model release];
        }
        {
            NSManagedObjectModel *model = [OCCloudKitMetadataModel _newMetadataModelV4];
            [models addObject:model];
            [model release];
        }
        {
            NSManagedObjectModel *model = [OCCloudKitMetadataModel _newMetadataModelV3];
            [models addObject:model];
            [model release];
        }
        {
            NSManagedObjectModel *model = [OCCloudKitMetadataModel _newMetadataModelV2];
            [models addObject:model];
            [model release];
        }
        {
            NSManagedObjectModel *model = [OCCloudKitMetadataModel _newMetadataModelV1];
            [models addObject:model];
            [model release];
        }
        [models autorelease];
        
        // sp + 0x38
        for (NSManagedObjectModel *model in models) {
            // x21 / sp, #0x58
            NSSQLModel *sqlModel = [[objc_lookUpClass("NSSQLModel") alloc] initWithManagedObjectModel:model];
            // x27
            NSMutableArray<NSString *> *trimmedSQLStrings = [[NSMutableArray alloc] init];
            // x28
            NSSQLiteAdapter *adapter = [[connection adapter] retain];
            // x19
            NSArray<NSSQLEntity *> *entities;
            assert(object_getInstanceVariable(sqlModel, "_entities", (void **)&entities) != NULL);
            
            // x21
            for (NSSQLEntity *sqlEntity in entities) {
                // x24
                NSSQLiteStatement *tableStatement = [OCSPIResolver NSSQLiteAdapter_newCreateTableStatementForEntity_:adapter x1:sqlEntity];
                // x23
                NSString *sqlString = [tableStatement sqlString];
                NSString *trimmed = [sqlString stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
                [trimmedSQLStrings addObject:trimmed];
                [tableStatement release];
                
                // x21
                NSArray<NSRelationshipDescription *> *manyToManyRelationships = [sqlEntity manyToManyRelationships];
                
                for (NSRelationshipDescription *relationship in manyToManyRelationships) {
                    // x23
                    NSSQLiteStatement *tableStatement = [OCSPIResolver NSSQLiteAdapter_newCreateTableStatementForManyToMany_:adapter x1:relationship];
                    NSString *sqlString = [tableStatement sqlString];
                    NSString *trimmed = [sqlString stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
                    [trimmedSQLStrings addObject:trimmed];
                    [tableStatement release];
                }
            }
            
            // x19
            NSArray<NSArray<NSString *> *> *tableCreationSQL = [[connection fetchTableCreationSQL] retain];
            // x22
            for (NSArray<NSString *> *array in tableCreationSQL) {
                [trimmedSQLStrings removeObject:[array objectAtIndex:1]];
                
                if ((hasOldMetadataTables != NULL) && [[array objectAtIndex:0] hasPrefix:@"ZNSCK"]) {
                    *hasOldMetadataTables = YES;
                }
            }
            
            [tableCreationSQL release];
            [trimmedSQLStrings release];
            [adapter release];
            [sqlModel release];
            
            if (trimmedSQLStrings.count == 0) {
                result = [model retain];
                break;
            }
            
            if (hasOldMetadataTables == NULL) {
                continue;
            } else {
                if (*hasOldMetadataTables) {
                    result = [model retain];
                    break;
                }
            }
        }
    }
    
    return result;
}

+ (NSManagedObjectModel *)newMetadataModelForFrameworkVersion:(NSNumber *)version {
    NSInteger v = version.integerValue;

    if (v <= 0x33a) {
        return [OCCloudKitMetadataModel _newMetadataModelV1];
    }
    if (v == 0x384 || v == 0x385) {
        return [OCCloudKitMetadataModel _newMetadataModelV2];
    }
    if (v == 0x386) {
        return [OCCloudKitMetadataModel _newMetadataModelV3];
    }
    if ((0x33b <= v && v <= 0x383) || (0x387 <= v && v <= 0x399)) {
        return [OCCloudKitMetadataModel _newMetadataModelV4];
    }
    if (0x39a <= v && v <= 0x3ab) {
        return [OCCloudKitMetadataModel _newMetadataModelV5];
    }
    if (0x3ac <= v && v <= 0x3ae) {
        return [OCCloudKitMetadataModel _newMetadataModelV6];
    }
    if (0x3af <= v && v <= 0x3c8) {
        return [OCCloudKitMetadataModel _newMetadataModelV7];
    }
    if (0x3c9 <= v && v <= 0x3f3) {
        return [OCCloudKitMetadataModel _newMetadataModelV8];
    }
    if (0x3f4 <= v && v <= 0x403) {
        return [OCCloudKitMetadataModel _newMetadataModelV9];
    }
    if (0x404 <= v && v <= 0x450) {
        return [OCCloudKitMetadataModel _newMetadataModelV10];
    }
    if (0x451 <= v && v <= 0x454) {
        return [OCCloudKitMetadataModel _newMetadataModelV11];
    }
    if (0x455 <= v && v <= 0x45f) {
        return [OCCloudKitMetadataModel _newMetadataModelV12];
    }
    if (0x460 <= v && v <= 0x469) {
        return [OCCloudKitMetadataModel _newMetadataModelV13];
    }
    if (0x46a <= v && v <= 0x470) {
        return [OCCloudKitMetadataModel _newMetadataModelV14];
    }
    if (0x471 <= v && v <= 0x4da) {
        return [OCCloudKitMetadataModel _newMetadataModelV15];
    }
    
    return [OCCloudKitMetadataModel _newMetadataModelV16];
}

+ (NSManagedObjectModel *)_newMetadataModelV1 __attribute__((objc_direct)) {
    abort();
}

+ (NSManagedObjectModel *)_newMetadataModelV2 __attribute__((objc_direct)) {
    abort();
}

+ (NSManagedObjectModel *)_newMetadataModelV3 __attribute__((objc_direct)) {
    abort();
}

+ (NSManagedObjectModel *)_newMetadataModelV4 __attribute__((objc_direct)) {
    abort();
}

+ (NSManagedObjectModel *)_newMetadataModelV5 __attribute__((objc_direct)) {
    abort();
}

+ (NSManagedObjectModel *)_newMetadataModelV6 __attribute__((objc_direct)) {
    abort();
}

+ (NSManagedObjectModel *)_newMetadataModelV7 __attribute__((objc_direct)) {
    abort();
}

+ (NSManagedObjectModel *)_newMetadataModelV8 __attribute__((objc_direct)) {
    abort();
}

+ (NSManagedObjectModel *)_newMetadataModelV9 __attribute__((objc_direct)) {
    abort();
}

+ (NSManagedObjectModel *)_newMetadataModelV10 __attribute__((objc_direct)) {
    abort();
}

+ (NSManagedObjectModel *)_newMetadataModelV11 __attribute__((objc_direct)) {
    abort();
}

+ (NSManagedObjectModel *)_newMetadataModelV12 __attribute__((objc_direct)) {
    abort();
}

+ (NSManagedObjectModel *)_newMetadataModelV13 __attribute__((objc_direct)) {
    abort();
}

+ (NSManagedObjectModel *)_newMetadataModelV14 __attribute__((objc_direct)) {
    abort();
}

+ (NSManagedObjectModel *)_newMetadataModelV15 __attribute__((objc_direct)) {
    abort();
}

+ (NSManagedObjectModel *)_newMetadataModelV16 __attribute__((objc_direct)) {
    static NSManagedObjectModel *result;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        /*
         0x1b8 = NSEntityDescription
         */
        
        @autoreleasepool {
            // x20
            NSManagedObjectModel *model = [[NSManagedObjectModel alloc] init];
            model._modelsReferenceIDOffset = [OCCloudKitMetadataModel ancillaryEntityOffset];
            
            // x20/x21
            NSEntityDescription *exportMetadata = [[NSEntityDescription alloc] init];
            exportMetadata.name = @"NSCKExportMetadata";
            // original : @"NSCKExportMetadata"
            exportMetadata.managedObjectClassName = NSStringFromClass([OCCKExportMetadata class]);
            
            // sp, #0x50
            NSEntityDescription *exportedObject = [[NSEntityDescription alloc] init];
            exportedObject.name = @"NSCKExportedObject";
            // original : NSCKExportedObject
            exportedObject.managedObjectClassName = NSStringFromClass([OCCKExportedObject class]);
            
            // x23
            NSEntityDescription *exportOperation = [[NSEntityDescription alloc] init];
            exportOperation.name = @"NSCKExportOperation";
            // original : NSCKExportOperation
            exportOperation.managedObjectClassName = NSStringFromClass([OCCKExportOperation class]);
            
            // sp, #0x60
            NSEntityDescription *mirroredRelationship = [[NSEntityDescription alloc] init];
            mirroredRelationship.name = NSStringFromClass(objc_lookUpClass("NSCKMirroredRelationship"));
            // original : NSCKMirroredRelationship
            mirroredRelationship.managedObjectClassName = NSStringFromClass([OCCKMirroredRelationship class]);
            
            // <+500>
            [OCSPIResolver _PFModelUtilities_addAttributes_toPropertiesOfEntity:objc_lookUpClass("_PFModelUtilities")
                                                                             x1:@{
                @"exportedAt": @[@(NSDateAttributeType)],
                @"historyToken": @[
                    @(NSTransformableAttributeType),
                    @YES, // isOptional
                    [NSPersistentHistoryToken class],
                    // original : @"com.apple.CoreData.cloudkit.metadata.transformer"
                    @"com.pookjw.OpenCloudData.cloudkit.metadata.transformer"
                ],
                @"identifier": @[@(NSStringAttributeType)]
            }
                                                                             x2:exportMetadata];
            
            // <+608>
            [OCSPIResolver _PFModelUtilities_addRelationships_toPropertiesOfEntity:objc_lookUpClass("_PFModelUtilities")
                                                                                x1:@{
                @"operations": @[
                    @0, // maxCount
                    exportOperation,
                    [NSNull null],
                    @(NSCascadeDeleteRule) // deleteRule
                ]
            }
                                                                                x2:exportMetadata];
            
            // <+628>
            [OCSPIResolver _PFModelUtilities_addAttributes_toPropertiesOfEntity:objc_lookUpClass("_PFModelUtilities")
                                                                             x1:@{
                @"identifier": @[@(NSStringAttributeType)],
                @"statusNum": @[
                    @(NSInteger64AttributeType),
                    @YES, // isOptional
                    @0 // defaultValue
                ]
            }
                                                                             x2:exportOperation];
            
            // <+784>
            [OCSPIResolver _PFModelUtilities_addRelationships_toPropertiesOfEntity:objc_lookUpClass("_PFModelUtilities")
                                                                                x1:@{
                @"exportMetadata": @[
                    @1, // maxCount
                    exportMetadata,
                    @"operations"
                ],
                @"objects": @[
                    @0, // maxCount
                    exportedObject,
                    @(NSCascadeDeleteRule) // deleteRule
                ]
            }
                                                                                x2:exportOperation];
            
            // <+808>
            [OCSPIResolver _PFModelUtilities_addAttributes_toPropertiesOfEntity:objc_lookUpClass("_PFModelUtilities")
                                                                             x1:@{
                @"changeTypeNum": @[
                    @(NSInteger64AttributeType),
                    @YES, // isOptional
                    @0 // defaultValue
                ],
                @"ckRecordName": @[
                    @(NSStringAttributeType)
                ],
                @"typeNum": @[
                    @(NSInteger64AttributeType),
                    @YES, // isOptional
                    @0 // defaultValue
                ],
                
            }
                                                                             x2:exportedObject];
            
            // <+892>
            [OCSPIResolver _PFModelUtilities_addRelationships_toPropertiesOfEntity:objc_lookUpClass("_PFModelUtilities")
                                                                                x1:@{
                @"operation": @[
                    @1, // maxCount
                    exportOperation,
                    @"objects" // inverse
                ]
            }
                                                                                x2:exportedObject];
            
            // <+896>
            // x19
            NSEntityDescription *importOperation = [[NSEntityDescription alloc] init];
            importOperation.name = NSStringFromClass(objc_lookUpClass("NSCKImportOperation"));
            // original : NSCKImportOperation
            importOperation.managedObjectClassName = NSStringFromClass([OCCKImportOperation class]);
            
            // x22
            NSEntityDescription *importPendingRelationship = [[NSEntityDescription alloc] init];
            importPendingRelationship.name = NSStringFromClass(objc_lookUpClass("ImportPendingRelationship"));
            // original : ImportPendingRelationship
            importPendingRelationship.managedObjectClassName = NSStringFromClass([OCCKImportPendingRelationship class]);
            
            [OCSPIResolver _PFModelUtilities_addAttributes_toPropertiesOfEntity:objc_lookUpClass("_PFModelUtilities")
                                                                             x1:@{
                @"changeTokenBytes": @[@(NSBinaryDataAttributeType)],
                @"importDate": @[@(NSDateAttributeType)],
                @"operationUUID": @[@(NSUUIDAttributeType)]
            }
                                                                             x2:importOperation];
            
            [OCSPIResolver _PFModelUtilities_addRelationships_toPropertiesOfEntity:objc_lookUpClass("_PFModelUtilities")
                                                                                x1:@{
                @"pendingRelationships": @[
                    @0, // maxCount
                    importPendingRelationship
                ]
            }
                                                                                x2:importOperation];
            
            [OCSPIResolver _PFModelUtilities_addAttributes_toPropertiesOfEntity:objc_lookUpClass("_PFModelUtilities")
                                                                             x1:@{
                @"cdEntityName": @[@(NSStringAttributeType)],
                @"needsDelete": @[
                    @(NSBooleanAttributeType),
                    @YES, // isOptional
                    @NO // defaultValue
                ],
                @"recordName": @[@(NSStringAttributeType)],
                @"recordZoneName": @[
                    @(NSStringAttributeType),
                    @NO // isOptional
                ],
                @"recordZoneOwnerName": @[
                    @(NSStringAttributeType),
                    @NO // isOptional
                ],
                @"relatedEntityName": @[@(NSStringAttributeType)],
                @"relatedRecordName": @[@(NSStringAttributeType)],
                @"relatedRecordZoneName": @[
                    @(NSStringAttributeType),
                    @NO // isOptional
                ],
                @"relatedRecordZoneOwnerName": @[
                    @(NSStringAttributeType),
                    @NO // isOptional
                ],
                @"relationshipName": @[@(NSStringAttributeType)]
            }
                                                                             x2:importPendingRelationship];
            
            // <+1236>
            [OCSPIResolver _PFModelUtilities_addRelationships_toPropertiesOfEntity:objc_lookUpClass("_PFModelUtilities")
                                                                                x1:@{
                @"operation": @[
                    @1, // maxCount
                    importOperation,
                    @"pendingRelationships" // inverse
                ]
            }
                                                                                x2:importPendingRelationship];
            
            // <+1528>
            [OCSPIResolver _PFModelUtilities_addAttributes_toPropertiesOfEntity:objc_lookUpClass("_PFModelUtilities")
                                                                             x1:@{
                @"cdEntityName": @[@(NSStringAttributeType)],
                @"ckRecordID": @[@(NSStringAttributeType)],
                @"ckRecordSystemFields": @[@(NSBinaryDataAttributeType)],
                @"isPending": @[
                    @(NSBooleanAttributeType),
                    @YES, // isOptional
                    @NO // defaultValue
                ],
                @"isUploaded": @[
                    @(NSBooleanAttributeType),
                    @YES, // isOptional
                    @NO // defaultValue
                ],
                @"needsDelete": @[
                    @(NSBooleanAttributeType),
                    @YES, // isOptional
                    @NO // defaultValue
                ],
                @"recordName": @[@(NSStringAttributeType)],
                @"relatedEntityName": @[@(NSStringAttributeType)],
                @"relatedRecordName": @[@(NSStringAttributeType)],
                @"relationshipName": @[@(NSStringAttributeType)]
            }
                                                                             x2:mirroredRelationship];
            
            // sp, #0x58
            NSEntityDescription *recordZoneMetadata = [[NSEntityDescription alloc] init];
            recordZoneMetadata.name = NSStringFromClass(objc_lookUpClass("NSCKRecordZoneMetadata"));
            // original : NSCKRecordZoneMetadata
            recordZoneMetadata.managedObjectClassName = NSStringFromClass([OCCKRecordZoneMetadata class]);
            
            // sp, #0x68
            NSEntityDescription *recordMetadata = [[NSEntityDescription alloc] init];
            recordMetadata.name = NSStringFromClass(objc_lookUpClass("NSCKRecordMetadata"));
            // original : NSCKRecordMetadata
            recordMetadata.managedObjectClassName = NSStringFromClass([OCCKRecordMetadata class]);
            
            // sp
            NSEntityDescription *metadataEntry = [[NSEntityDescription alloc] init];
            metadataEntry.name = NSStringFromClass(objc_lookUpClass("NSCKMetadataEntry"));
            // original : NSCKMetadataEntry
            metadataEntry.managedObjectClassName = NSStringFromClass([OCCKMetadataEntry class]);
            
            // x23
            NSEntityDescription *databaseMetadata = [[NSEntityDescription alloc] init];
            databaseMetadata.name = NSStringFromClass(objc_lookUpClass("NSCKDatabaseMetadata"));
            // original : NSCKDatabaseMetadata
            databaseMetadata.managedObjectClassName = NSStringFromClass([OCCKDatabaseMetadata class]);
            
            // <+2040>
            [OCSPIResolver _PFModelUtilities_addAttributes_toPropertiesOfEntity:objc_lookUpClass("_PFModelUtilities")
                                                                             x1:@{
                @"boolValueNum": @[@(NSInteger16AttributeType)],
                @"dateValue": @[@(NSDateAttributeType)],
                @"integerValue": @[@(NSInteger64AttributeType)],
                @"key": @[
                    @(NSStringAttributeType),
                    @NO // isOptional
                ],
                @"stringValue": @[@(NSStringAttributeType)],
                @"transformedValue": @[
                    @(NSTransformableAttributeType),
                    @YES, // isOptional
                    [NSNull null],
                    // original : @"com.apple.CoreData.cloudkit.metadata.transformer"
                    @"com.pookjw.OpenCloudData.cloudkit.metadata.transformer"
                ]
            }
                                                                             x2:metadataEntry];
            
            // <+2252>
            [OCSPIResolver _PFModelUtilities_addAttributes_toPropertiesOfEntity:objc_lookUpClass("_PFModelUtilities")
                                                                             x1:@{
                @"currentChangeToken": @[
                    @(NSTransformableAttributeType),
                    @YES, // isOptional
                    [CKServerChangeToken class], // original : getCloudKitCKServerChangeTokenClass
                    // original : @"com.apple.CoreData.cloudkit.metadata.transformer"
                    @"com.pookjw.OpenCloudData.cloudkit.metadata.transformer"
                ],
                @"databaseName": @[
                    @(NSStringAttributeType),
                    @NO // isOptional
                ],
                @"databaseScopeNum": @[
                    @(NSInteger16AttributeType),
                    @NO // isOptional
                ],
                @"hasSubscriptionNum": @[
                    @(NSInteger16AttributeType),
                    @YES, // isOptional
                    @0 // defaultValue
                ],
                @"lastFetchDate": @[
                    @(NSDateAttributeType),
                    @YES // isOptional
                ]
            }
                                                                             x2:databaseMetadata];
            
            databaseMetadata.uniquenessConstraints = @[@[@"databaseScopeNum"]];
            
            [OCSPIResolver _PFModelUtilities_addAttributes_toPropertiesOfEntity:objc_lookUpClass("_PFModelUtilities")
                                                                             x1:@{
                @"ckOwnerName": @[
                    @(NSStringAttributeType),
                    @NO // isOptional
                ],
                @"ckRecordZoneName": @[
                    @(NSStringAttributeType),
                    @NO // isOptional
                ],
                @"currentChangeToken": @[
                    @(NSTransformableAttributeType),
                    @YES, // isOptional
                    [CKServerChangeToken class], // original : getCloudKitCKServerChangeTokenClass
                    // original : @"com.apple.CoreData.cloudkit.metadata.transformer"
                    @"com.pookjw.OpenCloudData.cloudkit.metadata.transformer"
                ],
                @"encodedShareData": @[
                    @(NSBinaryDataAttributeType),
                    @YES
                ],
                @"hasRecordZoneNum": @[
                    @(NSInteger16AttributeType),
                    @YES, // isOptional
                    @0 // defaultValue
                ],
                @"hasSubscriptionNum": @[
                    @(NSInteger16AttributeType),
                    @YES, // isOptional
                    @0 // defaultValue
                ],
                @"lastFetchDate": @[
                    @(NSDateAttributeType),
                    @YES, // isOptional
                ],
                @"needsImport": @[
                    @(NSBooleanAttributeType),
                    @YES, // isOptional
                    @0 // defaultValue
                ],
                @"needsNewShareInvitation": @[
                    @(NSBooleanAttributeType),
                    @YES, // isOptional
                    @0 // defaultValue
                ],
                @"needsRecoveryFromIdentityLoss": @[
                    @(NSBooleanAttributeType),
                    @YES, // isOptional
                    @0 // defaultValue
                ],
                @"needsRecoveryFromUserPurge": @[
                    @(NSBooleanAttributeType),
                    @YES, // isOptional
                    @0 // defaultValue
                ],
                @"needsRecoveryFromZoneDelete": @[
                    @(NSBooleanAttributeType),
                    @YES, // isOptional
                    @0 // defaultValue
                ],
                @"needsShareDelete": @[
                    @(NSBooleanAttributeType),
                    @YES, // isOptional
                    @0 // defaultValue
                ],
                @"needsShareUpdate": @[
                    @(NSBooleanAttributeType),
                    @YES, // isOptional
                    @0 // defaultValue
                ],
                @"supportsAtomicChanges": @[
                    @(NSBooleanAttributeType),
                    @YES, // isOptional
                    @0 // defaultValue
                ],
                @"supportsFetchChanges": @[
                    @(NSBooleanAttributeType),
                    @YES, // isOptional
                    @0 // defaultValue
                ],
                @"supportsRecordSharing": @[
                    @(NSBooleanAttributeType),
                    @YES, // isOptional
                    @0 // defaultValue
                ],
                @"supportsZoneSharing": @[
                    @(NSBooleanAttributeType),
                    @YES, // isOptional
                    @0 // defaultValue
                ]
            }
                                                                             x2:recordZoneMetadata];
            
            // <+3104>
            [OCSPIResolver _PFModelUtilities_addAttributes_toPropertiesOfEntity:objc_lookUpClass("_PFModelUtilities")
                                                                             x1:@{
                @"ckRecordName": @[
                    @(NSStringAttributeType),
                    @NO, // isOptional
                ],
                @"ckRecordSystemFields": @[@(NSBinaryDataAttributeType)],
                @"ckShare": @[@(NSBinaryDataAttributeType)],
                @"encodedRecord": @[
                    @(NSBinaryDataAttributeType),
                    @YES, // isOptional
                    @YES // allowsExternalBinaryDataStorage
                ],
                @"entityId": @[
                    @(NSInteger64AttributeType),
                    @NO // isOptional
                ],
                @"entityPK": @[
                    @(NSInteger64AttributeType),
                    @NO // isOptional
                ],
                @"lastExportedTransactionNumber": @[
                    @(NSInteger64AttributeType),
                    @YES // isOptional
                ],
                @"needsCloudDelete": @[
                    @(NSBooleanAttributeType),
                    @YES, // isOptional
                    @NO // defaultValue
                ],
                @"needsLocalDelete": @[
                    @(NSBooleanAttributeType),
                    @YES, // isOptional
                    @NO // defaultValue
                ],
                @"needsUpload": @[
                    @(NSBooleanAttributeType),
                    @YES, // isOptional
                    @NO // defaultValue
                ],
                @"pendingExportChangeTypeNumber": @[
                    @(NSInteger16AttributeType),
                    @YES // isOptional
                ],
                @"pendingExportTransactionNumber": @[
                    @(NSInteger64AttributeType),
                    @YES // isOptional
                ]
            }
                                                                             x2:recordMetadata];
            
            // <+3244>
            [OCSPIResolver _PFModelUtilities_addRelationships_toPropertiesOfEntity:objc_lookUpClass("_PFModelUtilities")
                                                                                x1:@{
                @"recordZone": @[
                    @1, // maxCount
                    recordZoneMetadata,
                    [NSNull null], // inverse
                    @(NSNullifyDeleteRule), // deleteRule
                    @YES, // isOptional
                ]
            }
                                                                                x2:mirroredRelationship];
            
            // <+3368>
            [OCSPIResolver _PFModelUtilities_addRelationships_toPropertiesOfEntity:objc_lookUpClass("_PFModelUtilities")
                                                                                x1:@{
                @"recordZones": @[
                    @0, // maxCount
                    recordZoneMetadata,
                    [NSNull null],
                    @(NSCascadeDeleteRule) // deleteRule
                ]
            }
                                                                                x2:databaseMetadata];
            
            // <+3484>
            [OCSPIResolver _PFModelUtilities_addRelationships_toPropertiesOfEntity:objc_lookUpClass("_PFModelUtilities")
                                                                                x1:@{
                @"database": @[
                    @1, // maxCount
                    databaseMetadata,
                    @"recordZones",
                    @(NSNullifyDeleteRule), // deleteRule
                    @NO // isOptional
                ]
            }
                                                                                x2:recordZoneMetadata];
            
            // <+3660>
            [OCSPIResolver _PFModelUtilities_addRelationships_toPropertiesOfEntity:objc_lookUpClass("_PFModelUtilities")
                                                                                x1:@{
                @"mirroredRelationships": @[
                    @0, // maxCount
                    mirroredRelationship,
                    @"recordZone", // inverse
                    @(NSCascadeDeleteRule) // deleteRule
                ],
                @"records": @[
                    @0, // maxCount
                    recordMetadata,
                    [NSNull null], // inverse
                    @(NSCascadeDeleteRule) // deleteRule
                ]
            }
                                                                                x2:recordZoneMetadata];
            
            // <+3772>
            [OCSPIResolver _PFModelUtilities_addRelationships_toPropertiesOfEntity:objc_lookUpClass("_PFModelUtilities")
                                                                                x1:@{
                @"recordZone": @[
                    @1, // maxCount
                    recordZoneMetadata,
                    @"records", // inverse
                    @(NSNullifyDeleteRule), // deleteRule
                    @NO // isOptional
                ]
            }
                                                                                x2:recordMetadata];
            
            recordZoneMetadata.uniquenessConstraints = @[
                @[@"ckRecordZoneName", @"ckOwnerName", @"database"]
            ];
            mirroredRelationship.uniquenessConstraints = @[
                @[@"ckRecordID", @"recordZone"]
            ];
            
            // <+3832>
            abort();
        }
    });
    
    return [result retain];
}

@end
