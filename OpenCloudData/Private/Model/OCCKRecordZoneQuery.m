//
//  OCCKRecordZoneQuery.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/6/25.
//

#import <OpenCloudData/OCCKRecordZoneQuery.h>
#import <OpenCloudData/OCCloudKitMetadataModel.h>
#import <OpenCloudData/OCCKRecordZoneMetadata.h>

@implementation OCCKRecordZoneQuery
@dynamic recordZone;
@dynamic recordType;
@dynamic lastFetchDate;
@dynamic mostRecentRecordModificationDate;
@dynamic predicate;
@dynamic queryCursor;

+ (NSString *)entityPath {
    return [NSString stringWithFormat:@"%@/%@", OCCloudKitMetadataModel.ancillaryModelNamespace, NSStringFromClass(self)];
}

+ (OCCKRecordZoneQuery *)zoneQueryForRecordType:(CKRecordType)recordType inZone:(OCCKRecordZoneMetadata *)zone inStore:(__kindof NSPersistentStore *)store managedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable *)error {
    /*
     x20 = recordType
     x19 = zone
     x23 = store
     x21 = managedObjectContext
     x22 = error
     */
    
    // x24
    NSFetchRequest<OCCKRecordZoneQuery *> *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[OCCKRecordZoneQuery entityPath]];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"recordType = %@ AND recordZone = %@", recordType, zone.objectID];
    fetchRequest.affectedStores = @[store];
    
    NSArray<OCCKRecordZoneQuery *> * _Nullable results = [managedObjectContext executeFetchRequest:fetchRequest error:error];
    if (results == nil) return nil;
    
    // x22
    OCCKRecordZoneQuery * _Nullable lastObject = results.lastObject;
    if (lastObject != nil) return lastObject;
    
    OCCKRecordZoneQuery *query = [NSEntityDescription insertNewObjectForEntityForName:[OCCKRecordZoneQuery entityPath] inManagedObjectContext:managedObjectContext];
    query.recordType = recordType;
    query.recordZone = zone;
    
    return query;
}

- (CKQuery *)createQueryForUpdatingRecords {
    // x19 = self
    
    // x22
    NSPredicate *subpredicate;
    @autoreleasepool {
        // x21
        NSPredicate * _Nullable predicate = [self.predicate retain];
        NSDate * _Nullable mostRecentRecordModificationDate =  self.mostRecentRecordModificationDate;
        
        if (predicate == nil) {
            if (mostRecentRecordModificationDate == nil) {
                subpredicate = [[NSPredicate predicateWithValue:YES] retain];
            } else {
                subpredicate = [[NSPredicate predicateWithFormat:@"modificationDate > %@", self.mostRecentRecordModificationDate] retain];
            }
        } else {
            if (mostRecentRecordModificationDate == nil) {
                subpredicate = [predicate retain];
            } else {
                subpredicate = [[NSCompoundPredicate alloc] initWithType:NSAndPredicateType subpredicates:@[[NSPredicate predicateWithFormat:@"modificationDate > %@", self.mostRecentRecordModificationDate], predicate]];
            }
        }
        
        [predicate release];
    }
    
    // original : getCloudKitCKQueryClass
    // x19
    CKQuery *query = [[CKQuery alloc] initWithRecordType:self.recordType predicate:subpredicate];
    query.sortDescriptors = @[
        [NSSortDescriptor sortDescriptorWithKey:@"modificationDate" ascending:YES]
    ];
    [subpredicate release];
    
    return query;
}

@end
