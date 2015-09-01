
#import <Foundation/Foundation.h>
#import "MIFeed.h"

@interface MIFeedLoad : NSObject

@property (nonatomic, strong) NSMutableDictionary *feeds;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray *allFeeds;

- (MIFeed *)feedForURL:(NSURL *)feedURL;
+ (MIFeedLoad *)loadFeed;

@end
