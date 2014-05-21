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

@property (nonatomic, weak) id<PMCenteredCircularCollectionViewDelegate> centeredCollectionViewDelegate;

- (instancetype) initWithFrame:(CGRect)frame collectionViewLayout:(PMCenteredCollectionViewFlowLayout *)layout;

- (void) centerCell:(UICollectionViewCell *)cell animated:(BOOL)animated;

- (void) centerCellAtIndex:(NSUInteger)index animated:(BOOL)animated;

@end

@protocol PMCenteredCircularCollectionViewDelegate <NSObject>

- (void) collectionView:(PMCenteredCircularCollectionView *)collectionView didCenterItemAtIndexPath:(NSIndexPath *)indexPath;

@end
