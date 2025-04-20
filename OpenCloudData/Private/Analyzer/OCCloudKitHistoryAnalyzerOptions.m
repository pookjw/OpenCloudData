//
//  OCCloudKitHistoryAnalyzerOptions.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/20/25.
//

#import <OpenCloudData/OCCloudKitHistoryAnalyzerOptions.h>
#import <objc/runtime.h>

OBJC_EXPORT id _Nullable
objc_getProperty(id _Nullable self, SEL _Nonnull _cmd,
                 ptrdiff_t offset, BOOL atomic);

OBJC_EXPORT void
objc_setProperty_nonatomic(id _Nullable self, SEL _Nonnull _cmd,
                           id _Nullable newValue, ptrdiff_t offset);

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

@end
