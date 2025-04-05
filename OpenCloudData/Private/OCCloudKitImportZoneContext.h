//
//  OCCloudKitImportZoneContext.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/6/25.
//

#import <CloudKit/CloudKit.h>
#import <CoreData/CoreData.h>
#import <OpenCloudData/OCCloudKitMirroringDelegateOptions.h>

#warning TODO

NS_ASSUME_NONNULL_BEGIN

@interface OCCloudKitImportZoneContext : NSObject {
    // TODO: ivars Nullable
    NSArray<CKRecord *> *_updatedRecords;
    NSDictionary *_deletedRecordTypeToRecordID;
    NSSet *_deletedObjectIDs;
    NSArray *_modifiedRecords;
    NSMutableArray *_updatedRelationships;
    NSArray *_deletedRelationships;
    NSArray *_deletedMirroredRelationshipRecordIDs;
    @package NSMutableDictionary *_recordTypeToRecordIDToObjectID;
    NSMutableDictionary *_recordTypeToUnresolvedRecordIDs;
    NSMutableArray *_metadatasToLink;
    NSArray *_importOperations;
    OCCloudKitMirroringDelegateOptions *_mirroringOptions;
    NSURL *_fileBackedFuturesDirectory;
    NSSet *_deletedShareRecordIDs;
}

@end

NS_ASSUME_NONNULL_END
