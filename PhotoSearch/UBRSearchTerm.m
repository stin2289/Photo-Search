//
//  UBRSearchResult.m
//  PhotoSearch
//
//  Created by Austin Marusco on 4/27/14.
//  Copyright (c) 2014 Austin Marusco. All rights reserved.
//

#import "UBRSearchTerm.h"

@implementation UBRSearchTerm

#pragma mark - init
/*
 init with dictionary
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    
    if(self){
        _text = dictionary[@"searchTerm"];
        _lastPerformed = dictionary[@"lastPerformed"];
    }
    
    return self;
}

@end
