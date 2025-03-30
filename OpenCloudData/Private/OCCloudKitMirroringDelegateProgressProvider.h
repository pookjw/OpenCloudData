//
//  OCCloudKitMirroringDelegateProgressProvider.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 3/30/25.
//

#import <OpenCloudData/OCPersistentCloudKitContainerEvent.h>

NS_ASSUME_NONNULL_BEGIN

@protocol OCCloudKitMirroringDelegateProgressProvider <NSObject>
- (void)eventUpdated:(OCPersistentCloudKitContainerEvent *)event;
- (void)publishActivity:(id)arg1; // NSPersistentCloudKitContainerEventActivity
@end

NS_ASSUME_NONNULL_END
