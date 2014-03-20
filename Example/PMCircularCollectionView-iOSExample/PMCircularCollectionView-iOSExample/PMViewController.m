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
    layout.minimumLineSpacing = 0.0f;
    
    PMCircularCollectionView *collectionView = [[PMCircularCollectionView alloc] initWithFrame:self.view.bounds
                                                                          collectionViewLayout:layout];
    collectionView.backgroundColor = [UIColor clearColor];
    
//    UIImageView *pg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pg.jpg"]];
//    UIImageView *kobe = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"kobe.jpg"]];
//    UIImageView *lj = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lj.jpg"]];
//    UIImageView *cp = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cp.jpg"]];
//    collectionView.views = @[pg, kobe, lj, cp];
    
    CGRect frame = {0, 0, self.view.bounds.size.width/2.0f, self.view.bounds.size.width/2.0f};
    UILabel *label1 = [[UILabel alloc] initWithFrame:frame];
    label1.text = @"Label1";
    label1.textAlignment = NSTextAlignmentCenter;
    UILabel *label2 = [[UILabel alloc] initWithFrame:frame];
    label2.text = @"Label2";
    label2.textAlignment = NSTextAlignmentCenter;
    UILabel *label3 = [[UILabel alloc] initWithFrame:frame];
    label3.text = @"Label3";
    label3.textAlignment = NSTextAlignmentCenter;
    UILabel *label4 = [[UILabel alloc] initWithFrame:frame];
    label4.text = @"Label4";
    label4.textAlignment = NSTextAlignmentCenter;
    collectionView.views = @[label1, label2, label3, label4];
    
    [self.view addSubview:collectionView];
}


@end
