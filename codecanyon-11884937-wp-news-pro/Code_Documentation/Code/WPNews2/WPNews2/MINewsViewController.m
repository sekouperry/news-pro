//
//  MINewsViewController.h
//  WPNews
//
//  Created by Istvan Szabo on 2015.05.05..
//  Copyright (c) 2015 Istvan Szabo. All rights reserved.
//


#import "MINewsViewController.h"
#import "MIFeedLoad.h"
#import "NSArray+Additions.h"
#import "MIConfig.h"
#import "UIImageView+WebCache.h"
#import "MICustomColoredAccessory.h"
#import "MICellView.h"
#import "PostCell.h"


enum {
    TAG_UNUSED,
    TAG_TITLE,
    TAG_DATE,
    TAG_IMAGE,
    TAG_LABEL_CONTAINER,
    TAG_VIEW
};


#define HEADER_PADDING 4
#define HEADER_HEIGHT (TITLE_FONT_SIZE + HEADER_PADDING + HEADER_PADDING)
#define PHOTO_HEIGHT 190
#define PHOTO_V_PADDING 0
#define PHOTO_ROW_HEIGHT (PHOTO_HEIGHT + PHOTO_V_PADDING + PHOTO_V_PADDING)
#define CELL_PADDING 8
#define CELL_PADDING_RIGHT 28.0
#define TITLE_FONT_SIZE 16
#define DATE_FONT_SIZE (TITLE_FONT_SIZE - 2)
#define DATE_HEIGHT 16
#define DATE_Y CELL_PADDING
#define TITLE_Y (DATE_Y + DATE_HEIGHT)


NSDate *DayFromDate(NSDate *date)
{
    NSCalendar *cal = [NSCalendar autoupdatingCurrentCalendar];
    NSDate *day;
    [cal rangeOfUnit:NSCalendarUnitDay startDate:&day interval:NULL forDate:date];
    return day;
}

NSString* PluralizeTimeUnits(NSString *unit, int n)
{
    NSString *futureFormat = NSLocalizedString(@"RelativeDateFutureFormat", @"in %i %@");
    NSString *pastFormat = NSLocalizedString(@"RelativeDatePastFormat", @"%i %@ ago");
    NSString *format = ((n < 0) ? futureFormat : pastFormat);
    int count = ABS(n);
    NSString *unitKey = [NSString stringWithFormat:@"%@%@", (count == 1) ? @"Singular" : @"Plural", unit];
    NSString *unitText = NSLocalizedString(unitKey, nil);
    return [NSString stringWithFormat:format, count, unitText];
}

NSString* RelativeDateString(NSDate *date)
{
    NSCalendar *cal = [NSCalendar autoupdatingCurrentCalendar];
    NSInteger flags = NSCalendarUnitSecond | NSCalendarUnitMinute | NSCalendarUnitHour;
    NSDateComponents *components = [cal components:flags fromDate:date toDate:[NSDate date] options:0];
    
    if (24 < components.hour) {
        NSDateFormatter *formatter = [NSDateFormatter new];
        formatter.timeStyle = NSDateFormatterShortStyle;
        return [[formatter stringFromDate:date] uppercaseString];
    } else if (components.hour) {
        return PluralizeTimeUnits(@"Hour", (int)components.hour);
    } else if (components.minute) {
        return PluralizeTimeUnits(@"Minute", (int)components.minute);
    } else {
        return PluralizeTimeUnits(@"Second", (int)components.second);
    }
}

@implementation MINewsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NAVBAR_TITLE;
    
    _activityCover.hidden = NO;
    
    self.tableView.backgroundColor = BACKGROUND_COLOR;
    self.collectionView.backgroundColor = BACKGROUND_COLOR;
    [self.feed fetch];
    
    NSURL *feedURL = [NSURL URLWithString:WP_FEED_URL];
    MIFeed *feed = nil;
    feed = [[MIFeedLoad loadFeed] feedForURL:feedURL];
    self.feed = feed;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(feedChanged:) name:MIFeedChangedNotification object:self.feed];
    
    _refresh = [UIRefreshControl new];
    _refresh.tintColor=[UIColor grayColor];
    
    NSString *s = REFRESH;
    
    NSMutableAttributedString *a = [[NSMutableAttributedString alloc] initWithString:s];
    
    NSDictionary *refreshAttributes = @{ NSForegroundColorAttributeName: [UIColor grayColor], };
    
    [a setAttributes:refreshAttributes range:NSMakeRange(0, a.length)];
    
    _refresh.attributedTitle = a;
    
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
        
        self.tableView.hidden=YES;
        [self.collectionView addSubview:_refresh];
    } else {
        
        self.collectionView.hidden=YES;
        [self.tableView addSubview:_refresh];
    }    
    
    [_refresh addTarget:self action:@selector(refreshView) forControlEvents:UIControlEventValueChanged];
       
}

