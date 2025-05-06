//
//  OCCloudKitHistoryAnalyzerContext.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/20/25.
//

#import <OpenCloudData/OCCloudKitHistoryAnalyzerContext.h>
#import <OpenCloudData/Log.h>
#import <OpenCloudData/OCCKHistoryAnalyzerState.h>
#import <OpenCloudData/OCSPIResolver.h>
#import <OpenCloudData/NSManagedObjectID+Private.h>
#import <OpenCloudData/OCCKMetadataEntry.h>
#import <objc/runtime.h>
#import <objc/message.h>

OBJC_EXPORT id objc_msgSendSuper2(void);

@implementation OCCloudKitHistoryAnalyzerContext

+ (void)load {
    [self class];
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [[self class] allocWithZone:zone];
}

+ (Class)class {
    static Class isa;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class _isa = objc_allocateClassPair(objc_lookUpClass("PFHistoryAnalyzerContext"), "_OCCloudKitHistoryAnalyzerContext", 0);
        
        assert(class_addIvar(_isa, "_managedObjectContext", sizeof(id), sizeof(id), @encode(id)));
        assert(class_addIvar(_isa, "_configuredEntityNames", sizeof(id), sizeof(id), @encode(id)));
        assert(class_addIvar(_isa, "_resetChangedObjectIDs", sizeof(id), sizeof(id), @encode(id)));
        assert(class_addIvar(_isa, "_entityIDToChangedPrimaryKeySet", sizeof(id), sizeof(id), @encode(id)));
        assert(class_addIvar(_isa, "_store", sizeof(id), sizeof(id), @encode(id)));
        
        IMP initWithOptions_managedObjectContext_store_ = class_getMethodImplementation(self, @selector(initWithOptions:managedObjectContext:store:));
        assert(initWithOptions_managedObjectContext_store_ != NULL);
        assert(class_addMethod(_isa, @selector(initWithOptions:managedObjectContext:store:), initWithOptions_managedObjectContext_store_, NULL));
        
        IMP dealloc = class_getMethodImplementation(self, @selector(dealloc));
        assert(dealloc != NULL);
        assert(class_addMethod(_isa, @selector(dealloc), dealloc, NULL));
        
        IMP reset_ = class_getMethodImplementation(self, @selector(reset:));
        assert(reset_ != NULL);
        assert(class_addMethod(_isa, @selector(reset:), reset_, NULL));
        
        IMP fetchSortedStates_ = class_getMethodImplementation(self, @selector(fetchSortedStates:));
        assert(fetchSortedStates_ != NULL);
        assert(class_addMethod(_isa, @selector(fetchSortedStates:), fetchSortedStates_, NULL));
        
        IMP finishProcessing_ = class_getMethodImplementation(self, @selector(finishProcessing:));
        assert(finishProcessing_ != NULL);
        assert(class_addMethod(_isa, @selector(finishProcessing:), finishProcessing_, NULL));
        
        IMP newAnalyzerStateForChange_error_ = class_getMethodImplementation(self, @selector(newAnalyzerStateForChange:error:));
        assert(newAnalyzerStateForChange_error_ != NULL);
        assert(class_addMethod(_isa, @selector(newAnalyzerStateForChange:error:), newAnalyzerStateForChange_error_, NULL));
        
        IMP processChange_error_ = class_getMethodImplementation(self, @selector(processChange:error:));
        assert(processChange_error_ != NULL);
        assert(class_addMethod(_isa, @selector(processChange:error:), processChange_error_, NULL));
        
        IMP resetStateForObjectID_error_ = class_getMethodImplementation(self, @selector(resetStateForObjectID:error:));
        assert(resetStateForObjectID_error_ != NULL);
        assert(class_addMethod(_isa, @selector(resetStateForObjectID:error:), resetStateForObjectID_error_, NULL));
        
        objc_registerClassPair(_isa);
        
        isa = _isa;
    });
    
    return isa;
}

