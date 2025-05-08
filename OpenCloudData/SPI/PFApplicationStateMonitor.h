//
//  PFApplicationStateMonitor.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/4/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PFApplicationStateMonitor : NSObject
- (void)applicationDidActivate:(NSNotification *)notification;
- (void)applicationWillDeactivate:(NSNotification *)notification;
@end

NS_ASSUME_NONNULL_END
