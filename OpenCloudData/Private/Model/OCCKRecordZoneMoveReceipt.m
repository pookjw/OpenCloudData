//
//  OCCKRecordZoneMoveReceipt.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/6/25.
//

#import <OpenCloudData/OCCKRecordZoneMoveReceipt.h>
#import <OpenCloudData/OCCloudKitMetadataModel.h>
#import <OpenCloudData/Log.h>
#import <CloudKit/CloudKit.h>

@implementation OCCKRecordZoneMoveReceipt
@dynamic recordName;
@dynamic zoneName;
@dynamic ownerName;
@dynamic needsCloudDelete;
@dynamic movedAt;
@dynamic recordMetadata;

+ (NSString *)entityPath {
    return [NSString stringWithFormat:@"%@/%@", OCCloudKitMetadataModel.ancillaryModelNamespace, NSStringFromClass(self)];
}

- (CKRecordID *)createRecordIDForMovedRecord {
    // x19 = self
    
    // original = getCloudKitCKRecordZoneIDClass
    // x20
    CKRecordZoneID *zoneID = [[CKRecordZoneID alloc] initWithZoneName:self.zoneName ownerName:self.ownerName];
    
    // original = getCloudKitCKRecordIDClass
    // x19
    CKRecordID *recordID = [[CKRecordID alloc] initWithRecordName:self.recordName zoneID:zoneID];
    [zoneID release];
    
    return recordID;
}

+ (NSArray<OCCKRecordZoneMoveReceipt *> *)moveReceiptsMatchingRecordIDs:(NSArray<CKRecordID *> *)recordIDs inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext persistentStore:(__kindof NSPersistentStore *)persistentStore error:(NSError * _Nullable *)error {
    /*
     x23 = recordIDs
     x21 = managedObjectContext
     x22 = persistentStore
     x19 = error
     */
    
    // sp + 0x50
    __block NSError * _Nullable _error = nil;
    // x29 - 0x58 / *(uintptr_t *)(x29 - 0x70) + 0x18
    __block BOOL succeed = YES;
    
    // x20
    NSMutableArray<OCCKRecordZoneMoveReceipt *> *results = [[NSMutableArray alloc] init];
    
    if (recordIDs.count != 0) {
        /*
         recordIDs = x19 + 0x20
         managedObjectContext = x19 + 0x28
         persistentStore = x19 + 0x30
         results = x19 = 0x38
         _error = x19 + 0x40
         succeed = x19 + 0x48
         */
        [managedObjectContext performBlockAndWait:^{
            // x20
            NSMutableArray<NSPredicate *> *predicates = [NSMutableArray array];
            
            // x25
            for (CKRecordID *recordID in recordIDs) @autoreleasepool {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"recordName = %@ AND zoneName = %@ AND ownerName = %@", recordID.recordName, recordID.zoneID.zoneName, recordID.zoneID.ownerName];
                [predicates addObject:predicate];
                
                if (predicates.count < 100) continue;
                
                NSArray<OCCKRecordZoneMoveReceipt *> * _Nullable fetchedReceipts = [OCCKRecordZoneMoveReceipt _fetchReceiptsMatchingSubPredicates:predicates inManagedObjectContext:managedObjectContext persistentStore:persistentStore error:&_error];
                if (fetchedReceipts == nil) {
                    succeed = NO;
                    [_error retain];
                    break;
                }
                [results addObjectsFromArray:fetchedReceipts];
            }
            
            if (!succeed) return;
            if (predicates.count == 0) return;
            
            NSArray<OCCKRecordZoneMoveReceipt *> * _Nullable fetchedReceipts = [OCCKRecordZoneMoveReceipt _fetchReceiptsMatchingSubPredicates:predicates inManagedObjectContext:managedObjectContext persistentStore:persistentStore error:&_error];
            if (fetchedReceipts == nil) {
                succeed = NO;
                [_error retain];
            } else {
                [results addObjectsFromArray:fetchedReceipts];
            }
        }];
    }
    
    [results autorelease];
    
    if (!succeed) {
        if (_error == nil) {
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __func__, __LINE__);
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __func__, __LINE__);
        } else {
            if (error) *error = [[_error retain] autorelease];
        }
        
        results = nil;
        [_error release];
    }
    
    return results;
}

+ (NSArray<OCCKRecordZoneMoveReceipt *> * _Nullable)_fetchReceiptsMatchingSubPredicates:(NSArray<NSPredicate *> *)predicates inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext persistentStore:(__kindof NSPersistentStore *)persistentStore error:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct)) {
    abort();
}

@end
