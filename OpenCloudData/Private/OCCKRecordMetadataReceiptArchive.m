//
//  OCCKRecordMetadataReceiptArchive.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/7/25.
//

#import <OpenCloudData/OCCKRecordMetadataReceiptArchive.h>
#import <CloudKit/CloudKit.h>

@implementation OCCKRecordMetadataReceiptArchive

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (instancetype)initWithReceiptsToEncode:(NSSet<OCCKRecordZoneMoveReceipt *> *)moveReceipts {
    /*
     moveReceipts = sp + 0x8
     */
    if (self = [super init]) {
        // self = x20
        _zoneIDToArchivedReceipts = [[NSMutableDictionary alloc] init];
        
        // x23
        for (OCCKRecordZoneMoveReceipt *moveReceipt in moveReceipts) {
            // x22
            CKRecordID *recordID = [moveReceipt createRecordIDForMovedRecord];
            
            // x24
            NSMutableDictionary<NSString * ,NSDictionary<NSString *, id> *> *archivedReceipts = [[_zoneIDToArchivedReceipts objectForKey:recordID.zoneID] retain];
            if (archivedReceipts == nil) {
                archivedReceipts = [[NSMutableDictionary alloc] init];
                [_zoneIDToArchivedReceipts setObject:archivedReceipts forKey:recordID.zoneID];
            }
            
            [archivedReceipts setObject:@{@"movedAt": moveReceipt.movedAt} forKey:recordID.recordName];
            [archivedReceipts release];
            [recordID release];
        }
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    /*
     coder = x20
     */
    
    if (self= [super init]) {
        // self = x19
        // original : getCloudKitCKRecordZoneIDClass
        NSSet<Class> *classes = [NSSet setWithArray:@[[NSDictionary class], [CKRecordZoneID class], [NSString class], [NSDate class]]];
        _zoneIDToArchivedReceipts = [[coder decodeObjectOfClasses:classes forKey:@"archiveDictionary"] retain];
    }
    
    return self;
}

- (void)dealloc {
    [_zoneIDToArchivedReceipts release];
    [super dealloc];
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:_zoneIDToArchivedReceipts forKey:@"archiveDictionary"];
}

- (void)enumerateArchivedRecordIDsUsingBlock:(void (^ NS_NOESCAPE)(CKRecordID * _Nonnull, NSDate * _Nonnull))block {
    /*
     block = x19
     */
    // x24
    for (CKRecordZoneID *zoneID in _zoneIDToArchivedReceipts) {
        // x25
        NSMutableDictionary<NSString * ,NSDictionary<NSString *, id> *> *archivedReceipts = [_zoneIDToArchivedReceipts objectForKey:zoneID];
        // x27
        for (NSString *recordName in archivedReceipts) {
            // original : getCloudKitCKRecordIDClass
            // x28
            CKRecordID *recordID = [[CKRecordID alloc] initWithRecordName:recordName zoneID:zoneID];
            NSDate *movedAt = [[archivedReceipts objectForKey:recordName] objectForKey:@"movedAt"];
            block(recordID, movedAt);
            [recordID release];
        }
    }
}

@end
