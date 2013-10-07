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
@synthesize resistencia = resistencia;


// AULA 2 - Passo 15

-(id)initWithCapacity:(int)capacity spriteFrameName:(NSArray *)spritesFrameName batchNode:(CCSpriteBatchNode *)batchNode {
    
    //Adicionando um frame a mais para os chefões.
    capacity += 2;
    
    int quantidadeSprites = [spritesFrameName count];

    if ((self = [super init])) {
        
        array = [[CCArray alloc] initWithCapacity:capacity];
        resistencia = [[CCArray alloc] initWithCapacity:capacity];
        for(int i = 0; i < capacity; ++i) {
            int random = arc4random();
            random = random < 0 ? 0 : random;
            int indiceRandomico = random % quantidadeSprites;
            if (i == capacity -2) {
                //sub boss sempre vai ser o mesmo personagem
                indiceRandomico = 0;
            }
            if (quantidadeSprites > 1 && i == capacity -1) {
                //boss sempre vai ser o mesmo personagem
                indiceRandomico = 1;
            }
            NSLog(@"Array qrde: %d random: %d indiceRandomigo: %d", quantidadeSprites, random, indiceRandomico);
            CCSprite *sprite = [CCSprite
                                spriteWithSpriteFrameName:[spritesFrameName objectAtIndex:indiceRandomico]];
            sprite.visible = NO; 
            [batchNode addChild:sprite]; 
            [array addObject:sprite];

            //segundo tipo de inimigo deve ser mais forte
            int resis = 10 * indiceRandomico;
            [resistencia addObject: [NSNumber numberWithInt:resis]];
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

-(int) currentItemForce {
    return [resistencia objectAtIndex: nextItem];
}

-(id)bossSprite{
    //Último array é do boss
    return [array objectAtIndex:array.count-1];
}

-(id)subBossSprite{
    //Último array é do boss
    return [array objectAtIndex:array.count-2];
}

// AULA 2 - Passo 17
- (void)dealloc {
    [array release];
    array = nil;
    [super dealloc];
}

@end