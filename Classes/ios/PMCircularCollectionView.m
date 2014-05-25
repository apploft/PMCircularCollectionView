//
//  PMCircularCollectionView.m
//  
//
//  Created by Peter Meyers on 3/19/14.
//
//

#import "PMCircularCollectionView.h"
#import "PMUtils.h"

static NSUInteger const ContentMultiplier = 4;

@interface PMCircularCollectionView () <UICollectionViewDataSource>

@property (nonatomic, strong) CAGradientLayer *shadowLayer;
@property (nonatomic, strong) PMProtocolInterceptor *delegateInterceptor;
@property (nonatomic, strong) PMProtocolInterceptor *dataSourceInterceptor;
@property (nonatomic) NSInteger itemCount;
@property (nonatomic) CGFloat addedPadding;

@end


@implementation PMCircularCollectionView


+ (instancetype) collectionViewWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewFlowLayout *)layout
{
    return [[self alloc] initWithFrame:frame collectionViewLayout:layout];
}

+ (instancetype) collectionView
{
    return [[self alloc] init];
}

- (instancetype) init
{
    return [self initWithFrame:CGRectZero];
}

- (instancetype) initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame collectionViewLayout:[UICollectionViewFlowLayout new]];
}

- (instancetype) initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewFlowLayout *)layout
{
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        [self commonCircularCollectionViewInit];
    }
    return self;
}

- (instancetype) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonCircularCollectionViewInit];
    }
    return self;
}

- (void) commonCircularCollectionViewInit;
{
    NSSet *delegateProtocols = [NSSet setWithObjects:
                                @protocol(UICollectionViewDelegate),
                                @protocol(UIScrollViewDelegate),
                                @protocol(UICollectionViewDelegateFlowLayout), nil];
    
    self.delegateInterceptor = [PMProtocolInterceptor interceptorWithMiddleMan:self forProtocols:delegateProtocols];
    [super setDelegate:(id)self.delegateInterceptor];
    
    self.dataSourceInterceptor = [PMProtocolInterceptor interceptorWithMiddleMan:self
                                                                     forProtocol:@protocol(UICollectionViewDataSource)];
    [super setDataSource:(id)self.dataSourceInterceptor];
    
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
}

- (void)setDataSource:(id<PMCircularCollectionViewDataSource>)dataSource
{
    [super setDataSource:nil];
    self.dataSourceInterceptor.receiver = dataSource;
    [super setDataSource:(id)self.dataSourceInterceptor];
}

- (void)setDelegate:(id<UICollectionViewDelegateFlowLayout>)delegate
{
    [super setDelegate:nil];
    self.delegateInterceptor.receiver = delegate;
    [super setDelegate:(id)self.delegateInterceptor];
}

- (void) setShadowRadius:(CGFloat)shadowRadius
{
    if (_shadowRadius != shadowRadius) {
        _shadowRadius = shadowRadius;
        [self resetShadowLayer];
    }
}

- (void) setShadowColor:(UIColor *)shadowColor
{
    if (![_shadowColor isEqual:shadowColor]) {
        _shadowColor = shadowColor;
        [self resetShadowLayer];
    }
}

- (void) resetShadowLayer
{
    [self.shadowLayer removeFromSuperlayer];
    self.shadowLayer = nil;
    
    if (self.shadowRadius && self.shadowColor.alpha) {
        
        UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout*)self.collectionViewLayout;
        
        UIColor *outerColor = self.shadowColor;
        UIColor *innerColor = [self.shadowColor colorWithAlphaComponent:0.0];
        
        self.shadowLayer = [CAGradientLayer layer];
        self.shadowLayer.frame = self.bounds;
        self.shadowLayer.colors = @[(id)outerColor.CGColor, (id)innerColor.CGColor, (id)innerColor.CGColor, (id)outerColor.CGColor];
        self.shadowLayer.anchorPoint = CGPointZero;
        
        CGFloat totalDistance;
        switch (layout.scrollDirection) {
                
            case UICollectionViewScrollDirectionHorizontal:
                totalDistance = self.bounds.size.width;
                self.shadowLayer.startPoint = CGPointMake(0.0f, 0.5f);
                self.shadowLayer.endPoint = CGPointMake(1.0f, 0.5f);
                break;
                
            case UICollectionViewScrollDirectionVertical:
                totalDistance = self.bounds.size.height;
                self.shadowLayer.startPoint = CGPointMake(0.5f, 0.0f);
                self.shadowLayer.endPoint = CGPointMake(0.5f, 1.0f);
                break;
        }
        
        CGFloat location1 = self.shadowRadius / totalDistance;
        CGFloat location2 = 1.0f - location1;
        self.shadowLayer.locations = @[@0.0, @(location1), @(location2), @1.0];
        
        [self.layer addSublayer:self.shadowLayer];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.scrollEnabled) {
        [self recenterIfNecessary];
    }
}

