//
//  UBRSearchResultsViewController.h
//  PhotoSearch
//
//  Created by Austin Marusco on 4/26/14.
//  Copyright (c) 2014 Austin Marusco. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UBRSearchTermsViewControllerDelegate <NSObject>

@required
- (void)didSelectSearchTerm:(NSString *)searchTerm;

@end

@interface UBRSearchTermsViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,weak) NSObject <UBRSearchTermsViewControllerDelegate> *delegate;

/*
 search term updated
 */
- (void)updatedSearchTerm:(NSString *)searchTerm;

@end
