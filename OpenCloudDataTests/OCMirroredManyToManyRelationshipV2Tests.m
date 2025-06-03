//
//  OCMirroredManyToManyRelationshipV2Tests.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/12/25.
//

#import <XCTest/XCTest.h>
#import "OpenCloudData/Private/MirroredRelationship/OCMirroredManyToManyRelationshipV2.h"
#import "OpenCloudData/SPI/CoreData/MirroredRelationship/PFMirroredManyToManyRelationshipV2.h"
#import "OpenCloudData/SPI/OCSPIResolver.h"
#import "OpenCloudData/Helper/_OCDirectMethodResolver.h"
#include <objc/runtime.h>
#import "OCRecordKeyValueSettingImpl.h"

@interface OCMirroredManyToManyRelationshipV2Tests : XCTestCase
@end

@implementation OCMirroredManyToManyRelationshipV2Tests

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
        CKRecord *record = [[CKRecord alloc] initWithRecordType:@"Test"];
        OCRecordKeyValueSettingImpl *fakeRecord = [[OCRecordKeyValueSettingImpl alloc] init];
        [fakeRecord setObject:@"1" forKey:@"CD_recordNames"];
        [fakeRecord setObject:@"1" forKey:@"CD_relationships"];
        [fakeRecord setObject:@"1" forKey:@"CD_entityNames"];
        
        XCTAssertTrue([OCMirroredManyToManyRelationshipV2 _isValidMirroredRelationshipRecord:record values:fakeRecord]);
        XCTAssertTrue([objc_lookUpClass("PFMirroredManyToManyRelationshipV2") _isValidMirroredRelationshipRecord:record values:fakeRecord]);
        [record release];
        [fakeRecord release];
    }
    {
        CKRecord *record = [[CKRecord alloc] initWithRecordType:@"Test"];
        OCRecordKeyValueSettingImpl *fakeRecord = [[OCRecordKeyValueSettingImpl alloc] init];
        [fakeRecord setObject:@"" forKey:@"CD_recordNames"];
        [fakeRecord setObject:@"" forKey:@"CD_relationships"];
        [fakeRecord setObject:@"" forKey:@"CD_entityNames"];
        
        XCTAssertFalse([OCMirroredManyToManyRelationshipV2 _isValidMirroredRelationshipRecord:record values:fakeRecord]);
        XCTAssertFalse([objc_lookUpClass("PFMirroredManyToManyRelationshipV2") _isValidMirroredRelationshipRecord:record values:fakeRecord]);
        [record release];
        [fakeRecord release];
    }
}

- (void)test_initWithRecordID_forRecordWithID_relatedToRecordWithID_byRelationship_withInverse_andType_ {
    NSRelationshipDescription *relationship_1 = [[NSRelationshipDescription alloc] init];
    NSRelationshipDescription *relationship_2 = [[NSRelationshipDescription alloc] init];
    
    relationship_1.name = @"ABC";
    relationship_2.name = @"DEF";
    
    relationship_1.inverseRelationship = relationship_2;
    relationship_2.inverseRelationship = relationship_1;
    
    NSEntityDescription *entity_1 = [[NSEntityDescription alloc] init];
    entity_1.name = @"ABC";
    NSEntityDescription *entity_2 = [[NSEntityDescription alloc] init];
    entity_2.name = @"DEF";
    
    entity_1.properties = @[relationship_1];
    entity_2.properties = @[relationship_2];
    
    [self _test_initWithRecordID_forRecordWithID_relatedToRecordWithID_byRelationship_withInverse_andType_withRelationship:relationship_1 withInverseRelationship:relationship_2];
    
    entity_1.properties = @[relationship_2];
    entity_2.properties = @[relationship_1];
    
    [self _test_initWithRecordID_forRecordWithID_relatedToRecordWithID_byRelationship_withInverse_andType_withRelationship:relationship_1 withInverseRelationship:relationship_2];
    
    [relationship_1 release];
    [relationship_2 release];
    [entity_1 release];
    [entity_2 release];
}

