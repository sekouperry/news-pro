
#import "MIFeedCache.h"
#import "MIFeed.h"

#define FEED_ITEM_TABLE "feed_items"
#define SELECT_LIMIT "80"

static MIFeedCache *sharedCache;

@implementation MIFeedCache

+ (MIFeedCache *)sharedCache
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedCache = [self new];
    });

    return sharedCache;
}

- (instancetype)init
{
    if ((self = [super init])) {
        [self open];
        
        _queue = dispatch_queue_create("com.newsapp2.database2", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void) dealloc
{
    sqlite3_close(_db);
}

- (void)doSQL:(NSString *)sql
{
    char *errorMsg;
    sqlite3_exec(_db, [sql UTF8String], NULL, NULL, &errorMsg);
    if (errorMsg != NULL) {
        NSLog(@"Error executing SQL: %s", errorMsg);
    }
    sqlite3_free(errorMsg);
}

- (NSURL *)databaseFileURL
{
    NSFileManager *fileManager = [NSFileManager new];
    NSArray *paths = [fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask];
    NSURL *directoryURL = paths[0];
    if (![fileManager fileExistsAtPath:directoryURL.path]) {
        [fileManager createDirectoryAtURL:directoryURL withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return [directoryURL URLByAppendingPathComponent:@"news_cache2.sqlite"];
}

- (void)open
{
    NSURL *fileURL =[self databaseFileURL];
    NSError *backupExclusionError = nil;
    if (![fileURL setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:&backupExclusionError]) {
        NSLog(@"Could not exclude DB from backup: %@", backupExclusionError.userInfo);
    }
    
    const char *db_path = [fileURL.path UTF8String];
    
    if (sqlite3_open(db_path, &_db) != SQLITE_OK)
    {
        [NSException raise:@"Could not open SQLite database" format:@"Reason: %s", sqlite3_errmsg(_db)];
    }
    
    [self doSQL:@"CREATE TABLE IF NOT EXISTS " FEED_ITEM_TABLE " (feed_url TEXT, guid TEXT UNIQUE, pubDate INTEGER, data BLOB);"];
    [self doSQL:@"CREATE INDEX IF NOT EXISTS index_feed_url ON " FEED_ITEM_TABLE " (feed_url);"];
    [self doSQL:@"CREATE INDEX IF NOT EXISTS index_date ON " FEED_ITEM_TABLE " (pubDate DESC);"];
    
}

- (void)internalSaveItem:(MIFeedItem *)item
{
   
    sqlite3_exec(_db, "BEGIN", NULL, NULL, NULL);
    
    sqlite3_stmt *stmt;
    char *sql = "INSERT OR REPLACE INTO " FEED_ITEM_TABLE " (feed_url, guid, pubDate, data) VALUES (?, ?, ?, ?);";
    sqlite3_prepare_v2(_db, sql, -1, &stmt, NULL);
    
    // bind the URL
    sqlite3_bind_text(stmt, 1, item.feedURL.absoluteString.UTF8String, -1, SQLITE_TRANSIENT);
    // bind the GUID
    sqlite3_bind_text(stmt, 2, item.guid.UTF8String, -1, SQLITE_TRANSIENT);
    
    // bind the date in seconds since 1970
    sqlite3_bind_int64(stmt, 3, [item.pubDate timeIntervalSince1970]);
    
    // bind the data representing the whole feed item object
    NSData *itemData = [NSKeyedArchiver archivedDataWithRootObject:item];
    sqlite3_bind_blob(stmt, 4, itemData.bytes, (int)itemData.length, SQLITE_TRANSIENT);
    
    // step and check results
    if (sqlite3_step(stmt) != SQLITE_DONE) {
        NSLog(@"Error saving feed item: %s", sqlite3_errmsg(_db));
    }
    sqlite3_finalize(stmt);
    

    
    // finally, commit the transaction
    sqlite3_exec(_db, "COMMIT", NULL, NULL, NULL);
}

- (void)saveFeedItem:(MIFeedItem *)item
{
    dispatch_async(_queue, ^{
        [self internalSaveItem:item];
    });
}


+ (NSSet *)feedItemsFromStatement:(sqlite3_stmt *)stmt
{
    NSMutableSet *result = [NSMutableSet setWithCapacity:50];
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        
        const void* bytes = sqlite3_column_blob(stmt, 0);
        int numBytes = sqlite3_column_bytes(stmt, 0);
        
        
        NSData *itemData = [NSData dataWithBytes:bytes length:numBytes];
        MIFeedItem *item = [NSKeyedUnarchiver unarchiveObjectWithData:itemData];
        
        [result addObject:item];
    }
    
    return result;
}

@end
