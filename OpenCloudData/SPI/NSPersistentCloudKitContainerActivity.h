//
//  NSPersistentCloudKitContainerActivity.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/8/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSPersistentCloudKitContainerActivity : NSObject
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (NSMutableDictionary *)createDictionaryRepresentation;
- (instancetype)_initWithIdentifier:(NSUUID *)identifier forStore:(NSString * _Nullable)storeIdentifier activityType:(NSUInteger)activityType;
- (void)finishWithError:(NSError * _Nullable)error;
@end

NS_ASSUME_NONNULL_END
