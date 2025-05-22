//
//  OCMirroredManyToManyRelationshipTests.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/12/25.
//

#import <XCTest/XCTest.h>
#import "OpenCloudData/Private/MirroredRelationship/OCMirroredManyToManyRelationship.h"
#import "OpenCloudData/SPI/CoreData/MirroredRelationship/PFMirroredManyToManyRelationship.h"
#import "OpenCloudData/SPI/OCSPIResolver.h"
#import "OpenCloudData/Helper/_OCDirectMethodResolver.h"
#import <objc/runtime.h>

@interface OCMirroredManyToManyRelationshipTests : XCTestCase
@end

@implementation OCMirroredManyToManyRelationshipTests

- (NSDictionary<NSString *, id> *)_makeDemo {
    NSEntityDescription *parentEntity = [[NSEntityDescription alloc] init];
    parentEntity.name = @"Parent";
    NSEntityDescription *childEntity = [[NSEntityDescription alloc] init];
    childEntity.name = @"Child";
    
    NSRelationshipDescription *parentRelationship = [[NSRelationshipDescription alloc] init];
    NSRelationshipDescription *childrenRelationship = [[NSRelationshipDescription alloc] init];
    
    childrenRelationship.destinationEntity = childEntity;
    childrenRelationship.minCount = 0;
    childrenRelationship.maxCount = 0;
    childrenRelationship.name = @"children";
    childrenRelationship.ordered = NO;
    childrenRelationship.inverseRelationship = parentRelationship;
    
    parentRelationship.destinationEntity = parentEntity;
    parentRelationship.minCount = 0;
    parentRelationship.maxCount = 0;
    parentRelationship.name = @"parents";
    parentRelationship.ordered = NO;
    parentRelationship.inverseRelationship = childrenRelationship;
    
    parentEntity.properties = @[childrenRelationship];
    childEntity.properties = @[parentRelationship];
    
    NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel alloc] init];
    managedObjectModel.entities = @[parentEntity, childEntity];
    
    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    
    __block NSManagedObject *parentObject;
    __block NSManagedObject *childObject;
    
    [managedObjectContext performBlockAndWait:^{
        parentObject = [[NSManagedObject alloc] initWithEntity:parentEntity insertIntoManagedObjectContext:managedObjectContext];
        childObject = [[NSManagedObject alloc] initWithEntity:childEntity insertIntoManagedObjectContext:managedObjectContext];
        
        [parentObject setValue:[NSSet setWithObject:childObject] forKey:childrenRelationship.name];
        [childObject setValue:[NSSet setWithObject:parentObject] forKey:parentRelationship.name];
    }];
    
    CKRecordZoneID *zoneID = [[CKRecordZoneID alloc] initWithZoneName:@"Test 1" ownerName:@"Test 1"];
    CKRecordID *recordName = [[CKRecordID alloc] initWithRecordName:@"Test1:Test2" zoneID:zoneID];
    
    CKRecordZoneID *relatedZoneID = [[CKRecordZoneID alloc] initWithZoneName:@"Test 2" ownerName:@"Test 2"];
    CKRecordID *relatedRecordName = [[CKRecordID alloc] initWithRecordName:@"Test3:Test4" zoneID:relatedZoneID];
    
    NSDictionary<NSString *, id> *result = @{
        @"parentEntity": parentEntity,
        @"childEntity": childEntity,
        @"parentRelationship": parentRelationship,
        @"childrenRelationship": childrenRelationship,
        @"managedObjectModel": managedObjectModel,
        @"parentObject": parentObject,
        @"childObject": childObject,
        @"managedObjectContext": managedObjectContext,
        @"recordName": recordName,
        @"relatedRecordName": relatedRecordName
    };
    
    [parentEntity release];
    [childEntity release];
    [parentRelationship release];
    [childrenRelationship release];
    [managedObjectModel release];
    [parentObject release];
    [childObject release];
    [managedObjectContext release];
    [zoneID release];
    [recordName release];
    [relatedZoneID release];
    [relatedRecordName release];
    
    return result;
}

