//
//  NSManagedObjectContext+Private.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/1/25.
//

#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSManagedObjectContext (Private)
- (BOOL)_allowAncillaryEntities;
- (void)_setAllowAncillaryEntities:(BOOL)allowAncillaryEntities;
@end

NS_ASSUME_NONNULL_END
