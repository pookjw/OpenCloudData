//
//  OCCloudKitModelValidator.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/23/25.
//

#import "OpenCloudData/Private/OCCloudKitMirroringDelegateOptions.h"

NS_ASSUME_NONNULL_BEGIN

@interface OCCloudKitModelValidator : NSObject {
    @package NSManagedObjectModel *_model; // 0x8
    NSString *_configurationName; // 0x10
    @package BOOL _skipValueTransformerValidation; // 0x18
    BOOL _validateLegacyMetadataAttributes; // 0x19
    OCCloudKitMirroringDelegateOptions *_options; // 0x20
    BOOL _supportsMergeableTransformable; // 0x28
}
+ (BOOL)enforceUniqueConstraintChecks __attribute__((objc_direct));
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithManagedObjectModel:(NSManagedObjectModel *)managedObjectModel configuration:(NSString *)configuration mirroringDelegateOptions:(OCCloudKitMirroringDelegateOptions *)delegateOptions;
- (BOOL)_validateManagedObjectModel:(NSManagedObjectModel *)managedObjectModel error:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct));
- (BOOL)validateEntities:(NSArray<NSEntityDescription *> *)entities error:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct));
@end

NS_ASSUME_NONNULL_END
