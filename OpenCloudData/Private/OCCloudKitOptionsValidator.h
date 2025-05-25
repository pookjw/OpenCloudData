//
//  OCCloudKitOptionsValidator.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/23/25.
//

#import "OpenCloudData/Private/OCCloudKitMirroringDelegateOptions.h"

NS_ASSUME_NONNULL_BEGIN

@interface OCCloudKitOptionsValidator : NSObject {
    OCCloudKitMirroringDelegateOptions *_parsedOptions; // 0x8
}
- (BOOL)validateOptions:(OCCloudKitMirroringDelegateOptions *)delegateOptions andStoreOptions:(NSDictionary<NSString *, NSObject *> *)storeOptions error:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct));
@end

NS_ASSUME_NONNULL_END
