//
//  NSDictionary+RemovingNull.h
//  Wordpress
//
//  Created by Evgeniy Yurtaev on 01/01/15.
//  Copyright (c) 2015 Evgeniy Yurtaev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (RemovingNull)

- (NSDictionary *)wp_dictionaryByRemovingNullValues;

@end
