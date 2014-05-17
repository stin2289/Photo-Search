//
//  NSString+InternetQueries.m
//  PhotoSearch
//
//  Created by Austin Marusco on 4/26/14.
//  Copyright (c) 2014 Austin Marusco. All rights reserved.
//

#import "NSString+InternetQueries.h"

@implementation NSString (InternetQueries)

/*
 return valid query string
 converts ' ' to %20
 removed multiple ' 's in a row
 */
- (NSString *)validQueryString
{
    if([self length] < 1)
        return self;
    
    //replace spaces in string w/ '%20'
    NSMutableString *convertedSearchTerm = [self mutableCopy];
    
    BOOL isPrecedingCharacterSpace = NO;
    
    //remove multiple spaces in a row
    for(int i = 0; i < [convertedSearchTerm length]; i++){
        
        //current char is a space
        if([[convertedSearchTerm substringWithRange:NSMakeRange(i,1)] isEqualToString:@" "]){
            
            if(isPrecedingCharacterSpace){
                //delete previous char and move back one index
                [convertedSearchTerm deleteCharactersInRange:NSMakeRange(i-1, 1)];
                i--;
            }
            else
                isPrecedingCharacterSpace = YES;
            
        }
        //current char is not space
        else{
            isPrecedingCharacterSpace = NO;
        }
        
    }
    
    //remove space from beginning of string
    [convertedSearchTerm replaceOccurrencesOfString:@" "
                                         withString:@""
                                            options:NSCaseInsensitiveSearch
                                              range:NSMakeRange(0,1)];
    
    //remove space from end of string
    [convertedSearchTerm replaceOccurrencesOfString:@" "
                                         withString:@""
                                            options:NSCaseInsensitiveSearch
                                              range:NSMakeRange([convertedSearchTerm length] - 1,1)];
    
    //return string w/ '%20' removed
    [convertedSearchTerm replaceOccurrencesOfString:@" "
                                         withString:@"%20"
                                            options:NSCaseInsensitiveSearch
                                              range:NSMakeRange(0,[convertedSearchTerm length])];
    
    return [convertedSearchTerm copy];
    
}

@end
