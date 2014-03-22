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

@property (nonatomic, strong) PMCircularCollectionView *collectionView;
@property (nonatomic, strong) UIView *viewToScrollTo;

@end

@implementation PMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 100.0f; // Vertical Spacing
    layout.minimumInteritemSpacing = 100.0f; // Horizontal Spacing
    
    CGRect frame = self.view.bounds;
    
    self.collectionView = [[PMCircularCollectionView alloc] initWithFrame:frame
                                                     collectionViewLayout:layout];
    
    self.collectionView.backgroundColor = [UIColor clearColor];
    
//    UIImageView *pg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pg.jpg"]];
//    UIImageView *kobe = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"kobe.jpg"]];
//    UIImageView *lj = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lj.jpg"]];
//    UIImageView *cp = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cp.jpg"]];
//    collectionView.views = @[pg, kobe, lj, cp];
    
    self.viewToScrollTo = [self labelWithString:@"label 1"];
    
    self.collectionView.views = @[[self labelWithString:@"label 0"],
                             self.viewToScrollTo,
                             [self labelWithString:@"label 2"],
                             [self labelWithString:@"label 3"]];
    
    [self.view addSubview:self.collectionView];
    
    if ([self.collectionView.delegate respondsToSelector:@selector(collectionView:didSelectItemAtIndexPath:)]) {
        [self.collectionView.delegate collectionView:self.collectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForItem:2 inSection:0]];
    }
}

- (void) viewDidAppear:(BOOL)animated
{
    [self.collectionView scrollToView:self.viewToScrollTo animated:YES];
}

- (UILabel *)labelWithString:(NSString *)string
{
    UILabel *label = [UILabel new];
    label.text = string;
    [label sizeToFit];
    return label;
}

@end
