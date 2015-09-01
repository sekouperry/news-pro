
#import "MIFeed.h"
#import "MIFeedCache.h"

NSString* const MIFeedChangedNotification = @"MIFeedChangedNotification";

@implementation MIFeed

- (instancetype)initWithFeedURL:(NSURL *)feedURL
{
    if ((self = [super init])) {
        self.feedURL = feedURL;
        self.cache = [[MIRemoteFile alloc] initWithBundleResource:nil ofType:nil remoteURL:self.feedURL];
        _queue = dispatch_queue_create("com.newsapp2_loading", NULL);
    }
    
    return self;
}

- (void)notify
{
    dispatch_sync(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:MIFeedChangedNotification object:self userInfo:nil];
    });
}

- (NSSet *)parseFeedData:(NSData *)data
{
    NSMutableSet *items = [NSMutableSet set];
    MIFeedParser *parser = [[MIFeedParser alloc] initWithFeedData:data];
    [parser parse: ^(MIFeedItem *item) {
        item.feedURL = self.feedURL;
        [items addObject:item];
    }];
    return items;
}

- (void)internalFetch
{
    if (self.items == nil && self.isDatabaseBacked) {
       
        self.items = [self parseFeedData:[self.cache data]];
        if (self.items.count) {
           
            [self notify];
        }
    }
    
   
    [self.cache updateWithValidator:^BOOL(NSData *remoteData) {
        
        self.items = [self parseFeedData:remoteData];
        self.lastUpdatedDate = [NSDate date];
        [self notify];
        return self.isDatabaseBacked;
    }];
}

- (void)fetch
{
    dispatch_async(_queue, ^{
        [self internalFetch];
    });
}

@end
