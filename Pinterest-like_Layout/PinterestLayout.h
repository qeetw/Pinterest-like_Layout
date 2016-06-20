//
//  PinterestLayout.h
//  Pinterest-like_Layout
//
//  Created by qee on 2016/6/5.
//  Copyright © 2016年 qee. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol PinterestLayoutDelegate
@required
//  ask item size for prepareLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath;
@end


@interface PinterestLayout : UICollectionViewLayout

typedef NS_ENUM(NSUInteger, PinterestLayoutRenderDirection) {
    PinterestLayoutRenderDirectionShortestFirst,
    PinterestLayoutRenderDirectionLeftToRight,
    PinterestLayoutRenderDirectionRightToLeft
};

@property (nonatomic, assign) NSUInteger columnCount;
@property (nonatomic, assign) CGFloat minimumColumnSpacing;
@property (nonatomic, assign) CGFloat minimumInteritemSpacing;
@property (nonatomic, assign) UIEdgeInsets sectionInset;
@property (nonatomic, assign) PinterestLayoutRenderDirection itemRenderDirection;
@property (nonatomic, weak) id<PinterestLayoutDelegate> delegate;

@end