- (NSArray *)sortFeedItems:(NSArray *)unsortedItems
{
    return [unsortedItems sortedArrayUsingComparator:^NSComparisonResult(MIFeedItem *a, MIFeedItem *b) {
        return [b.pubDate compare:a.pubDate];
    }];
}

- (void)updateFeedItems:(NSSet *)feedItems
{
    NSArray *orderedItems = [self sortFeedItems:feedItems.allObjects];
    self.postsByDate = [orderedItems partitionedArrayUsingBlock:^(MIFeedItem *obj) {
        return DayFromDate(obj.pubDate);
    }];
    
        
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
        self.posts = [self sortFeedItems:feedItems.allObjects];
        [self.collectionView reloadData];
    } else {
        
        self.posts = [self sortFeedItems:feedItems.allObjects];
        [self.tableView reloadData];
    }
    _activityCover.hidden = YES;
    
}

- (void)refreshView {
    
    
    __weak typeof(self) weakSelf = self;
    [weakSelf.feed fetch];
    NSURL *feedURL = [NSURL URLWithString:WP_FEED_URL];
    MIFeed *feed = nil;
    feed = [[MIFeedLoad loadFeed] feedForURL:feedURL];
    self.feed = feed;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(feedChanged:) name:MIFeedChangedNotification object:self.feed];
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
        [self.collectionView reloadData];
    } else {
        [self.tableView reloadData];
    }
    [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(endRefresh) userInfo:nil repeats:NO];
}

- (void)endRefresh
{
    [self.refresh endRefreshing];
    
}
- (void)feedChanged:(NSNotification *)notification
{
    
    [self updateFeedItems:((MIFeed *)notification.object).items];
}

#pragma mark - TableView Section

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.postsByDate.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    MIFeedItem *item = [(self.postsByDate)[section] firstObject];
    NSDate *day = DayFromDate(item.pubDate);
    NSDate *today = DayFromDate([NSDate date]);
    
    NSCalendar *cal = [NSCalendar autoupdatingCurrentCalendar];
    NSDateComponents *components = [cal components:NSCalendarUnitDay fromDate:day toDate:today options:NSCalendarWrapComponents];
    
    if (components.day == 0) {
        return NSLocalizedString(@"Today", @"Today");
    } else if (components.day == 1) {
        return NSLocalizedString(@"Yesterday", @"Yesterday");
    } else {
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        dateFormatter.dateStyle = NSDateFormatterMediumStyle;
        return [dateFormatter stringFromDate:item.pubDate];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [(self.postsByDate)[section] count];
}

- (MIFeedItem *)feedItemForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (self.postsByDate)[indexPath.section][indexPath.row];
}

- (NSURL *)thumbnailURLForItem:(MIFeedItem *)item
{
    return [item bestThumbnailForWidth:[UIScreen mainScreen].bounds.size.width].URL;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MIFeedItem *item = [self feedItemForRowAtIndexPath:indexPath];
    if (item.mediaThumbnails.count) {
        return PHOTO_ROW_HEIGHT;
    }
    
    CGFloat titleWidth = self.tableView.bounds.size.width - (CELL_PADDING + CELL_PADDING_RIGHT);
    UIFont *font = [UIFont fontWithName:IPHONE_TABLE_VIEW_FONT_NAME size:TITLE_FONT_SIZE];
    NSAttributedString *attributedText =[[NSAttributedString alloc] initWithString:item.title
                                                                        attributes:@
                                         {
                                         NSFontAttributeName: font
                                         }];
    
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){titleWidth, CGFLOAT_MAX}
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    
    CGSize newSize = rect.size;
    return TITLE_Y + newSize.height + CELL_PADDING;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return HEADER_HEIGHT;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, HEADER_HEIGHT)];
    headerView.backgroundColor = BACKGROUND_COLOR;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(HEADER_PADDING, HEADER_PADDING, [[UIScreen mainScreen] bounds].size.width, TITLE_FONT_SIZE)];
    label.backgroundColor = [UIColor clearColor];
    label.text = [self tableView:tableView titleForHeaderInSection:section];
    label.font = [UIFont fontWithName:IPHONE_TABLE_VIEW_FONT_NAME size:14];
    label.textColor = [UIColor blackColor];
    label.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    label.shadowOffset = CGSizeMake(0, 1);
    [headerView addSubview:label];
    return headerView;
}

- (UIImageView *)imageViewForCell:(UITableViewCell *)cell
{
    return (UIImageView *)[cell viewWithTag:TAG_IMAGE];
}

