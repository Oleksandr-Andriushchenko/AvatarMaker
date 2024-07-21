# Project Structure

- Project structure should be synchronized with file system;
- Expected structure:

```
    Project folder
        xcode project
        xcode workspace
        Vendor          // shared between targets
        Resources       // shared between targets
        Lib
            Lib target folder
        App target folder
        App target folder
        Tests
            Test target folder
```

**Lib** - project frameworks folder. As a general rule of thumb, it contains several targets for frameworks for project-wide reusable code.

**Vendor** - third-party libraries added without package manager usage;

**Resources** - resources shared between targets, e.g. images, translations, etc.

**Tests** - test targets folder. It contains test targets (e.g. behavioral tests, integration tests).

**App target folder** - folder for one target. This is the folder of application, which, after building, could be launched on the device. There could be multiple with partially shared codebase.

```
Target folder
    AppDelegate.swift/Target.h
    App
    Info.plist
    Sources
        Assembly
        UI
            Flow
                View
                    Reducer
                    Private
                        Subview.swift
        Models
            Persistence
            Entities
        Services
        Lib
            Extensions
                View
                    View+Extensions.swift
                UIKit
                    UIView+Extensions.swift
                Foundation
                    String+Extensions.swift
                    Tuple
                        Tuple+Lift.swift
                        Tuple+Sequence.swift
                        Tuple.F
                            Tuple.F+Map.swift
                            Tuple.F+ArrayTransform.swift
            Entities
                Locks
                    UnfairLock.swift
                    PThreadLock.swift
            Mixins
            Functions
            Operators
    Resources
        Icons.xcassets
        Images.xcassets
        Color.xcassets
        Font.swift
        Image.swift
        Fonts
            super-duper-font.fnt
```

**Sources/UI** - folder containing UI. It should be split into modules (e.g. each tab in tab bar view, auth, etc.) based on the design. Each flow should be abstracted out using some interface and be independent from other flowes.

**Sources/Assembly** - folder containing dependency containers, factories, etc.;

**Sources/UI/Flow** - contains view and one or several view with reducers;

**Sources/UI/Flow/View** - folder containing one **View** and its Reducer;

**Sources/UI/Flow/View/Private** - entities specific for current view only;

**Sources/UI/Flow/View/Reducer** - instances specific for certain view buisness logic;

**Models/Entities** - contains models, each in a separate subfolder, grouped by purpose;

**Models/Persistence** - contains mappable models, each in a separate subfolder, grouped by purpose;

**Sources/Services** - services;

**Sources/Lib** - shared entities in target;

**Sources/Lib/Extensions** - entity extensions. If there are multiple extension files for entity, they should be placed in a subfolder named, as entity. Entity extensions should be grouped by the entity framework;

**Sources/Lib/Entities** - entities specific to the target. Should be grouped by their purpose;

**Sources/Lib/Mixins** - protocols with protocol extensions used, as mixins;

**Sources/Lib/Functions** - pure and namespaced functions used, as a DSL inside the module;

**Sources/Lib/Operators** - operators and their precedence groups used inside the module;

**Resources** - resources specific for target, e.g. images, translations, etc. It should also contain swift files with constants for fonts, colors and images

- Further structuring depends on the task and should be decided by programmer;
- One or more of the subfolders could be absent in target;
- It is recommended to create small targets and use them for namespacing purposes;
- If the entity contains both the protocol and implementation, it should be placed in a separate subfolder with the name of entity;
- One folder shouldn't contain loads of source files, it should be split into subfolders in that case.

#### Entities file name

- Files should be named the same as the entities they contain.
- If the file is about an inner type, it would have the following convention: <Outer Type>.<Inner Type>.swift. Each inner type depth would be delimited by a dot. E.g. Module.Constants.Strings.swift.

#### Extension file name

- Extension file name naming convention is as follows: <Entity Name>+<Extension Name>.swift, e.g. `Object+Mapping.swift`;
- If the extension is generalized, without any clear purpose in its contents, it should be called <Entity Name>+Extensions.swift, e.g. `Object+Extensions.swift`