- (instancetype)initWithOptions:(OCCloudKitHistoryAnalyzerOptions *)options managedObjectContext:(NSManagedObjectContext *)managedObjectContext store:(NSSQLCore *)store {
    /*
     self = x22
     options = x20
     managedObjectContext = x21
     store = x19
     */
    // original : PFCloudKitHistoryAnalyzerOptions
    if (![options isKindOfClass:[OCCloudKitHistoryAnalyzerOptions class]]) {
        os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Attempt to initialize OCCloudKitHistoryAnalyzerContext with options that aren't OCCloudKitHistoryAnalyzerOptions: %@\n", options);
        os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Attempt to initialize OCCloudKitHistoryAnalyzerContext with options that aren't OCCloudKitHistoryAnalyzerOptions: %@\n", options);
    }
    
    struct objc_super superInfo = { self, [self class] };
    // x20
    ((id (*)(struct objc_super *, SEL, id))objc_msgSendSuper2)(&superInfo, @selector(initWithOptions:), options);
    
    if (self) {
        *[self _managedObjectContextPtr] = [managedObjectContext retain];
        *[self _resetChangedObjectIDsPtr] = [[NSMutableSet alloc] init];
        *[self _entityIDToChangedPrimaryKeySetPtr] = [[NSMutableDictionary alloc] init];
        
        @autoreleasepool {
            // x23
            NSMutableSet<NSString *> *set = [[NSMutableSet alloc] init];
            // x21
            NSManagedObjectModel *managedObjectModel = managedObjectContext.persistentStoreCoordinator.managedObjectModel;
            // x21
            NSArray<NSEntityDescription *> *entities = [managedObjectModel entitiesForConfiguration:store.configurationName];
            
            for (NSEntityDescription *entity in entities) {
                [set addObject:entity.name];
            }
            
            *[self _configuredEntityNamesPtr] = [set copy];
            [set release];
        }
        
        *[self _storePtr] = [store retain];
    }
    
    return self;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-missing-super-calls"
- (void)dealloc {
    [*[self _entityIDToChangedPrimaryKeySetPtr] release];
    [*[self _resetChangedObjectIDsPtr] release];
    [*[self _managedObjectContextPtr] release];
    [*[self _configuredEntityNamesPtr] release];
    [*[self _storePtr] release];
    
    struct objc_super superInfo = { self, [self class] };
    ((void (*)(struct objc_super *, SEL))objc_msgSendSuper2)(&superInfo, _cmd);
}
#pragma clang diagnostic pop

- (BOOL)reset:(NSError * _Nullable * _Nullable)error {
    /*
     self = x20
     error = x19
     */
    
    NSError * _Nullable _error = nil;
    
    struct objc_super superInfo = { self, [self class] };
    BOOL result = ((BOOL (*)(struct objc_super *, SEL, id *))objc_msgSendSuper2)(&superInfo, _cmd, &_error);
    
    if (!result) {
        if (_error == nil) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        } else {
            if (error != NULL) {
                *error = _error;
            }
        }
        
        return NO;
    }
    
    [*[self _entityIDToChangedPrimaryKeySetPtr] removeAllObjects];
    [*[self _resetChangedObjectIDsPtr] removeAllObjects];
    
    NSFetchRequest<OCCKHistoryAnalyzerState *> *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[OCCKHistoryAnalyzerState entityPath]];
    // x21
    NSBatchDeleteRequest *request = [[NSBatchDeleteRequest alloc] initWithFetchRequest:fetchRequest];
    request.resultType = NSBatchDeleteResultTypeStatusOnly;
    
    // x22
    BOOL boolValue = ((NSNumber *)((NSBatchDeleteResult *)[*[self _managedObjectContextPtr] executeRequest:request error:&_error]).result).boolValue;
    [request release];
    
    if (!boolValue) {
        if (_error == nil) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        } else {
            if (error != NULL) {
                *error = _error;
            }
        }
        
        return NO;
    }
    
    [*[self _managedObjectContextPtr] reset];
    return YES;
}

- (NSArray<id<PFHistoryAnalyzerObjectState>> * _Nullable)fetchSortedStates:(NSError * _Nullable * _Nullable)error NS_RETURNS_RETAINED {
    /*
     self = x20
     error = x19
     */
    // x21
    NSFetchRequest<OCCKHistoryAnalyzerState *> *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[OCCKHistoryAnalyzerState entityPath]];
    fetchRequest.sortDescriptors = @[
        [NSSortDescriptor sortDescriptorWithKey:@"finalTransactionNumber" ascending:YES]
    ];
    fetchRequest.fetchBatchSize = 200;
    
    return [[*[self _managedObjectContextPtr] executeFetchRequest:fetchRequest error:error] retain];
}

