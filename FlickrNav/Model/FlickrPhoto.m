//
// Created by Artem Vysotsky on 7/28/13.
// Copyright (c) 2013 ___FULLUSERNAME___. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "FlickrPhoto.h"


@implementation FlickrPhoto

- (NSURL *)thumbnail {
    if (self.farm && self.id && self.server && self.secret && !_thumbnail) {
        _thumbnail = [NSURL URLWithString:[NSString stringWithFormat:@"http://farm%@.staticflickr.com/%@/%@_%@_q.jpg", self.farm, self.server, self.id, self.secret]];
    }

    return _thumbnail;
}

@end