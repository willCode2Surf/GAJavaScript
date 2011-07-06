/*
 Copyright (c) 2011 Andrew Goodale. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are
 permitted provided that the following conditions are met:
 
 1. Redistributions of source code must retain the above copyright notice, this list of
 conditions and the following disclaimer.
 
 2. Redistributions in binary form must reproduce the above copyright notice, this list
 of conditions and the following disclaimer in the documentation and/or other materials
 provided with the distribution.
 
 THIS SOFTWARE IS PROVIDED BY ANDREW GOODALE "AS IS" AND ANY EXPRESS OR IMPLIED
 WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> OR
 CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 The views and conclusions contained in the software and documentation are those of the
 authors and should not be interpreted as representing official policies, either expressed
 or implied, of Andrew Goodale.
 */

#import "UIView+GAViewStyling.h"
#import "GAViewStyling.h"
#import "GAScriptEngine.h"
#import "NSObject+GAJavaScript.h"
#import "GAScriptMethodSignatures.h"

@implementation UIView (GAViewStyling)

- (NSString *)styleSelector
{
    // TODO: Tags identify views within the hierarchy, so we'll use it if we can...
//    if ([self tag] > 0)
//        return [NSString stringWithFormat:@"#tag-%d", [self tag]];
    
    NSString* className = NSStringFromClass([self class]);  
    return [NSString stringWithFormat:@".%@", className];
}

- (void)applyStylesWithScriptEngine:(GAScriptEngine *)engine
{
    NSString* selector = [self styleSelector];
    NSLog(@"GAViewStyling selector: %@", selector);
    
    id element = [[engine documentObject] querySelector:selector];
    
    if ([element isJavaScriptTrue])
    {
        id cssDeclaration = [[engine windowObject] getComputedStyle:element];    
        [self applyComputedStyles:cssDeclaration];
    }
    
    for (UIView* childView in self.subviews)
    {
        [childView applyStylesWithScriptEngine:engine];
    }
}

- (void)applyComputedStyles:(id)cssDeclaration
{
    // String will be "rgb(r, g, b)" with numbers in base 10
    //
    NSString* backgroundColor = [cssDeclaration valueForKey:@"background-color"];
    self.backgroundColor = [UIColor colorWithCSSColor:backgroundColor];    
    
    NSString* opacity = [cssDeclaration valueForKey:@"opacity"];
    NSLog(@"TODO: View opacity %@", opacity);
    
    NSString* backgroundImage = [cssDeclaration valueForKey:@"background-image"];
    
    // TODO: If this view's layer is a CAGradientLayer, we can use a webkit linear gradient
    // -webkit-gradient(<type>, <point>, <point> [, <stop>]*)
    //
    if ([backgroundImage hasPrefix:@"-webkit-gradient(linear,"]
        && [[self layer] isKindOfClass:[CAGradientLayer class]])
    {
        NSLog(@"TODO: Gradient: %@", backgroundImage);
    }
}

@end

#pragma mark -

@implementation UINavigationBar (GAViewStyling)

- (void)applyComputedStyles:(id)cssDeclaration
{
    // String will be "rgb(r, g, b)" with numbers in base 10
    //
    NSString* color = [cssDeclaration valueForKey:@"color"];
    self.tintColor = [UIColor colorWithCSSColor:color];    
}

@end

#pragma mark -

@implementation UILabel (GAViewStyling)

- (void)applyComputedStyles:(id)cssDeclaration
{
    // Text Font
    self.font = [UIFont fontWithCSSDeclaration:cssDeclaration];

    // Text Color
    NSString* color = [cssDeclaration valueForKey:@"color"];
    self.textColor = [UIColor colorWithCSSColor:color];
    
    // Text Alignment
    // UIKit doesn't support "justified" and "inherit" is about the rule
    //
    NSString* textAlign = [cssDeclaration valueForKey:@"text-align"];
    
    if ([textAlign isEqualToString:@"left"])
        self.textAlignment = UITextAlignmentLeft;
    else if ([textAlign isEqualToString:@"center"])
        self.textAlignment = UITextAlignmentCenter;
    else if ([textAlign isEqualToString:@"right"])
        self.textAlignment = UITextAlignmentRight;
}

@end
