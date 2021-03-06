//
//  NSValueTransformer+Factory.h
//  Wordpress
//
//  Created by Evgeniy Yurtaev on 01/01/15.
//  Copyright (c) 2015 Evgeniy Yurtaev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSValueTransformer (Factory)

+ (NSValueTransformer *)wp_URLValueTansformer;

+ (NSValueTransformer *)wp_dateTimeValueTransformer;

+ (NSValueTransformer *)wp_arrayValueTransformer;

@end
