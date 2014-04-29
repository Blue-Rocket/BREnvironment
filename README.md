BREnvironment
=============

A little helper for supporting different deployment environments during development, a.k.a. **DDEDD**.

This project provides a way to define *environment* settings in a **Environment.plist** file. For example you might define a *baseURL* as `http://my.awesome.service` for some web service your app communicates with. During development you might want to have the app use a *test* server, however, so **BREnvironment** also supports a **LocalEnvironment.plist** file where you can override that *baseURL* setting to `http://my.crashful.service`.

Here the **Environment.plist** file can be checked into your project's source control system, and provides *default* settings for your application to use. The **LocalEnvironment.plist** file is **not** checked into source control, so each developer can create their own copy and modify it to their needs.

Oh, and one more thing: `NSUserDefault` values are loaded into `BREnvironment` as well, so a single API can be used for a variety of use cases.


Setup in 3 easy steps
---------------------

First, add `BREnvironment.h` and `BREnvironment.m` to your project, by any means necessary (file copy, git submodule, etc).

Second, add an `Environment.plist` file to your project. This file *should* be part of your app's build target(s).

Third, create a `LocalEnvironment.plist` file, at the root of your project. Add this to your SCM's **ignore** list so it is **not** added to version control. This is an *optional* file, so we can't add it directly to any build target(s). Instead, add a **Run Script** build step to your app's build phases that copies the file if it exists, for example:

```sh
filePath=${PROJECT_DIR}/LocalEnvironment.plist
if [ -e "$filePath" ]; then
	cp "$filePath" "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/"
	echo $filePath copied to ${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}
else
	echo $filePath not found.
fi
```

Forth, ah ha! Just seeing if you actually read this far. There *are* only 3 easy steps!


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


Example App
-----------

The project includes a mind-numbingly simple app in the **Environmental** directory. The app loads up a `BREnvironment` and shows all values in a table. There is an example `LocalEnvironment-sample.plist` file that, if you copy to `LocalEnvironment.plist` and re-run the app, will override the default settings.