- (BOOL)finishProcessing:(NSError * _Nullable * _Nullable)error {
    /*
     self = x20
     error = x19
     */
    // sp + 0x28
    NSError * _Nullable _error = nil;
    
    struct objc_super superInfo = { self, [self class] };
    BOOL result = ((BOOL (*)(struct objc_super *, SEL, id *))objc_msgSendSuper2)(&superInfo, _cmd, &_error);
    
    if (!result) {
        if (_error == nil) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        } else {
            if (error != NULL) {
                *error = _error;
            }
        }
        
        return NO;
    }
    
    result = [self _flushPendingAnalyzerStates:&_error];
    if (!result) {
        if (_error == nil) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        } else {
            if (error != NULL) {
                *error = _error;
            }
        }
        
        return NO;
    }
    
    BOOL _automaticallyPruneTransientRecords;
    {
        if (self == nil) {
            _automaticallyPruneTransientRecords = NO;
        } else {
            PFHistoryAnalyzerOptions * _Nullable options;
            assert(object_getInstanceVariable(self, "_options", (void **)&options) != NULL);
            if (options == nil) {
                _automaticallyPruneTransientRecords = NO;
            } else {
                Ivar ivar = object_getInstanceVariable(options, "_automaticallyPruneTransientRecords", NULL);
                assert(ivar != NULL);
                _automaticallyPruneTransientRecords = *(BOOL *)((uintptr_t)options + ivar_getOffset(ivar));
            }
        }
    }
    
    if (!_automaticallyPruneTransientRecords) return YES;
    // x21
    NSFetchRequest<OCCKHistoryAnalyzerState *> *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[OCCKHistoryAnalyzerState entityPath]];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"originalChangeTypeNum = %@ AND finalChangeTypeNum = %@", @0, @2];
    // x21
    NSBatchDeleteRequest *request = [[NSBatchDeleteRequest alloc] initWithFetchRequest:fetchRequest];
    request.resultType = NSBatchDeleteResultTypeStatusOnly;
    // x20
    BOOL boolValue = ((NSNumber *)((NSBatchDeleteResult *)[*[self _managedObjectContextPtr] executeRequest:request error:&_error]).result).boolValue;
    [request release];
    if (!boolValue) {
        if (_error == nil) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        } else {
            if (error != NULL) {
                *error = _error;
            }
        }
        
        return NO;
    }
    
    return YES;
}

- (id<PFHistoryAnalyzerObjectState> _Nullable)newAnalyzerStateForChange:(NSPersistentHistoryChange *)change error:(NSError * _Nullable * _Nullable)error {
    /*
     self = x20
     */
    struct objc_super superInfo = { self, [self class] };
    // x19
    id<PFHistoryAnalyzerObjectState> result = ((id<PFHistoryAnalyzerObjectState> (*)(struct objc_super *, SEL, id, id *))objc_msgSendSuper2)(&superInfo, _cmd, change, error);
    if (result == nil) return nil;
    
    // x21
    NSSQLModel *model = (*[self _storePtr]).model;
    NSEntityDescription *entity = result.analyzedObjectID.entity;
    // x22
    NSSQLEntity * _Nullable sqlEntity = [OCSPIResolver _sqlEntityForEntityDescription:model x1:entity];
    uint _entityID;
    {
        if (entity == nil) {
            _entityID = 0;
        } else {
            Ivar ivar = object_getInstanceVariable(sqlEntity, "_entityID", NULL);
            assert(ivar != NULL);
            _entityID = *(uint *)((uintptr_t)sqlEntity + ivar_getOffset(ivar));
        }
    }
    
    // x21
    NSMutableSet<NSNumber *> * _Nullable primaryKeySet = [[*[self _entityIDToChangedPrimaryKeySetPtr] objectForKey:@(_entityID)] retain];
    if (primaryKeySet == nil) {
        primaryKeySet = [[NSMutableSet alloc] init];
        [*[self _entityIDToChangedPrimaryKeySetPtr] setObject:primaryKeySet forKey:@(_entityID)];
    }
    [primaryKeySet addObject:@([result.analyzedObjectID _referenceData64])];
    [primaryKeySet release];
    
    return result;
}