- (void) recenterIfNecessary
{
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionViewLayout;
    CGPoint currentOffset = self.contentOffset;
    
    switch (layout.scrollDirection) {
            
        case UICollectionViewScrollDirectionHorizontal: {

            CGFloat contentCenteredX = (self.contentSize.width - self.bounds.size.width) / 2.0f;
            CGFloat deltaFromCenter = currentOffset.x - contentCenteredX;
            CGFloat singleContentWidth = self.contentSize.width / ContentMultiplier;

            if (fabsf(deltaFromCenter) >= singleContentWidth ) {
                
                CGFloat correction = (deltaFromCenter > 0)? deltaFromCenter - singleContentWidth : deltaFromCenter + singleContentWidth;
                
                currentOffset.x = contentCenteredX + correction;
            }
            break;
        }
        case UICollectionViewScrollDirectionVertical: {
            
            CGFloat contentCenteredY = (self.contentSize.height - self.bounds.size.height) / 2.0f;
            CGFloat deltaFromCenter = currentOffset.y - contentCenteredY;
            CGFloat singleContentHeight = self.contentSize.height / ContentMultiplier;
            
            if (fabsf(deltaFromCenter) >= singleContentHeight) {
                
                CGFloat correction = (deltaFromCenter > 0)? deltaFromCenter - singleContentHeight : deltaFromCenter + singleContentHeight;
                
                currentOffset.y = contentCenteredY + correction;
            }
            break;
        }
    }
    
    self.contentOffset = currentOffset;
}


- (NSUInteger) normalizedIndexFromIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.item % self.itemCount;
}

#pragma mark - UICollectionViewDatasource Methods


- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    self.itemCount = [self.dataSourceInterceptor.receiver numberOfItemsInCircularCollectionView:self];
    
    CGSize contentSize = CGSizeZero;
    for (NSUInteger i = 0; i < self.itemCount; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        CGSize itemSize = [self collectionView:collectionView layout:collectionView.collectionViewLayout sizeForItemAtIndexPath:indexPath];
        contentSize.height += itemSize.height;
        contentSize.width += itemSize.width;
    }
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)collectionView.collectionViewLayout;
    switch (layout.scrollDirection)
    {
        case UICollectionViewScrollDirectionHorizontal:
            collectionView.scrollEnabled = contentSize.width >= collectionView.bounds.size.width;
            break;
        case UICollectionViewScrollDirectionVertical:
            collectionView.scrollEnabled = contentSize.height >= collectionView.bounds.size.height;
            break;
    }
    
    self.shadowLayer.hidden = !collectionView.scrollEnabled;
    return collectionView.scrollEnabled? self.itemCount * ContentMultiplier : self.itemCount;
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger normalizedIndex = [self normalizedIndexFromIndexPath:indexPath];
    NSString *reuseIdentifier = [self.dataSourceInterceptor.receiver circularCollectionView:self reuseIdentifierForIndex:normalizedIndex];
    UICollectionViewCell *cell = [self dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    [self.dataSourceInterceptor.receiver circularCollectionView:self configureCell:cell atIndex:normalizedIndex];
    return cell;
}


#pragma mark - UICollectionViewDelegateFlowLayout Methods

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegateInterceptor.receiver respondsToSelector:@selector(collectionView:layout:sizeForItemAtIndexPath:)]) {
        return [self.delegateInterceptor.receiver collectionView:collectionView layout:collectionViewLayout sizeForItemAtIndexPath:indexPath];
    }
    return collectionViewLayout.itemSize;
}

#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.shadowRadius) {
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        self.shadowLayer.position = scrollView.contentOffset;
        [CATransaction commit];
    }
    
    if ([self.delegateInterceptor.receiver respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [self.delegateInterceptor.receiver scrollViewDidScroll:scrollView];
    }
}

@end
