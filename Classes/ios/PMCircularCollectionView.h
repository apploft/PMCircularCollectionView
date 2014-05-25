//
//  PMCircularCollectionView.h
//  
//
//  Created by Peter Meyers on 3/19/14.
//
//

#import <UIKit/UIKit.h>

@protocol PMCircularCollectionViewDataSource;

@interface PMCircularCollectionView : UICollectionView <UICollectionViewDelegateFlowLayout>

@property (nonatomic) CGFloat shadowRadius;
@property (nonatomic, strong) UIColor *shadowColor;
@property (nonatomic, strong) UICollectionViewFlowLayout *collectionViewLayout;

// Overwrite type of delegate and datasource
- (void) setDelegate:(id<UICollectionViewDelegate>)delegate;
- (void) setDataSource:(id<PMCircularCollectionViewDataSource>)dataSource;

// delegate methods all say what index path was selected but we've multiplied the items in the row by a multiplier to allow the circular scroll. Feed that index path to this method to get the correct index.
- (NSUInteger) normalizedIndexFromIndexPath:(NSIndexPath *)indexPath;

- (instancetype) initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewFlowLayout *)layout;
+ (instancetype) collectionViewWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewFlowLayout *)layout;
+ (instancetype) collectionView;

@end

@protocol PMCircularCollectionViewDataSource <NSObject>

@required
- (NSString *) circularCollectionView:(PMCircularCollectionView *)collectionView reuseIdentifierForIndex:(NSUInteger)index;
- (NSUInteger) numberOfItemsInCircularCollectionView:(PMCircularCollectionView *)collectionView;
- (void) circularCollectionView:(PMCircularCollectionView *)collectionView configureCell:(UICollectionViewCell *)cell atIndex:(NSUInteger)index;

@end
