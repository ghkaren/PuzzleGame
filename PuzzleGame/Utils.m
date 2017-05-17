//
//  Utils.m
//  PuzzleGame
//
//  Created by Karen Ghandilyan on 5/17/17.
//  Copyright © 2017 Wagawin. All rights reserved.
//

#import "Utils.h"

@implementation Utils

+ (NSArray *)shuffleArray:(NSArray *)array {
    NSMutableArray *itemsArray = [NSMutableArray arrayWithArray:array];
    for (NSUInteger i = itemsArray.count; i > 1; --i) {
        [itemsArray exchangeObjectAtIndex:i - 1 withObjectAtIndex:arc4random_uniform((u_int32_t)i)];
    }
    return itemsArray;
}


@end
