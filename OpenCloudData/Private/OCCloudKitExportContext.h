//
//  OCCloudKitExportContext.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/5/25.
//

#import <CoreData/CoreData.h>
#import <OpenCloudData/OCCloudKitExporterOptions.h>

NS_ASSUME_NONNULL_BEGIN

@interface OCCloudKitExportContext : NSObject {
    OCCloudKitExporterOptions *_options;
    NSUInteger _totalBytes;
    NSUInteger _totalRecords;
    NSUInteger _totalRecordIDs;
    NSMutableArray *_writtenAssetURLs;
}
- (instancetype)initWithOptions:(OCCloudKitExporterOptions *)options;
- (BOOL)checkForObjectsNeedingExportInStore:(__kindof NSPersistentStore *)store andReturnCount:(NSUInteger *)count withManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable * _Nullable)error;
@end

NS_ASSUME_NONNULL_END