- (void)test__isValidMirroredRelationshipRecord_values_ {
    {
        CKRecord *record = [[CKRecord alloc] initWithRecordType:@"ABC"];
        
        Ivar ivar = object_getInstanceVariable(record, "_recordType", NULL);
        XCTAssertNotEqual(ivar, NULL);
        *(id *)((uint64_t)record + ivar_getOffset(ivar)) = [@"" copy];
        
        XCTAssertFalse([OCMirroredManyToManyRelationship _isValidMirroredRelationshipRecord:record values:record]);
        XCTAssertFalse([objc_lookUpClass("PFMirroredManyToManyRelationship") _isValidMirroredRelationshipRecord:record values:record]);
        [record release];
    }
    
    {
        CKRecord *record = [[CKRecord alloc] initWithRecordType:@"Test"];
        XCTAssertTrue([OCMirroredManyToManyRelationship _isValidMirroredRelationshipRecord:record values:record]);
        XCTAssertTrue([objc_lookUpClass("PFMirroredManyToManyRelationship") _isValidMirroredRelationshipRecord:record values:record]);
        [record release];
    }
}

- (void)test_ckRecordTypeForOrderedRelationships_ {
    NSDictionary<NSString *, id> *demo = [self _makeDemo];
    NSArray<NSRelationshipDescription *> *relationships = @[
        demo[@"parentRelationship"],
        demo[@"childrenRelationship"]
    ];
    
    XCTAssertEqualObjects([_OCDirectMethodResolver OCMirroredManyToManyRelationship:[OCMirroredManyToManyRelationship class] ckRecordTypeForOrderedRelationships:relationships], [OCSPIResolver PFMirroredManyToManyRelationship_ckRecordTypeForOrderedRelationships_:objc_lookUpClass("PFMirroredManyToManyRelationship") x1:relationships]);
}

- (void)test_ckRecordNameForOrderedRecordNames_ {
    NSArray<NSString *> *recordNames = @[
        @"Test 1",
        @"Test 2"
    ];
    
    XCTAssertEqualObjects([_OCDirectMethodResolver OCMirroredManyToManyRelationship:[OCMirroredManyToManyRelationship class] ckRecordNameForOrderedRecordNames:recordNames], [OCSPIResolver PFMirroredManyToManyRelationship_ckRecordNameForOrderedRecordNames_:objc_lookUpClass("PFMirroredManyToManyRelationship") x1:recordNames]);
}

