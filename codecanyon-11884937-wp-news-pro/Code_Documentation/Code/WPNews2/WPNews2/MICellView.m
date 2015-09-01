
#import "MICellView.h"
#import <QuartzCore/QuartzCore.h>
#import "MIConfig.h"
#import "UIImageView+WebCache.h"
#import <Foundation/Foundation.h>

@implementation MICellView

- (void)setFeedItem:(MIFeedItem *)feedItem
{
    _feedItem = feedItem;
    
    _titleLabel.text = feedItem.title;
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    dateFormatter.timeStyle = NSDateFormatterShortStyle;
    
    NSString *dateString = [dateFormatter stringFromDate:feedItem.pubDate];
    
    self.accessibilityLabel = [NSString stringWithFormat:@"%@, %@", feedItem.title, dateString];
    
    
    _dateLabel.text = dateString;
    
    
    self.imageView.image = PLACEHOLDER_IMAGE;
    
    MIMediaElement *thumb = [self.feedItem bestThumbnailForWidth:(self.bounds.size.width + 50)];
    if (thumb) {
        self.imageView.hidden = NO;
        self.textLabel.hidden = YES;
        
        __block UIActivityIndicatorView *activityIndicator;
        __weak UIImageView *weakImageView = self.imageView;
        [self.imageView sd_setImageWithURL:thumb.URL
                              placeholderImage:nil
                                       options:SDWebImageProgressiveDownload
                                      progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                          if (!activityIndicator) {
                                              [weakImageView addSubview:activityIndicator = [UIActivityIndicatorView.alloc initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray]];
                                              activityIndicator.center = weakImageView.center;
                                              [activityIndicator startAnimating];
                                          }
                                      }
                                     completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                         [activityIndicator removeFromSuperview];
                                         activityIndicator = nil;
                                     }];
        
    } else {
        self.textLabel.hidden = NO;
        self.imageView.hidden = YES;
        
        NSArray *lines = [feedItem.descriptionText componentsSeparatedByString:@"\n"];
        NSMutableArray *trimmedLines = [NSMutableArray arrayWithCapacity:lines.count];
        NSCharacterSet *trimChars = [NSCharacterSet whitespaceCharacterSet];
        for (NSString *line in lines) {
            [trimmedLines addObject:[line stringByTrimmingCharactersInSet:trimChars]];
        }
        _textLabel.text = [trimmedLines componentsJoinedByString:@"\n"];
    }
    
    [self setNeedsLayout];
}

#define PANEL_PADDING 10
#define LABEL_MARGIN 4

- (UILabel *)createLabel
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectInset(self.bounds, PANEL_PADDING, PANEL_PADDING)];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    label.numberOfLines = 0;
    [self addSubview:label];
    return label;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.isAccessibilityElement = YES;
        
        self.backgroundColor = [UIColor whiteColor];
        CALayer *layer = self.layer;
        layer.borderColor = [[UIColor colorWithWhite:0.9 alpha:1.0] CGColor];
        layer.borderWidth = 1.0;
        
        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.imageView.clipsToBounds = YES;
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:self.imageView];
        
        self.titleLabel = [self createLabel];
        self.titleLabel.backgroundColor = self.backgroundColor;
        self.titleLabel.font = [UIFont fontWithName:IPAD_COLLECTION_VIEW_TITLE_FONT_NAME size:16];
        self.titleLabel.textColor = IPAD_COLLECTION_VIEW_TITLE_FONT_COLOR;
        
        self.dateLabel = [self createLabel];
        self.dateLabel.font = [UIFont fontWithName:IPAD_COLLECTION_VIEW_DATE_FONT_NAME size:12];
        self.dateLabel.textColor = IPAD_COLLECTION_VIEW_DATE_FONT_COLOR;
        
        self.textLabel = [self createLabel];
        self.textLabel.font = [UIFont fontWithName:IPAD_COLLECTION_VIEW_DESCRIPTION_FONT_NAME size:14];
        self.textLabel.textColor = IPAD_COLLECTION_VIEW_DESCRIPTION_FONT_COLOR;
    }
    return self;
}

- (void)positionView:(UIView *)southView underView:(UIView *)northView
{
    [northView sizeToFit];
    CGRect southFrame = southView.frame;
    southFrame.origin.y = CGRectGetMaxY(northView.frame) + LABEL_MARGIN;
    southView.frame = southFrame;
}

- (void)layoutSubviews
{
    CALayer *layer = self.layer;
    layer.shadowOffset = CGSizeMake(0, 3.0);
    layer.shadowOpacity = 0.05;
    layer.shadowRadius = 3.0;
    CGPathRef shadowPath = CGPathCreateWithRect(self.bounds, nil);
    layer.shadowPath = shadowPath;
    CGPathRelease(shadowPath);
    
    CGRect resetFrame = CGRectInset(self.bounds, PANEL_PADDING, PANEL_PADDING);
    self.titleLabel.frame = self.dateLabel.frame = self.textLabel.frame = resetFrame;
    [self.titleLabel sizeToFit];
    [self.dateLabel sizeToFit];
    
    if (self.imageView.hidden) {
        [self positionView:self.dateLabel underView:self.titleLabel];
        [self positionView:self.textLabel underView:self.dateLabel];
        [self.textLabel sizeToFit];
        CGRect textFrame = CGRectIntersection(self.textLabel.frame, resetFrame);
        self.textLabel.frame = textFrame;
    } else {
        CGFloat barHeight = self.dateLabel.bounds.size.height + self.titleLabel.bounds.size.height + (PANEL_PADDING * 2) + LABEL_MARGIN;
        CGFloat h = self.bounds.size.height;
        CGFloat w = self.bounds.size.width;
        
        self.titleLabel.frame = CGRectOffset(self.titleLabel.frame, 0, h - barHeight);
        [self positionView:self.dateLabel underView:self.titleLabel];
        
        CGRect imageFrame = CGRectMake(0, 0, w, h - barHeight);
        self.imageView.frame = CGRectInset(imageFrame, 1, 1);
    }
    
    [super layoutSubviews];
}

@end
