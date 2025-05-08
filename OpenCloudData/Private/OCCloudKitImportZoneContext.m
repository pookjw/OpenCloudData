//
//  OCCloudKitImportZoneContext.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/6/25.
//

#import <OpenCloudData/OCCloudKitImportZoneContext.h>

@implementation OCCloudKitImportZoneContext

- (instancetype)initWithUpdatedRecords:(NSArray<CKRecord *> *)updatedRecords deletedRecordTypeToRecordIDs:(NSDictionary<NSString *,NSArray<CKRecordID *> *> *)deletedRecordTypeToRecordIDs options:(OCCloudKitMirroringDelegateOptions *)options fileBackedFuturesDirectory:(NSURL *)fileBackedFuturesDirectory {
    abort();
}

- (BOOL)initializeCachesWithManagedObjectContext:(NSManagedObjectContext *)managedObjectConrext andObservedStore:(NSSQLCore *)observedStore error:(NSError * _Nullable *)error {
    abort();
}

- (void)registerObject:(NSManagedObject *)object forInsertedRecord:(CKRecord *)record withMetadata:(id)metadata {
    abort();
}

@end
