//
//  OCCloudKitMirroringRequestManager.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/22/25.
//

#import <OpenCloudData/OCCloudKitMirroringRequest.h>

NS_ASSUME_NONNULL_BEGIN

#warning TODO

@interface OCCloudKitMirroringRequestManager : NSObject
- (BOOL)enqueueRequest:(__kindof OCCloudKitMirroringRequest *)request error:(NSError * _Nullable * _Nullable)error __attribute__((objc_direct));
@end

NS_ASSUME_NONNULL_END
