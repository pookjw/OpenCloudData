//
//  PFMirroredRelationship.h
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/6/25.
//

#import <CoreData/CoreData.h>
#import <OpenCloudData/PFCloudKitImportZoneContext.h>

NS_ASSUME_NONNULL_BEGIN

@interface PFMirroredRelationship : NSObject
+ (BOOL)isValidMirroredRelationshipRecord:(CKRecord *)record values:(id<CKRecordKeyValueSetting>)values;
- (BOOL)updateRelationshipValueUsingImportContext:(PFCloudKitImportZoneContext *)importContext andManagedObjectContext:(NSManagedObjectContext *)managedObjectContext error:(NSError * _Nullable * _Nullable)error;
@end

NS_ASSUME_NONNULL_END
