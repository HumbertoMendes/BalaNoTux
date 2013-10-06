//
// AULA 2 - Passo 13 - criado SpriteArray como extensao do NSObject
//

#import "cocos2d.h"

@interface SpriteArray : NSObject {
    CCArray * array;
    CCArray * resistencia;
    int nextItem;
}

@property (readonly) CCArray * array;
@property (readonly) CCArray * resistencia;

-(id)initWithCapacity:(int)capacity spriteFrameName:(NSArray *)spritesFrameName
             batchNode:(CCSpriteBatchNode *)batchNode;
-(id)nextSprite;
-(id)bossSprite;
-(id)subBossSprite;
-(int) currentItemForce;

@end