- (void)test_init {
    NSDictionary<NSString *, id> *demo = [self _makeDemo];
    
    OCMirroredManyToManyRelationship *impl = [[OCMirroredManyToManyRelationship alloc] initWithRecordID:demo[@"recordName"] recordType:@"CD_M2M_Parent_children" managedObjectModel:demo[@"managedObjectModel"] andType:1];
    XCTAssertNotNil(impl);
    
    PFMirroredManyToManyRelationship *platform = [[objc_lookUpClass("PFMirroredManyToManyRelationship") alloc] initWithRecordID:demo[@"recordName"] recordType:@"CD_M2M_Parent_children" managedObjectModel:demo[@"managedObjectModel"] andType:1];
    XCTAssertNotNil(platform);
    
    {
        NSUInteger type_1;
        {
            Ivar ivar = object_getInstanceVariable(impl, "_type", NULL);
            XCTAssertNotEqual(ivar, NULL);
            type_1 = *(NSUInteger *)((uint64_t)impl + ivar_getOffset(ivar));
        }
        NSUInteger type_2;
        {
            Ivar ivar = object_getInstanceVariable(platform, "_type", NULL);
            XCTAssertNotEqual(ivar, NULL);
            type_2 = *(NSUInteger *)((uint64_t)platform + ivar_getOffset(ivar));
        }
        XCTAssertEqual(type_1, type_2);
    }
    
    {
        NSRelationshipDescription *relationshipDescription_1;
        {
            Ivar ivar = object_getInstanceVariable(impl, "_relationshipDescription", NULL);
            XCTAssertNotEqual(ivar, NULL);
            relationshipDescription_1 = *(id *)((uint64_t)impl + ivar_getOffset(ivar));
        }
        NSRelationshipDescription *relationshipDescription_2;
        {
            Ivar ivar = object_getInstanceVariable(platform, "_relationshipDescription", NULL);
            XCTAssertNotEqual(ivar, NULL);
            relationshipDescription_2 = *(id *)((uint64_t)platform + ivar_getOffset(ivar));
        }
        XCTAssertEqualObjects(relationshipDescription_1, relationshipDescription_2);
    }
    
    {
        NSRelationshipDescription *inverseRelationshipDescription_1;
        {
            Ivar ivar = object_getInstanceVariable(impl, "_inverseRelationshipDescription", NULL);
            XCTAssertNotEqual(ivar, NULL);
            inverseRelationshipDescription_1 = *(id *)((uint64_t)impl + ivar_getOffset(ivar));
        }
        NSRelationshipDescription *inverseRelationshipDescription_2;
        {
            Ivar ivar = object_getInstanceVariable(platform, "_inverseRelationshipDescription", NULL);
            XCTAssertNotEqual(ivar, NULL);
            inverseRelationshipDescription_2 = *(id *)((uint64_t)platform + ivar_getOffset(ivar));
        }
        XCTAssertEqualObjects(inverseRelationshipDescription_1, inverseRelationshipDescription_2);
    }
    
    {
        CKRecordID *manyToManyRecordID_1;
        {
            Ivar ivar = object_getInstanceVariable(impl, "_manyToManyRecordID", NULL);
            XCTAssertNotEqual(ivar, NULL);
            manyToManyRecordID_1 = *(id *)((uint64_t)impl + ivar_getOffset(ivar));
        }
        CKRecordID *manyToManyRecordID_2;
        {
            Ivar ivar = object_getInstanceVariable(platform, "_manyToManyRecordID", NULL);
            XCTAssertNotEqual(ivar, NULL);
            manyToManyRecordID_2 = *(id *)((uint64_t)platform + ivar_getOffset(ivar));
        }
        XCTAssertEqualObjects(manyToManyRecordID_1, manyToManyRecordID_2);
    }
    
    {
        CKRecordType manyToManyRecordType_1;
        {
            Ivar ivar = object_getInstanceVariable(impl, "_manyToManyRecordType", NULL);
            XCTAssertNotEqual(ivar, NULL);
            manyToManyRecordType_1 = *(CKRecordType *)((uint64_t)impl + ivar_getOffset(ivar));
        }
        CKRecordType manyToManyRecordType_2;
        {
            Ivar ivar = object_getInstanceVariable(platform, "_manyToManyRecordType", NULL);
            XCTAssertNotEqual(ivar, NULL);
            manyToManyRecordType_2 = *(CKRecordType *)((uint64_t)platform + ivar_getOffset(ivar));
        }
        XCTAssertEqualObjects(manyToManyRecordType_1, manyToManyRecordType_2);
    }
    
    {
        CKRecordID *ckRecordID_1;
        {
            Ivar ivar = object_getInstanceVariable(impl, "_ckRecordID", NULL);
            XCTAssertNotEqual(ivar, NULL);
            ckRecordID_1 = *(id *)((uint64_t)impl + ivar_getOffset(ivar));
        }
        CKRecordID *ckRecordID_2;
        {
            Ivar ivar = object_getInstanceVariable(platform, "_ckRecordID", NULL);
            XCTAssertNotEqual(ivar, NULL);
            ckRecordID_2 = *(id *)((uint64_t)platform + ivar_getOffset(ivar));
        }
        XCTAssertEqualObjects(ckRecordID_1, ckRecordID_2);
    }
    
    {
        CKRecordID *relatedCKRecordID_1;
        {
            Ivar ivar = object_getInstanceVariable(impl, "_relatedCKRecordID", NULL);
            XCTAssertNotEqual(ivar, NULL);
            relatedCKRecordID_1 = *(id *)((uint64_t)impl + ivar_getOffset(ivar));
        }
        CKRecordID *relatedCKRecordID_2;
        {
            Ivar ivar = object_getInstanceVariable(platform, "_relatedCKRecordID", NULL);
            XCTAssertNotEqual(ivar, NULL);
            relatedCKRecordID_2 = *(id *)((uint64_t)platform + ivar_getOffset(ivar));
        }
        XCTAssertEqualObjects(relatedCKRecordID_1, relatedCKRecordID_2);
    }
    
    [impl release];
    [platform release];
}

