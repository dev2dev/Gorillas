/*
 * This file is part of Gorillas.
 *
 *  Gorillas is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  Gorillas is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with Gorillas in the file named 'COPYING'.
 *  If not, see <http://www.gnu.org/licenses/>.
 */

//
//  HUDLayer.m
//  Gorillas
//
//  Created by Maarten Billemont on 10/11/08.
//  Copyright 2008 Lin.k. All rights reserved.
//

#import "HUDLayer.h"
#import "GorillasAppDelegate.h"
#import "GorillasConfig.h"
#import "Utility.h"
#import "ShadeTo.h"


@implementation HUDLayer


-(id) init {
    
    if(!(self = [super init]))
        return self;

    width = [[Director sharedDirector] winSize].size.width;
    height =[[GorillasConfig get] fontSize] + 5;
    position = cpv(0, -height);

    menuButton = [MenuItemFont itemFromString:@"                              " target:self selector:@selector(menuButton:)];
    
    menuMenu = [[Menu menuWithItems:menuButton, nil] retain];
    [menuMenu setPosition:cpv([menuMenu position].x, 0)];
    
    // Score.
    scoreLabel = [[Label alloc] initWithString:[NSString stringWithFormat:@"%05d", [[GorillasConfig get] score]] dimensions:CGSizeMake(100, [[GorillasConfig get] fontSize] + 5) alignment:UITextAlignmentRight fontName:[[GorillasConfig get] fontName] fontSize:[[GorillasConfig get] fontSize]];
    [self add:scoreLabel];
    
    CGSize winSize = [[Director sharedDirector] winSize].size;
    [scoreLabel setPosition:cpv(winSize.width - [scoreLabel contentSize].width / 2, [scoreLabel contentSize].height / 2)];
    
    return self;
}


-(void) updateScore {
    
    [scoreLabel setString:[NSString stringWithFormat:@"%05d", [[GorillasConfig get] score]]];
    [scoreLabel do:[ShadeTo actionWithColor:0xFF0000FF duration:1]];
    //[scoreLabel do:[Sequence actions:[ShadeTo actionWithColor:0xFF0000FF duration:1], nil]];
}


-(void) setMenuTitle: (NSString *)title {
    
    [[menuButton label] setString:title];
}


-(void) reveal {

    if(revealed)
        return;
    
    revealed = true;
    [self do:[MoveTo actionWithDuration:[[GorillasConfig get] transitionDuration] position:cpv(0, 0)]];
    [self add:menuMenu];
}


-(void) dismiss {
    
    if(!revealed)
        return;
    
    revealed = false;
    [self do:[Sequence actions:
                  [MoveTo actionWithDuration:[[GorillasConfig get] transitionDuration] position:cpv(0, -height)],
                  [CallFunc actionWithTarget:self selector:@selector(gone)],
                  nil]];
}


-(void) gone {
    
    [self remove:menuMenu];
}


-(void) menuButton: (id) caller {
    
    [[GorillasAppDelegate get] showMainMenu];
}


-(BOOL) hitsHud: (cpVect)pos {
    
    return  pos.x >= position.x         &&
            pos.y >= position.y         &&
            pos.x <= position.x + width &&
            pos.y <= position.y + height;
}


-(void) draw {
    
    [Utility drawBoxFrom:cpv(0, 0) size:cpv(width, height) color:[[GorillasConfig get] shadeColor]];
}


-(void) dealloc {
    
    [super dealloc];
    
    [menuButton release];
    [menuMenu release];
}


@end
