//
// AULA 2 - Passo 13 - criado SpriteArray como extensao do NSObject
//

#import "cocos2d.h"

@interface SpriteArray : NSObject {
    CCArray * array;
    int nextItem;
}

@property (readonly) CCArray * array;

-(id)initWithCapacity:(int)capacity spriteFrameName:(NSString *)spriteFrameName
             batchNode:(CCSpriteBatchNode *)batchNode;
-(id)nextSprite;
-(id)bossSprite;

@end