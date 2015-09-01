
#import <Foundation/Foundation.h>
#import "MIFeedParser.h"
#import "MIRemoteFile.h"

extern NSString* const MIFeedChangedNotification;

@interface MIFeed : NSObject {
    dispatch_queue_t _queue;
}

@property (nonatomic, strong) NSURL *feedURL;
@property (nonatomic, strong) NSString *title;
@property (atomic, strong) NSSet *items;
@property (nonatomic, assign) BOOL isDatabaseBacked;
@property (nonatomic, strong) NSDate *lastUpdatedDate;
@property (nonatomic, strong) MIRemoteFile *cache;

- (instancetype)initWithFeedURL:(NSURL *)feedURL NS_DESIGNATED_INITIALIZER;
- (void)fetch;


@end
