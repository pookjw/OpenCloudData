//
//  OCCloudKitMirroringDelegateProgressProvider.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 3/30/25.
//

#import "OpenCloudData/Public/OCPersistentCloudKitContainerEvent.h"
#import "OpenCloudData/Private/OCPersistentCloudKitContainerActivity.h"

NS_ASSUME_NONNULL_BEGIN

@protocol OCCloudKitMirroringDelegateProgressProvider <NSObject>
- (void)eventUpdated:(OCPersistentCloudKitContainerEvent *)event;
- (void)publishActivity:(__kindof OCPersistentCloudKitContainerActivity *)activity;
@end

NS_ASSUME_NONNULL_END
