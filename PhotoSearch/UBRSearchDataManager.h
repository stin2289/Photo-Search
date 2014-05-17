//
//  UBRDataManager.h
//  PhotoSearch
//
//  Created by Austin Marusco on 4/26/14.
//  Copyright (c) 2014 Austin Marusco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UBRPhotoMetaData.h"

@interface UBRSearchDataManager : NSObject

#define DEFAULT_MAX_RESULTS 8

+ (UBRSearchDataManager *)sharedInstance;

@property (nonatomic) NSString *query;
@property (nonatomic,getter = isLoadingSearchQuery) BOOL loadingSearchQuery;

/*
 returns search results stored in core data
 */
- (void)getSearchResultsWithCompletionBlock:(void(^)(NSArray *items,BOOL success,NSString *error))completionBlock;

/*
 returns search results with search term and page stored in core data
 */
- (void)getSearchResultsWithSearchTerm:(NSString *)searchTerm
                                  page:(NSInteger)page
                       completionBlock:(void(^)(NSArray *items,BOOL success,NSString *error))completionBlock;

/*
 returns search results with search term and domain stored in core data
 */
- (void)getSearchResultsWithSearchTerm:(NSString *)searchTerm
                                domain:(UBRSearchDataManagerDomain)domain
                                  page:(NSInteger)page
                            maxResults:(NSInteger)maxResults
                       completionBlock:(void(^)(NSArray *items,BOOL success,NSString *error))completionBlock;

@end
