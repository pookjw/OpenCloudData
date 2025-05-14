//
//  OCCloudKitMirroringDelegateSetupRequestOptions.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/14/25.
//

#import <OpenCloudData/OCCloudKitMirroringRequestOptions.h>

NS_ASSUME_NONNULL_BEGIN

@interface OCCloudKitMirroringDelegateSetupRequestOptions : OCCloudKitMirroringRequestOptions {
    BOOL _fromNotification; // 0x18
}
@end

NS_ASSUME_NONNULL_END
