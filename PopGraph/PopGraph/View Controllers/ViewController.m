//
//  ViewController.m
//  CircularAnimatedLayout
//
//  Created by Cillian on 29/03/2014.
//  Copyright (c) 2014 Cillian. All rights reserved.
//

#import "CHCollectionViewGraphLayout.h"
#import "ViewController.h"
#import "CollectionViewCell.h"
#import "Math.h"
#import "UIView+Custom.h"
#import "GraphItem.h"
#import "NSArray+Extended.h"
#import "UIColor+Extended.h"
#import "SelectedAreaViewController.h"
#import "LoremIpsum.h"

static NSString *kCellIdentifier = @"UICollectionViewCell";

@interface ViewController ()

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) CHCollectionViewGraphLayout *collectionViewLayout;
@property (nonatomic, strong) SelectedAreaViewController *selectedArea;

@end

@implementation ViewController {
    NSArray *collectionData;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setup];
}

- (void)setup {
    
    [self setupData];
    self.collectionViewLayout = [CHCollectionViewGraphLayout new];
    [self updateDataWithArray:collectionData];
    [self.collectionView setCollectionViewLayout:self.collectionViewLayout];
    
    GraphItem *item = [collectionData objectAtIndex:0];
    [self.selectedArea setDataForItem:item atPoint:CGPointZero];
}

- (void)setupData {
    
    NSMutableArray *array = [NSMutableArray array];
    NSInteger count = 5;
    
    while (count > 0) {
        GraphItem *item = [[GraphItem alloc] initWithValue:arc4random()%50 andColor:[UIColor random]];
        [array addObject:item];
        count--;
    }
    
    [self updateDataWithArray:array];
}

- (void)updateDataWithArray:(NSArray *)array {
    collectionData = [NSArray arrayWithArray:array];
    self.collectionViewLayout.collectionData = collectionData;
}

- (IBAction)button:(id)sender {
    if (collectionData.count > 0) {
        [self.collectionView performBatchUpdates:^{
            NSArray *indexPaths = [NSArray arrayWithArray:[collectionData indexPaths]];
            [self.collectionView deleteItemsAtIndexPaths:indexPaths];
            [self updateDataWithArray:[NSArray array]];
        } completion:^(BOOL finished) {
            [self.selectedArea hide];
        }];
    }
    else {
        [self.collectionView performBatchUpdates:^{
            [self setupData];
            NSArray *indexPaths = [NSArray arrayWithArray:[collectionData indexPaths]];
            [self.collectionView insertItemsAtIndexPaths:indexPaths];
        } completion:^(BOOL finished) {
            [self.selectedArea show];
            [self selectItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
            
        }];
    }
}

- (void)selectItemAtIndexPath:(NSIndexPath *)indexPath {
    GraphItem *item = [collectionData objectAtIndex:indexPath.row];
    
    CollectionViewCell *cell = (CollectionViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    
    CGRect cellRect = [self.collectionView convertRect:cell.frame toView:self.view];
    [self.selectedArea setDataForItem:item atPoint:cellRect.origin];
}

#pragma mark - UICollectionView setup

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier forIndexPath:indexPath];
    GraphItem *item = [collectionData objectAtIndex:indexPath.row];
    [cell setData:item];
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [collectionData count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

#pragma mark - UICollectionView interactions

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    GraphItem *item = [collectionData objectAtIndex:indexPath.row];
    
    CollectionViewCell *cell = (CollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    CGRect cellRect = [collectionView convertRect:cell.frame toView:self.view];
    [self.selectedArea setDataForItem:item atPoint:cellRect.origin];
    [cell popDownThenUp];
}

#pragma mark - segue stuff

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"SelectedAreaContainerSegue"]) {
        self.selectedArea = segue.destinationViewController;
    }
}

@end
