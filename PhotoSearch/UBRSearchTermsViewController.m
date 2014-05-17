//
//  UBRSearchResultsViewController.m
//  PhotoSearch
//
//  Created by Austin Marusco on 4/26/14.
//  Copyright (c) 2014 Austin Marusco. All rights reserved.
//

#import "UBRSearchTermsViewController.h"
#import "UBRSearchTerm.h"
#import "UBRCoreData.h"

#define BACKGROUND_VIEW_FINAL_ALPHA        0.9
#define BACKGROUND_VIEW_ANIMATION_DURATION 0.3

@interface UBRSearchTermsViewController ()

//views
@property (nonatomic) UITableView *searchResultsTableView;
@property (nonatomic) UIView *backgroundView;

//data
@property (nonatomic) NSArray *searchTerms;
@property (nonatomic) NSString *searchTerm;

@end

@implementation UBRSearchTermsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //init
    self.searchTerms = [NSArray new];
    
    /*
     init background view
     */
    self.backgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.backgroundView.backgroundColor = [UIColor whiteColor];
    self.backgroundView.alpha = 0.0;
    
    /*
     init search results tableview
     */
    self.searchResultsTableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.searchResultsTableView.delegate = self;
    self.searchResultsTableView.dataSource = self;
    self.searchResultsTableView.backgroundColor = [UIColor clearColor];
    self.searchResultsTableView.separatorColor = [UIColor lightGrayColor];
    
    //add subviews
    [self.view addSubview:self.backgroundView];
    [self.view addSubview:self.searchResultsTableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    //set subviews above view
    self.backgroundView.center = CGPointMake(self.view.frame.size.width/2.0,-self.view.frame.size.height/2.0);
    self.searchResultsTableView.center = CGPointMake(self.view.frame.size.width/2.0,-self.view.frame.size.height/2.0);
    
    //animate views on screen
    [UIView animateWithDuration:BACKGROUND_VIEW_ANIMATION_DURATION animations:^{
        self.backgroundView.alpha = BACKGROUND_VIEW_FINAL_ALPHA;
        self.backgroundView.frame = self.view.bounds;
        self.searchResultsTableView.frame = self.view.bounds;
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    //animate views off screen
    [UIView animateWithDuration:BACKGROUND_VIEW_ANIMATION_DURATION animations:^{
        self.backgroundView.alpha = 0.0;
        self.backgroundView.center = CGPointMake(self.view.frame.size.width/2.0,-self.view.frame.size.height/2.0);
        self.searchResultsTableView.center = CGPointMake(self.view.frame.size.width/2.0,-self.view.frame.size.height/2.0);
    }];
}

#pragma mark - tableview
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.searchTerms count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"search_result_cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    //if not allocated, create
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    //set cell properties
    UBRSearchTerm *searchTerm = self.searchTerms[indexPath.row];
    cell.textLabel.text = searchTerm.text;
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor blackColor];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //send message to delegate that search term was selected
    UBRSearchTerm *searchTerm = self.searchTerms[indexPath.row];
    [self.delegate didSelectSearchTerm:searchTerm.text];
}

#pragma mark - search results
/*
 search term updated
 */
- (void)updatedSearchTerm:(NSString *)searchTerm
{
    self.searchTerm = searchTerm;
    UBRCoreData *coreData = [[UBRCoreData alloc] init];
    
    [coreData fetchPreviousSearchTermsWithNewSearchTerm:searchTerm completionBlock:^(NSArray *searchTerms,NSString *searchTerm) {
        
        //if the search term is still the same
        //makes sure that the correct values are updated even w/ asynchronous calls
        if([self.searchTerm isEqualToString:searchTerm]){
            self.searchTerms = searchTerms;
            [self.searchResultsTableView reloadData];
        }
        
    }];

}

@end