- (BOOL)processChange:(NSPersistentHistoryChange *)change error:(NSError * _Nullable * _Nullable)error {
    /*
     self = x20
     change = x21
     error = x19
     */
    
    NSSet<NSString *> *configuredEntityNames = *[self _configuredEntityNamesPtr];
    
    // 1 = <+472> / 0 = <+202>
    BOOL flag;
    
    if (![configuredEntityNames containsObject:change.changedObjectID.entity.name]) {
        // <+276>
        os_log_with_type(_OCLogGetLogStream(0x11), OS_LOG_TYPE_DEFAULT, "OpenCloudData+CloudKit: %s(%d): %@: Skipping change because its entity is not in the configured set of entities for this store: %@", __func__, __LINE__, self, change.changedObjectID);
        // <+472>
        flag = YES;
    } else {
        // +104>
        NSString *NSCloudKitMirroringDelegateImportContextName = [OCSPIResolver NSCloudKitMirroringDelegateImportContextName];
        NSString *NSCloudKitMirroringDelegateResetSyncAuthor = [OCSPIResolver NSCloudKitMirroringDelegateResetSyncAuthor];
        
        if (([change.transaction.author isEqualToString:NSCloudKitMirroringDelegateImportContextName]) || ([change.transaction.contextName isEqualToString:NSCloudKitMirroringDelegateImportContextName]) || ([change.transaction.author isEqualToString:NSCloudKitMirroringDelegateResetSyncAuthor])) {
            // <+196>
            OCCloudKitHistoryAnalyzerOptions *options;
            assert(object_getInstanceVariable(self, "_options", (void **)&options) != NULL);
            if (!options.includePrivateTransactions) {
                // <+564>
                if (change.changeType == NSPersistentHistoryChangeTypeDelete) {
                    // <+580>
                    BOOL result = [self resetStateForObjectID:change.changedObjectID error:error];
                    if (result) {
                        // <+472>
                        flag = YES;
                    } else {
                        return NO;
                    }
                } else {
                    // <+472>
                    flag = YES;
                }
            } else {
                // <+220>
                flag = NO;
            }
        } else {
            // <+616>
            if (change.changeType == NSPersistentHistoryChangeTypeDelete) {
                // <+220>
                flag = NO;
            } else {
                // <+632>
                if (change.updatedProperties.count == 0) {
                    // <+220>
                    flag = NO;
                } else {
                    flag = YES;
                    for (NSPropertyDescription *property in change.updatedProperties) {
                        BOOL boolValue = ((NSNumber *)property.userInfo[[OCSPIResolver NSCloudKitMirroringDelegateIgnoredPropertyKey]]).boolValue;
                        if (!boolValue) {
                            // <+220>
                            flag = NO;
                            break;
                        }
                    }
                    
                    // break가 안 됐다면 <+472> (flag = YES)
                }
            }
        }
    }
    
    if (!flag) {
        // <+220>
        struct objc_super superInfo = { self, [self class] };
        BOOL result = ((BOOL (*)(struct objc_super *, SEL, id, id *))objc_msgSendSuper2)(&superInfo, _cmd, change, error);
        if (!result) return NO;
    }
    
    // <+472>
    NSMutableDictionary<NSManagedObjectID *, id<PFHistoryAnalyzerObjectState>> *objectIDToState;
    assert(object_getInstanceVariable(self, "_objectIDToState", (void **)&objectIDToState) != NULL);
    
    if (objectIDToState.count < 1000) {
        return YES;
    } else {
        return [self _flushPendingAnalyzerStates:error];
    }
}

- (BOOL)resetStateForObjectID:(NSManagedObjectID *)objectID error:(NSError * _Nullable * _Nullable)error {
    /*
     self = x22
     objectID = x21
     error = x20
     */
    // sp, #0x18
    NSError * _Nullable _error = nil;
    
    struct objc_super superInfo = { self, [self class] };
    BOOL result = ((BOOL (*)(struct objc_super *, SEL, id, id *))objc_msgSendSuper2)(&superInfo, _cmd, objectID, &_error);
    
    if (result) {
        [*[self _resetChangedObjectIDsPtr] addObject:objectID];
    } else {
        if (_error == nil) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        } else {
            if (error != NULL) {
                *error = _error;
            }
        }
    }
    
    return result;
}

