//
//  OCCloudKitMirroringRequest.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/1/25.
//

#import <CoreData/CoreData.h>
#import <OpenCloudData/OCCloudKitMirroringRequestOptions.h>
#import <OpenCloudData/OCCloudKitMirroringResult.h>
#import <OpenCloudData/CKSchedulerActivity.h>
#import <OpenCloudData/OCPersistentCloudKitContainerEventActivity.h>

NS_ASSUME_NONNULL_BEGIN

@interface OCCloudKitMirroringRequest : NSPersistentStoreRequest {
    @package BOOL _deferredByBackgroundTimeout; // 0x28
    NSMutableArray *_containerBlocks;
    BOOL _isContainerRequest;
    @package CKSchedulerActivity *_schedulerActivity; // 0x40
    @package OCPersistentCloudKitContainerEventActivity *_activity; // 0x48
}
+ (NSSet<Class> *)allRequestClasses;

// original : (nonatomic, readonly) 내부적으로 retain/release하고 있음
@property (retain, nonatomic, readonly) NSUUID* requestIdentifier;

@property (copy, nonatomic, readonly, nullable) OCCloudKitMirroringRequestOptions *options;
@property (copy, nonatomic, readonly) void (^ requestCompletionBlock)(OCCloudKitMirroringResult * result);

- (instancetype)initWithOptions:(OCCloudKitMirroringRequestOptions * _Nullable)options completionBlock:(void (^ _Nullable)(OCCloudKitMirroringResult * result))requestCompletionBlock;
- (instancetype)initWithActivity:(CKSchedulerActivity *)activity options:(OCCloudKitMirroringRequestOptions * _Nullable)options completionBlock:(void (^ _Nullable)(OCCloudKitMirroringResult * result))requestCompletionBlock;

- (OCCloudKitMirroringRequestOptions *)createDefaultOptions NS_RETURNS_RETAINED;
- (BOOL)validateForUseWithStore:(__kindof NSPersistentStore *)store error:(NSError * _Nullable * _Nullable)error;

- (void)invokeCompletionBlockWithResult:(OCCloudKitMirroringResult *)result __attribute__((objc_direct));
- (void)addContainerBlock:(void (^)(OCCloudKitMirroringResult * result))block __attribute__((objc_direct));
@end

NS_ASSUME_NONNULL_END
