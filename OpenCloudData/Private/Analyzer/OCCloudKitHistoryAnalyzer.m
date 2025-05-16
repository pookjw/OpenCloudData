//
//  OCCloudKitHistoryAnalyzer.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/20/25.
//

#import <OpenCloudData/OCCloudKitHistoryAnalyzer.h>
#import <OpenCloudData/OCSPIResolver.h>
#import <OpenCloudData/OCCloudKitHistoryAnalyzerContext.h>
#import <OpenCloudData/Log.h>
#import <objc/runtime.h>
#import <objc/message.h>

OBJC_EXPORT id objc_msgSendSuper2(void);

@implementation OCCloudKitHistoryAnalyzer

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
        Class _isa = objc_allocateClassPair(objc_lookUpClass("PFHistoryAnalyzer"), "_OCCloudKitHistoryAnalyzer", 0);
        
        assert(class_addIvar(_isa, "_managedObjectContext", sizeof(id), sizeof(id), @encode(id)));
        assert(class_addIvar(_isa, "_lastProcessedToken", sizeof(id), sizeof(id), @encode(id)));
        
        IMP isPrivateContextName_ = method_getImplementation(class_getClassMethod(self, @selector(isPrivateContextName:)));
        assert(isPrivateContextName_ != NULL);
        assert(class_addMethod(object_getClass(_isa), @selector(isPrivateContextName:), isPrivateContextName_, NULL));
        
        IMP isPrivateTransaction_ = method_getImplementation(class_getClassMethod(self, @selector(isPrivateTransaction:)));
        assert(isPrivateTransaction_ != NULL);
        assert(class_addMethod(object_getClass(_isa), @selector(isPrivateTransaction:), isPrivateTransaction_, NULL));
        
        IMP isPrivateTransactionAuthor_ = method_getImplementation(class_getClassMethod(self, @selector(isPrivateTransactionAuthor:)));
        assert(isPrivateTransactionAuthor_ != NULL);
        assert(class_addMethod(object_getClass(_isa), @selector(isPrivateTransactionAuthor:), isPrivateTransactionAuthor_, NULL));
        
        IMP initWithOptions_managedObjectContext_ = class_getMethodImplementation(self, @selector(initWithOptions:managedObjectContext:));
        assert(initWithOptions_managedObjectContext_ != NULL);
        assert(class_addMethod(_isa, @selector(initWithOptions:managedObjectContext:), initWithOptions_managedObjectContext_, NULL));
        
        IMP dealloc = class_getMethodImplementation(self, @selector(dealloc));
        assert(dealloc != NULL);
        assert(class_addMethod(_isa, @selector(dealloc), dealloc, NULL));
        
        IMP instantiateNewAnalyzerContextForChangesInStore_ = class_getMethodImplementation(self, @selector(instantiateNewAnalyzerContextForChangesInStore:));
        assert(instantiateNewAnalyzerContextForChangesInStore_ != NULL);
        assert(class_addMethod(_isa, @selector(instantiateNewAnalyzerContextForChangesInStore:), instantiateNewAnalyzerContextForChangesInStore_, NULL));
        
        IMP processTransaction_withContext_error_ = class_getMethodImplementation(self, @selector(processTransaction:withContext:error:));
        assert(processTransaction_withContext_error_ != NULL);
        assert(class_addMethod(_isa, @selector(processTransaction:withContext:error:), processTransaction_withContext_error_, NULL));
        
        objc_registerClassPair(_isa);
        
        isa = _isa;
    });
    
    return isa;
}

+ (BOOL)isPrivateContextName:(NSString *)name {
    if ([name isEqualToString:[OCSPIResolver NSCloudKitMirroringDelegateExportContextName]]) return YES;
    if ([name isEqualToString:[OCSPIResolver NSCloudKitMirroringDelegateImportContextName]]) return YES;
    return NO;
}

+ (BOOL)isPrivateTransaction:(NSPersistentHistoryTransaction *)transaction {
    if ([OCCloudKitHistoryAnalyzer isPrivateTransactionAuthor:transaction.author]) {
        return YES;
    }
    if ([OCCloudKitHistoryAnalyzer isPrivateContextName:transaction.contextName]) {
        return YES;
    }
    return NO;
}

+ (BOOL)isPrivateTransactionAuthor:(NSString *)author {
    if ([author isEqualToString:[OCSPIResolver NSCloudKitMirroringDelegateExportContextName]]) return YES;
    if ([author isEqualToString:[OCSPIResolver NSCloudKitMirroringDelegateImportContextName]]) return YES;
    if ([author isEqualToString:[OCSPIResolver NSCloudKitMirroringDelegateResetSyncAuthor]]) return YES;
    if ([author isEqualToString:[OCSPIResolver NSCloudKitMirroringDelegateMigrationAuthor]]) return YES;
    if ([author isEqualToString:[OCSPIResolver NSCloudKitMirroringDelegateSetupAuthor]]) return YES;
    if ([author isEqualToString:[OCSPIResolver NSCloudKitMirroringDelegateEventAuthor]]) return YES;
    return NO;
}

