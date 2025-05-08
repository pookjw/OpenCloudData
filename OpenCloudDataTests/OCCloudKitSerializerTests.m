//
//  OCCloudKitSerializerTests.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/6/25.
//

#import <XCTest/XCTest.h>
#import <OpenCloudData/OCCloudKitSerializer.h>
#import <OpenCloudData/PFCloudKitSerializer.h>
#import <OpenCloudData/_OCDirectMethodResolver.h>
#import <OpenCloudData/OCSPIResolver.h>
#import <objc/runtime.h>

@interface OCCloudKitSerializerTests : XCTestCase
@end

@implementation OCCloudKitSerializerTests

- (void)test_defaultRecordZoneIDForDatabaseScope {
    CKRecordZoneID *publicRecordZoneID_platform = [objc_lookUpClass("PFCloudKitSerializer") defaultRecordZoneIDForDatabaseScope:CKDatabaseScopePublic];
    CKRecordZoneID *publicRecordZoneID_impl = [OCCloudKitSerializer defaultRecordZoneIDForDatabaseScope:CKDatabaseScopePublic];
    XCTAssertEqual(publicRecordZoneID_platform, publicRecordZoneID_impl);
    [publicRecordZoneID_platform release];
    [publicRecordZoneID_impl release];
    
    CKRecordZoneID *privateRecordZoneID_platform = [objc_lookUpClass("PFCloudKitSerializer") defaultRecordZoneIDForDatabaseScope:CKDatabaseScopePrivate];
    CKRecordZoneID *privateRecordZoneID_impl = [OCCloudKitSerializer defaultRecordZoneIDForDatabaseScope:CKDatabaseScopePrivate];
    XCTAssertEqual(privateRecordZoneID_platform, privateRecordZoneID_impl);
    [privateRecordZoneID_platform release];
    [privateRecordZoneID_impl release];
}

- (void)test_mtmKey {
    NSRelationshipDescription *relationship = [[NSRelationshipDescription alloc] init];
    relationship.name = @"Test1";
    
    NSRelationshipDescription *inverseRelationship = [[NSRelationshipDescription alloc] init];
    inverseRelationship.name = @"Test2";
    
    relationship.inverseRelationship = inverseRelationship;
    inverseRelationship.inverseRelationship = relationship;
    
    NSString *impl = [_OCDirectMethodResolver OCCloudKitSerializer:[OCCloudKitSerializer class] mtmKeyForObjectWithRecordName:@"RecordName" relatedToObjectWithRecordName:@"RelatedRecordName" byRelationship:relationship withInverse:inverseRelationship];
    NSString *platform = [OCSPIResolver PFCloudKitSerializer_mtmKeyForObjectWithRecordName_relatedToObjectWithRecordName_byRelationship_withInverse_:objc_lookUpClass("PFCloudKitSerializer") x1:@"RecordName" x2:@"RelatedRecordName" x3:relationship x4:inverseRelationship];
    XCTAssertEqualObjects(impl, platform);
    
    NSEntityDescription *entity_1 = [[NSEntityDescription alloc] init];
    entity_1.name = @"Entity1";
    entity_1.properties = @[relationship];
    NSEntityDescription *entity_2 = [[NSEntityDescription alloc] init];
    entity_2.name = @"Entity1";
    entity_2.properties = @[inverseRelationship];
    
    impl = [_OCDirectMethodResolver OCCloudKitSerializer:[OCCloudKitSerializer class] mtmKeyForObjectWithRecordName:@"RecordName" relatedToObjectWithRecordName:@"RelatedRecordName" byRelationship:relationship withInverse:inverseRelationship];
    platform = [OCSPIResolver PFCloudKitSerializer_mtmKeyForObjectWithRecordName_relatedToObjectWithRecordName_byRelationship_withInverse_:objc_lookUpClass("PFCloudKitSerializer") x1:@"RecordName" x2:@"RelatedRecordName" x3:relationship x4:inverseRelationship];
    XCTAssertEqualObjects(impl, platform);
    
    [entity_1 release];
    [entity_2 release];
    [relationship release];
    [inverseRelationship release];
}

- (void)test_estimateByteSizeOfRecordID {
    CKRecordZoneID *zoneID = [[CKRecordZoneID alloc] initWithZoneName:@"Test1" ownerName:@"Test2"];
    CKRecordID *recordID = [[CKRecordID alloc] initWithRecordName:@"Test3" zoneID:zoneID];
    
    XCTAssertEqual([_OCDirectMethodResolver OCCloudKitSerializer:[OCCloudKitSerializer class] estimateByteSizeOfRecordID:recordID], [OCSPIResolver PFCloudKitSerializer_estimateByteSizeOfRecordID_:objc_lookUpClass("PFCloudKitSerializer") x1:recordID]);
    [recordID release];
}

