//
//  NSDictionary+Valid.m
//  PhotoSearch
//
//  Created by Austin Marusco on 4/26/14.
//  Copyright (c) 2014 Austin Marusco. All rights reserved.
//

#import "NSDictionary+Valid.h"

@implementation NSDictionary (Valid)

/*
 checks to see if a key is valid for a dictionary
 */
- (BOOL)validKey:(id <NSCopying>)key forDictionary:(NSDictionary *)dictionary
{
    return (dictionary[key] && dictionary[key] != [NSNull null]);
}

@end
