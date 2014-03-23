//
//  PMCircularCollectionView.m
//  
//
//  Created by Peter Meyers on 3/19/14.
//
//

#import "PMCircularCollectionView.h"
#import "PMUtils.h"

static CGFloat const ContentMultiplier = 4.0f;

static inline NSString * PMReuseIdentifierForViewIndex(NSUInteger index) {
    return [[NSNumber numberWithInteger:index] stringValue];
}

@interface PMCircularCollectionView ()

<UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic) CGSize viewsSize;

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
    }
    return self;
}

- (void) setViews:(NSArray *)views
{
    if (_views != views) {
        _views = views;
        [self registerCells];
        [self setMinimumSpacing];
        [self reloadData];
    }
}

- (void) registerCells
{
    for (NSUInteger i = 0; i < self.views.count; i++) {
        [self registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:PMReuseIdentifierForViewIndex(i)];
    }
}

- (void) setMinimumSpacing
{
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionViewLayout;
    
    CGFloat contentWidth = 0.0f;
    CGFloat contentHeight = 0.0f;
    
    for (UIView *view in self.views) {
        contentWidth += view.frame.size.width;
        contentHeight += view.frame.size.height;
    }
    
    self.viewsSize = CGSizeMake(contentWidth, contentHeight);
    
    NSUInteger spaces = self.views.count - 1;
    CGFloat minimumInteritemSpacing = ceilf((self.bounds.size.width - contentWidth) / spaces + 1.0f);
    CGFloat minimumLineSpacing = ceilf((self.bounds.size.height - contentHeight) / spaces + 1.0f);
    
    if (minimumInteritemSpacing - layout.minimumInteritemSpacing > 0.0f) {
        layout.minimumInteritemSpacing = minimumInteritemSpacing;
    }
    
    if (minimumLineSpacing - layout.minimumLineSpacing > 0.0f) {
        layout.minimumLineSpacing = minimumLineSpacing;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self recenterIfNecessary];
}

- (void) recenterIfNecessary
{
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionViewLayout;
    CGPoint currentOffset = self.contentOffset;
    
    switch (layout.scrollDirection) {
            
        case UICollectionViewScrollDirectionHorizontal: {

            CGFloat contentCenteredX = (self.contentSize.width - self.bounds.size.width) / 2.0f;
            CGFloat deltaFromCenter = currentOffset.x - contentCenteredX;
            CGFloat singleContentWidth = self.viewsSize.width + layout.minimumInteritemSpacing * self.views.count;
            
            if (fabsf(deltaFromCenter) >= singleContentWidth ) {
                
                CGFloat correction = (deltaFromCenter > 0)? deltaFromCenter - singleContentWidth : deltaFromCenter + singleContentWidth;
                
                currentOffset.x = contentCenteredX + correction;
            }

            break;
        }
        case UICollectionViewScrollDirectionVertical: {
            
            CGFloat contentCenteredY = (self.contentSize.height - self.bounds.size.height) / 2.0f;
            CGFloat deltaFromCenter = currentOffset.y - contentCenteredY;
            CGFloat singleContentHeight = self.viewsSize.height + layout.minimumLineSpacing * self.views.count;
            
            if (fabsf(deltaFromCenter) >= singleContentHeight) {
                
                CGFloat correction = (deltaFromCenter > 0)? deltaFromCenter - singleContentHeight : deltaFromCenter + singleContentHeight;
                
                currentOffset.y = contentCenteredY + correction;
            }
            
            break;
        }
    }
    
    self.contentOffset = currentOffset;
}

- (void) centerNearestIndexPath
{
    // Find index path of closest cell. Do not use -indexPathForItemAtPoint:
    // This method returns nil if the specified point lands in the spacing between cells.
    
    NSIndexPath *indexPath = [self visibleIndexPathNearestToPoint:[self contentOffsetInBoundsCenter]];
    
    if (indexPath) {
        [self collectionView:self didSelectItemAtIndexPath:indexPath];
    }
}

- (void) scrollToView:(UIView *)view animated:(BOOL)animated
{
    NSUInteger originalIndexOfView = [self.views indexOfObject:view];
    
    if (originalIndexOfView != NSNotFound) {
        
        NSIndexPath *indexPathAtMiddle;
        if (self.visibleCells.count) {
            indexPathAtMiddle = [self visibleIndexPathNearestToPoint:[self contentOffsetInBoundsCenter]];
        }
        else {
            indexPathAtMiddle = [self indexPathNearestToPoint:[self contentOffsetInBoundsCenter]];
        }
        
        if (indexPathAtMiddle) {
            
            NSInteger originalIndexOfMiddle = indexPathAtMiddle.item % self.views.count;
                
            NSInteger delta = [self.views distanceFromIndex:originalIndexOfMiddle toIndex:originalIndexOfView circular:YES];
            
            NSInteger toItem = indexPathAtMiddle.item + delta;
            
            NSIndexPath *toIndexPath = [NSIndexPath indexPathForItem:toItem inSection:0];
            
            [self scrollToItemAtIndexPath:toIndexPath
                         atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally | UICollectionViewScrollPositionCenteredVertically
                                 animated:animated];
        }
    }
}

