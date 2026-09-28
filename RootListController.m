#import <UIKit/UIKit.h>
#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import <spawn.h>
#import <rootless.h>

extern char **environ;

@interface FastXRootListController : PSListController
@end

@implementation FastXRootListController

- (NSArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
    }
    return _specifiers;
}

- (void)respring {
    const char *argv[] = { "sbreload", NULL };
    pid_t pid = 0;
    (void)posix_spawn(&pid, ROOT_PATH("/usr/bin/sbreload"), NULL, NULL,
                      (char *const *)argv, environ);
}

@end
