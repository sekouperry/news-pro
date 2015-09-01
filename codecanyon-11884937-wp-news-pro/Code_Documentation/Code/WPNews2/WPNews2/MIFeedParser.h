
#import <Foundation/Foundation.h>
#import "MIFeedItem.h"

typedef void (^ MIFeedParserCallback)(MIFeedItem *item);

@interface MIFeedParser : NSObject <NSXMLParserDelegate>

@property (nonatomic, copy) MIFeedParserCallback callbackBlock;
@property (nonatomic, strong) NSData *feedData;
@property (nonatomic, strong) MIFeedItem *currentItem;
@property (nonatomic, strong) NSMutableArray *tagStack;

- (instancetype)initWithFeedData:(NSData *)feedData NS_DESIGNATED_INITIALIZER;
- (void)parse:(MIFeedParserCallback)callback;

@end
