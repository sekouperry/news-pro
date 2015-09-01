
#import "MIArticleViewController.h"
#import "Social/Social.h"
#import "MIConfig.h"
#import "ISImageViewController.h"


// Customize swift brindig header "Your Project Name-Swift.h"

#import "WPNews2-Swift.h"

@implementation MIArticleViewController

@synthesize needsTemplateRendering;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
        _shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(share)];
        _shareButton.style = UIBarButtonItemStylePlain;
        self.navigationItem.rightBarButtonItem = _shareButton;
    }
    return self;
}

- (void)share
{
    NSString *message = [self.feedItem.link absoluteString];
    UIImage *imageToShare = SHARE_IMAGE;
    
    NSArray *postItems = @[message, imageToShare];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]
                                            initWithActivityItems:postItems
                                            applicationActivities:nil];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
       
       UIPopoverController *popOverPad = [[UIPopoverController alloc] initWithContentViewController:activityVC];
        [popOverPad presentPopoverFromBarButtonItem:_shareButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
   
   } else {
       
       [self presentViewController:activityVC animated:YES completion:nil];
    }
}

- (void)textUp
{
    [self.webView stringByEvaluatingJavaScriptFromString:@"News.textUp()"];
}

- (void)textDown
{
    [self.webView stringByEvaluatingJavaScriptFromString:@"News.textDown()"];
}

- (void)openSafari
{
    _notification.titleText = @"Open Safari Browser";
    _notification.subtitleText = [NSString stringWithFormat:@"Post title: %@", self.feedItem.title];
    _notification.image = [UIImage imageNamed:@"world"];
    _notification.topButtonText = @"Open";
    _notification.bottomButtonText = @"Cancel";
    _notification.dismissOnTap = YES;
    [_notification presentInView:self.view withGravityAnimation:YES];
}

-(void)dropdownNotificationTopButtonTapped
{
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString:[self.feedItem.link absoluteString]]];
    [_notification dismissWithGravityAnimation:NO];
}

-(void)dropdownNotificationBottomButtonTapped
{
    NSLog(@"Dismiss");
    [_notification dismissWithGravityAnimation:NO];
}

- (void)loadArticleContent
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterLongStyle;
    dateFormatter.timeStyle = NSDateFormatterShortStyle;
    NSString *dateString = [dateFormatter stringFromDate:self.feedItem.pubDate];
    
    NSMutableDictionary *pageInfo = [NSMutableDictionary dictionary];
    pageInfo[@"description"] = self.feedItem.descriptionHTML;
    pageInfo[@"link"] = [self.feedItem.link absoluteString];
    pageInfo[@"title"] = self.feedItem.title;
    pageInfo[@"date"] = dateString;
    pageInfo[@"timestamp"] = [NSNumber numberWithInt:[self.feedItem.pubDate timeIntervalSince1970]];
    pageInfo[@"creator"] = self.feedItem.creator;
    pageInfo[@"baseURL"] = @"http://mactech.hu";
    
    NSError *error = nil;
    NSData *pageInfoData = [NSJSONSerialization dataWithJSONObject:pageInfo options:0 error:&error];
    if (!pageInfoData) {
        NSLog(@"Could not write JSON data: %@", error);
    } else {
        NSString *pageInfoString = [[NSString alloc] initWithData:pageInfoData encoding:NSUTF8StringEncoding];
        NSString *script = [NSString stringWithFormat:@"News.loadPage(%@);", pageInfoString];
        [self.webView stringByEvaluatingJavaScriptFromString:script];
    }
}

- (void)loadTemplate
{
    
    self.needsTemplateRendering = YES;
    NSURL *base = [[NSBundle mainBundle] URLForResource:@"news" withExtension:@"html"];
    [self.webView loadRequest:[NSURLRequest requestWithURL:base]];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
        if (self.needsTemplateRendering) {
        self.needsTemplateRendering = NO;
        [self loadArticleContent];
    }
}

- (UIView *)brandingView
{
    UILabel *brandingLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    
    CGFloat brandingFontSize;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        brandingFontSize = 17;
    } else {
        brandingFontSize = 14;
    }
    
    brandingLabel.font = [UIFont fontWithName:TOOLBAR_TITLE_FONT_NAME size:brandingFontSize];
    brandingLabel.text = TOOLBAR_TITLE;
    brandingLabel.textColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    brandingLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    brandingLabel.shadowOffset = CGSizeMake(0, -1);
    brandingLabel.backgroundColor = [UIColor clearColor];
    brandingLabel.alpha = 0.7;
    [brandingLabel sizeToFit];
    
    UIView *brandingView = [[UIView alloc] initWithFrame:brandingLabel.bounds];
    [brandingView addSubview:brandingLabel];
    
    return brandingView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGFloat viewWidth = self.view.bounds.size.width;
    CGFloat viewHeight = self.view.bounds.size.height;
    CGFloat toolbarHeight = 44;
    
    self.toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, viewHeight - toolbarHeight, viewWidth, toolbarHeight)];
    self.toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bigText"] style:UIBarButtonItemStylePlain target:self action:@selector(textUp)];
    UIBarButtonItem *itemSmaller = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"smallText"] style:UIBarButtonItemStylePlain target:self action:@selector(textDown)];
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *branding = [[UIBarButtonItem alloc] initWithCustomView:[self brandingView]];
    UIBarButtonItem *openSafariButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"world"] style:UIBarButtonItemStylePlain target:self action:@selector(openSafari)];
    self.toolbar.items = @[item, itemSmaller, space, branding, space, openSafariButton];
    self.toolbar.tintColor = TOOLBAR_TINT_COLOR;
    self.toolbar.barTintColor = TOOLBAR_BARTINT_COLOR;
    
    
    [self.view addSubview:self.toolbar];
    
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, viewHeight - toolbarHeight)];
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.webView.delegate = self;
    [self.view addSubview:self.webView];
    self.title=self.feedItem.title;
    
    [self loadTemplate];
    
    _notification = [AFDropdownNotification new];
    _notification.notificationDelegate = self;
}

- (void)viewDidUnload
{
    self.webView.delegate = nil;
    [self.webView stopLoading];
    [super viewDidUnload];
}

-(void) viewWillDisappear:(BOOL)animated {
   
    [super viewWillDisappear:animated];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
   
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        
        _clickedURL = [request.URL absoluteString];
        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(loadControllers) userInfo:nil repeats:NO];
        return NO;
        
    }
    return YES;
}

-(void) loadControllers{
    
    NSString*clicked=[_clickedURL pathExtension];
    NSLog(@"1 %@", clicked);
    NSString *fileExstensionJPG = @"jpg";
    NSString *fileExstensionPNG = @"png";
    NSString *fileExstensionJPEG = @"jpeg";
    NSString *fileExstensionGIF = @"gif";
   
    if ([clicked isEqualToString:fileExstensionJPEG] || [clicked isEqualToString:fileExstensionPNG] || [clicked isEqualToString:fileExstensionJPG] || [clicked isEqualToString:fileExstensionGIF]){
        
        ISImageViewController *photoView = [ISImageViewController new];
        photoView.imageURL=_clickedURL;
        photoView.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        
        [self presentViewController:photoView animated:YES completion:nil];
       
        }else{
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] bundle:[NSBundle mainBundle]];
        ISInAppBrowser *browser = [ISInAppBrowser new];
        browser = [storyboard instantiateViewControllerWithIdentifier:@"InAppBrowser"];
        browser.webTitle=_clickedURL;
        browser.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            
            [self presentViewController:browser animated:YES completion:nil];
    }

}

@end