- (instancetype)initWithOptions:(OCCloudKitHistoryAnalyzerOptions *)options managedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    /*
     self = x21
     options = x20
     managedObjectContext = x19
     */
    if (![options isKindOfClass:[OCCloudKitHistoryAnalyzerOptions class]]) {
        os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Attempt to init PFCloudKitHistoryAnalyzer with the wrong options class: %@\n", [options class]);
        os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Attempt to init PFCloudKitHistoryAnalyzer with the wrong options class: %@\n", [options class]);
    }
    
    struct objc_super superInfo = { self, [self class] };
    self = ((id (*)(struct objc_super *, SEL, id))objc_msgSendSuper2)(&superInfo, @selector(initWithOptions:), options);
    
    if (self) {
        *[self _managedObjectContextPtr] = [managedObjectContext retain];
    }
    
    return self;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-missing-super-calls"
- (void)dealloc {
    [*[self _managedObjectContextPtr] release];
    [*[self _lastProcessedTokenPtr] release];
    
    struct objc_super superInfo = { self, [self class] };
    ((void (*)(struct objc_super *, SEL))objc_msgSendSuper2)(&superInfo, _cmd);
}
#pragma clang diagnostic pop

- (PFHistoryAnalyzerContext *)instantiateNewAnalyzerContextForChangesInStore:(NSPersistentStore *)store NS_RETURNS_RETAINED {
    return (PFHistoryAnalyzerContext *)[[OCCloudKitHistoryAnalyzerContext alloc] initWithOptions:*((OCCloudKitHistoryAnalyzerOptions **)[self _optionsPtr]) managedObjectContext:*[self _managedObjectContextPtr] store:(NSSQLCore *)store];
}

- (BOOL)processTransaction:(NSPersistentHistoryTransaction *)transaction withContext:(NSManagedObjectContext *)context error:(NSError * _Nullable * _Nullable)error {
    /*
     self = x21
     transaction = x19
     context = x22
     error = x20
     */
    
    NSError * _Nullable _error = nil;
    
    if ([OCCloudKitHistoryAnalyzer isPrivateTransaction:transaction] && ![transaction.author isEqualToString:[OCSPIResolver NSCloudKitMirroringDelegateImportContextName]] && ![transaction.contextName isEqualToString:[OCSPIResolver NSCloudKitMirroringDelegateImportContextName]] && ![transaction.contextName isEqualToString:[OCSPIResolver NSCloudKitMirroringDelegateResetSyncAuthor]]) {
        // nop (<+388>)
    } else {
        // x23
        OCCloudKitMirroringRequest *request = (*(OCCloudKitHistoryAnalyzerOptions **)[self _optionsPtr]).request;
        
        BOOL deferred;
        CKSchedulerActivity *schedulerActivity;
        {
            if (request == nil) {
                schedulerActivity = nil;
            } else {
                schedulerActivity = request->_schedulerActivity;
            }
        }
        if (schedulerActivity.shouldDefer) {
            deferred = YES;
        } else {
            BOOL deferredByBackgroundTimeout;
            {
                if (request == nil) {
                    deferredByBackgroundTimeout = NO;
                } else {
                    deferredByBackgroundTimeout = request->_deferredByBackgroundTimeout;
                }
            }
            deferred = deferredByBackgroundTimeout;
        }
        
        if (deferred) {
            _error = [NSError errorWithDomain:NSCocoaErrorDomain code:134419 userInfo:@{
                NSLocalizedFailureReasonErrorKey: @"History analysis was aborted because the activity was deferred by the system."
            }];
            
            if (error != NULL) {
                *error = _error;
            }
            return NO;
        }
        
        // <+344>
        struct objc_super superInfo = { self, [self class] };
        BOOL result = ((BOOL (*)(struct objc_super *, SEL, id, id, id *))objc_msgSendSuper2)(&superInfo, _cmd, transaction, context, &_error);
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
    }
    
    // <+388>
    // x22
    NSPersistentHistoryToken *lastProcessedToken = *[self _lastProcessedTokenPtr];
    
    if (lastProcessedToken == transaction.token) {
        // <+584>
        if (transaction.token != nil) {
            os_log_error(_OCLogGetLogStream(0x11), "OpenCloudData: fault: Transaction appears to have been processed twice: %@\n", transaction);
            os_log_fault(_OCLogGetLogStream(0x11), "OpenCloudData: Transaction appears to have been processed twice: %@\n", transaction);
        }
    } else {
        // Analyzer 무시
        [*[self _lastProcessedTokenPtr] release];
        *[self _lastProcessedTokenPtr] = [transaction.token retain];
    }
    
    return YES;
}

- (PFHistoryAnalyzerOptions * _Nullable *)_optionsPtr __attribute__((objc_direct)) {
    Ivar ivar = object_getInstanceVariable(self, "_options", NULL);
    assert(ivar != NULL);
    return (id *)((uintptr_t)self + ivar_getOffset(ivar));
}

- (NSManagedObjectContext * _Nullable *)_managedObjectContextPtr __attribute__((objc_direct)) {
    Ivar ivar = object_getInstanceVariable(self, "_managedObjectContext", NULL);
    assert(ivar != NULL);
    return (id *)((uintptr_t)self + ivar_getOffset(ivar));
}

- (NSPersistentHistoryToken * _Nullable *)_lastProcessedTokenPtr __attribute__((objc_direct)) {
    Ivar ivar = object_getInstanceVariable(self, "_lastProcessedToken", NULL);
    assert(ivar != NULL);
    return (id *)((uintptr_t)self + ivar_getOffset(ivar));
}

@end
