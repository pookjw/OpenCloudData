//
//  _PFRoutines.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/10/25.
//

#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface _PFRoutines : NSObject
+ (void)wrapBlockInGuardedAutoreleasePool:(void (^ NS_NOESCAPE)(void))block;
@end

NS_ASSUME_NONNULL_END
