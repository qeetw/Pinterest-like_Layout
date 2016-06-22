//
//  PinterestLayout.m
//  Pinterest-like_Layout
//
//  Created by qee on 2016/6/5.
//  Copyright © 2016年 qee. All rights reserved.
//

#import "PinterestLayout.h"

@interface PinterestLayout ()
@property (nonatomic, strong) NSMutableArray *sectionColumnHeights;
@property (nonatomic, strong) NSMutableArray *sectionItemAttributes;
@end


@implementation PinterestLayout

#pragma mark - Accessors

- (NSMutableArray *)sectionColumnHeights {
    if (!_sectionColumnHeights) {
        _sectionColumnHeights = [[NSMutableArray alloc] init];
    }
    return _sectionColumnHeights;
}

- (NSMutableArray *)sectionItemAttributes {
    if (!_sectionItemAttributes) {
        _sectionItemAttributes = [[NSMutableArray alloc] init];
    }
    return _sectionItemAttributes;
}

#pragma mark - Init

- (void)defaultInit {
    _columnCount = 2;
    _minimumColumnSpacing = 10;
    _minimumInteritemSpacing = 10;
    _sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    _itemRenderDirection = PinterestLayoutRenderDirectionShortestFirst;
}

- (id)init {
    if (self = [super init]) {
        [self defaultInit];
    }
    return self;
}

#pragma mark - Methods to Override

- (void)prepareLayout {
    [super prepareLayout];
    
    [self.sectionColumnHeights removeAllObjects];
    [self.sectionItemAttributes removeAllObjects];
    
    UIEdgeInsets sectionInset = self.sectionInset;
    CGFloat columnSpacing = self.minimumColumnSpacing;
    CGFloat width = self.collectionView.bounds.size.width - sectionInset.left - sectionInset.right;
    NSInteger columnCount = self.columnCount;
    CGFloat itemWidth = floor((width - (columnCount - 1) * columnSpacing) / columnCount);
    
    NSInteger numberOfSections = [self.collectionView numberOfSections];
    for (NSInteger section = 0; section < numberOfSections; section++) {
        NSMutableArray *columnHeights = [NSMutableArray arrayWithCapacity:columnCount];
        for (NSInteger idx = 0; idx < columnCount; idx++) {
            [columnHeights addObject:@(0)];
        }
        
        [self.sectionColumnHeights addObject:columnHeights];
    }
    
    CGFloat top = 0;
    UICollectionViewLayoutAttributes *attributes;
    
    for (NSInteger section = 0; section < numberOfSections; section++) {
        NSInteger itemCount = [self.collectionView numberOfItemsInSection:section];
        NSMutableArray *itemAttributes = [NSMutableArray arrayWithCapacity:itemCount];
        
        top += sectionInset.top;
        for (NSInteger idx = 0; idx < columnCount; idx++) {
            self.sectionColumnHeights[section][idx] = @(top);
        }
        
        for (NSInteger idx = 0; idx < itemCount; idx++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:idx inSection:section];
            NSUInteger columnIndex = [self nextColumnIndexForItem:idx inSection:section];
            CGFloat xOffset = sectionInset.left + (itemWidth + columnSpacing) * columnIndex;
            CGFloat yOffset = [self.sectionColumnHeights[section][columnIndex] floatValue];
            CGSize itemSize = [self.sizeDelegate collectionView:self.collectionView layout:self sizeForItemAtIndexPath:indexPath];
            CGFloat itemHeight = 0;
            if (itemSize.height > 0 && itemSize.width > 0) {
                itemHeight = floor(itemSize.height * itemWidth / itemSize.width);
            }
            
            attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            attributes.frame = CGRectMake(xOffset, yOffset, itemWidth, itemHeight);
            [itemAttributes addObject:attributes];
            
            self.sectionColumnHeights[section][columnIndex] = @(CGRectGetMaxY(attributes.frame) + self.minimumInteritemSpacing);
        }
        
        [self.sectionItemAttributes addObject:itemAttributes];
        
        NSUInteger columnIndex = [self longestColumnIndexInSection:section];
        top = [self.sectionColumnHeights[section][columnIndex] floatValue] - self.minimumInteritemSpacing + sectionInset.bottom;
    }
}

- (CGSize)collectionViewContentSize {
    NSInteger numberOfSections = [self.collectionView numberOfSections];
    if (numberOfSections == 0) {
        return CGSizeZero;
    }
    
    CGSize contentSize = self.collectionView.bounds.size;
 
    CGFloat contentHeight = 0;
    NSInteger columnCount = self.columnCount;
    for (NSInteger idx = 0; idx < columnCount; idx++) {
        CGFloat height = [[[self.sectionColumnHeights lastObject] objectAtIndex:idx] floatValue];
        if (height > contentHeight) {
            contentHeight = height;
        }
    }
    contentSize.height = contentHeight;
    
    return contentSize;
}

- (NSArray<UICollectionViewLayoutAttributes *> *) layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *attrs = [NSMutableArray array];
    
    NSInteger numberOfSections = [self.collectionView numberOfSections];
    for (NSInteger section = 0; section < numberOfSections; section++) {
        NSInteger itemCount = [self.collectionView numberOfItemsInSection:section];
        for (NSInteger idx = 0; idx < itemCount; idx++) {
            UICollectionViewLayoutAttributes *attr = self.sectionItemAttributes[section][idx];
            CGRect itemRect = attr.frame;
            if (CGRectIntersectsRect(rect, itemRect)) {
                [attrs addObject:attr];
            }
        }
    }

    return [NSArray arrayWithArray:attrs];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.sectionItemAttributes[indexPath.section][indexPath.item];
}

#pragma mark - Private Methods

- (NSUInteger)nextColumnIndexForItem:(NSInteger)item inSection:(NSInteger)section {
    NSUInteger index = 0;
    NSInteger columnCount = self.columnCount;
    
    switch (self.itemRenderDirection) {
        case PinterestLayoutRenderDirectionShortestFirst:
            index = [self shortestColumnIndexInSection:section];
            break;
            
        case PinterestLayoutRenderDirectionLeftToRight:
            index = (item % columnCount);
            break;
            
        case PinterestLayoutRenderDirectionRightToLeft:
            index = (columnCount - 1) - (item % columnCount);
            break;
            
        default:
            index = [self shortestColumnIndexInSection:section];
            break;
    }
    
    return index;
}

- (NSUInteger)shortestColumnIndexInSection:(NSInteger)section {
    NSInteger index = 0;
    CGFloat shortestHeight = MAXFLOAT;
    
    NSInteger columnCount = self.columnCount;
    for (NSInteger idx = 0; idx < columnCount; idx++) {
        CGFloat height = [self.sectionColumnHeights[section][idx] floatValue];
        if (height < shortestHeight) {
            shortestHeight = height;
            index = idx;
        }
    }
    
    return index;
}

- (NSUInteger)longestColumnIndexInSection:(NSInteger)section {
    NSUInteger index = 0;
    CGFloat longestHeight = 0;

    NSInteger columnCount = self.columnCount;
    for (NSInteger idx = 0; idx < columnCount; idx++) {
        CGFloat height = [self.sectionColumnHeights[section][idx] floatValue];
        if (height > longestHeight) {
            longestHeight = height;
            index = idx;
        }
    }
    
    return index;
}

@end
