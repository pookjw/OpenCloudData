//
//  OCMirroredOneToManyRelationshipTests.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/12/25.
//

#import <XCTest/XCTest.h>
#import "OpenCloudData/Private/MirroredRelationship/OCMirroredOneToManyRelationship.h"
#import "OpenCloudData/SPI/CoreData/MirroredRelationship/PFMirroredOneToManyRelationship.h"
#import "OpenCloudData/SPI/OCSPIResolver.h"
#import "OpenCloudData/Helper/_OCDirectMethodResolver.h"
#include <objc/runtime.h>

@interface OCMirroredOneToManyRelationshipTests : XCTestCase
@end

@implementation OCMirroredOneToManyRelationshipTests

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
    parentRelationship.maxCount = 1;
    parentRelationship.name = @"parent";
    parentRelationship.inverseRelationship = childrenRelationship;
    
    parentEntity.properties = @[childrenRelationship];
    childEntity.properties = @[parentRelationship];
    
    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    
    __block NSManagedObject *parentObject;
    __block NSManagedObject *childObject;
    
    [managedObjectContext performBlockAndWait:^{
        parentObject = [[NSManagedObject alloc] initWithEntity:parentEntity insertIntoManagedObjectContext:managedObjectContext];
        childObject = [[NSManagedObject alloc] initWithEntity:childEntity insertIntoManagedObjectContext:managedObjectContext];
        
        [parentObject setValue:[NSSet setWithObject:childObject] forKey:childrenRelationship.name];
        [childObject setValue:parentObject forKey:parentRelationship.name];
    }];
    
    CKRecordZoneID *zoneID = [[CKRecordZoneID alloc] initWithZoneName:@"Test 1" ownerName:@"Test 1"];
    CKRecordID *recordName = [[CKRecordID alloc] initWithRecordName:@"Test 1" zoneID:zoneID];
    
    CKRecordZoneID *relatedZoneID = [[CKRecordZoneID alloc] initWithZoneName:@"Test 2" ownerName:@"Test 2"];
    CKRecordID *relatedRecordName = [[CKRecordID alloc] initWithRecordName:@"Test 2" zoneID:relatedZoneID];
    
    NSDictionary<NSString *, id> *result = @{
        @"parentEntity": parentEntity,
        @"childEntity": childEntity,
        @"parentRelationship": parentRelationship,
        @"childrenRelationship": childrenRelationship,
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
    [parentObject release];
    [childObject release];
    [managedObjectContext release];
    [zoneID release];
    [recordName release];
    [relatedZoneID release];
    [relatedRecordName release];
    
    return result;
}

- (void)test_init {
    NSDictionary<NSString *, id> *demo = [self _makeDemo];
    
    OCMirroredOneToManyRelationship *impl = [[OCMirroredOneToManyRelationship alloc] initWithManagedObject:demo[@"childObject"] withRecordName:demo[@"relatedRecordName"] relatedToRecordWithRecordName:demo[@"recordName"] byRelationship:demo[@"parentRelationship"]];
    PFMirroredOneToManyRelationship *platform = [[objc_lookUpClass("PFMirroredOneToManyRelationship") alloc] initWithManagedObject:demo[@"childObject"] withRecordName:demo[@"relatedRecordName"] relatedToRecordWithRecordName:demo[@"recordName"] byRelationship:demo[@"parentRelationship"]];
    
    {
        NSRelationshipDescription *relationshipDescription_1;
        XCTAssertNotEqual(object_getInstanceVariable(impl, "_relationshipDescription", (void **)&relationshipDescription_1), NULL);
        NSRelationshipDescription *relationshipDescription_2;
        XCTAssertNotEqual(object_getInstanceVariable(platform, "_relationshipDescription", (void **)&relationshipDescription_2), NULL);
        XCTAssertEqualObjects(relationshipDescription_1, relationshipDescription_2);
    }
    
    {
        NSRelationshipDescription *inverseRelationshipDescription_1;
        XCTAssertNotEqual(object_getInstanceVariable(impl, "_inverseRelationshipDescription", (void **)&inverseRelationshipDescription_1), NULL);
        NSRelationshipDescription *inverseRelationshipDescription_2;
        XCTAssertNotEqual(object_getInstanceVariable(platform, "_inverseRelationshipDescription", (void **)&inverseRelationshipDescription_2), NULL);
        XCTAssertEqualObjects(inverseRelationshipDescription_1, inverseRelationshipDescription_2);
    }
    
    {
        CKRecordID *relatedRecordID_1;
        XCTAssertNotEqual(object_getInstanceVariable(impl, "_relatedRecordID", (void **)&relatedRecordID_1), NULL);
        NSRelationshipDescription *relatedRecordID_2;
        XCTAssertNotEqual(object_getInstanceVariable(platform, "_relatedRecordID", (void **)&relatedRecordID_2), NULL);
        XCTAssertEqualObjects(relatedRecordID_1, relatedRecordID_2);
    }
    
    {
        CKRecordID *recordID_1;
        XCTAssertNotEqual(object_getInstanceVariable(impl, "_recordID", (void **)&recordID_1), NULL);
        NSRelationshipDescription *recordID_2;
        XCTAssertNotEqual(object_getInstanceVariable(platform, "_recordID", (void **)&recordID_2), NULL);
        XCTAssertEqualObjects(recordID_1, recordID_2);
    }
    
    {
        NSRelationshipDescription *inverseRelationshipDescription_1;
        XCTAssertNotEqual(object_getInstanceVariable(impl, "_inverseRelationshipDescription", (void **)&inverseRelationshipDescription_1), NULL);
        NSRelationshipDescription *inverseRelationshipDescription_2;
        XCTAssertNotEqual(object_getInstanceVariable(platform, "_inverseRelationshipDescription", (void **)&inverseRelationshipDescription_2), NULL);
        XCTAssertEqualObjects(inverseRelationshipDescription_1, inverseRelationshipDescription_2);
    }
    
   
    [impl release];
    [platform release];
}

