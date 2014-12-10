BREnvironment
=============

A little Objective-C helper class for supporting different deployment environments during development, a.k.a. **DDEDD**.

This project provides a way to define *environment* settings in a **Environment.plist** file. For example you might define a *baseURL* as `http://my.awesome.service` for some web service your app communicates with. During development you might want to have the app use a *test* server, however, so **BREnvironment** also supports a **LocalEnvironment.plist** file where you can override that *baseURL* setting to `http://my.crashful.service`.

Here the **Environment.plist** file can be checked into your project's source control system, and provides *default* settings for your application to use. The **LocalEnvironment.plist** file is **not** checked into source control, so each developer can create their own copy and modify it to their needs.

Oh, and one more thing: `NSUserDefault` values are loaded into `BREnvironment` as well, so a single API can be used for a variety of use cases.


Querying Settings
-----------------

Typical querying for settings is accomplished like this:
	
```objc
// some convenient accessor methods
BOOL awesome = [[BREnvironment sharedEnvironment] boolForKey:@"are_you_awesome"]
NSURL *host = [[BREnvironment sharedEnvironment] URLForKey:@"baseURL"];
NSString *foo = [[BREnvironment sharedEnvironment] stringForKey:@"bar"];

// some super-convenient Objective-C literal syntax
NSString *foo = [BREnvironment sharedEnvironment][@"bar"];

// get the whole she-bang environment
NSDictionary *env = [BREnvironment environmentDictionary];
```


Manipulating Settings
---------------------

Environment settings can be manipulated as well, in either a transient fashion or persisted across app restarts. Persisted settings are managed via `NSUserDefaults`. For example:

```objc
// change the "bar" setting to "bam"
[[BREnvironment sharedEnvironment] setTransientEnvironmentValue:@"bam" forKey:@"bar"];

// do the same thing, using Objective-C literal syntax
[BREnvironment sharedEnvironment][@"bar"] = @"bam";

// do the same thing, but persist the setting so it is preserved across app restarts
[BREnvironment saveEnvironmentValue:@"bam" forKey:@"bar"];
```


Custom Environment Hook
-----------------------

You can also register your own `BREnvironmentProvider` instances to provide environment values managed outside the areas already managed directly. The API is extremely simple:

```objc
@protocol BREnvironmentProvider <NSObject>

/**
 Get an environment value for a given key.
 
 @param key The key to get the associated environment value for.
 @return The object, or @c nil if not available.
 */
- (id)objectForKeyedSubscript:(id)key;

@end
```

The keen observer (that's you!) might notice that is the Objective-C KVC literal subscript access method. One example use case for this functionality would be to hook into Parse Config values, as demonstrated in this fictional code:

```objc
// register a Parse Config hook
[BREnvironment registerEnvironmentProvider:[ParseConfigEnvironmentProvider new]];
```

`BREnvironment` will return the *first non-nil* value found in any registered provider, traversing the providers in the order they are registered. If no provider provides a value, then the usual search paths will be used, so the app can fall back to values included by the app itself.

# Setup in 3 easy steps

The first step is to integrate BREnvironment into your own project. You can integrate
BRCocoaLumberjack via [CocoaPods](http://cocoapods.org/), or manually just copy the
class files to your own project.

## Step 1: integrate via CocoaPods

Install CocoaPods if not already available:

```bash
$ [sudo] gem install cocoapods
$ pod setup
```

Change to the directory of your Xcode project, and create a file named `Podfile` with
contents similar to this:

	platform :ios, '5.0' 
	pod 'BREnvironment', '~> 1.0'

Install into your project:

``` bash
$ pod install
```

Open your project in Xcode using the **.xcworkspace** file CocoaPods generated.

## Step 1: integrate manually

Only do this if you're *not* using CocoaPods. Add `BREnvironment.h` and `BREnvironment.m` to your project, by any means necessary (file copy, git submodule, etc).

## Step 2: create your default environment

Add an `Environment.plist` file to your project. This file *should* be part of your app's build target(s).


## Step 3: create your local environment

Create a `LocalEnvironment.plist` file, at the root of your project. Add this to your SCM's **ignore** list so it is **not** added to version control. This is an *optional* file, so we can't add it directly to any build target(s). Instead, add a **Run Script** build step to your app's build phases that copies the file if it exists, for example:

```sh
filePath=${PROJECT_DIR}/LocalEnvironment.plist
if [ -e "$filePath" ]; then
	cp "$filePath" "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/"
	echo $filePath copied to ${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}
else
	echo $filePath not found.
fi
```

## Step 4

Forth, ah ha! Just seeing if you actually read this far. There *are* only 3 easy steps!


Example App
-----------

The project includes a mind-numbingly simple app in the **Environmental** directory. The app loads up a `BREnvironment` and shows all values in a table. There is an example `LocalEnvironment-sample.plist` file that, if you copy to `LocalEnvironment.plist` and re-run the app, will override the default settings.
