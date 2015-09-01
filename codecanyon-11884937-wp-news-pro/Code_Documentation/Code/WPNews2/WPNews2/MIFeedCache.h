
#import <Foundation/Foundation.h>

#import "MIFeed.h"
#import "MIFeedItem.h"
#import "sqlite3.h"

@interface MIFeedCache : NSObject {
   
    sqlite3 *_db;
    dispatch_queue_t _queue;
}

+ (MIFeedCache *)sharedCache;


- (void)saveFeedItem:(MIFeedItem *)item;

@end
