//
//  PMViewController.m
//  PMPMInfiniteScrollView-iOSExample
//
//  Created by Peter Meyers on 3/19/14.
//  Copyright (c) 2014 Peter Meyers. All rights reserved.
//

#import "PMViewController.h"
#import "PMCircularCollectionView.h"

@interface PMViewController ()

@end

@implementation PMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 100.0f; // Vertical Spacing
    layout.minimumInteritemSpacing = 100.0f; // Horizontal Spacing
    
    PMCircularCollectionView *collectionView = [[PMCircularCollectionView alloc] initWithFrame:self.view.bounds
                                                                          collectionViewLayout:layout];
    collectionView.backgroundColor = [UIColor clearColor];
    
//    UIImageView *pg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pg.jpg"]];
//    UIImageView *kobe = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"kobe.jpg"]];
//    UIImageView *lj = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lj.jpg"]];
//    UIImageView *cp = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cp.jpg"]];
//    collectionView.views = @[pg, kobe, lj, cp];
    
    collectionView.views = @[[self labelWithString:@"label 0"],
                             [self labelWithString:@"label 1"],
                             [self labelWithString:@"label 2"],
                             [self labelWithString:@"label 3"]];
    
    [self.view addSubview:collectionView];
}

- (UILabel *)labelWithString:(NSString *)string
{
    UILabel *label = [UILabel new];
    label.text = string;
    [label sizeToFit];
    return label;
}

@end
