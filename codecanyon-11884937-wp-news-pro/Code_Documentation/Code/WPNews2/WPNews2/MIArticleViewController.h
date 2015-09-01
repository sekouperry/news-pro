
#import <UIKit/UIKit.h>
#import "MIFeedItem.h"
#import "AFDropdownNotification.h"

@interface MIArticleViewController : UIViewController <UIWebViewDelegate,AFDropdownNotificationDelegate>

@property (nonatomic, strong) MIFeedItem *feedItem;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, assign) BOOL needsTemplateRendering;
@property (nonatomic, strong) AFDropdownNotification *notification;
@property (nonatomic, strong) NSString *clickedURL;
@property (nonatomic, strong) UIBarButtonItem *shareButton;

@end
