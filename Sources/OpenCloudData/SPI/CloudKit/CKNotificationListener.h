//
//  CKNotificationListener.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/22/25.
//

#import <CloudKit/CloudKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CKNotificationListener : NSObject
- (instancetype)initWithMachServiceName:(NSString *)machServiceName;
@end

NS_ASSUME_NONNULL_END