- (void)test_updateRelationshipValueUsingImportContext_andManagedObjectContext_error_ {
    NSDictionary<NSString *, id> *demo = [self _makeDemo];
    
    NSMutableDictionary<CKRecordType, NSMutableDictionary<CKRecordID *, NSManagedObjectID *> *> *recordTypeToRecordIDToObjectID = [[NSMutableDictionary alloc] init];
    {
        NSMutableDictionary<CKRecordID *, NSManagedObjectID *> *recordIDToObjectID = [[NSMutableDictionary alloc] init];
        
        CKRecordID *recordID = [[CKRecordID alloc] initWithRecordName:@"Test1" zoneID:((CKRecordID *)demo[@"recordName"]).zoneID];
        [recordIDToObjectID setObject:((NSManagedObject *)demo[@"parentObject"]).objectID forKey:recordID];
        [recordID release];
        
        [recordTypeToRecordIDToObjectID setObject:recordIDToObjectID forKey:((NSRelationshipDescription *)demo[@"childrenRelationship"]).entity.name];
        [recordIDToObjectID release];
    }
    {
        NSMutableDictionary<CKRecordID *, NSManagedObjectID *> *recordIDToObjectID = [[NSMutableDictionary alloc] init];
        
        CKRecordID *relatedRecordID = [[CKRecordID alloc] initWithRecordName:@"Test2" zoneID:((CKRecordID *)demo[@"recordName"]).zoneID];
        [recordIDToObjectID setObject:((NSManagedObject *)demo[@"childObject"]).objectID forKey:relatedRecordID];
        [relatedRecordID release];
        
        [recordTypeToRecordIDToObjectID setObject:recordIDToObjectID forKey:((NSRelationshipDescription *)demo[@"parentRelationship"]).entity.name];
        [recordIDToObjectID release];
    }
    
    //
    
    {
        OCMirroredManyToManyRelationship *impl = [[OCMirroredManyToManyRelationship alloc] initWithRecordID:demo[@"recordName"] recordType:@"CD_M2M_Parent_children" managedObjectModel:demo[@"managedObjectModel"] andType:0];
        XCTAssertNotNil(impl);
        
        OCCloudKitImportZoneContext *importContext_impl = [[OCCloudKitImportZoneContext alloc] init];
        {
            Ivar ivar = object_getInstanceVariable(importContext_impl, "_recordTypeToRecordIDToObjectID", NULL);
            XCTAssertNotEqual(ivar, NULL);
            
            *(id *)((uintptr_t)importContext_impl + ivar_getOffset(ivar)) = [recordTypeToRecordIDToObjectID mutableCopy];
        }
        
        NSError * _Nullable error = nil;
        XCTAssertTrue([impl updateRelationshipValueUsingImportContext:importContext_impl andManagedObjectContext:demo[@"managedObjectContext"] error:&error]);
        XCTAssertNil(error);
        
        {
            NSSet<NSManagedObject *> *children = [(NSManagedObject *)demo[@"parentObject"] valueForKey:((NSRelationshipDescription *)demo[@"childrenRelationship"]).name];
            XCTAssertNotNil(children);
            XCTAssertTrue([children containsObject:demo[@"childObject"]]);
        }
    }
    
    {
        OCMirroredManyToManyRelationship *impl = [[OCMirroredManyToManyRelationship alloc] initWithRecordID:demo[@"recordName"] recordType:@"CD_M2M_Parent_children" managedObjectModel:demo[@"managedObjectModel"] andType:1];
        XCTAssertNotNil(impl);
        
        OCCloudKitImportZoneContext *importContext_impl = [[OCCloudKitImportZoneContext alloc] init];
        {
            Ivar ivar = object_getInstanceVariable(importContext_impl, "_recordTypeToRecordIDToObjectID", NULL);
            XCTAssertNotEqual(ivar, NULL);
            
            *(id *)((uintptr_t)importContext_impl + ivar_getOffset(ivar)) = [recordTypeToRecordIDToObjectID mutableCopy];
        }
        
        NSError * _Nullable error = nil;
        XCTAssertTrue([impl updateRelationshipValueUsingImportContext:importContext_impl andManagedObjectContext:demo[@"managedObjectContext"] error:&error]);
        XCTAssertNil(error);
        
        {
            NSSet<NSManagedObject *> *children = [(NSManagedObject *)demo[@"parentObject"] valueForKey:((NSRelationshipDescription *)demo[@"childrenRelationship"]).name];
            XCTAssertNotNil(children);
            XCTAssertFalse([children containsObject:demo[@"childObject"]]);
        }
        
        [impl release];
        [importContext_impl release];
    }
    
    //
    
    {
        PFMirroredManyToManyRelationship *platform = [[objc_lookUpClass("PFMirroredManyToManyRelationship") alloc] initWithRecordID:demo[@"recordName"] recordType:@"CD_M2M_Parent_children" managedObjectModel:demo[@"managedObjectModel"] andType:0];
        XCTAssertNotNil(platform);
        
        PFCloudKitImportZoneContext *importContext_platform = [[objc_lookUpClass("PFCloudKitImportZoneContext") alloc] init];
        {
            Ivar ivar = object_getInstanceVariable(importContext_platform, "_recordTypeToRecordIDToObjectID", NULL);
            XCTAssertNotEqual(ivar, NULL);
            
            *(id *)((uintptr_t)importContext_platform + ivar_getOffset(ivar)) = [recordTypeToRecordIDToObjectID mutableCopy];
        }
        
        NSError * _Nullable error = nil;
        XCTAssertTrue([platform updateRelationshipValueUsingImportContext:importContext_platform andManagedObjectContext:demo[@"managedObjectContext"] error:&error]);
        XCTAssertNil(error);
        
        {
            NSSet<NSManagedObject *> *children = [(NSManagedObject *)demo[@"parentObject"] valueForKey:((NSRelationshipDescription *)demo[@"childrenRelationship"]).name];
            XCTAssertNotNil(children);
            XCTAssertTrue([children containsObject:demo[@"childObject"]]);
        }
        
        [platform release];
        [importContext_platform release];
    }
    
    {
        PFMirroredManyToManyRelationship *platform = [[objc_lookUpClass("PFMirroredManyToManyRelationship") alloc] initWithRecordID:demo[@"recordName"] recordType:@"CD_M2M_Parent_children" managedObjectModel:demo[@"managedObjectModel"] andType:1];
        XCTAssertNotNil(platform);
        
        PFCloudKitImportZoneContext *importContext_platform = [[objc_lookUpClass("PFCloudKitImportZoneContext") alloc] init];
        {
            Ivar ivar = object_getInstanceVariable(importContext_platform, "_recordTypeToRecordIDToObjectID", NULL);
            XCTAssertNotEqual(ivar, NULL);
            
            *(id *)((uintptr_t)importContext_platform + ivar_getOffset(ivar)) = [recordTypeToRecordIDToObjectID mutableCopy];
        }
        
        NSError * _Nullable error = nil;
        XCTAssertTrue([platform updateRelationshipValueUsingImportContext:importContext_platform andManagedObjectContext:demo[@"managedObjectContext"] error:&error]);
        XCTAssertNil(error);
        
        {
            NSSet<NSManagedObject *> *children = [(NSManagedObject *)demo[@"parentObject"] valueForKey:((NSRelationshipDescription *)demo[@"childrenRelationship"]).name];
            XCTAssertNotNil(children);
            XCTAssertFalse([children containsObject:demo[@"childObject"]]);
        }
        
        [platform release];
        [importContext_platform release];
    }
}

@end
