//
//  OCPersistentCloudKitContainerSetupPhaseActivity.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 3/31/25.
//

#import <OpenCloudData/OCPersistentCloudKitContainerActivity.h>

NS_ASSUME_NONNULL_BEGIN

@interface OCPersistentCloudKitContainerSetupPhaseActivity : OCPersistentCloudKitContainerActivity
+ (NSString *)stringForPhase:(NSUInteger)phase __attribute__((objc_direct));
- (instancetype)initWithPhase:(NSUInteger)phase storeIdentifier:(NSString * _Nullable)storeIdentifier;
@end

NS_ASSUME_NONNULL_END
