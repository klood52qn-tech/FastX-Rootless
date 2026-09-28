// FastX Rootless reimplementation
// Reconstructed from the original binary's exported Logos method names and
// the preference contract com.gh.fastx / h1. Private APIs are intentionally
// limited to methods observed in the original binary.

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

static NSString * const kFastXDefaults = @"com.gh.fastx";
static NSString * const kFastXEnabledKey = @"h1";

static BOOL FastXEnabled(void) {
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:kFastXDefaults];
    if ([defaults objectForKey:kFastXEnabledKey] == nil) {
        return YES;
    }
    return [defaults boolForKey:kFastXEnabledKey];
}

// FastX's core behavior is to remove implicit UIKit/CoreAnimation actions
// while the BeFast preference is enabled. Returning nil is the documented
// CALayer action contract for “animate nothing”.
%hook UIViewAnimationState

- (id)actionForLayer:(CALayer *)layer forKey:(NSString *)key forView:(id)view {
    if (FastXEnabled()) {
        return nil;
    }
    return %orig(layer, key, view);
}

- (id)animationForLayer:(CALayer *)layer forKey:(NSString *)key forView:(id)view {
    if (FastXEnabled()) {
        return nil;
    }
    return %orig(layer, key, view);
}

%end

%hook UIViewInProcessAnimationState

- (id)actionForLayer:(CALayer *)layer forKey:(NSString *)key forView:(id)view {
    if (FastXEnabled()) {
        return nil;
    }
    return %orig(layer, key, view);
}

%end

%hook UIPopoverBackgroundView

- (id)actionForLayer:(CALayer *)layer forKey:(NSString *)key {
    if (FastXEnabled()) {
        return nil;
    }
    return %orig(layer, key);
}

%end

%hook SBCoverSheetTranstionSettings

// The original binary contains setIconFlyIn:. Disable the icon fly-in when
// FastX is enabled, preserving the caller's value when it is disabled.
- (void)setIconFlyIn:(BOOL)iconFlyIn {
    if (FastXEnabled()) {
        %orig(NO);
        return;
    }
    %orig(iconFlyIn);
}

%end

%hook SBFluidSwitcherViewController

// This selector is present in the original binary. Keep the system's normal
// icon selection and visibility semantics; animation suppression above is the
// compatible part that applies across newer SpringBoard revisions.
- (id)_iconViewForDisplayItem:(id)item isVisible:(BOOL)isVisible {
    return %orig(item, isVisible);
}

%end

%ctor {
    @autoreleasepool {
        NSLog(@"[FastX] rootless reimplementation loaded; enabled=%@",
              FastXEnabled() ? @"YES" : @"NO");
    }
}
