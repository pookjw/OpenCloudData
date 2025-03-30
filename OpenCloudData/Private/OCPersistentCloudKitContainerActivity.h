//
//  OCPersistentCloudKitContainerActivity.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 3/31/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OCPersistentCloudKitContainerActivity : NSObject
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (NSDictionary *)createDictionaryRepresentation;
- (instancetype)_initWithIdentifier:(NSUUID *)identifier forStore:(NSString *)storeIdentifier activityType:(NSUInteger)activityType;
- (void)finishWithError:(NSError * _Nullable)error;
@end

NS_ASSUME_NONNULL_END