- (void)_test_initWithRecordID_forRecordWithID_relatedToRecordWithID_byRelationship_withInverse_andType_withRelationship:(NSRelationshipDescription *)relationship withInverseRelationship:(NSRelationshipDescription *)inverseRelationship {
    CKRecordZoneID *manyToManyRecordZoneID = [[CKRecordZoneID alloc] initWithZoneName:@"Test 1" ownerName:@"Test 1"];
    CKRecordID *manyToManyRecordID = [[CKRecordID alloc] initWithRecordName:@"Test 1" zoneID:manyToManyRecordZoneID];
    [manyToManyRecordZoneID release];
    
    CKRecordZoneID *recordZoneID = [[CKRecordZoneID alloc] initWithZoneName:@"Test 2" ownerName:@"Test 2"];
    CKRecordID *recordID = [[CKRecordID alloc] initWithRecordName:@"Test 2" zoneID:recordZoneID];
    [recordZoneID release];
    
    CKRecordZoneID *relatedRecordZoneID = [[CKRecordZoneID alloc] initWithZoneName:@"Test 3" ownerName:@"Test 3"];
    CKRecordID *relatedRecordID = [[CKRecordID alloc] initWithRecordName:@"Test 3" zoneID:relatedRecordZoneID];
    [relatedRecordZoneID release];
    
    OCMirroredManyToManyRelationshipV2 *impl = [[OCMirroredManyToManyRelationshipV2 alloc] initWithRecordID:manyToManyRecordID forRecordWithID:recordID relatedToRecordWithID:relatedRecordID byRelationship:relationship withInverse:inverseRelationship andType:1];
    PFMirroredManyToManyRelationshipV2 *platform = [[objc_lookUpClass("PFMirroredManyToManyRelationshipV2") alloc] initWithRecordID:manyToManyRecordID forRecordWithID:recordID relatedToRecordWithID:relatedRecordID byRelationship:relationship withInverse:inverseRelationship andType:1];
    
    [manyToManyRecordID release];
    [recordID release];
    [relatedRecordID release];
    
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

- (void)test_initWithRecord_andValues_withManagedObjectModel_andType_ {
    NSDictionary<NSString *, id> *demo = [self _makeDemo];
    
    CKRecord *record = [[CKRecord alloc] initWithRecordType:@"Test"];
    
    OCRecordKeyValueSettingImpl *fakeValues = [[OCRecordKeyValueSettingImpl alloc] init];
    [fakeValues setObject:@"Child:Parent" forKey:@"CD_recordNames"];
    [fakeValues setObject:@"parents:children" forKey:@"CD_relationships"];
    [fakeValues setObject:@"Child:Parent" forKey:@"CD_entityNames"];
    
    OCMirroredManyToManyRelationshipV2 *impl = [[OCMirroredManyToManyRelationshipV2 alloc] initWithRecord:record andValues:fakeValues withManagedObjectModel:demo[@"managedObjectModel"] andType:1];
    PFMirroredManyToManyRelationshipV2 *platform = [[objc_lookUpClass("PFMirroredManyToManyRelationshipV2") alloc] initWithRecord:record andValues:fakeValues withManagedObjectModel:demo[@"managedObjectModel"] andType:1];
    
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

- (void)test_populateRecordValues_ {
    NSDictionary<NSString *, id> *demo = [self _makeDemo];
    CKRecord *record = [[CKRecord alloc] initWithRecordType:@"Test"];
    
    OCRecordKeyValueSettingImpl *recordValues = [[OCRecordKeyValueSettingImpl alloc] init];
    [recordValues setObject:@"Child:Parent" forKey:@"CD_recordNames"];
    [recordValues setObject:@"parents:children" forKey:@"CD_relationships"];
    [recordValues setObject:@"Child:Parent" forKey:@"CD_entityNames"];
    
    OCRecordKeyValueSettingImpl *recordValues_impl = [recordValues copy];
    OCMirroredManyToManyRelationshipV2 *impl = [[OCMirroredManyToManyRelationshipV2 alloc] initWithRecord:record andValues:recordValues_impl withManagedObjectModel:demo[@"managedObjectModel"] andType:1];
    [impl populateRecordValues:recordValues_impl];
    
    OCRecordKeyValueSettingImpl *recordValues_platform = [recordValues copy];
    PFMirroredManyToManyRelationshipV2 *platform = [[objc_lookUpClass("PFMirroredManyToManyRelationshipV2") alloc] initWithRecord:record andValues:recordValues_platform withManagedObjectModel:demo[@"managedObjectModel"] andType:1];
    [platform populateRecordValues:recordValues_platform];
    
    XCTAssertEqualObjects(recordValues_impl, recordValues_platform);
    
    [record release];
    [recordValues release];
    [recordValues_impl release];
    [recordValues_platform release];
}

@end
