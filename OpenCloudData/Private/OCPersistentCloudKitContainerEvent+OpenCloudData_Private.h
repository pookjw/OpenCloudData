//
//  OCPersistentCloudKitContainerEvent+OpenCloudData_Private.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/1/25.
//

#import "OpenCloudData/Public/OCPersistentCloudKitContainerEvent.h"
#import "OpenCloudData/Private/Model/OCCKEvent.h"

NS_ASSUME_NONNULL_BEGIN

@interface OCPersistentCloudKitContainerEvent (OpenCloudData_Private)
- (instancetype)initWithCKEvent:(OCCKEvent *)event;
@end

NS_ASSUME_NONNULL_END
