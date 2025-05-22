//
//  OCCloudKitHistoryAnalyzerOptions.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/20/25.
//

#import "OpenCloudData/Private/Analyzer/OCCloudKitHistoryAnalyzerOptions.h"
#import <objc/runtime.h>
#import <objc/message.h>

OBJC_EXPORT id _Nullable objc_getProperty(id _Nullable self, SEL _Nonnull _cmd, ptrdiff_t offset, BOOL atomic);
OBJC_EXPORT void objc_setProperty_nonatomic(id _Nullable self, SEL _Nonnull _cmd, id _Nullable newValue, ptrdiff_t offset);
OBJC_EXPORT id objc_msgSendSuper2(void);

@implementation OCCloudKitHistoryAnalyzerOptions

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
        Class _isa = objc_allocateClassPair(objc_lookUpClass("PFHistoryAnalyzerOptions"), "_OCCloudKitHistoryAnalyzerOptions", 0);
        
        assert(class_addIvar(_isa, "_includePrivateTransactions", sizeof(BOOL), sizeof(BOOL), @encode(BOOL)));
        assert(class_addIvar(_isa, "_request", sizeof(OCCloudKitMirroringRequest *), sizeof(OCCloudKitMirroringRequest *), @encode(OCCloudKitMirroringRequest *)));
        
        IMP dealloc = class_getMethodImplementation(self, @selector(dealloc));
        assert(dealloc != NULL);
        assert(class_addMethod(_isa, @selector(dealloc), dealloc, NULL));
        
        IMP copyWithZone_ = class_getMethodImplementation(self, @selector(copyWithZone:));
        assert(copyWithZone_ != NULL);
        assert(class_addMethod(_isa, @selector(copyWithZone:), copyWithZone_, NULL));
        
        objc_registerClassPair(_isa);
        
        isa = _isa;
    });
    
    return isa;
}

- (BOOL)includePrivateTransactions {
    Ivar ivar = object_getInstanceVariable(self, "_includePrivateTransactions", NULL);
    assert(ivar != NULL);
    return *(BOOL *)((uintptr_t)self + ivar_getOffset(ivar));
}

- (void)setIncludePrivateTransactions:(BOOL)includePrivateTransactions {
    Ivar ivar = object_getInstanceVariable(self, "_includePrivateTransactions", NULL);
    assert(ivar != NULL);
    *(BOOL *)((uintptr_t)self + ivar_getOffset(ivar)) = includePrivateTransactions;
}

- (OCCloudKitMirroringRequest *)request {
    Ivar ivar = object_getInstanceVariable(self, "_request", NULL);
    assert(ivar != NULL);
    return objc_getProperty(self, _cmd, ivar_getOffset(ivar), NO);
}

- (void)setRequest:(OCCloudKitMirroringRequest *)request {
    Ivar ivar = object_getInstanceVariable(self, "_request", NULL);
    assert(ivar != NULL);
    objc_setProperty_nonatomic(self, _cmd, request, ivar_getOffset(ivar));
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-missing-super-calls"
- (void)dealloc {
    Ivar ivar = object_getInstanceVariable(self, "_request", NULL);
    assert(ivar != NULL);
    ptrdiff_t offset = ivar_getOffset(ivar);
    [*(id *)((uintptr_t)self + offset) release];
    
    struct objc_super superInfo = { self, [self class] };
    ((void (*)(struct objc_super *, SEL))objc_msgSendSuper2)(&superInfo, _cmd);
}
#pragma clang diagnostic pop

- (id)copyWithZone:(struct _NSZone *)zone {
    struct objc_super superInfo = { self, [self class] };
    OCCloudKitHistoryAnalyzerOptions *copy = ((id (*)(struct objc_super *, SEL, struct _NSZone *))objc_msgSendSuper2)(&superInfo, _cmd, zone);
    
    {
        Ivar ivar = object_getInstanceVariable(self, "_includePrivateTransactions", NULL);
        assert(ivar != NULL);
        ptrdiff_t offset = ivar_getOffset(ivar);
        *(BOOL *)((uintptr_t)copy + offset) = *(BOOL *)((uintptr_t)self + offset);
    }
    
    {
        Ivar ivar = object_getInstanceVariable(self, "_request", NULL);
        assert(ivar != NULL);
        ptrdiff_t offset = ivar_getOffset(ivar);
        *(id *)((uintptr_t)copy + offset) = [*(id *)((uintptr_t)self + offset) retain];
    }
    
    return copy;
}

@end
