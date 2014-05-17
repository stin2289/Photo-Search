//
//  UBRSearchPhotoCollectionViewCell.m
//  PhotoSearch
//
//  Created by Austin Marusco on 4/26/14.
//  Copyright (c) 2014 Austin Marusco. All rights reserved.
//

#import "UBRSearchPhotoCollectionViewCell.h"

#define DEFAULT_IMAGE_BUFFER_SIZE 4.0

@interface UBRSearchPhotoCollectionViewCell ()

@property (nonatomic) UIImageView *imageView;

@end

@implementation UBRSearchPhotoCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setup];
    }
    return self;
}

/*
 setup initial variables for view
 */
- (void)setup
{
    self.backgroundColor = [UIColor whiteColor];
    _imageBufferSize = DEFAULT_IMAGE_BUFFER_SIZE;
    
    //init image view w/ properties
    _imageView = [[UIImageView alloc] init];
    _imageView.clipsToBounds = NO;
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [self addSubview:_imageView];
}

/*
 layout subviews
 */
- (void)layoutSubviews{
    //resize imageview
    self.imageView.frame = CGRectMake(self.imageBufferSize,
                                      self.imageBufferSize,
                                      self.frame.size.width - (2 * self.imageBufferSize),
                                      self.frame.size.height - (2 * self.imageBufferSize));
    
}

#pragma mark - accessors
- (void)setImageBufferSize:(CGFloat)imageBufferSize
{
    _imageBufferSize = imageBufferSize;
    
    [self setNeedsLayout];
}

@end
