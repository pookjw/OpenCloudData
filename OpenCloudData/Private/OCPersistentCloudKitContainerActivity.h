//
//  OCPersistentCloudKitContainerActivity.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 3/31/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OCPersistentCloudKitContainerActivity : NSObject {
@package NSUUID *_identifier;
@package NSString *_storeIdentifier;
@package NSError *_error;
@package NSUUID *_parentActivityIdentifier;
@package NSUInteger _activityType;
@package NSDate *_startDate;
@package NSDate *_endDate;
}
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (NSMutableDictionary *)createDictionaryRepresentation;
- (instancetype)_initWithIdentifier:(NSUUID *)identifier forStore:(NSString * _Nullable)storeIdentifier activityType:(NSUInteger)activityType;
- (void)finishWithError:(NSError * _Nullable)error;
@end

NS_ASSUME_NONNULL_END
