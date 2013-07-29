//
// Created by Artem Vysotsky on 7/28/13.
// Copyright (c) 2013 ___FULLUSERNAME___. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <AFNetworking/UIImageView+AFNetworking.h>
#import "FlickrPhotoCell.h"
#import "FlickrPhoto.h"


@implementation FlickrPhotoCell

- (void)setPhoto:(FlickrPhoto *)photo {

    if (_photo != photo) {
        _photo = photo;
    }
    [self.imageView setImageWithURL:self.photo.thumbnail];
}
@end