//
//  PMCircularCollectionView.m
//  
//
//  Created by Peter Meyers on 3/19/14.
//
//

#import "PMCircularCollectionView.h"
#import "PMUtils.h"

static NSString *CellReuseID = @"Cell";
static CGFloat const ContentMultiplier = 3.0f;

@interface PMCircularCollectionView () <UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate>

@end

@implementation PMCircularCollectionView

- (instancetype) initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewFlowLayout *)layout
{
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        self.dataSource = self;
        self.delegate = self;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        [self registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:CellReuseID];
    }
    return self;
}

- (void) recenterIfNecessary
{
    CGPoint currentOffset = self.contentOffset;
    CGFloat centerOffset;
    CGFloat distanceFromCenter;
    CGFloat contentDistance;
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionViewLayout;
    
    switch (layout.scrollDirection) {
            
        case UICollectionViewScrollDirectionHorizontal:
            contentDistance = self.contentSize.width;
            centerOffset = (contentDistance -  self.bounds.size.width) / 2.0f;
            distanceFromCenter = fabsf(currentOffset.x - centerOffset);
            break;
            
        case UICollectionViewScrollDirectionVertical:
            contentDistance = self.contentSize.height;
            centerOffset = (contentDistance - self.bounds.size.height) / 2.0f;
            distanceFromCenter = fabsf(currentOffset.y - centerOffset);
            break;
    }
    
    if (distanceFromCenter >= contentDistance / ContentMultiplier  ) {
        
        switch (layout.scrollDirection) {
            case UICollectionViewScrollDirectionHorizontal:
                currentOffset.x = centerOffset;
                break;
            case UICollectionViewScrollDirectionVertical:
                currentOffset.y = centerOffset;
                break;
        }
        
        self.contentOffset = currentOffset;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self recenterIfNecessary];
}

#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGPoint middlePoint = self.contentOffset;
    middlePoint.x += self.bounds.size.width / 2.0f;
    middlePoint.y += self.bounds.size.height / 2.0f;
    
    NSIndexPath *middleIndexPath = [self indexPathForItemAtPoint:middlePoint];
    [self scrollToItemAtIndexPath:middleIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
}

#pragma mark - UICollectionViewDatasource Methods


- (NSInteger) collectionView: (UICollectionView *) collectionView
      numberOfItemsInSection: (NSInteger) section
{
    return self.views.count * ContentMultiplier;
}

- (UICollectionViewCell *) collectionView:(UICollectionView *) collectionView
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellReuseID
                                                                           forIndexPath:indexPath];
    
    UIView *view = self.views[indexPath.row % self.views.count];

    [cell.contentView removeSubviews];
    [cell.contentView addSubview:view];
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionViewLayout;
    PMDirection direction = layout.scrollDirection == UICollectionViewScrollDirectionHorizontal? PMDirectionVertical : PMDirectionHorizontal;
    [view centerInRect:cell.contentView.bounds forDirection:direction];
    return cell;
}

#pragma mark - UICollectionViewDelegate Methods

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UIView *view = self.views[indexPath.row % self.views.count];
    
    switch (collectionViewLayout.scrollDirection) {
        case UICollectionViewScrollDirectionHorizontal: return CGSizeMake(view.frame.size.width, self.bounds.size.height);
        case UICollectionViewScrollDirectionVertical: return CGSizeMake(self.bounds.size.width, view.frame.size.height);
    }
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewScrollPosition position;
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)collectionView.collectionViewLayout;
    switch (layout.scrollDirection) {
        case UICollectionViewScrollDirectionHorizontal:
            position = UICollectionViewScrollPositionCenteredHorizontally;
            break;
        case UICollectionViewScrollDirectionVertical:
            position = UICollectionViewScrollPositionCenteredVertically;
            break;
    }
    [self scrollToItemAtIndexPath:indexPath atScrollPosition:position animated:YES];
    [self.secondaryDelegate collectionView:collectionView didSelectItemAtIndexPath:indexPath];
}
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.secondaryDelegate) {
        return YES;
    }
    return [self.secondaryDelegate collectionView:collectionView shouldHighlightItemAtIndexPath:indexPath];
}
- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.secondaryDelegate collectionView:collectionView didHighlightItemAtIndexPath:indexPath];
}
- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.secondaryDelegate collectionView:collectionView didUnhighlightItemAtIndexPath:indexPath];
}
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.secondaryDelegate) {
        return YES;
    }
    return [self.secondaryDelegate collectionView:collectionView shouldSelectItemAtIndexPath:indexPath];
}
- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.secondaryDelegate) {
        return YES;
    }
    return [self.secondaryDelegate collectionView:collectionView shouldDeselectItemAtIndexPath:indexPath];
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.secondaryDelegate collectionView:collectionView didDeselectItemAtIndexPath:indexPath];
}
- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.secondaryDelegate collectionView:collectionView didEndDisplayingCell:cell forItemAtIndexPath:indexPath];
}
- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingSupplementaryView:(UICollectionReusableView *)view forElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath
{
    [self.secondaryDelegate collectionView:collectionView didEndDisplayingSupplementaryView:view forElementOfKind:elementKind atIndexPath:indexPath];
}
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.secondaryDelegate collectionView:collectionView shouldShowMenuForItemAtIndexPath:indexPath];
}
- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if (!self.secondaryDelegate) {
        return NO;
    }
    return [self.secondaryDelegate collectionView:collectionView canPerformAction:action forItemAtIndexPath:indexPath withSender:sender];
}
- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    [self.secondaryDelegate collectionView:collectionView performAction:action forItemAtIndexPath:indexPath withSender:sender];
}
- (UICollectionViewTransitionLayout *)collectionView:(UICollectionView *)collectionView transitionLayoutForOldLayout:(UICollectionViewLayout *)fromLayout newLayout:(UICollectionViewLayout *)toLayout
{
    if (!self.secondaryDelegate) {
        return [[UICollectionViewTransitionLayout alloc] initWithCurrentLayout:fromLayout
                                                                    nextLayout:toLayout];
    }
    return [self.secondaryDelegate collectionView:collectionView transitionLayoutForOldLayout:fromLayout newLayout:toLayout];
}

@end
