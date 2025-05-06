//
//  OCCloudKitHistoryAnalyzer.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/20/25.
//

#import <OpenCloudData/PFHistoryAnalyzer.h>
#import <OpenCloudData/OCCloudKitHistoryAnalyzerOptions.h>

NS_ASSUME_NONNULL_BEGIN

@interface OCCloudKitHistoryAnalyzer : NSObject /* PFHistoryAnalyzer */
{
//    NSManagedObjectContext *_managedObjectContext; // 0x10
//    NSPersistentHistoryToken *_lastProcessedToken; // 0x18
}
+ (BOOL)isPrivateContextName:(NSString *)name;
+ (BOOL)isPrivateTransaction:(NSPersistentHistoryTransaction *)transaction;
+ (BOOL)isPrivateTransactionAuthor:(NSString *)author;
- (instancetype)initWithOptions:(OCCloudKitHistoryAnalyzerOptions *)options managedObjectContext:(NSManagedObjectContext *)managedObjectContext;
@end

NS_ASSUME_NONNULL_END