- (void)test_recordTypesToRecordIDs {
    NSDictionary<NSString *, id> *demo = [self _makeDemo];
    
    OCMirroredOneToManyRelationship *impl = [[OCMirroredOneToManyRelationship alloc] initWithManagedObject:demo[@"childObject"] withRecordName:demo[@"relatedRecordName"] relatedToRecordWithRecordName:demo[@"recordName"] byRelationship:demo[@"parentRelationship"]];
    PFMirroredOneToManyRelationship *platform = [[objc_lookUpClass("PFMirroredOneToManyRelationship") alloc] initWithManagedObject:demo[@"childObject"] withRecordName:demo[@"relatedRecordName"] relatedToRecordWithRecordName:demo[@"recordName"] byRelationship:demo[@"parentRelationship"]];
    
    XCTAssertEqualObjects([_OCDirectMethodResolver OCMirroredOneToManyRelationship_recordTypesToRecordIDs:impl], [OCSPIResolver PFMirroredOneToManyRelationship_recordTypesToRecordIDs:platform]);
    
    [impl release];
    [platform release];
}

- (void)test_updateRelationshipValueUsingImportContext_andManagedObjectContext_error_ {
    NSDictionary<NSString *, id> *demo = [self _makeDemo];
    
    OCMirroredOneToManyRelationship *impl = [[OCMirroredOneToManyRelationship alloc] initWithManagedObject:demo[@"childObject"] withRecordName:demo[@"relatedRecordName"] relatedToRecordWithRecordName:demo[@"recordName"] byRelationship:demo[@"parentRelationship"]];
    
    PFMirroredOneToManyRelationship *platform = [[objc_lookUpClass("PFMirroredOneToManyRelationship") alloc] initWithManagedObject:demo[@"childObject"] withRecordName:demo[@"relatedRecordName"] relatedToRecordWithRecordName:demo[@"recordName"] byRelationship:demo[@"parentRelationship"]];
    
    NSMutableDictionary<CKRecordType, NSMutableDictionary<CKRecordID *, NSManagedObjectID *> *> *recordTypeToRecordIDToObjectID = [[NSMutableDictionary alloc] init];
    {
        NSMutableDictionary<CKRecordID *, NSManagedObjectID *> *recordIDToObjectID = [[NSMutableDictionary alloc] init];
        [recordIDToObjectID setObject:((NSManagedObject *)demo[@"parentObject"]).objectID forKey:demo[@"recordName"]];
        [recordTypeToRecordIDToObjectID setObject:recordIDToObjectID forKey:((NSRelationshipDescription *)demo[@"childrenRelationship"]).entity.name];
        [recordIDToObjectID release];
    }
    {
        NSMutableDictionary<CKRecordID *, NSManagedObjectID *> *recordIDToObjectID = [[NSMutableDictionary alloc] init];
        [recordIDToObjectID setObject:((NSManagedObject *)demo[@"childObject"]).objectID forKey:demo[@"relatedRecordName"]];
        [recordTypeToRecordIDToObjectID setObject:recordIDToObjectID forKey:((NSRelationshipDescription *)demo[@"parentRelationship"]).entity.name];
        [recordIDToObjectID release];
    }
    
    OCCloudKitImportZoneContext *importContext_impl = [[OCCloudKitImportZoneContext alloc] init];
    {
        Ivar ivar = object_getInstanceVariable(importContext_impl, "_recordTypeToRecordIDToObjectID", NULL);
        XCTAssertNotEqual(impl, NULL);
        
        *(id *)((uintptr_t)importContext_impl + ivar_getOffset(ivar)) = [recordTypeToRecordIDToObjectID mutableCopy];
    }
    
    PFCloudKitImportZoneContext *importContext_platform = [[objc_lookUpClass("PFCloudKitImportZoneContext") alloc] init];
    {
        Ivar ivar = object_getInstanceVariable(importContext_platform, "_recordTypeToRecordIDToObjectID", NULL);
        XCTAssertNotEqual(impl, NULL);
        
        *(id *)((uintptr_t)importContext_platform + ivar_getOffset(ivar)) = [recordTypeToRecordIDToObjectID mutableCopy];
    }
    
    [recordTypeToRecordIDToObjectID release];
    
    NSError * _Nullable error = nil;
    
    XCTAssertTrue([impl updateRelationshipValueUsingImportContext:importContext_impl andManagedObjectContext:demo[@"managedObjectContext"] error:&error]);
    XCTAssertNil(error);
    
    {
        NSSet<NSManagedObject *> *children = [(NSManagedObject *)demo[@"parentObject"] valueForKey:((NSRelationshipDescription *)demo[@"childrenRelationship"]).name];
        XCTAssertNotNil(children);
        XCTAssertTrue([children containsObject:demo[@"childObject"]]);
    }
    
    XCTAssertTrue([platform updateRelationshipValueUsingImportContext:importContext_platform andManagedObjectContext:demo[@"managedObjectContext"] error:&error]);
    XCTAssertNil(error);
    
    {
        NSSet<NSManagedObject *> *children = [(NSManagedObject *)demo[@"parentObject"] valueForKey:((NSRelationshipDescription *)demo[@"childrenRelationship"]).name];
        XCTAssertNotNil(children);
        XCTAssertTrue([children containsObject:demo[@"childObject"]]);
    }
}

@end
