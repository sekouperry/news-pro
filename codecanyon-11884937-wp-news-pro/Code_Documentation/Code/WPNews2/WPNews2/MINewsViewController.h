//
//  MINewsViewController.h
//  WPNews
//
//  Created by Istvan Szabo on 2015.05.05..
//  Copyright (c) 2015 Istvan Szabo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MIArticleViewController.h"
#import "MIFeed.h"
#import <Foundation/Foundation.h>
#import "MICircleActivity.h"

NSDate *DayFromDate(NSDate *date);

@interface MINewsViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,UITableViewDataSource,UITableViewDelegate>


@property (nonatomic, strong) NSArray *postsByDate;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;
@property (nonatomic, weak) IBOutlet MICircleActivity *activityCover;

@property (nonatomic, strong) NSArray *posts;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIRefreshControl *refresh;
@property (nonatomic, strong) MIFeed *feed;
@property (readonly, strong) UITableViewCell *createMediaCell;
@property (nonatomic, strong) UIImageView *newsImageView;


- (NSArray *)sortFeedItems:(NSArray *)unsortedItems;
- (MIFeedItem *)feedItemForRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)updateFeedItems:(NSSet *)feedItems;

@end
