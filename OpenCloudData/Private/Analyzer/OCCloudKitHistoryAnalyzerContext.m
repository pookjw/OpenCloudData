//
//  OCCloudKitHistoryAnalyzerContext.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/20/25.
//

#import <OpenCloudData/OCCloudKitHistoryAnalyzerContext.h>
#import <OpenCloudData/Log.h>
#import <OpenCloudData/OCCKHistoryAnalyzerState.h>
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
    abort();
}

- (BOOL)finishProcessing:(NSError * _Nullable * _Nullable)error {
    abort();
}

- (id<PFHistoryAnalyzerObjectState> _Nullable)newAnalyzerStateForChange:(NSPersistentHistoryChange *)change error:(NSError * _Nullable * _Nullable)error {
    abort();
}

- (BOOL)processChange:(NSPersistentHistoryChange *)change error:(NSError * _Nullable * _Nullable)error {
    abort();
}

- (BOOL)resetStateForObjectID:(NSManagedObjectID *)objectID error:(NSError * _Nullable * _Nullable)error {
    abort();
}

- (BOOL)_flushPendingAnalyzerStates:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct)) {
    abort();
}

// 0x8
- (NSMutableDictionary<NSNumber *, NSMutableSet<NSNumber *> *> * _Nullable *)_entityIDToChangedPrimaryKeySetPtr {
    Ivar ivar = object_getInstanceVariable(self, "_entityIDToChangedPrimaryKeySet", NULL);
    assert(ivar != NULL);
    return (id *)((uintptr_t)self + ivar_getOffset(ivar));
}

// 0x4
- (NSMutableSet<NSManagedObjectID *> * _Nullable *)_resetChangedObjectIDsPtr __attribute__((objc_direct)) {
    Ivar ivar = object_getInstanceVariable(self, "_resetChangedObjectIDs", NULL);
    assert(ivar != NULL);
    return (id *)((uintptr_t)self + ivar_getOffset(ivar));
}

// 0x0
- (NSManagedObjectContext * _Nullable *)_managedObjectContextPtr __attribute__((objc_direct)) {
    Ivar ivar = object_getInstanceVariable(self, "_managedObjectContext", NULL);
    assert(ivar != NULL);
    return (id *)((uintptr_t)self + ivar_getOffset(ivar));
}

// 0xc
- (NSSet<NSString *> * _Nullable *)_configuredEntityNamesPtr __attribute__((objc_direct)) {
    Ivar ivar = object_getInstanceVariable(self, "_configuredEntityNames", NULL);
    assert(ivar != NULL);
    return (id *)((uintptr_t)self + ivar_getOffset(ivar));
}

// 0x10
- (NSSQLCore * _Nullable *)_storePtr __attribute__((objc_direct)) {
    Ivar ivar = object_getInstanceVariable(self, "_store", NULL);
    assert(ivar != NULL);
    return (id *)((uintptr_t)self + ivar_getOffset(ivar));
}

@end
