//
//  OCCKDatabaseMetadata.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/5/25.
//

#import "OpenCloudData/Private/Model/OCCKDatabaseMetadata.h"
#import "OpenCloudData/Private/OCCloudKitMetadataModel.h"
#include <objc/runtime.h>

@implementation OCCKDatabaseMetadata
@dynamic hasSubscriptionNum;
@dynamic databaseScopeNum;
@dynamic databaseName;
@dynamic databaseScope;
@dynamic currentChangeToken;
@dynamic lastFetchDate;
@dynamic hasSubscription;
@dynamic recordZones;

+ (OCCKDatabaseMetadata *)databaseMetadataForScope:(CKDatabaseScope)databaseScope forStore:(__kindof NSPersistentStore *)store inContext:(NSManagedObjectContext *)context error:(NSError * _Nullable *)error {
    // x21 = databaseScope
    // x19 = store
    // x20 = context
    // x22 = error
    
    NSFetchRequest<OCCKDatabaseMetadata *> *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:OCCKDatabaseMetadata.entityPath];
    fetchRequest.affectedStores = @[store];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"databaseScopeNum = %@", @(databaseScope)];
    fetchRequest.propertiesToFetch = @[
        @"currentChangeToken",
        @"databaseName",
        @"databaseScopeNum",
        @"hasSubscriptionNum",
        @"lastFetchDate"
    ];
    
    NSArray<OCCKDatabaseMetadata *> * _Nullable results = [context executeFetchRequest:fetchRequest error:error];
    
    if (results == nil) return nil;
    
    OCCKDatabaseMetadata *result = results.lastObject;
    
    if (result == nil) {
        result = [NSEntityDescription insertNewObjectForEntityForName:OCCKDatabaseMetadata.entityPath inManagedObjectContext:context];
        result.databaseScope = databaseScope;
        
        NSString * _Nullable databaseName;
        switch (databaseScope) {
            case CKDatabaseScopePublic:
                databaseName = @"Public";
                break;
            case CKDatabaseScopePrivate:
                databaseName = @"Private";
                break;
            case CKDatabaseScopeShared:
                databaseName = @"Shared";
                break;
            default:
                databaseName = nil;
                break;
        }
        result.databaseName = databaseName;
        
        result.hasSubscriptionNum = @(NO);
        
        [context assignObject:result toPersistentStore:store];
    }
    
    return result;
}

+ (NSString *)entityPath {
//    return [NSString stringWithFormat:@"%@/%@", [OCCloudKitMetadataModel ancillaryModelNamespace], NSStringFromClass(self)];
    return [NSString stringWithFormat:@"%@/%@", [OCCloudKitMetadataModel ancillaryModelNamespace], NSStringFromClass(objc_lookUpClass("NSCKDatabaseMetadata"))];
}

- (BOOL)hasSubscription {
    return self.hasSubscriptionNum.boolValue;
}

- (void)setHasSubscription:(BOOL)hasSubscription {
    self.hasSubscriptionNum = @(hasSubscription);
}

- (CKDatabaseScope)databaseScope {
    return self.databaseScopeNum.integerValue;
}

- (void)setDatabaseScope:(CKDatabaseScope)databaseScope {
    self.databaseScopeNum = @(databaseScope);
}

@end
