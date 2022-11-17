# Alternative Installation

The ResearchKit framework can also be added to your app using CocoaPods, Carthage, or as a dynamic framework.

## Prerequisites

* [Git](https://www.git-scm.com) 2.19 or later (`git --version`)
* [Git-LFS](https://git-lfs.github.com) 2.4.2 or later (`git-lfs --version`)


## Installation with CocoaPods

### Prerequisite

* [CocoaPods](https://cocoapods.org) 1.0 or later (`pod env --version`)

### Instructions

Add the following line to your [Podfile](http://guides.cocoapods.org/syntax/podfile.html) and run `pod install`:

```ruby
pod 'ResearchKit', '~> 1.0'
```

## Installation with Carthage

### Prerequisite

* [Carthage](https://github.com/Carthage/Carthage) 0.30 or later (`carthage version`)

### Instructions

Add the following line to your [Cartfile](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfile) and run `carthage update`:

```
github "ResearchKit/ResearchKit" "stable"
```

## Installation as a dynamic framework

### Installation

The latest stable version of *ResearchKit framework* can be cloned with

```
git clone -b stable https://github.com/ResearchKit/ResearchKit.git
```

Or, for the latest changes, use the `main` branch:

```
git clone https://github.com/ResearchKit/ResearchKit.git
```

### Building

Build the *ResearchKit framework* by opening `ResearchKit.xcodeproj` and running the `ResearchKit` framework target. Optionally, run the unit tests too.


### Adding the ResearchKit framework to your App

This walk-through shows how to embed the *ResearchKit framework* in your app using the [Swift Package Manager](https://www.swift.org/package-manager/), and present a simple task view controller.

To get started, drag `ResearchKit.xcodeproj` from your checkout into your *iOS* app project in *Xcode*:

<center>
<figure>
  <img src="https://github.com/ResearchKit/ResearchKit/wiki/AddingResearchKitXcode.png" alt="Adding the ResearchKit framework to your
   project" align="middle"/>
</figure>
</center>

Then, embed the *ResearchKit framework* as a dynamic framework in your app by adding it to the *Embedded Binaries* section of the *General* pane for your target, as shown in the figure below.

<center>
<figure>
  <img src="https://github.com/ResearchKit/ResearchKit/wiki/AddedBinaries.png" width="100%" alt="Adding the ResearchKit framework to
   Embedded Binaries" align="middle"/>
   <figcaption><center>Adding the ResearchKit framework to Embedded Binaries</center></figcaption>
</figure>
</center>