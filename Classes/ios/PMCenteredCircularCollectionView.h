//
//  PMCenteredCircularCollectionView.h
//  Pods
//
//  Created by Peter Meyers on 3/23/14.
//
//

#import "PMCircularCollectionView.h"
#import "PMCenteredCollectionViewFlowLayout.h"


@protocol PMCenteredCircularCollectionViewDelegate;

@interface PMCenteredCircularCollectionView : PMCircularCollectionView

- (void) setDelegate:(id<PMCenteredCircularCollectionViewDelegate>)delegate;

- (void) centerCell:(UICollectionViewCell *)cell animated:(BOOL)animated;

- (void) centerCellAtIndex:(NSUInteger)index animated:(BOOL)animated;

+ (instancetype) collectionViewWithFrame:(CGRect)frame collectionViewLayout:(PMCenteredCollectionViewFlowLayout *)layout;
- (instancetype) initWithFrame:(CGRect)frame collectionViewLayout:(PMCenteredCollectionViewFlowLayout *)layout;

@end

@protocol PMCenteredCircularCollectionViewDelegate <UICollectionViewDelegateFlowLayout>

@optional

- (void) collectionView:(PMCenteredCircularCollectionView *)collectionView didCenterItemAtIndex:(NSUInteger)index;

@end


