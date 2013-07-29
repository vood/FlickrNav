//
// Created by Artem Vysotsky on 7/28/13.
// Copyright (c) 2013 ___FULLUSERNAME___. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>


@interface FlickrPhoto : NSObject
@property(nonatomic, copy) NSNumber *farm;
@property(nonatomic, copy) NSNumber *id;
@property(nonatomic, copy) NSString *secret;
@property(nonatomic, copy) NSString *server;
@property(nonatomic, copy) NSString *title;
@property(nonatomic, strong) NSURL *thumbnail;
@end