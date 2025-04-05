//
//  OCCloudKitExportContext.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/5/25.
//

#import <OpenCloudData/OCCloudKitExportContext.h>

@implementation OCCloudKitExportContext

- (instancetype)initWithOptions:(OCCloudKitExporterOptions *)options {
    if (self = [super init]) {
        _options = [options retain];
        _totalBytes = 0;
        _totalRecords = 0;
        _totalRecordIDs = 0;
        _writtenAssetURLs = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)dealloc {
    [_options release];
    _options = nil;
    [_writtenAssetURLs release];
    _writtenAssetURLs = nil;
    [super dealloc];
}

- (BOOL)checkForObjectsNeedingExportInStore:(__kindof NSPersistentStore *)store andReturnCount:(NSUInteger *)count withManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable *)error {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"needsUpload = YES"];
    
#warning TODO OCCKRecordMetadata
    abort();
    // +[NSCKRecordMetadata countRecordMetadataInStore:matchingPredicate:withManagedObjectContext:error:]
}

@end
