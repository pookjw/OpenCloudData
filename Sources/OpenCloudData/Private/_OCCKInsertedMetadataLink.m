//
//  _OCCKInsertedMetadataLink.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 5/13/25.
//

#import "OpenCloudData/Private/_OCCKInsertedMetadataLink.h"
#import <CloudKit/CloudKit.h>

@implementation _OCCKInsertedMetadataLink

- (instancetype)initWithRecordMetadata:(OCCKRecordMetadata *)recordMetadata insertedObject:(NSManagedObject *)insertedObject {
    // inlined from -[PFCloudKitImportZoneContext registerObject:forInsertedRecord:withMetadata:]
    if (self = [super init]) {
        _recordMetadata = [recordMetadata retain];
        _insertedObject = [insertedObject retain];
    }
    
    return self;
}

- (void)dealloc {
    [_recordMetadata release];
    [_insertedObject release];
    [super dealloc];
}

- (NSString *)description {
    /*
     self = x19
     */
    // x20
    CKRecordID *recordID = [self->_recordMetadata createRecordID];
    NSString *result = [NSString stringWithFormat:@"<%@: %p> %@ -> %@", NSStringFromClass([self class]), self, self->_insertedObject.objectID, recordID];
    [recordID release];
    return result;
}

@end
