//
//  OCCloudKitExportContext.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/5/25.
//

#import <OpenCloudData/OCCloudKitExportContext.h>
#import <OpenCloudData/OCCKRecordMetadata.h>
#import <OpenCloudData/OCCKMirroredRelationship.h>
#import <OpenCloudData/OCCKRecordZoneMetadata.h>
#import <OpenCloudData/OCCKRecordZoneMoveReceipt.h>
#import <OpenCloudData/OCCKMetadataEntry.h>
#import <OpenCloudData/_NSPersistentHistoryToken.h>
#import <OpenCloudData/OCCKHistoryAnalyzerState.h>
#import <OpenCloudData/_PFRoutines.h>
#import <OpenCloudData/Log.h>
#import <objc/runtime.h>
@import ellekit;

@implementation OCCloudKitExportContext

- (instancetype)initWithOptions:(OCCloudKitExporterOptions *)options {
    if (self = [super init]) {
        _options = [options retain];
        _totalBytes = 0;
        _totalRecords = 0;
        _totalRecordIDs = 0;
        _writtenAssetURLs = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)dealloc {
    [_options release];
    _options = nil;
    [_writtenAssetURLs release];
    _writtenAssetURLs = nil;
    [super dealloc];
}

- (BOOL)processAnalyzedHistoryInStore:(__kindof NSPersistentStore *)store inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable *)error {
    /*
     x19 = error
     */
    
    // x29 - 0x50
    __block BOOL succeed = YES;
    // sp + 0x50
    __block NSError * _Nullable _error = nil;
    
    /*
     sp + 0x28 = store = x19 + 0x20
     sp + 0x30 = managedObjectContext = x19 + 0x28
     sp + 0x38 = self
     sp + 0x40 = error
     sp + 0x48 = succeed
     */
    [managedObjectContext performBlockAndWait:^{
        // original : NSCloudKitMirroringDelegateLastHistoryTokenKey
        OCCKMetadataEntry * _Nullable entry = [OCCKMetadataEntry entryForKey:@"NSCloudKitMirroringDelegateLastHistoryTokenKey" fromStore:store inManagedObjectContext:managedObjectContext error:&_error];
        
        if (_error == nil) {
            succeed = NO;
            [_error retain];
            
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData+CloudKit: %s(%d): Unable to read the last history token: %@", __func__, __LINE__, self);
            return;
        }
        
        // x20
        NSDictionary<NSString *, NSNumber *> *storeTokens = [(_NSPersistentHistoryToken *)entry.transformedValue storeTokens];
        // x20
        NSNumber *tokenNumber = [storeTokens[store.identifier] retain];
        if (tokenNumber == nil) {
            tokenNumber = [[NSNumber alloc] initWithInt:0];
        }
        
        // x21 / x25
        NSMutableSet *set_1 = [[NSMutableSet alloc] init];
        // *(x19 - 0xc8) + 0x28
        NSMutableDictionary *dictionary_1 = [[NSMutableDictionary alloc] init];
        // *(x19 - 0xf8) + 0x28
        NSMutableDictionary *dictionary_2 = [[NSMutableDictionary alloc] init];
        // x22
        NSMutableSet *set_2 = [[NSMutableSet alloc] init];
        // x23
        NSMutableSet *set_3 = [[NSMutableSet alloc] init];
        
        // x24
        NSFetchRequest<OCCKHistoryAnalyzerState *> *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[OCCKHistoryAnalyzerState entityPath]];
        fetchRequest.returnsObjectsAsFaults = NO;
        fetchRequest.propertiesToFetch = @[@"entityPK", @"entityId", @"finalChangeTypeNum"];
        fetchRequest.fetchBatchSize = 200;
        
        const void *image = MSGetImageByName("/System/Library/Frameworks/CoreData.framework/CoreData");
        const void *symbol = MSFindSymbol(image, "+[_PFRoutines efficientlyEnumerateManagedObjectsInFetchRequest:usingManagedObjectContext:andApplyBlock:]");
        ((void (*)(Class, id, id, id))symbol)(objc_lookUpClass("_PFRoutines"), fetchRequest, managedObjectContext, ^(NSArray<OCCKHistoryAnalyzerState *> * _Nullable states, NSError * _Nullable error, BOOL *, BOOL *) {
            
        });
    }];
    
    abort();
}

