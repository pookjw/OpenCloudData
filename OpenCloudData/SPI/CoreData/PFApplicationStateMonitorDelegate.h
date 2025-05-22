//
//  PFApplicationStateMonitorDelegate.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/4/25.
//

#import "OpenCloudData/SPI/CoreData/PFApplicationStateMonitor.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PFApplicationStateMonitorDelegate <NSObject>
- (void)applicationStateMonitorEnteredBackground:(PFApplicationStateMonitor *)applicationStateMonitor;
- (void)applicationStateMonitorEnteredForeground:(PFApplicationStateMonitor *)applicationStateMonitor;
- (void)applicationStateMonitorExpiredBackgroundActivityTimeout:(PFApplicationStateMonitor *)applicationStateMonitor;
@end

NS_ASSUME_NONNULL_END
