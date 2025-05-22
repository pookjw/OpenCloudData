//
//  PFHistoryAnalyzer.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/20/25.
//

#import "OpenCloudData/SPI/CoreData/PFHistoryAnalyzerOptions.h"
#import "OpenCloudData/SPI/CoreData/PFHistoryAnalyzerContext.h"

NS_ASSUME_NONNULL_BEGIN

@interface PFHistoryAnalyzer : NSObject {
@private PFHistoryAnalyzerOptions *_options; // 0x8
}
- (PFHistoryAnalyzerContext *)instantiateNewAnalyzerContextForChangesInStore:(NSPersistentStore *)store NS_RETURNS_RETAINED;
- (BOOL)processTransaction:(NSPersistentHistoryTransaction *)transaction withContext:(NSManagedObjectContext *)context error:(NSError * _Nullable * _Nullable)error;
@end

NS_ASSUME_NONNULL_END
