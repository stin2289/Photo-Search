//
//  UBRPhoto.h
//  PhotoSearch
//
//  Created by Austin Marusco on 4/26/14.
//  Copyright (c) 2014 Austin Marusco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UBRPhotoMetaData : NSObject

/*
 image origin i.e. google, bing, etc.
 */
@property (nonatomic) UBRSearchDataManagerDomain *origin;

//unique id
@property (nonatomic) NSString *photoId;

//original context URL
@property (nonatomic) NSURL *originalContextURL;

//title
@property (nonatomic) NSString *title;

/*
 thumnail photo
 */
@property (nonatomic) NSURL  *thumbnailPhotoURL;
@property (nonatomic) CGFloat thumbnailPhotoHeight;
@property (nonatomic) CGFloat thumbnailPhotoWidth;
@property (nonatomic) CGSize  thumnailPhotoSize;

/*
 photo
 */
@property (nonatomic) NSURL   *photoURL;
@property (nonatomic) CGFloat photoHeight;
@property (nonatomic) CGFloat photoWidth;
@property (nonatomic) CGSize  photoSize;

//init methods
- (instancetype)initWithDictionary:(NSDictionary *)dictionary domain:(UBRSearchDataManagerDomain)domain;

@end
