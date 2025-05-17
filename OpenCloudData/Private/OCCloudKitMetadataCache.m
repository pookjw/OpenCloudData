//
//  OCCloudKitMetadataCache.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/15/25.
//

#import <OpenCloudData/OCCloudKitMetadataCache.h>

@implementation OCCloudKitMetadataCache

- (BOOL)cacheMetadataForObjectsWithIDs:(NSArray<NSManagedObjectID *> *)objectIDs andRecordsWithIDs:(NSArray *)recordsWithIDs inStore:(NSSQLCore *)store withManagedObjectContext:(NSManagedObjectContext *)managedObjectContext mirroringOptions:(OCCloudKitMirroringDelegateOptions * _Nullable)mirroringOptions error:(NSError * _Nullable *)error {
    abort();
}

- (void)registerRecordMetadata:(OCCKRecordMetadata *)recordMetadata forObject:(NSManagedObject *)object {
    abort();
}

- (void)cacheZoneMetadata:(OCCKRecordZoneMetadata *)zoneMetadata {
    abort();
}

- (OCCKRecordMetadata *)recordMetadataForRecordID:(CKRecordID *)recordID {
    abort();
}

@end
