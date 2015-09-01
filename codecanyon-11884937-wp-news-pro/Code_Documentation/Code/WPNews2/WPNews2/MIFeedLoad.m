
#import "MIFeedLoad.h"

static MIFeedLoad *loadFeed = nil;

@implementation MIFeedLoad

+ (MIFeedLoad *)loadFeed
{
    if (loadFeed == nil)
    {
        loadFeed = [MIFeedLoad new];
    }
    
    return loadFeed;
}

- (instancetype)init
{
    if ((self = [super init])) {
        self.feeds = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (MIFeed *)feedForURL:(NSURL *)feedURL
{
    MIFeed *controller = (self.feeds)[feedURL];
    if (controller == nil) {
        controller = [[MIFeed alloc] initWithFeedURL:feedURL];
        (self.feeds)[feedURL] = controller;
    }
    
    return controller;
}

- (NSArray *)allFeeds
{
    return [self.feeds allValues];
}

@end
