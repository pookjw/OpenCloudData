//
//  OCCloudKitContainerProvider.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/22/25.
//

#import <CloudKit/CloudKit.h>
#import "OpenCloudData/SPI/CloudKit/CKContainerOptions.h"

NS_ASSUME_NONNULL_BEGIN

@interface OCCloudKitContainerProvider : NSObject
- (CKContainer * _Nullable)containerWithIdentifier:(NSString *)identifier;
- (CKContainer * _Nullable)containerWithIdentifier:(NSString *)identifier options:(CKContainerOptions * _Nullable)options;
@end

NS_ASSUME_NONNULL_END
