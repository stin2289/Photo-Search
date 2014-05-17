//
//  UBRSearchPhotosViewController.h
//  PhotoSearch
//
//  Created by Austin Marusco on 4/26/14.
//  Copyright (c) 2014 Austin Marusco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UBRSearchTermsViewController.h"

@interface UBRSearchCollectionViewController : UIViewController <UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UISearchBarDelegate,UBRSearchTermsViewControllerDelegate>

//items
@property (nonatomic) UICollectionView *itemCollectionView;
@property (nonatomic) NSMutableArray *items;
@property (nonatomic, getter = isLoadingItems) BOOL loadingItems;

//search
@property (nonatomic) NSString *searchTerm;
@property (nonatomic) UISearchBar *searchBar;

//scrollview
@property (nonatomic) CGFloat lastScrollViewContentOffsetY;
@property (nonatomic) CGFloat infiniteScrollBuffer;

/*
 new search query
 */
- (void)newSearchQueryWithCompletion:(void(^)())completion;

/*
 load next page of items
 */
- (void)loadNextPageWithCompletion:(void(^)())completion;

@end
