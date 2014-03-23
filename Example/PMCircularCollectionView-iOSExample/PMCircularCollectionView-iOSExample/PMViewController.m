//
//  PMViewController.m
//  PMPMInfiniteScrollView-iOSExample
//
//  Created by Peter Meyers on 3/19/14.
//  Copyright (c) 2014 Peter Meyers. All rights reserved.
//

#import "PMViewController.h"
#import "PMCenteredCircularCollectionView.h"

@interface PMViewController ()

@property (nonatomic, strong) PMCenteredCircularCollectionView *collectionView;
@property (nonatomic, strong) UIView *viewToScrollTo;

@end

@implementation PMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 10.0f; // Vertical Spacing
    layout.minimumInteritemSpacing = 10.0f; // Horizontal Spacing
    
    CGRect frame = self.view.bounds;
    
    self.collectionView = [[PMCenteredCircularCollectionView alloc] initWithFrame:frame
                                                             collectionViewLayout:layout];
    
    self.collectionView.backgroundColor = [UIColor clearColor];
    
    UIImageView *pg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pg.jpg"]];
    UIImageView *kobe = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"kobe.jpg"]];
    UIImageView *lj = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lj.jpg"]];
    UIImageView *cp = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cp.jpg"]];
    self.collectionView.views = @[pg, kobe, lj, cp];
    
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
    [self.collectionView centerView:self.viewToScrollTo animated:YES];
}

- (UILabel *)labelWithString:(NSString *)string
{
    UILabel *label = [UILabel new];
    label.text = string;
    [label sizeToFit];
    return label;
}

@end
