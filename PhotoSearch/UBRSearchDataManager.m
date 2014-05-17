//
//  UBRDataManager.m
//  PhotoSearch
//
//  Created by Austin Marusco on 4/26/14.
//  Copyright (c) 2014 Austin Marusco. All rights reserved.
//

#import "UBRSearchDataManager.h"
#import "AFHTTPRequestOperationManager.h"
#import "NSString+InternetQueries.h"
#import "UBRPhotoMetaData.h"

#define DEFAULT_PAGE        0

#define GOOGLE_QUERY_DOMAIN  @"https://ajax.googleapis.com/ajax/services/search/images"
#define GOOGLE_QUERY_VERSION @"1.0"

@interface UBRSearchDataManager ()

@property (nonatomic) AFHTTPRequestOperationManager *requestManager;

@end

@implementation UBRSearchDataManager

+ (UBRSearchDataManager *)sharedInstance
{
    static UBRSearchDataManager *instance;
    
    if(!instance)
    {
        instance = [[UBRSearchDataManager alloc] init];
        instance.requestManager = [AFHTTPRequestOperationManager manager];
        instance.loadingSearchQuery = NO;
    }
    
    return instance;
}

#pragma mark - get search results
/*
 returns search results stored in core data
 */
- (void)getSearchResultsWithCompletionBlock:(void(^)(NSArray *items,BOOL success,NSString *error))completionBlock
{
    [self getSearchResultsWithSearchTerm:@""
                                  domain:UBRSearchDataManagerDomainDefault
                                    page:DEFAULT_PAGE
                              maxResults:DEFAULT_MAX_RESULTS
                         completionBlock:^(NSArray *items,BOOL success,NSString *error) {
        completionBlock(items,success,error);
    }];
}

/*
 returns search results with search term and page stored in core data
 */
- (void)getSearchResultsWithSearchTerm:(NSString *)searchTerm
                                  page:(NSInteger)page
                       completionBlock:(void(^)(NSArray *items,BOOL success,NSString *error))completionBlock
{
    [self getSearchResultsWithSearchTerm:searchTerm
                                  domain:UBRSearchDataManagerDomainDefault
                                    page:page
                              maxResults:DEFAULT_MAX_RESULTS
                         completionBlock:^(NSArray *items,BOOL success,NSString *error) {
        completionBlock(items,success,error);
    }];
}

/*
 returns search results with search term and domain stored in core data
 */
- (void)getSearchResultsWithSearchTerm:(NSString *)searchTerm
                                domain:(UBRSearchDataManagerDomain)domain
                                  page:(NSInteger)page
                            maxResults:(NSInteger)maxResults
                       completionBlock:(void(^)(NSArray *items,BOOL success,NSString *error))completionBlock
{
    //don't allow more than one search at a time
    if([self isLoadingSearchQuery]){
        completionBlock(nil,NO,@"already_loading_search_query");
        return;
    }
    else{
        self.loadingSearchQuery = YES;
    }
    
    //make sure the search term has more than 1 character
    if([searchTerm length] < 1){
        self.loadingSearchQuery = NO;
        completionBlock(nil,NO,@"serch_term_has_no_characters");
        return;
    }
    
    //convert search term to valid string
    NSString *convertedSearchTerm = [searchTerm validQueryString];
    
    //if the domain is google or default(google is default)
    if(domain == UBRSearchDataManagerDomainGoogle || domain == UBRSearchDataManagerDomainDefault){
    
        //GET request
        [self.requestManager GET:[self constructSearchStringWithDomain:GOOGLE_QUERY_DOMAIN
                                                               version:GOOGLE_QUERY_VERSION
                                                            searchTerm:convertedSearchTerm
                                                            maxResults:maxResults
                                                                  page:page]
                      parameters:nil
                         success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            //process data on background thread
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0),^{
                
                /*
                 check response data dictionary
                 */
                NSDictionary *responseObjectDictionary = responseObject;
                responseObjectDictionary = responseObjectDictionary[@"responseData"];
                
                if(!responseObjectDictionary || ![responseObjectDictionary respondsToSelector:@selector(objectForKey:)]){
                    self.loadingSearchQuery = NO;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completionBlock(nil,NO,@"invalid_json_response");
                    });
                    return;
                }
                
                /*
                 check results array
                 */
                NSArray *results = responseObjectDictionary[@"results"];
                
                if(!results || ![results respondsToSelector:@selector(objectAtIndex:)]){
                    self.loadingSearchQuery = NO;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completionBlock(nil,NO,@"invalid_json_response");
                    });
                    return;
                }
            
                /*
                 convert results to model objects
                 */
                NSMutableArray *convertedResults = [NSMutableArray new];
                
                for(int i = 0; i < [results count]; i++){
                    UBRPhotoMetaData *photoMetaData = [[UBRPhotoMetaData alloc] initWithDictionary:results[i] domain:domain];
                    [convertedResults addObject:photoMetaData];
                }
                
                //return converted results
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.loadingSearchQuery = NO;
                    completionBlock(convertedResults,YES,nil);
                });
                
            });
                        
                          
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            self.loadingSearchQuery = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(nil,NO,@"http_request_failed");
            });
            
        }];
        
    }
    else{
        self.loadingSearchQuery = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(nil,NO,@"invalid_domain");
        });
    }

}

#pragma mark - helpers
/*
 construct search string with parameters
 */
- (NSString *)constructSearchStringWithDomain:(NSString *)domain
                                      version:(NSString *)version
                                   searchTerm:(NSString *)searchTerm
                                   maxResults:(NSInteger)maxResults
                                         page:(NSInteger)page
{
    return [NSString stringWithFormat:@"%@?v=%@&q=%@&rsz=%i&start=%i",
            GOOGLE_QUERY_DOMAIN,
            GOOGLE_QUERY_VERSION,
            searchTerm,
            (int)maxResults,
            (int)page * DEFAULT_MAX_RESULTS];
}

@end