- (BOOL)_flushPendingAnalyzerStates:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct)) {
    /*
     self = x20
     error = x19
     */
    
    // sp + 0x90
    __block NSError * _Nullable _error = nil;
    // sp + 0x48
    __block BOOL _succeed = YES;
    
    /*
     __64-[PFCloudKitHistoryAnalyzerContext _flushPendingAnalyzerStates:]_block_invoke
     self = sp + 0x28 = x19 + 0x20
     _succeed = sp + 0x30 = x19 + 0x28
     _error = sp + 0x38 = x19 + 0x30
     */
    [*[self _managedObjectContextPtr] performBlockAndWait:^{
        if (!_succeed) return;
        
        NSMutableDictionary<NSManagedObjectID *, id<PFHistoryAnalyzerObjectState>> *objectIDToState;
        {
            if (self == nil) {
                objectIDToState = nil;
            } else {
                assert(object_getInstanceVariable(self, "_objectIDToState", (void **)&objectIDToState) != NULL);
            }
        }
        
        if (objectIDToState.count != 0) {
            // x20
            for (NSNumber *entityIDNumber in *[self _entityIDToChangedPrimaryKeySetPtr]) {
                NSMutableSet<NSNumber *> *changedPrimaryKeySet = [*[self _entityIDToChangedPrimaryKeySetPtr] objectForKey:entityIDNumber];
                // x26
                NSFetchRequest<OCCKHistoryAnalyzerState *> *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[OCCKHistoryAnalyzerState entityPath]];
                fetchRequest.predicate = [NSPredicate predicateWithFormat:@"entityId = %@ AND entityPK in %@", entityIDNumber, changedPrimaryKeySet];
                
                NSArray<OCCKHistoryAnalyzerState *> * _Nullable results = [*[self _managedObjectContextPtr] executeFetchRequest:fetchRequest error:&_error];
                if (results == nil) {
                    _succeed = NO;
                    [_error retain];
                    return;
                }
                
                // x20
                for (OCCKHistoryAnalyzerState *state in results) {
                    // x22
                    NSManagedObjectID *analyzedObjectID = state.analyzedObjectID;
                    
                    // x28
                    id<PFHistoryAnalyzerObjectState> state_2 = [[objectIDToState objectForKey:analyzedObjectID] retain];
                    if (state_2 != nil) {
                        [state mergeWithState:state_2];
                        [objectIDToState removeObjectForKey:analyzedObjectID];
                    }
                    
                    if ([*[self _resetChangedObjectIDsPtr] containsObject:analyzedObjectID]) {
                        [*[self _managedObjectContextPtr] deleteObject:state];
                    } else {
                        os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: History parsing corruption detected. An existing analyzer state was fetched from the database for '%@' but it's corresponding in-memory copy is no longer present in the in-memory cache.\n", analyzedObjectID);
                        os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: History parsing corruption detected. An existing analyzer state was fetched from the database for '%@' but it's corresponding in-memory copy is no longer present in the in-memory cache.\n", analyzedObjectID);
                    }
                    
                    [state_2 release];
                }
            }
        }
        
        // <+876>
        // x26
        for (NSManagedObjectID *objectID in objectIDToState) {
            // x25
            id<PFHistoryAnalyzerObjectState> state = [[objectIDToState objectForKey:objectID] retain];
            // x27
            OCCKHistoryAnalyzerState *stateObject = [NSEntityDescription insertNewObjectForEntityForName:[OCCKHistoryAnalyzerState entityPath] inManagedObjectContext:*[self _managedObjectContextPtr]];
            
            [stateObject setValue:state.originalTransactionNumber forKey:@"originalTransactionNumber"];
            stateObject.originalChangeTypeNum = @(state.originalChangeType);
            [stateObject setValue:state.finalTransactionNumber forKey:@"finalTransactionNumber"];
            [stateObject setValue:state.finalChangeAuthor forKey:@"finalChangeAuthor"];
            stateObject.finalChangeTypeNum = @(state.finalChangeType);
            
            NSSQLCore *store = *[self _storePtr];
            NSSQLEntity * _Nullable sqlEntity = [OCSPIResolver _sqlEntityForEntityDescription:store.model x1:objectID.entity];
            
            uint _entityID;
            {
                if (sqlEntity == nil) {
                    _entityID = 0;
                } else {
                    Ivar ivar = object_getInstanceVariable(sqlEntity, "_entityID", NULL);
                    assert(ivar != NULL);
                    _entityID = *(uint *)((uintptr_t)sqlEntity + ivar_getOffset(ivar));
                }
            }
            
            stateObject.entityId = @(_entityID);
            stateObject.entityPK = @([objectID _referenceData64]);
            
            [*[self _managedObjectContextPtr] assignObject:stateObject toPersistentStore:*[self _storePtr]];
            [state release];
        }
        
        NSPersistentHistoryToken *finalHistoryToken;
        assert(object_getInstanceVariable(self, "_finalHistoryToken", (void **)&finalHistoryToken) != NULL);
        
        // <+1448>
        OCCKMetadataEntry * _Nullable entry = [OCCKMetadataEntry updateOrInsertMetadataEntryWithKey:[OCSPIResolver NSCloudKitMirroringDelegateLastHistoryTokenKey] transformedValue:finalHistoryToken forStore:*[self _storePtr] intoManagedObjectContext:*[self _managedObjectContextPtr] error:&_error];
        if (entry == nil) {
            _succeed = NO;
            [_error retain];
            return;
        }
        
        BOOL result = [*[self _managedObjectContextPtr] save:&_error];
        if (!result) {
            // 원래 코드에는 NO로 설정하지 않음
            _succeed = NO;
            
            [_error retain];
        }
    }];
    
    if (_succeed) {
        NSMutableDictionary<NSManagedObjectID *, id<PFHistoryAnalyzerObjectState>> *objectIDToState;
        assert(object_getInstanceVariable(self, "_objectIDToState", (void **)&objectIDToState) != NULL);
        [objectIDToState removeAllObjects];
        
        NSMutableSet<NSNumber *> *processedTransactionIDs;
        assert(object_getInstanceVariable(self, "_processedTransactionIDs", (void **)&processedTransactionIDs) != NULL);
        [processedTransactionIDs removeAllObjects];
        
        [*[self _resetChangedObjectIDsPtr] removeAllObjects];
        [*[self _entityIDToChangedPrimaryKeySetPtr] removeAllObjects];
    } else {
        if (_error == nil) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Illegal attempt to return an error without one in %s:%d\n", __FILE__, __LINE__);
        } else {
            if (error != NULL) {
                *error = [[_error retain] autorelease];
            }
        }
    }
    
    [_error release];
    return _succeed;
}