static NSString *CellIdentifier = @"PhotoCell";

- (UITableViewCell *)createMediaCell{
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    
    _newsImageView = [UIImageView new];
    [_newsImageView sizeToFit];
    _newsImageView.tag = TAG_IMAGE;
    _newsImageView.contentMode = UIViewContentModeScaleAspectFill;
    _newsImageView.clipsToBounds = YES;
    cell.backgroundView = _newsImageView;
    
   
    CGRect barFrame = CGRectMake(0, PHOTO_V_PADDING + PHOTO_HEIGHT - 74, self.view.frame.size.width, 74);
    UIView *blackBar = [[UIView alloc] initWithFrame:barFrame];
    blackBar.tag = TAG_LABEL_CONTAINER;
    blackBar.backgroundColor = [UIColor blackColor];
    blackBar.alpha= 0.7;
    [cell.contentView addSubview:blackBar];
    
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:blackBar.frame];
    cell.selectedBackgroundView.backgroundColor = [UIColor colorWithHue:(211.0 / 360.0) saturation:0.99 brightness:0.93 alpha:0.2];
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone){
        
        CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
        
        if (iOSDeviceScreenSize.height == 736){
            // iPhone 6 Plus 5.5 inch
            MICustomColoredAccessory *arrow = [MICustomColoredAccessory accessoryWithColor:[UIColor whiteColor]];
            arrow.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
            CGRect arrowFrame = arrow.frame;
            arrowFrame.origin = CGPointMake(self.view.frame.size.width-37, 30);
            arrow.frame = arrowFrame;
            [blackBar addSubview:arrow];
            
             }else{
            
            MICustomColoredAccessory *arrow = [MICustomColoredAccessory accessoryWithColor:[UIColor whiteColor]];
            arrow.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
            CGRect arrowFrame = arrow.frame;
            arrowFrame.origin = CGPointMake(self.view.frame.size.width-23, 30);
            arrow.frame = arrowFrame;
            [blackBar addSubview:arrow];
        }
    }
    
   CGRect titleFrame = CGRectMake(CELL_PADDING, TITLE_Y, [[UIScreen mainScreen] bounds].size.width - CELL_PADDING - CELL_PADDING_RIGHT, TITLE_FONT_SIZE * 2);
    _titleLabel = [[UILabel alloc] initWithFrame:titleFrame];
    _titleLabel.tag = TAG_TITLE;
    _titleLabel.font = [UIFont fontWithName:IPHONE_TABLE_VIEW_FONT_NAME size:TITLE_FONT_SIZE];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.numberOfLines = 0;
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.highlightedTextColor = [UIColor whiteColor];
    [blackBar addSubview:_titleLabel];
    
    UILabel *dateView = [[UILabel alloc] initWithFrame:CGRectMake(CELL_PADDING, CELL_PADDING, [[UIScreen mainScreen] bounds].size.width, DATE_HEIGHT)];
    dateView.tag = TAG_DATE;
    dateView.font = [UIFont fontWithName:IPHONE_TABLE_VIEW_FONT_NAME size:12];
    dateView.textColor = [UIColor grayColor];
    dateView.backgroundColor = [UIColor clearColor];
    dateView.highlightedTextColor = [UIColor colorWithWhite:0.8 alpha:1.0];
    [blackBar addSubview:dateView];
    
    return cell;
}