- (CGPoint) contentOffsetInBoundsCenter
{
    CGPoint middlePoint = self.contentOffset;
    middlePoint.x += self.bounds.size.width / 2.0f;
    middlePoint.y += self.bounds.size.height / 2.0f;
    return middlePoint;
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
    NSUInteger viewIndex = indexPath.item % self.views.count;
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:PMReuseIdentifierForViewIndex(viewIndex)
                                                                           forIndexPath:indexPath];
    if (!cell.contentView.subviews.count) {
        
        UIView *view = self.views[viewIndex];
        [cell.contentView addSubview:view];
        
        UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionViewLayout;
        PMDirection direction = layout.scrollDirection == UICollectionViewScrollDirectionHorizontal? PMDirectionVertical : PMDirectionHorizontal;
        [view centerInRect:cell.contentView.bounds forDirection:direction];
    }

    return cell;
}


#pragma mark - UIScrollViewDelegate Methods


- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    CGPoint targetOffset = *targetContentOffset;
    
    BOOL targetFirstIndexPath = CGPointEqualToPoint(targetOffset, CGPointZero);
    BOOL targetLastIndexPath = (targetOffset.x == self.contentSize.width - self.bounds.size.width &&
                                targetOffset.y == self.contentSize.height - self.bounds.size.height);
    
    if ( !targetFirstIndexPath && !targetLastIndexPath) {
        
        targetOffset.x += self.bounds.size.width / 2.0f;
        targetOffset.y += self.bounds.size.height / 2.0f;
        
        NSIndexPath *targetedIndexPath = [self indexPathNearestToPoint:targetOffset];

        UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:targetedIndexPath];
        
        targetOffset = [self contentOffsetForCenteredRect:attributes.frame];
        
        *targetContentOffset = targetOffset;
    }
    
    if ([self.secondaryDelegate respondsToSelector:@selector(scrollViewWillEndDragging:withVelocity:targetContentOffset:)]) {
        [self.secondaryDelegate scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self centerNearestIndexPath];
    
    if ([self.secondaryDelegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
        [self.secondaryDelegate scrollViewDidEndDecelerating:scrollView];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([self.secondaryDelegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [self.secondaryDelegate scrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    if ([self.secondaryDelegate respondsToSelector:@selector(scrollViewDidZoom:)]) {
        [self.secondaryDelegate scrollViewDidZoom:scrollView];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([self.secondaryDelegate respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
        [self.secondaryDelegate scrollViewWillBeginDragging:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self centerNearestIndexPath];
    }
    
    if ([self.secondaryDelegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [self.secondaryDelegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    if ([self.secondaryDelegate respondsToSelector:@selector(scrollViewWillBeginDecelerating:)]) {
        [self.secondaryDelegate scrollViewWillBeginDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if ([self.secondaryDelegate respondsToSelector:@selector(scrollViewDidEndScrollingAnimation:)]) {
        [self.secondaryDelegate scrollViewDidEndScrollingAnimation:scrollView];
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    if ([self.secondaryDelegate respondsToSelector:@selector(viewForZoomingInScrollView:)]) {
        [self.secondaryDelegate viewForZoomingInScrollView:scrollView];
    }
    return nil;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    if ([self.secondaryDelegate respondsToSelector:@selector(scrollViewWillBeginZooming:withView:)]) {
        [self.secondaryDelegate scrollViewWillBeginZooming:scrollView withView:view];
    }
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    if ([self.secondaryDelegate respondsToSelector:@selector(scrollViewDidEndZooming:withView:atScale:)]) {
        [self.secondaryDelegate scrollViewDidEndZooming:scrollView withView:view atScale:scale];
    }
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    if ([self.secondaryDelegate respondsToSelector:@selector(scrollViewShouldScrollToTop:)]) {
        return [self.secondaryDelegate scrollViewShouldScrollToTop:scrollView];
    }
    return YES;
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
    if ([self.secondaryDelegate respondsToSelector:@selector(scrollViewDidScrollToTop:)]) {
        [self.secondaryDelegate scrollViewDidScrollToTop:scrollView];
    }
}


#pragma mark - UICollectionViewDelegateFlowLayout Methods


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UIView *view = self.views[indexPath.row % self.views.count];
    
    switch (collectionViewLayout.scrollDirection) {
        case UICollectionViewScrollDirectionHorizontal: return CGSizeMake(view.frame.size.width, self.bounds.size.height);
        case UICollectionViewScrollDirectionVertical: return CGSizeMake(self.bounds.size.width, view.frame.size.height);
    }
}

#pragma mark - UICollectionViewDelegate Methods


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self scrollToItemAtIndexPath:indexPath
                 atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally | UICollectionViewScrollPositionCenteredVertically
                         animated:YES];
    
    if ([self.secondaryDelegate respondsToSelector:@selector(collectionView:didSelectItemAtIndexPath:)]) {
        [self.secondaryDelegate collectionView:collectionView didSelectItemAtIndexPath:indexPath];
    }
}
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.secondaryDelegate respondsToSelector:@selector(collectionView:shouldHighlightItemAtIndexPath:)]) {
        return [self.secondaryDelegate collectionView:collectionView shouldHighlightItemAtIndexPath:indexPath];
    }
    return YES;
}
- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.secondaryDelegate respondsToSelector:@selector(collectionView:didHighlightItemAtIndexPath:)]) {
        [self.secondaryDelegate collectionView:collectionView didHighlightItemAtIndexPath:indexPath];
    }
}
- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.secondaryDelegate respondsToSelector:@selector(collectionView:didUnhighlightItemAtIndexPath:)]) {
        [self.secondaryDelegate collectionView:collectionView didUnhighlightItemAtIndexPath:indexPath];
    }
}
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.secondaryDelegate respondsToSelector:@selector(collectionView:shouldSelectItemAtIndexPath:)]) {
        return [self.secondaryDelegate collectionView:collectionView shouldSelectItemAtIndexPath:indexPath];
    }
    return YES;
}
- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.secondaryDelegate respondsToSelector:@selector(collectionView:shouldDeselectItemAtIndexPath:)]) {
        return [self.secondaryDelegate collectionView:collectionView shouldDeselectItemAtIndexPath:indexPath];
    }
    return YES;
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.secondaryDelegate respondsToSelector:@selector(collectionView:didDeselectItemAtIndexPath:)]) {
        [self.secondaryDelegate collectionView:collectionView didDeselectItemAtIndexPath:indexPath];
    }
}
- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.secondaryDelegate respondsToSelector:@selector(collectionView:didEndDisplayingCell:forItemAtIndexPath:)]) {
        [self.secondaryDelegate collectionView:collectionView didEndDisplayingCell:cell forItemAtIndexPath:indexPath];
    }
}
- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingSupplementaryView:(UICollectionReusableView *)view forElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath
{
    if ([self.secondaryDelegate respondsToSelector:@selector(collectionView:didEndDisplayingSupplementaryView:forElementOfKind:atIndexPath:)]) {
        [self.secondaryDelegate collectionView:collectionView didEndDisplayingSupplementaryView:view forElementOfKind:elementKind atIndexPath:indexPath];
    }
}
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.secondaryDelegate respondsToSelector:@selector(collectionView:shouldShowMenuForItemAtIndexPath:)]) {
        return [self.secondaryDelegate collectionView:collectionView shouldShowMenuForItemAtIndexPath:indexPath];
    }
    return NO;
}
- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if ([self.secondaryDelegate respondsToSelector:@selector(collectionView:canPerformAction:forItemAtIndexPath:withSender:)]) {
        return [self.secondaryDelegate collectionView:collectionView canPerformAction:action forItemAtIndexPath:indexPath withSender:sender];
    }
    return NO;
}
- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if ([self.secondaryDelegate respondsToSelector:@selector(collectionView:performAction:forItemAtIndexPath:withSender:)]) {
        [self.secondaryDelegate collectionView:collectionView performAction:action forItemAtIndexPath:indexPath withSender:sender];
    }
}
- (UICollectionViewTransitionLayout *)collectionView:(UICollectionView *)collectionView transitionLayoutForOldLayout:(UICollectionViewLayout *)fromLayout newLayout:(UICollectionViewLayout *)toLayout
{
    if ([self.secondaryDelegate respondsToSelector:@selector(collectionView:transitionLayoutForOldLayout:newLayout:)]) {
        return [self.secondaryDelegate collectionView:collectionView transitionLayoutForOldLayout:fromLayout newLayout:toLayout];
    }
    return [[UICollectionViewTransitionLayout alloc] initWithCurrentLayout:fromLayout
                                                                nextLayout:toLayout];
}

@end
