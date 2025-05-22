//
//  OCPersistentCloudKitContainerEventActivity.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 3/31/25.
//

#import "OpenCloudData/Private/OCPersistentCloudKitContainerActivity.h"
#import "OpenCloudData/Private/OCPersistentCloudKitContainerSetupPhaseActivity.h"

NS_ASSUME_NONNULL_BEGIN

@interface OCPersistentCloudKitContainerEventActivity : OCPersistentCloudKitContainerActivity
- (instancetype)initWithRequestIdentifier:(NSUUID *)requestIdentifier storeIdentifier:(NSString *)storeIdentifier eventType:(NSInteger)eventType __attribute__((objc_direct));
- (__kindof OCPersistentCloudKitContainerActivity *)beginActivityForPhase:(NSUInteger)phase NS_RETURNS_RETAINED;
- (__kindof OCPersistentCloudKitContainerActivity *)endActivityForPhase:(NSUInteger)phase withError:(NSError * _Nullable)error NS_RETURNS_RETAINED;
@end

NS_ASSUME_NONNULL_END
