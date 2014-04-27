//
//  PMViewController.m
//  PMPMInfiniteScrollView-iOSExample
//
//  Created by Peter Meyers on 3/19/14.
//  Copyright (c) 2014 Peter Meyers. All rights reserved.
//

#import "PMViewController.h"
#import "PMCenteredCircularCollectionView.h"
#import "PMUtils.h"

static NSString * const PMCellReuseIdentifier = @"PMCellReuseIdentifier";

@interface PMViewController () <UICollectionViewDelegate, UIScrollViewDelegate, PMCircularCollectionViewDataSource>

@property (nonatomic, strong) PMCenteredCircularCollectionView *collectionView;
@property (nonatomic, strong) UIView *viewToScrollTo;
@property (nonatomic, strong) NSArray *images;

@end

@implementation PMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage *pg = [UIImage imageNamed:@"pg.jpg"];
    UIImage *kobe = [UIImage imageNamed:@"kobe.jpg"];
    UIImage *lj = [UIImage imageNamed:@"lj.jpg"];
    UIImage *cp = [UIImage imageNamed:@"cp.jpg"];
    self.images = @[pg, kobe, lj, cp];
    
    CGRect frame = self.view.bounds;
    
    PMCenteredCollectionViewFlowLayout *layout = [PMCenteredCollectionViewFlowLayout new];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 10.0f; // Vertical Spacing
    layout.minimumInteritemSpacing = 10.0f; // Horizontal Spacing
    layout.itemSize = frame.size;
    
    self.collectionView = [[PMCenteredCircularCollectionView alloc] initWithFrame:frame
                                                             collectionViewLayout:layout];
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.shadowRadius = 10.0f;
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:PMCellReuseIdentifier];
    [self.collectionView setDataSource:self];

    
//    self.viewToScrollTo = [self labelWithString:@"label 1"];
//    
//    self.collectionView.views = @[[self labelWithString:@"label 0"],
//                                  self.viewToScrollTo,
//                                  [self labelWithString:@"label 2"],
//                                  [self labelWithString:@"label 3"],
//                                  [self labelWithString:@"label 4"],
//                                  [self labelWithString:@"label 5"]];
    
    [self.view addSubview:self.collectionView];
}

- (void) viewDidAppear:(BOOL)animated
{
    [self.collectionView centerCellAtIndex:2 animated:YES];
}

- (UILabel *)labelWithString:(NSString *)string
{
    UILabel *label = [UILabel new];
    label.text = string;
    [label sizeToFit];
    return label;
}

#pragma mark - PMCircularCollectionViewDataSource Methods

- (NSString *) circularCollectionView:(PMCircularCollectionView *)collectionView reuseIdentifierForIndex:(NSUInteger)index
{
    return PMCellReuseIdentifier;
}

- (NSUInteger) numberOfItemsInCircularCollectionView:(PMCircularCollectionView *)collectionView
{
    return self.images.count;
}

- (void) circularCollectionView:(PMCircularCollectionView *)collectionView configureCell:(UICollectionViewCell *)cell atIndex:(NSUInteger)index
{
    if (![cell.contentView.subviews.lastObject isKindOfClass:[UIImageView class]]   ) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:cell.contentView.bounds];
        imageView.contentMode = UIViewContentModeCenter;
        imageView.clipsToBounds = YES;
        [cell.contentView addSubview:imageView];
    }
    
    UIImageView *imageView = cell.contentView.subviews.lastObject;
    imageView.image = self.images[index];
}

@end
