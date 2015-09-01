
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MIMediaElement : NSObject <NSCoding>

@property (nonatomic, assign) CGSize size;
@property (nonatomic, strong) NSURL *URL;
@property (nonatomic, strong) NSString *medium;
@property (nonatomic, strong) NSString *type;
@end

@interface MIFeedItem : NSObject <NSCoding>

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *guid;
@property (nonatomic, strong) NSURL *link;
@property (nonatomic, strong) NSString *descriptionText;
@property (nonatomic, strong) NSString *descriptionHTML;
@property (nonatomic, strong) NSArray *categories;
@property (nonatomic, strong) NSDate *pubDate;
@property (nonatomic, strong) NSString *creator;
@property (nonatomic, strong) NSURL *enclosureURL;
@property (nonatomic, strong) NSMutableSet *mediaThumbnails;
@property (nonatomic, strong) NSMutableSet *mediaContents;

@property (nonatomic, strong) NSURL *feedURL;

- (MIMediaElement *)bestThumbnailForWidth:(CGFloat)width;
- (MIMediaElement *)bestContentForWidth:(CGFloat)width;

- (void)addMediaThumbnail:(MIMediaElement *)media;
- (void)addMediaContent:(MIMediaElement *)media;

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *trackingPathCompontent;

- (BOOL)isEqualToFeedItem:(MIFeedItem *)other;

@end
