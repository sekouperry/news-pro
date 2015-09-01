
#import "MIFeedItem.h"
#import "MIXMLUtils.h"

@implementation MIMediaElement

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    
}


- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super init])) {
        
    }
    return self;
}


@end

@implementation MIFeedItem

- (instancetype)init
{
    if ((self = [super init])) {
        self.mediaContents = [NSMutableSet set];
        self.mediaThumbnails = [NSMutableSet set];
    }
    
    return self;
}


- (NSString *)description
{
    return [NSString stringWithFormat:@"<FeedItem guid: %@; title: %@; pubDate: %@>", self.guid, self.title, self.pubDate];
}


#define ENCODE_PROPERTY(name) [aCoder encodeObject:self.name forKey:@#name]

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    ENCODE_PROPERTY(title);
    ENCODE_PROPERTY(guid);
    ENCODE_PROPERTY(link);
    ENCODE_PROPERTY(descriptionText);
    ENCODE_PROPERTY(descriptionHTML);
    ENCODE_PROPERTY(categories);
    ENCODE_PROPERTY(pubDate);
    ENCODE_PROPERTY(creator);
    ENCODE_PROPERTY(mediaThumbnails);
    ENCODE_PROPERTY(mediaContents);
    ENCODE_PROPERTY(enclosureURL);
    ENCODE_PROPERTY(feedURL);
    }

#define DECODE_PROPERTY(name) self.name = [aDecoder decodeObjectForKey:@#name]

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super init])) {
        DECODE_PROPERTY(title);
        DECODE_PROPERTY(guid);
        DECODE_PROPERTY(link);
        DECODE_PROPERTY(descriptionText);
        
        NSString *oldItemDescription = [aDecoder decodeObjectForKey:@"itemDescription"];
        if (oldItemDescription) {
            self.descriptionHTML = oldItemDescription;
            self.descriptionText = [MIXMLUtils textFromHTMLString:oldItemDescription xpath:@"//p"];
        } else {
            DECODE_PROPERTY(descriptionHTML);
            DECODE_PROPERTY(descriptionText);
        }
        
        DECODE_PROPERTY(categories);
        DECODE_PROPERTY(pubDate);
        DECODE_PROPERTY(creator);
        DECODE_PROPERTY(mediaThumbnails);
        DECODE_PROPERTY(mediaContents);
        DECODE_PROPERTY(enclosureURL);
        DECODE_PROPERTY(feedURL);
    }
    return self;
}

- (void)addMediaThumbnail:(MIMediaElement *)media
{
    if (!self.mediaThumbnails) {
        self.mediaThumbnails = [NSMutableSet set];
    }
    
    [self.mediaThumbnails addObject:media];
}

- (void)addMediaContent:(MIMediaElement *)media
{
    if (!self.mediaContents) {
        self.mediaContents = [NSMutableSet set];
    }
    
    [self.mediaContents addObject:media];
}

- bestMediaElement:(id <NSFastEnumeration>)collection forWidth:(CGFloat)width
{
    CGFloat pixelWidth = width * [UIScreen mainScreen].scale;
    
    MIMediaElement *closest = nil;
    for (MIMediaElement *media in collection) {
        CGFloat mediaDiff = ABS(pixelWidth - media.size.width);
        CGFloat closestDiff = ABS(pixelWidth - closest.size.width);
        if (closest == nil) {
            closest = media;
        } else if (mediaDiff < closestDiff) {
            closest = media;
        } else if (mediaDiff == closestDiff && closest.size.width < media.size.width) {
            closest = media;
        }
    }
    
   
    
    return closest;   
}

- (MIMediaElement *)bestThumbnailForWidth:(CGFloat)width
{
    return [self bestMediaElement:self.mediaThumbnails forWidth:width];
}

- (MIMediaElement *)bestContentForWidth:(CGFloat)width
{
    return [self bestMediaElement:self.mediaContents forWidth:width];
}

- (NSString *)trackingPathCompontent
{
    if (self.title) {
        return self.title;
    } else if (self.guid) {
        return self.guid;
    } else {
        return @"(unknown)";
    }
}

#pragma mark Equality testing

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[self class]]) {
        return [self isEqualToFeedItem:object];
    }
    
    return NO;
}

- (NSUInteger)hash
{
    return [self.guid hash];
}

- (BOOL)isEqualToFeedItem:(MIFeedItem *)other
{
    if (self == other) {
        return YES;
    }
    
    return [self.guid isEqualToString:other.guid];
}

@end
