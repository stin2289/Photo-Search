//
//  UBRSearchResult.h
//  PhotoSearch
//
//  Created by Austin Marusco on 4/27/14.
//  Copyright (c) 2014 Austin Marusco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UBRSearchTerm : NSObject

@property (nonatomic) NSString *text;
@property (nonatomic) NSDate *lastPerformed;

/*
 init with dictionary
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
