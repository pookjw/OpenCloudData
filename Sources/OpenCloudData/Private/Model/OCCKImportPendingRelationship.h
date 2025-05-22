//
//  OCCKImportPendingRelationship.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/28/25.
//

#import <CoreData/CoreData.h>
#import "OpenCloudData/Private/MirroredRelationship/OCMirroredRelationship.h"

NS_ASSUME_NONNULL_BEGIN

@class OCCKImportOperation;

@interface OCCKImportPendingRelationship : NSManagedObject
+ (NSString *)entityPath __attribute__((objc_direct));
+ (OCCKImportPendingRelationship *)insertPendingRelationshipForFailedRelationship:(OCMirroredRelationship *)failedRelationship forOperation:(OCCKImportOperation *)operation inStore:(NSPersistentStore *)store withManagedObjectContext:(NSManagedObjectContext *)managedObjectContext __attribute__((objc_direct));
@property (retain, nonatomic, nullable) NSString *recordName;
@property (retain, nonatomic, nullable) NSString *cdEntityName;
@property (retain, nonatomic, nullable) NSString *relatedRecordName;
@property (retain, nonatomic, nullable) NSString *relatedEntityName;
@property (retain, nonatomic, nullable) NSString *relationshipName;
@property (retain, nonatomic) NSString *recordZoneName;
@property (retain, nonatomic) NSString *recordZoneOwnerName;
@property (retain, nonatomic) NSString *relatedRecordZoneName;
@property (retain, nonatomic) NSString *relatedRecordZoneOwnerName;
@property (retain, nonatomic, nullable) NSNumber *needsDelete;
@property (retain, nonatomic, nullable) OCCKImportOperation* operation;
@end

NS_ASSUME_NONNULL_END
