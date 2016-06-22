//
//  PinterestCollectionViewController.m
//  Pinterest-like_Layout
//
//  Created by qee on 2016/6/5.
//  Copyright © 2016年 qee. All rights reserved.
//

#import "PinterestCollectionViewController.h"
#import "PinterestLayout.h"

@interface PinterestCollectionViewController () <PinterestLayoutDelegate>
{
    NSMutableArray *data;
    NSInteger sectionCount;
    NSInteger itemCount;
}
@end

@implementation PinterestCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

- (id)init {
    PinterestLayout *layout = [[PinterestLayout alloc] init];
    return [super initWithCollectionViewLayout:layout];
}

- (void)viewDidLoad {
    [super viewDidLoad];
   
    // Register cell classes
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    // Set layout delegate
    ((PinterestLayout *)self.collectionViewLayout).sizeDelegate = self;
    
    // Set data
    sectionCount = 2;
    itemCount = 5;
    srand(time(0));
    data = [NSMutableArray arrayWithCapacity:sectionCount];
    
    for (NSInteger section = 0; section < sectionCount; section++) {
        NSMutableArray *sectionData = [NSMutableArray arrayWithCapacity:itemCount];
        
        for (NSInteger idx = 0; idx < itemCount; idx++) {
            UIColor *itemColor = [UIColor colorWithRed:((CGFloat)rand() / RAND_MAX) green:((CGFloat)rand() / RAND_MAX) blue:((CGFloat)rand() / RAND_MAX) alpha:1.0];
            CGSize itemSize = CGSizeMake(((CGFloat)rand() / RAND_MAX) * 200 + 50, ((CGFloat)rand() / RAND_MAX) * 200 + 50);
            NSDictionary *item = @{ @"color" : itemColor,
                                    @"size" : [NSValue valueWithCGSize:itemSize] };
            [sectionData addObject:item];
        }
        
        [data addObject:sectionData];
    }
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return data.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return ((NSArray *)data[section]).count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell
    cell.backgroundColor = data[indexPath.section][indexPath.item][@"color"];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [data[indexPath.section][indexPath.item][@"size"] CGSizeValue];
}

@end
