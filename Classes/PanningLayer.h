/*
 * This file is part of Gorillas.
 *
 *  Gorillas is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 2 of the License, or
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
//  PanningLayer.h
//  Gorillas
//
//  Created by Maarten Billemont on 15/02/09.
//  Copyright, lhunath (Maarten Billemont) 2008. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"
#import "Resettable.h"

@interface PanningLayer : Layer <Resettable> {

    cpFloat initialScale;
    cpFloat initialDist;
    ScaleTo *scaleAction;
    MoveTo *scrollAction;
}

-(void) scaleTo:(cpFloat)newScale;
-(void) scrollToCenter:(cpVect)r horizontal:(BOOL)horizontal;

@end
