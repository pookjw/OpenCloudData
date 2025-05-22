//
//  OCCKHistoryAnalyzerState.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/10/25.
//

#import "OpenCloudData/Private/Model/OCCKHistoryAnalyzerState.h"
#import "OpenCloudData/Private/OCCloudKitMetadataModel.h"
#import "OpenCloudData/SPI/CoreData/NSSQLEntity.h"
#import "OpenCloudData/SPI/CoreData/NSSQLCore.h"
#import "OpenCloudData/Private/Log.h"
#import "OpenCloudData/SPI/OCSPIResolver.h"
#import <objc/runtime.h>

@implementation OCCKHistoryAnalyzerState
@dynamic entityId;
@dynamic entityPK;
@dynamic originalChangeTypeNum;
@dynamic finalChangeTypeNum;
@dynamic originalTransactionNumber;
@dynamic finalTransactionNumber;
@dynamic tombstone; // ???
@dynamic finalChangeAuthor;

+ (NSString *)entityPath {
//    return [NSString stringWithFormat:@"%@/%@", [OCCloudKitMetadataModel ancillaryModelNamespace], NSStringFromClass(self)];
    return [NSString stringWithFormat:@"%@/%@", [OCCloudKitMetadataModel ancillaryModelNamespace], NSStringFromClass(objc_lookUpClass("NSCKHistoryAnalyzerState"))];
}

+ (BOOL)purgeAnalyzedHistoryFromStore:(__kindof NSPersistentStore *)store withManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable *)error {
    /*
     x22 = store
     x20 = managedObjectContext
     x19 = error
     */
    
    // sp + 0x8
    NSError * _Nullable _error = nil;
    
    NSFetchRequest<OCCKHistoryAnalyzerState *> *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[OCCKHistoryAnalyzerState entityPath]];
    // x21
    NSBatchDeleteRequest *deleteRequest = [[NSBatchDeleteRequest alloc] initWithFetchRequest:fetchRequest];
    deleteRequest.resultType = NSBatchDeleteResultTypeStatusOnly;
    deleteRequest.affectedStores = @[store];
    
    // x20
    BOOL status = ((NSNumber *)((NSBatchDeleteResult *)[managedObjectContext executeRequest:deleteRequest error:&_error]).result).boolValue;
    [deleteRequest release];
    
    if (status) {
        if (_error == nil) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        } else {
            if (error) *error = _error;
        }
    }
    
    return status;
}

+ (NSNumber *)countAnalyzerStatesInStore:(__kindof NSPersistentStore *)store withManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable *)error {
    /*
     x22 = store
     x20 = managedObjectContext
     x19 = error
     */
    
    // x21
    NSFetchRequest<OCCKHistoryAnalyzerState *> *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[OCCKHistoryAnalyzerState entityPath]];
    fetchRequest.affectedStores = @[store];
    fetchRequest.predicate = nil;
    fetchRequest.resultType = NSCountResultType;
    
    NSInteger count;
    
    if (managedObjectContext == nil) {
        count = 0;
    } else {
        count = [OCSPIResolver NSManagedObjectContext__countForFetchRequest__error_:managedObjectContext x1:fetchRequest x2:error];
        
        if (count == NSNotFound) {
            return nil;
        }
    }
    
    return [NSNumber numberWithUnsignedInteger:count];
}

- (NSDictionary *)tombstone {
    os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Tombstones aren't supported yet for CloudKit history analysis\\n");
    os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Tombstones aren't supported yet for CloudKit history analysis\\n");
    return nil;
}

- (void)mergeWithState:(id<PFHistoryAnalyzerObjectState>)state {
    /*
     x19 = self
     x20 = state
     */
    
    if (([state.originalTransactionNumber compare:self.originalTransactionNumber] == NSOrderedAscending) ||
        ([state.originalTransactionNumber compare:self.finalTransactionNumber] == NSOrderedAscending) ||
        ([state.originalTransactionNumber compare:self.finalTransactionNumber] == NSOrderedAscending) ||
        ([state.finalTransactionNumber compare:self.finalTransactionNumber] == NSOrderedAscending)) {
        os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: History analysis corruption detected. State is behind (or overlaps) this copy but is attempting to be merged. %@ / %@\n", state, self);
        os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: History analysis corruption detected. State is behind (or overlaps) this copy but is attempting to be merged. %@ / %@\n", state, self);
    }
    
    [self setValue:state.finalTransactionNumber forKey:@"finalTransactionNumber"];
    [self setValue:state.finalChangeAuthor forKey:@"finalChangeAuthor"];
    self.finalChangeTypeNum = @(state.finalChangeType);
}

- (void)updateWithChange:(NSPersistentHistoryChange *)change {
    /*
     x20 = self
     x19 = change
     */
    
    [self setValue:@(change.transaction.transactionNumber) forKey:@"finalTransactionNumber"];
    [self setValue:change.transaction.author forKey:@"finalChangeAuthor"];
    self.finalChangeTypeNum = @(change.changeType);
}

- (NSManagedObjectID *)analyzedObjectID {
    // x19 = self
    
    // x21
    unsigned long entityId = self.entityId.unsignedLongValue;
    // x20
    NSInteger entityPK = self.entityPK.integerValue;
    
    if (entityId == 0) {
        os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Cannot create objectID: called before the record has the necessary properties: %@\n", self);
        os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Cannot create objectID: called before the record has the necessary properties: %@\n", self);
        return nil;
    }
    
    // x22
    NSSQLCore *persistentStore = (NSSQLCore *)self.objectID.persistentStore;
    NSSQLEntity * _Nullable sqlEntity = [OCSPIResolver _sqlCoreLookupSQLEntityForEntityID:persistentStore x1:entityId];
    
    if (sqlEntity == nil) {
        return nil;
    }
    
    if (entityPK < 1) {
        os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Cannot create objectID: called before the record has the necessary properties: %@\n", self);
        os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Cannot create objectID: called before the record has the necessary properties: %@\n", self);
        return nil;
    }
    
    NSManagedObjectID *objectID = [persistentStore newObjectIDForEntity:sqlEntity pk:entityPK];
    return [objectID autorelease];
}

- (NSInteger)originalChangeType {
    return self.originalChangeTypeNum.integerValue;
}

- (NSInteger)finalChangeType {
    return self.finalChangeTypeNum.integerValue;
}

- (NSInteger)estimatedSizeInBytes {
    return 0;
}

@end
