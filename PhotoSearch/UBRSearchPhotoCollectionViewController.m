//
//  UBRSearchPhotoViewController.m
//  PhotoSearch
//
//  Created by Austin Marusco on 4/26/14.
//  Copyright (c) 2014 Austin Marusco. All rights reserved.
//

#import "UBRSearchPhotoCollectionViewController.h"
#import "UBRSearchDataManager.h"
#import "UBRSearchPhotoCollectionViewCell.h"

#define NUMBER_OF_COLUMNS 3

#define MINIMUM_INTERIM_LINE_SPACING 0.0

#define COLLECTION_VIEW_CELL_WIDTH          (self.itemCollectionView.frame.size.width/NUMBER_OF_COLUMNS)
#define COLLECTION_VIEW_CELL_HEIGHT         COLLECTION_VIEW_CELL_WIDTH

@interface UBRSearchPhotoCollectionViewController ()

@end

@implementation UBRSearchPhotoCollectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    /*
     set itemCollectionView cell class
     */
    static NSString *cellIdentifier = @"photo_cell";
    [self.itemCollectionView registerClass:[UBRSearchPhotoCollectionViewCell class] forCellWithReuseIdentifier:cellIdentifier];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - collection view
/*
 cell returned at indexPath
 */
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"photo_cell";

    UBRSearchPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    UBRPhotoMetaData *photoMetaData = self.items[indexPath.row];
    
    [cell.imageView setImageWithURL:photoMetaData.thumbnailPhotoURL
                   placeholderImage:nil];
    
    return cell;
}

/*
 size for collection view cell
 */
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(COLLECTION_VIEW_CELL_WIDTH, COLLECTION_VIEW_CELL_HEIGHT);
}

/*
 minimum spacing
 */
-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return MINIMUM_INTERIM_LINE_SPACING;
}

#pragma mark - data accessors/helpers
/*
 new search query
 */
- (void)newSearchQueryWithCompletion:(void(^)())completion
{
    [[UBRSearchDataManager sharedInstance] getSearchResultsWithSearchTerm:self.searchTerm
                                                                     page:0
                                                          completionBlock:^(NSArray *items,BOOL success,NSString *error) {
                                                              
      if(success){
          
          self.items = [items mutableCopy];
          
          //if items returned the full page amount, load next page
          if([items count] == DEFAULT_MAX_RESULTS){
          
              //load next page of items
              [self loadNextPageWithCompletion:^{
                  //to-do
                  completion();
              }];
              
          }
          else{
              //reload data from item collection view
              [self.itemCollectionView reloadData];
          }
          
      }
      else{
          completion();
      }
      
    }];
}

/*
 load next page of items
 */
- (void)loadNextPageWithCompletion:(void(^)())completion
{
    int currentPage = (int)[self.items count] / DEFAULT_MAX_RESULTS;
    
    [[UBRSearchDataManager sharedInstance] getSearchResultsWithSearchTerm:self.searchTerm
                                                                     page:currentPage
                                                          completionBlock:^(NSArray *items,BOOL success,NSString *error) {
                                                              
                                                              if(success){
                                                                  
                                                                  //add objects to array and reload data
                                                                  [self.items addObjectsFromArray:items];
                                                                  
                                                              }
                                                              
                                                              [self.itemCollectionView reloadData];
                            
                                                              completion();
                                                              
                                                          }];
}

/*
 is the collection view loading new items
 */
- (BOOL)isLoadingItems
{
    return [[UBRSearchDataManager sharedInstance] isLoadingSearchQuery];
}

@end
