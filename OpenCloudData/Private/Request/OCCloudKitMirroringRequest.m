//
//  OCCloudKitMirroringRequest.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/1/25.
//

#import <OpenCloudData/OCCloudKitMirroringRequest.h>
#import <OpenCloudData/OCCloudKitMirroringInitializeSchemaRequest.h>

@implementation OCCloudKitMirroringRequest

+ (NSSet<Class> *)allRequestClasses {
    /*
     {(
         NSCloudKitMirroringResetMetadataRequest,
         NSCloudKitMirroringDelegateSetupRequest,
         NSCloudKitMirroringInitializeSchemaRequest, 🙃
         NSCloudKitMirroringExportProgressRequest,
         NSCloudKitMirroringAcceptShareInvitationsRequest,
         NSCloudKitMirroringFetchRecordsRequest,
         NSCloudKitMirroringDelegateResetRequest,
         NSCloudKitMirroringDelegateSerializationRequest,
         NSCloudKitMirroringImportRequest,
         NSCloudKitMirroringExportRequest,
         NSCloudKitMirroringResetZoneRequest
     )}
     */
    return [NSSet setWithObjects:[OCCloudKitMirroringInitializeSchemaRequest class],
            nil];
}

- (instancetype)initWithOptions:(OCCloudKitMirroringRequestOptions *)options completionBlock:(void (^)(OCCloudKitMirroringResult * _Nonnull))requestCompletionBlock {
    if (self = [super init]) {
        if (options == nil) {
            _options = [self createDefaultOptions];
        } else {
            _options = [options copy];
        }
        
        _requestIdentifier = [[NSUUID alloc] init];
        _requestCompletionBlock = [requestCompletionBlock copy];
        _deferredByBackgroundTimeout = NO;
        _containerBlocks = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (instancetype)initWithActivity:(CKSchedulerActivity *)activity options:(OCCloudKitMirroringRequestOptions *)options completionBlock:(void (^)(OCCloudKitMirroringResult * _Nonnull))requestCompletionBlock {
    if (self = [self initWithOptions:options completionBlock:requestCompletionBlock]) {
        _schedulerActivity = [activity retain];
    }
    
    return self;
}

- (void)dealloc {
    [_requestIdentifier release];
    [_options release];
    [_requestCompletionBlock release];
    [_schedulerActivity release];
    [_activity release];
    [_containerBlocks release];
    [super dealloc];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p> %@", NSStringFromClass([self class]), self, _requestIdentifier];
}

- (id)copyWithZone:(struct _NSZone *)zone {
    __kindof OCCloudKitMirroringRequest *copy = [super copyWithZone:zone];
    
    copy->_requestIdentifier = [_requestIdentifier retain];
    copy->_options = [_options retain];
    copy->_requestIdentifier = [_requestIdentifier retain];
    copy->_schedulerActivity = [_schedulerActivity retain];
    copy->_isContainerRequest = _isContainerRequest;
    copy->_containerBlocks = [_containerBlocks mutableCopy];
    copy->_deferredByBackgroundTimeout = _deferredByBackgroundTimeout;
    
    return copy;
}

- (NSPersistentStoreRequestType)requestType {
    return 9;
}

- (OCCloudKitMirroringRequestOptions *)createDefaultOptions {
    return [[OCCloudKitMirroringRequestOptions alloc] init];
}

- (void)invokeCompletionBlockWithResult:(OCCloudKitMirroringResult *)result {
    void (^ _Nullable requestCompletionBlock)(OCCloudKitMirroringResult * result) = _requestCompletionBlock;
    if (requestCompletionBlock) {
        requestCompletionBlock(result);
    }
    
    [self _invokeCompletionBlockWithResult:result];
}

- (void)_invokeCompletionBlockWithResult:(OCCloudKitMirroringResult *)result __attribute__((objc_direct)) {
    for (void (^ block)(OCCloudKitMirroringResult * result) in _containerBlocks) {
        block(result);
    }
}

- (BOOL)validateForUseWithStore:(__kindof NSPersistentStore *)store error:(NSError * _Nullable *)error {
    return YES;
}

- (void)addContainerBlock:(void (^)(OCCloudKitMirroringResult * _Nonnull))block {
    @autoreleasepool {
        void (^copy)(OCCloudKitMirroringResult * _Nonnull) = [block copy];
        [_containerBlocks addObject:copy];
        [copy release];
    }
}

@end