- (NSMutableDictionary<NSNumber *, NSMutableSet<NSNumber *> *> * _Nullable *)_entityIDToChangedPrimaryKeySetPtr {
    Ivar ivar = object_getInstanceVariable(self, "_entityIDToChangedPrimaryKeySet", NULL);
    assert(ivar != NULL);
    return (id *)((uintptr_t)self + ivar_getOffset(ivar));
}

- (NSMutableSet<NSManagedObjectID *> * _Nullable *)_resetChangedObjectIDsPtr __attribute__((objc_direct)) {
    Ivar ivar = object_getInstanceVariable(self, "_resetChangedObjectIDs", NULL);
    assert(ivar != NULL);
    return (id *)((uintptr_t)self + ivar_getOffset(ivar));
}

- (NSManagedObjectContext * _Nullable *)_managedObjectContextPtr __attribute__((objc_direct)) {
    Ivar ivar = object_getInstanceVariable(self, "_managedObjectContext", NULL);
    assert(ivar != NULL);
    return (id *)((uintptr_t)self + ivar_getOffset(ivar));
}

- (NSSet<NSString *> * _Nullable *)_configuredEntityNamesPtr __attribute__((objc_direct)) {
    Ivar ivar = object_getInstanceVariable(self, "_configuredEntityNames", NULL);
    assert(ivar != NULL);
    return (id *)((uintptr_t)self + ivar_getOffset(ivar));
}

- (NSSQLCore * _Nullable *)_storePtr __attribute__((objc_direct)) {
    Ivar ivar = object_getInstanceVariable(self, "_store", NULL);
    assert(ivar != NULL);
    return (id *)((uintptr_t)self + ivar_getOffset(ivar));
}

@end
