//
//  OCCloudKitMirroringDelegateResetRequest.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/26/25.
//

#import <OpenCloudData/OCCloudKitMirroringRequest.h>

NS_ASSUME_NONNULL_BEGIN

@interface OCCloudKitMirroringDelegateResetRequest : OCCloudKitMirroringRequest {
    NSError * _Nullable _causedByError;
}
- (instancetype)initWithError:(NSError * _Nullable)error completionBlock:(void (^ _Nullable)(OCCloudKitMirroringResult * result))requestCompletionBlock;
@end

NS_ASSUME_NONNULL_END