- (void)test_recordTypeForEntity {
    NSEntityDescription *entity = [[NSEntityDescription alloc] init];
    entity.name = @"Test";
    NSString *impl = [_OCDirectMethodResolver OCCloudKitSerializer:objc_lookUpClass("OCCloudKitSerializer") recordTypeForEntity:entity];
    NSString *platform = [OCSPIResolver PFCloudKitSerializer_recordTypeForEntity_:objc_lookUpClass("PFCloudKitSerializer") x1:entity];
    XCTAssertEqualObjects(impl, platform);
    [entity release];
}

- (void)test_isMirroredRelationshipRecordType {
    CKRecordType recordType_1 = [[OCSPIResolver PFCloudKitMirroringDelegateToManyPrefix] stringByAppendingString:@"Test"];
    XCTAssertEqual([_OCDirectMethodResolver OCCloudKitSerializer:[OCCloudKitSerializer class] isMirroredRelationshipRecordType:recordType_1], [OCSPIResolver PFCloudKitSerializer_isMirroredRelationshipRecordType_:objc_lookUpClass("PFCloudKitSerializer") x1:recordType_1]);
    XCTAssertTrue([_OCDirectMethodResolver OCCloudKitSerializer:[OCCloudKitSerializer class] isMirroredRelationshipRecordType:recordType_1]);
    
    CKRecordType recordType_2 = @"CDMR";
    XCTAssertEqual([_OCDirectMethodResolver OCCloudKitSerializer:[OCCloudKitSerializer class] isMirroredRelationshipRecordType:recordType_2], [OCSPIResolver PFCloudKitSerializer_isMirroredRelationshipRecordType_:objc_lookUpClass("PFCloudKitSerializer") x1:recordType_2]);
    XCTAssertTrue([_OCDirectMethodResolver OCCloudKitSerializer:[OCCloudKitSerializer class] isMirroredRelationshipRecordType:recordType_2]);
    
    CKRecordType recordType_3 = @"Random";
    XCTAssertEqual([_OCDirectMethodResolver OCCloudKitSerializer:[OCCloudKitSerializer class] isMirroredRelationshipRecordType:recordType_3], [OCSPIResolver PFCloudKitSerializer_isMirroredRelationshipRecordType_:objc_lookUpClass("PFCloudKitSerializer") x1:recordType_3]);
    XCTAssertFalse([_OCDirectMethodResolver OCCloudKitSerializer:[OCCloudKitSerializer class] isMirroredRelationshipRecordType:recordType_3]);
}

- (void)test_createSetOfObjectIDsRelatedToObject {
    NSEntityDescription *nodeEntity = [[NSEntityDescription alloc] init];
    nodeEntity.name = @"Node";

    NSRelationshipDescription *childrenRel = [[NSRelationshipDescription alloc] init];
    childrenRel.name = @"children";
    childrenRel.destinationEntity = nodeEntity;
    childrenRel.minCount = 0;
    childrenRel.maxCount = 0;

    NSRelationshipDescription *parentRel = [[NSRelationshipDescription alloc] init];
    parentRel.name = @"parent";
    parentRel.destinationEntity = nodeEntity;
    parentRel.minCount = 0;
    parentRel.maxCount = 1;
    
    childrenRel.inverseRelationship = parentRel;
    parentRel.inverseRelationship = childrenRel;

    nodeEntity.properties = @[childrenRel, parentRel];
    [childrenRel release];
    [parentRel release];
    
    NSManagedObject *managedObject = [[NSManagedObject alloc] initWithEntity:nodeEntity insertIntoManagedObjectContext:nil];
    
    NSManagedObject *child1 = [[NSManagedObject alloc] initWithEntity:nodeEntity insertIntoManagedObjectContext:nil];
    NSManagedObject *child2 = [[NSManagedObject alloc] initWithEntity:nodeEntity insertIntoManagedObjectContext:nil];
    
    NSManagedObject *superParent = [[NSManagedObject alloc] initWithEntity:nodeEntity insertIntoManagedObjectContext:nil];
    
    [managedObject setValue:[NSSet setWithObjects:child1, child2, nil] forKey:@"children"];
    [child1 setValue:managedObject forKey:@"parent"];
    [child2 setValue:managedObject forKey:@"parent"];
    [child1 release];
    [child2 release];
    
    [managedObject setValue:superParent forKey:@"parent"];
    [superParent setValue:[NSSet setWithObject:managedObject] forKey:@"children"];
    [superParent release];
    
    [nodeEntity release];
    
    NSSet<NSManagedObjectID *> *impl = [_OCDirectMethodResolver OCCloudKitSerializer:[OCCloudKitSerializer class] createSetOfObjectIDsRelatedToObject:managedObject];
    NSSet<NSManagedObjectID *> *platform = [OCSPIResolver PFCloudKitSerializer_createSetOfObjectIDsRelatedToObject_:objc_lookUpClass("PFCloudKitSerializer") x1:managedObject];
    [managedObject release];
    
    XCTAssertEqualObjects(impl, platform);
    XCTAssertTrue(impl.count > 0);
}

@end
