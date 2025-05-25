//
//  CKOperationConfiguration+Private.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/26/25.
//

#import <CloudKit/CloudKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CKOperationConfiguration (Private)
@property (assign) BOOL allowsExpensiveNetworkAccess;
@end

NS_ASSUME_NONNULL_END