- (UITableViewCell *)photoCellForItem:(MIFeedItem *)item{
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [self createMediaCell];
    }
    
    _newsImageView = [self imageViewForCell:cell];
    
    __block UIActivityIndicatorView *activityIndicator;
    __weak UIImageView *weakImageView = self.newsImageView;
    
    
    [self.newsImageView sd_setImageWithURL:[self thumbnailURLForItem:item]
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
    
    
    
    _titleLabel = (UILabel *)[cell viewWithTag:TAG_TITLE];
    
    
    CGFloat titleWidth = self.tableView.bounds.size.width - (CELL_PADDING + CELL_PADDING_RIGHT);
    UIFont *font = [UIFont fontWithName:IPHONE_TABLE_VIEW_FONT_NAME size:TITLE_FONT_SIZE];
    NSAttributedString *attributedText =[[NSAttributedString alloc] initWithString:item.title
                                                                        attributes:@
                                         {
                                         NSFontAttributeName: font
                                         }];
    
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){titleWidth, CGFLOAT_MAX}
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    
    CGSize titleSize = rect.size;
    _titleLabel.frame = CGRectMake(CELL_PADDING, TITLE_Y, titleSize.width, titleSize.height);
    _titleLabel.numberOfLines = 0;
    _titleLabel.text = item.title;
    
    UIView *labelContaier = [cell viewWithTag:TAG_LABEL_CONTAINER];
    CGFloat containerHeight = TITLE_Y + titleSize.height + CELL_PADDING;
    labelContaier.frame = CGRectMake(0, PHOTO_ROW_HEIGHT - containerHeight, [[UIScreen mainScreen] bounds].size.width, containerHeight);
    
    UILabel *dateView = (UILabel *)[cell viewWithTag:TAG_DATE];
    dateView.text = RelativeDateString(item.pubDate);
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MIFeedItem *item = [self feedItemForRowAtIndexPath:indexPath];
        
        if  (item.mediaThumbnails.count) {
            return [self photoCellForItem:item];
        }
        
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            titleLabel.adjustsFontSizeToFitWidth = YES;
            titleLabel.tag = TAG_TITLE;
            titleLabel.font = [UIFont fontWithName:IPHONE_TABLE_VIEW_FONT_NAME size:TITLE_FONT_SIZE];
            titleLabel.textColor = [UIColor blackColor];
            titleLabel.numberOfLines = 0;
            titleLabel.backgroundColor = [UIColor clearColor];
            titleLabel.highlightedTextColor = [UIColor whiteColor];
            [cell.contentView addSubview:titleLabel];
            
            UILabel *dateView = [[UILabel alloc] initWithFrame:CGRectMake(CELL_PADDING, CELL_PADDING, [[UIScreen mainScreen] bounds].size.width, DATE_HEIGHT)];
            dateView.tag = TAG_DATE;
            dateView.font = [UIFont fontWithName:IPHONE_TABLE_VIEW_FONT_NAME size:12];
            dateView.textColor = [UIColor grayColor];
            dateView.backgroundColor = [UIColor clearColor];
            dateView.highlightedTextColor = [UIColor colorWithWhite:0.8 alpha:1.0];
            [cell.contentView addSubview:dateView];
        }
        
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:TAG_TITLE];
    CGFloat titleWidth = self.tableView.bounds.size.width - (CELL_PADDING + CELL_PADDING_RIGHT);
    UIFont *font = [UIFont fontWithName:IPHONE_TABLE_VIEW_FONT_NAME size:TITLE_FONT_SIZE];
    NSAttributedString *attributedText =[[NSAttributedString alloc] initWithString:item.title
                                                                        attributes:@
                                         {
                                         NSFontAttributeName: font
                                         }];
    
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){titleWidth, CGFLOAT_MAX}
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    
    CGSize titleSize = rect.size;
    titleLabel.frame = CGRectMake(CELL_PADDING, TITLE_Y, titleSize.width, titleSize.height);
    titleLabel.adjustsFontSizeToFitWidth = YES;
    titleLabel.numberOfLines = 0;
    titleLabel.text = item.title;
    
    UILabel *dateView = (UILabel *)[cell viewWithTag:TAG_DATE];
    dateView.text = RelativeDateString(item.pubDate);
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    MIFeedItem *item = [self feedItemForRowAtIndexPath:indexPath];
    MIArticleViewController *web = [[MIArticleViewController alloc] initWithNibName:nil bundle:nil];
    web.feedItem = item;
    [self.navigationController pushViewController:web animated:YES];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return (self.posts.count);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    
    PostCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PostCell" forIndexPath:indexPath];
    
    MICellView *cellView = [[MICellView alloc] initWithFrame:CGRectMake(0, 0, 244, 230)];
    
    MIFeedItem *item = (self.posts)[indexPath.row];
    cellView.feedItem = item;
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(itemTapped:)];
    [cellView addGestureRecognizer:recognizer];
    
    [cell.postsView addSubview:cellView];
    
    return cell;
    
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
        [self.collectionView reloadData];
    } else {
        [self.tableView reloadData];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.feed.items.count) {
        [self.feed fetch];
    }
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
        [self.collectionView reloadData];
    } else {
        [self.tableView reloadData];
    }
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    }

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.posts = [NSMutableArray array];
    self.tableView = nil;
    self.collectionView = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MIFeedChangedNotification object:self.feed];
}

- (void)itemTapped:(UITapGestureRecognizer *)gestureRecognizer
{
    MICellView *cellView = (MICellView *)gestureRecognizer.view;
    MIFeedItem *item = cellView.feedItem;
   
    MIArticleViewController *web = [[MIArticleViewController alloc] initWithNibName:nil bundle:nil];
    web.feedItem = item;
    [self.navigationController pushViewController:web animated:YES];

}

- (UITableViewCell *)cellForImageView:(UIView *)imageView
{
    for (UITableViewCell *cell in self.tableView.visibleCells) {
        if (imageView == [self imageViewForCell:cell]) {
            return cell;
        }
    }
    
    return nil;
}

@end
