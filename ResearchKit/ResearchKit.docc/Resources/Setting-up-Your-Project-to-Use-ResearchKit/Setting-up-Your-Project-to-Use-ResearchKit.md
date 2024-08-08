# Setting up your project to use ResearchKit

Add the ResearchKit framework to your app as a dynamic framework

## Overview

ResearchKit is an open source framework and is not shipped with native IOS. To use it, you can embed ResearchKit into your app as dynamic framework.

### Installation

Clone the latest stable version of ResearchKit.

```
git clone -b stable https://github.com/ResearchKit/ResearchKit.git
```

Or, for the latest changes, use the main branch:

```
git clone https://github.com/ResearchKit/ResearchKit.git
```

### Add the ResearchKit framework to your app 

To get started, drag ResearchKit.xcodeproj from your checkout into your iOS app project in Xcode:

![drag ResearchKit.xcodeproj from your checkout](setting-up-your-project-to-use-researchkit-1)


Embed the ResearchKit framework as a dynamic framework in your app by adding it to the Embedded Binaries section of the General pane for your target as shown in the figure below.

![Embed the ResearchKit framework as a dynamic framework](setting-up-your-project-to-use-researchkit-2)

### Import the correct modules

If you only want to present Consent and Survey UI, import ResearchKit & ResearchKitUI.

```swift
import ResearchKit
import ResearchKitUI
```

If you also want to use ResearchKit Active Tasks, import ResearchKitActiveTask

```swift
import ResearchKit
import ResearchKitUI
import ResearchKitActiveTask
```
