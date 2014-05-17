//
//  UBRPhoto.m
//  PhotoSearch
//
//  Created by Austin Marusco on 4/26/14.
//  Copyright (c) 2014 Austin Marusco. All rights reserved.
//

#import "UBRPhotoMetaData.h"
#import "NSDictionary+Valid.h"

@implementation UBRPhotoMetaData

#pragma mark init
/*
 init with dictionary and domain
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary domain:(UBRSearchDataManagerDomain)domain
{
    self = [super init];
    
    if(self){
    
        //if the dictionary is allocated
        if(dictionary){
            
            //if the domain is google or default(google is default)
            if(domain == UBRSearchDataManagerDomainDefault || domain == UBRSearchDataManagerDomainGoogle){
        
                _origin = UBRSearchDataManagerDomainGoogle;
                
                id <NSCopying> key;
                
                key = @"imageId";
                if([dictionary validKey:key forDictionary:dictionary])
                    _photoId = dictionary[key];
                
                key = @"originalContextUrl";
                if([dictionary validKey:key forDictionary:dictionary]){
                    _originalContextURL = [NSURL URLWithString:dictionary[key]];
                }
                
                key = @"title";
                if([dictionary validKey:key forDictionary:dictionary])
                    _title = dictionary[key];

                /*
                 thumnail photo
                 */
                key = @"tbUrl";
                if([dictionary validKey:key forDictionary:dictionary])
                    _thumbnailPhotoURL = [NSURL URLWithString:dictionary[key]];
                
                key = @"tbHeight";
                if([dictionary validKey:key forDictionary:dictionary]){
                    NSNumber *number = dictionary[key];
                    _thumbnailPhotoHeight = [number doubleValue];
                }
                
                key = @"tbWidth";
                if([dictionary validKey:key forDictionary:dictionary]){
                    NSNumber *number = dictionary[key];
                    _thumbnailPhotoWidth = [number doubleValue];
                }
                
        
                /*
                 photo
                 */
                key = @"url";
                if([dictionary validKey:key forDictionary:dictionary])
                    _photoURL = [NSURL URLWithString:dictionary[key]];
                
                key = @"height";
                if([dictionary validKey:key forDictionary:dictionary]){
                    NSNumber *number = dictionary[key];
                    _photoHeight = [number doubleValue];
                }
                
                key = @"width";
                if([dictionary validKey:key forDictionary:dictionary]){
                    NSNumber *number = dictionary[key];
                    _photoWidth = [number doubleValue];
                }
                
            }
        }
    }
    
    return self;
    
}

#pragma mark - accessor
- (CGSize)thumnailPhotoSize{
    return CGSizeMake(self.thumbnailPhotoWidth, self.thumbnailPhotoHeight);
}

- (CGSize)photoSize{
    return CGSizeMake(self.photoWidth, self.photoHeight);
}

@end
