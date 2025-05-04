//
//  OCCloudKitMetadataMigrationContext.m
//  OpenCloudData
//
//  Created by Jinwoo Kim on 4/29/25.
//

#import <OpenCloudData/OCCloudKitMetadataMigrationContext.h>

@implementation OCCloudKitMetadataMigrationContext
@synthesize currentModel = _currentModel;
@synthesize sqlModel = _sqlModel;
@synthesize storeMetadataModel = _storeMetadataModel;
@synthesize storeSQLModel = _storeSQLModel;
@synthesize storeMetadataVersion = _storeMetadataVersion;
@synthesize storeMetadataVersionHashes = _storeMetadataVersionHashes;

- (instancetype)init {
    if (self = [super init]) {
        _migrationStatements = [[NSMutableArray alloc] init];
        _sqlEntitiesToCreate = [[NSMutableArray alloc] init];
        _hasWorkToDo = NO;
        _constrainedEntitiesToPreflight = [[NSMutableSet alloc] init];
    }
    return self;
}

- (void)dealloc {
    [_migrationStatements release];
    _migrationStatements = nil;
    
    [_sqlEntitiesToCreate release];
    _sqlEntitiesToCreate = nil;
    
    [_currentModel release];
    _currentModel = nil;
    
    [_sqlModel release];
    _sqlModel = nil;
    
    [_storeMetadataModel release];
    _storeMetadataModel = nil;
    
    [_storeSQLModel release];
    _storeSQLModel = nil;
    
    [_storeMetadataVersionHashes release];
    _storeMetadataVersionHashes = nil;
    
    [_storeMetadataVersion release];
    _storeMetadataVersion = nil;
    
    // 원래 코드가 이렇다. _storeMetadataVersionHashes에 release를 두 번 호출한다. 위에서 nil을 주입해 주기에 문제는 안 되겠지만...
    [_storeMetadataVersionHashes release];
    _storeMetadataVersionHashes = nil;
    
    [_constrainedEntitiesToPreflight release];
    _constrainedEntitiesToPreflight = nil;
    
    [super dealloc];
}

- (void)addConstrainedEntityToPreflight:(NSSQLEntity *)entity {
    [_constrainedEntitiesToPreflight addObject:entity];
}

@end
