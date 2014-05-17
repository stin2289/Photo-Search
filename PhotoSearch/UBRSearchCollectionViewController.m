//
//  UBRSearchPhotosViewController.m
//  PhotoSearch
//
//  Created by Austin Marusco on 4/26/14.
//  Copyright (c) 2014 Austin Marusco. All rights reserved.
//

#import "UBRSearchCollectionViewController.h"
#import "UBRSearchTermsViewController.h"
#import "UBRCoreData.h"

#define DEFAULT_SEARCH_TEXT              @"search..."
#define DEFAULT_INFINITE_SCROLL_BUFFER_Y 40.0
#define ACTIVITY_INDICATOR_BUFFER_Y      40.0

@interface UBRSearchCollectionViewController ()

@property (nonatomic) UBRSearchTermsViewController *searchTermsViewController;
@property (nonatomic) UIActivityIndicatorView *activityIndicator;

@end

@implementation UBRSearchCollectionViewController

- (UBRSearchCollectionViewController *)init
{
    self = [super init];
    
    if(self){
        //init default variables
        _searchTerm = DEFAULT_SEARCH_TEXT;
        _lastScrollViewContentOffsetY = 0.0;
        _infiniteScrollBuffer = DEFAULT_INFINITE_SCROLL_BUFFER_Y;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //init
    self.items = [NSMutableArray new];
    
    /*
     create item collection view
     */
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    self.itemCollectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    self.itemCollectionView.delegate = self;
    self.itemCollectionView.dataSource = self;
    self.itemCollectionView.backgroundColor = [UIColor whiteColor];
    
    /*
     create search bar
     */
    self.searchBar = [[UISearchBar alloc] initWithFrame:self.navigationController.navigationBar.bounds];
    self.searchBar.delegate = self;
    self.searchBar.placeholder = DEFAULT_SEARCH_TEXT;
    //start activity indicators
    [self startNewSearchQueryActivityIndicator];
    [self newSearchQueryWithCompletion:^{
        //stop activiy indicator
        [self stopNewSearchQueryActivityIndicator];
    }];
    
    /*
     create search terms view controller
     */
    self.searchTermsViewController = [[UBRSearchTermsViewController alloc] init];
    self.searchTermsViewController.delegate = self;
    
    //add subviews
    [self.view addSubview:self.itemCollectionView];
    [self.navigationController.navigationBar addSubview:self.searchBar];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - collection view
// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    [NSException raise:NSInternalInconsistencyException
                format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
    
    return nil;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.items count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

#pragma mark - infinite scroll
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    //calculate offsets
    BOOL isScrollingDown = (scrollView.contentOffset.y - self.lastScrollViewContentOffsetY > 0.0);
    self.lastScrollViewContentOffsetY = scrollView.contentOffset.y;
    CGFloat offset = scrollView.contentSize.height - scrollView.contentOffset.y - scrollView.frame.size.height;
    
    //scrolling down, not loading items, and past buffer
    if (![self isLoadingItems] && offset < self.infiniteScrollBuffer && isScrollingDown)
    {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        [self loadNextPageWithCompletion:^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }];
    }
    
}

/*
 load next page of items
 */
- (void)loadNextPageWithCompletion:(void(^)())completion
{
    [NSException raise:NSInternalInconsistencyException
                format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
}

#pragma mark - search
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    //set search properties
    [self.searchBar setShowsCancelButton:YES animated:YES];
    self.searchTerm = searchBar.text;
    
    //add search terms view controller
    [self addChildViewController:self.searchTermsViewController];
    self.searchTermsViewController.view.frame = CGRectMake(0,
                                                           self.navigationController.navigationBar.frame.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height,
                                                           self.view.frame.size.width,
                                                           self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height - KEYBOARD_HEIGHT - [[UIApplication sharedApplication] statusBarFrame].size.height);
    [self.view addSubview:self.searchTermsViewController.view];
    [self.searchTermsViewController updatedSearchTerm:self.searchTerm];
}
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    //set search properties
    [self.searchBar setShowsCancelButton:NO animated:YES];
    self.searchTerm = self.searchBar.text;
    
    //remove search terms view controller
    [self.searchTermsViewController.view removeFromSuperview];
    [self.searchTermsViewController removeFromParentViewController];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    //set search properties
    NSString *previousSearchQuery = self.searchTerm;
    [self.searchBar resignFirstResponder];
    self.searchTerm = searchBar.text;
    
    //save search term to database
    UBRCoreData *coreData = [[UBRCoreData alloc] init];
    [coreData saveSearchTerm:self.searchTerm];
    
    //if the search bar text is not equal to the previous text
    if(![self.searchTerm isEqualToString:previousSearchQuery]){
        
        //remove all items
        [self.items removeAllObjects];
        [self.itemCollectionView reloadData];
        
        //set activity indicators
        [self startNewSearchQueryActivityIndicator];
        
        [self newSearchQueryWithCompletion:^{
            //stop activiy indicator
            [self stopNewSearchQueryActivityIndicator];
        }];
    }

}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    //set search properties
    [self.searchBar resignFirstResponder];
    self.searchTerm = self.searchBar.text;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    //update search text after each button press
    [self.searchTermsViewController updatedSearchTerm:[searchText lowercaseString]];
}

#pragma mark - search collection view delegate
- (void)didSelectSearchTerm:(NSString *)searchTerm
{
    //hide search bar
    [self.searchBar resignFirstResponder];
    
    //set new search term
    self.searchTerm = searchTerm;
    self.searchBar.text = searchTerm;
    
    //save search term to database
    UBRCoreData *coreData = [[UBRCoreData alloc] init];
    [coreData saveSearchTerm:self.searchTerm];
    
    //remove all items
    [self.items removeAllObjects];
    [self.itemCollectionView reloadData];
    
    //set activity indicator
    [self startNewSearchQueryActivityIndicator];
    
    //new search
    [self newSearchQueryWithCompletion:^{
        //stop activiy indicator
        [self stopNewSearchQueryActivityIndicator];
    }];
}

#pragma mark - data accessors/helpers
/*
 new search query
 */
- (void)newSearchQueryWithCompletion:(void(^)())completion
{
    [NSException raise:NSInternalInconsistencyException
                format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
}

/*
 is the collection view loading new items
 */
- (BOOL)isLoadingItemsWithCompletion:(void(^)())completion
{
    [NSException raise:NSInternalInconsistencyException
                format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
    
    return NO;
}

/*
 return lowercase version of search term string
 */
- (NSString *)searchTerm
{
    return [_searchTerm lowercaseString];
}

#pragma mark - activity indicator
/*
 start new search query activity indicators
 */
- (void)startNewSearchQueryActivityIndicator
{
    //set activity indicators
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicator.frame = CGRectMake(self.itemCollectionView.frame.size.width/2.0 - self.activityIndicator.frame.size.width/2.0,
                                              ACTIVITY_INDICATOR_BUFFER_Y,
                                              self.activityIndicator.frame.size.width,
                                              self.activityIndicator.frame.size.height);
    [self.activityIndicator startAnimating];
    [self.itemCollectionView addSubview:self.activityIndicator];
}

/*
 stop new search query activity indicators
 */
- (void)stopNewSearchQueryActivityIndicator
{
    //remove activity indicators
    [self.activityIndicator stopAnimating];
    [self.activityIndicator removeFromSuperview];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

@end
