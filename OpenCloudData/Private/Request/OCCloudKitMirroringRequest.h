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

NS_ASSUME_NONNULL_BEGIN

#warning TODO

@interface OCCloudKitMirroringRequest : NSPersistentStoreRequest
+ (NSSet<Class> *)allRequestClasses;

// original : (nonatomic, readonly) 내부적으로 retain/release하고 있음
@property (retain, nonatomic, readonly) NSUUID* requestIdentifier;

@property (copy, nonatomic, readonly) OCCloudKitMirroringRequestOptions *options;
@property (copy, nonatomic, readonly) void (^ requestCompletionBlock)(OCCloudKitMirroringResult * result);

- (instancetype)initWithOptions:(OCCloudKitMirroringRequestOptions * _Nullable)options completionBlock:(void (^ _Nullable)(OCCloudKitMirroringResult * result))requestCompletionBlock;
- (instancetype)initWithActivity:(CKSchedulerActivity *)activity options:(OCCloudKitMirroringRequestOptions * _Nullable)options completionBlock:(void (^ _Nullable)(OCCloudKitMirroringResult * result))requestCompletionBlock;

- (OCCloudKitMirroringRequestOptions *)createDefaultOptions NS_RETURNS_RETAINED;
- (BOOL)validateForUseWithStore:(__kindof NSPersistentStore *)store error:(NSError * _Nullable * _Nullable)error;

- (void)invokeCompletionBlockWithResult:(OCCloudKitMirroringResult *)result __attribute__((objc_direct));
- (void)addContainerBlock:(void (^)(OCCloudKitMirroringResult * result))block __attribute__((objc_direct));
@end

NS_ASSUME_NONNULL_END
