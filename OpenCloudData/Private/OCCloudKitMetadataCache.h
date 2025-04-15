//
//  OCCloudKitMetadataCache.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/15/25.
//

#import <CloudKit/CloudKit.h>
#import <CoreData/CoreData.h>
#import <OpenCloudData/NSSQLCore.h>
#import <OpenCloudData/OCCloudKitMirroringDelegateOptions.h>

NS_ASSUME_NONNULL_BEGIN

#warning TODO

@interface OCCloudKitMetadataCache : NSObject {
    @package NSMutableSet<CKRecordZoneID *> *_mutableZoneIDs; // + 0x40
}
- (BOOL)cacheMetadataForObjectsWithIDs:(NSArray<NSManagedObjectID *> *)objectIDs andRecordsWithIDs:(NSArray *)recordsWithIDs inStore:(NSSQLCore *)store withManagedObjectContext:(NSManagedObjectContext *)managedObjectContext mirroringOptions:(OCCloudKitMirroringDelegateOptions * _Nullable)mirroringOptions error:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct));
@end

NS_ASSUME_NONNULL_END