- (BOOL)checkForObjectsNeedingExportInStore:(__kindof NSPersistentStore *)store andReturnCount:(NSUInteger *)count withManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable *)error {
    /*
     x23 = store
     x20 = count
     x21 = managedObjectContext
     x19 = error
     */
    
    NSError * _Nullable _error = nil;
    
    NSNumber * _Nullable recordMetadataCountNumber = [OCCKRecordMetadata countRecordMetadataInStore:store
                                                                            matchingPredicate:[NSPredicate predicateWithFormat:@"needsUpload = YES"]
                                                                     withManagedObjectContext:managedObjectContext
                                                                                        error:&_error];
    if (recordMetadataCountNumber == nil) {
        if (error == nil) {
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d", __func__, __LINE__);
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d", __func__, __LINE__);
        } else {
            if (error) *error = _error;
        }
        
        return NO;
    }
    
    // x22
    NSUInteger recordMetadataCount = recordMetadataCountNumber.unsignedIntegerValue;
    
    NSNumber * _Nullable mirroredRelationshipsCountNumber = [OCCKMirroredRelationship countMirroredRelationshipsInStore:store
                                                                                                 matchingPredicate:[NSPredicate predicateWithFormat:@"isUploaded = NO"]
                                                                                          withManagedObjectContext:managedObjectContext
                                                                                                             error:&_error];
    if (mirroredRelationshipsCountNumber == nil) {
        if (error == nil) {
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d", __func__, __LINE__);
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d", __func__, __LINE__);
        } else {
            if (error) *error = _error;
        }
        
        return NO;
    }
    
    // x24
    NSUInteger mirroredRelationshipsCount = mirroredRelationshipsCountNumber.unsignedIntegerValue;
    
    // x25
    NSInteger recordZoneMetadataCount;
    {
        NSFetchRequest<OCCKRecordZoneMetadata *> *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[OCCKRecordZoneMetadata entityPath]];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"needsShareUpdate = YES OR needsShareDelete = YES"];
        fetchRequest.resultType = NSCountResultType;
        fetchRequest.affectedStores = @[store];
        
        if (managedObjectContext == nil) {
            recordZoneMetadataCount = 0;
        } else {
            const void *image = MSGetImageByName("/System/Library/Frameworks/CoreData.framework/CoreData");
            const void *symbol = MSFindSymbol(image, "-[NSManagedObjectContext _countForFetchRequest_:error:]");
            recordZoneMetadataCount = ((NSInteger (*)(id, id, id *))symbol)(managedObjectContext, fetchRequest, error);
            
            if (recordZoneMetadataCount == NSNotFound) {
                // <+476>
                abort();
            }
        }
    }
    
    NSInteger recordZoneMoveReceiptsCount;
    {
        NSFetchRequest<OCCKRecordZoneMoveReceipt *> *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[OCCKRecordZoneMoveReceipt entityPath]];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"needsCloudDelete = YES"];
        fetchRequest.resultType = NSCountResultType;
        fetchRequest.affectedStores = @[store];
        
        if (managedObjectContext == nil) {
            recordZoneMoveReceiptsCount = 0;
        } else {
            const void *image = MSGetImageByName("/System/Library/Frameworks/CoreData.framework/CoreData");
            const void *symbol = MSFindSymbol(image, "-[NSManagedObjectContext _countForFetchRequest_:error:]");
            recordZoneMoveReceiptsCount = ((NSInteger (*)(id, id, id *))symbol)(managedObjectContext, fetchRequest, error);
            
            if (recordZoneMoveReceiptsCount == NSNotFound) {
                if (error == nil) {
                    os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d", __func__, __LINE__);
                    os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d", __func__, __LINE__);
                } else {
                    if (error) *error = _error;
                }
                
                return NO;
            }
        }
    }
    
    *count = (recordMetadataCount + mirroredRelationshipsCount + recordZoneMetadataCount + recordZoneMoveReceiptsCount);
    return YES;
}

@end
