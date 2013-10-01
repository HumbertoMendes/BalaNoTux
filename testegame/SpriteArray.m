//
//  SpriteArray.m
//  testegame
//
//  Created by Patrick Tracanelli on 28/11/11.
//  Copyright 2011 FreeBSD Brasil LTDA. All rights reserved.
//

// AULA 2 - Passo 14
#import "SpriteArray.h"

@implementation SpriteArray
@synthesize array = array;

// AULA 2 - Passo 15

-(id)initWithCapacity:(int)capacity spriteFrameName:(NSString *)spriteFrameName batchNode:(CCSpriteBatchNode *)batchNode {
    
    //Adicionando um frame a mais para os chefões.
    capacity++;
    
    if ((self = [super init])) {
        
        array = [[CCArray alloc] initWithCapacity:capacity];
        for(int i = 0; i < capacity; ++i) {            
            CCSprite *sprite = [CCSprite
                                spriteWithSpriteFrameName:spriteFrameName]; 
            sprite.visible = NO; 
            [batchNode addChild:sprite]; 
            [array addObject:sprite];            
        }
        
    }
    return self;
    
}

// AULA 2 - Passo 16

-(id)nextSprite {
    id retval = [array objectAtIndex:nextItem];
    nextItem++;
    if (nextItem >= array.count-1) nextItem = 0;
    return retval;
}

-(id)bossSprite{
    //Último array é do boss
    return [array objectAtIndex:array.count-1];
}

// AULA 2 - Passo 17
- (void)dealloc {
    [array release];
    array = nil;
    [super dealloc];
}

@end