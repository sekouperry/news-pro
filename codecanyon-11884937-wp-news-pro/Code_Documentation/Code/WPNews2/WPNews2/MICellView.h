
#import <UIKit/UIKit.h>
#import "MIFeedItem.h"

@interface MICellView : UIView

@property (nonatomic, strong) MIFeedItem *feedItem;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UIImageView *imageView;

@end
