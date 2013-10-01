// CCParallaxNode-Extras.m

#import "CCParallaxNode-Extras.h"

@class CGPointObject;

@implementation CCParallaxNode (Extras)

-(void) incrementOffset:(CGPoint)offset forChild:(CCNode*)node 
{
for (unsigned int i = 0; i < parallaxArray_->num; i++) {
CGPointObject *point = parallaxArray_->arr[i];
if ([[point child] isEqual:node]) { // <- this is where the warning is: Method '-child' not found (return type defaults to 'id')
[point setOffset:ccpAdd([point offset], offset)];
break;
}
}
}

@end




