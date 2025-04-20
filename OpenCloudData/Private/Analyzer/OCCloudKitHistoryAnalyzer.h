//
//  OCCloudKitHistoryAnalyzer.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/20/25.
//

#import <OpenCloudData/PFHistoryAnalyzer.h>
#import <OpenCloudData/OCCloudKitHistoryAnalyzerOptions.h>

NS_ASSUME_NONNULL_BEGIN

#warning TODO

@interface OCCloudKitHistoryAnalyzer : NSObject /* PFHistoryAnalyzer */
- (instancetype)initWithOptions:(OCCloudKitHistoryAnalyzerOptions *)options managedObjectContext:(NSManagedObjectContext *)managedObjectContext;
@end

NS_ASSUME_NONNULL_END
