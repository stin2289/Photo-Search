//
//  NSString+InternetQueries.h
//  PhotoSearch
//
//  Created by Austin Marusco on 4/26/14.
//  Copyright (c) 2014 Austin Marusco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (InternetQueries)

/*
 return valid query string
 converts ' ' to %20
 removed multiple ' 's in a row
 */
- (NSString *)validQueryString;

@end
