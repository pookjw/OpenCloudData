//
//  OCCKImportOperation.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/29/25.
//

#import <OpenCloudData/OCCKImportOperation.h>
#import <OpenCloudData/OCCloudKitMetadataModel.h>
#import <OpenCloudData/Log.h>
#import <objc/runtime.h>

@implementation OCCKImportOperation
@dynamic importDate;
@dynamic operationUUID;
@dynamic changeTokenBytes;
@dynamic pendingRelationships;

+ (NSString *)entityPath {
//    return [NSString stringWithFormat:@"%@/%@", [OCCloudKitMetadataModel ancillaryModelNamespace], NSStringFromClass(self)];
    return [NSString stringWithFormat:@"%@/%@", [OCCloudKitMetadataModel ancillaryModelNamespace], NSStringFromClass(objc_lookUpClass("NSCKImportOperation"))];
}

+ (NSArray<OCCKImportOperation *> *)fetchUnfinishedImportOperationsInStore:(NSPersistentStore *)store withManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable *)error {
    /*
     store = x21
     managedObjectContext = x20
     error = x19
     */
    
    // x22
    NSFetchRequest<OCCKImportOperation *> *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[OCCKImportOperation entityPath]];
    fetchRequest.affectedStores = @[store];
    
    return [managedObjectContext executeFetchRequest:fetchRequest error:error];
}

+ (OCCKImportOperation *)fetchOperationWithIdentifier:(NSUUID *)identifier fromStore:(NSPersistentStore *)store inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable *)error {
    /*
     identifier = x19
     store = x22
     managedObjectContext = x21
     error = x20
     */
    
    // x23
    NSFetchRequest<OCCKImportOperation *> *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[OCCKImportOperation entityPath]];
    fetchRequest.affectedStores = @[store];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"operationUUID == %@", identifier];
    
    // x20
    NSArray<OCCKImportOperation *> * _Nullable results = [managedObjectContext executeFetchRequest:fetchRequest error:error];
    if (results == nil) return nil;
    
    if (results.count < 2) return results.lastObject;
    
    os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Duplicate operations for identifier: %@\n%@\n", identifier, results);
    os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Duplicate operations for identifier: %@\n%@\n", identifier, results);
    return nil;
}

+ (BOOL)purgeFinishedImportOperationsInStore:(NSPersistentStore *)store withManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable *)error {
    /*
     store = x21
     managedObjectContext = x19
     error = x20
     */
    
    // x22
    NSFetchRequest<OCCKImportOperation *> *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[OCCKImportOperation entityPath]];
    fetchRequest.affectedStores = @[store];
    
    // x20
    NSArray<OCCKImportOperation *> * _Nullable results = [managedObjectContext executeFetchRequest:fetchRequest error:error];
    if (results == nil) return NO;
    
    // x22
    for (OCCKImportOperation *operation in results) {
        NSUInteger count = operation.pendingRelationships.count;
        if (count == 0) {
            [managedObjectContext deleteObject:operation];
        }
    }
    
    return YES;
}

@end
