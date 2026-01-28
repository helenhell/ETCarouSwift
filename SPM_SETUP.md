# Swift Package Manager Setup Guide

This guide will help you set up the ETCarouSwift demo project to use the Swift Package Manager.

## Steps to Add Local Package in Xcode

1. **Open the Demo Project**
   - Open `ETCarouSwiftDemo/ETCarouSwiftDemo.xcodeproj` in Xcode

2. **Add Package Dependency**
   - Select the project in the navigator
   - Select the `ETCarouSwiftDemo` target
   - Go to the "General" tab
   - Scroll down to "Frameworks, Libraries, and Embedded Content"
   - Click the "+" button
   - Click "Add Other..." → "Add Package Dependency..."
   - In the dialog, click "Add Local..."
   - Navigate to the parent directory (one level up from ETCarouSwiftDemo)
   - Select the `ETCarouSwift` folder (the one containing Package.swift)
   - Click "Add Package"
   - Select the `ETCarouSwift` library product
   - Click "Add Package"

3. **Remove Old Framework References** (if any remain)
   - In the project navigator, if you see `ETCarouSwift.framework`, right-click and delete it
   - Make sure to select "Remove Reference" (not "Move to Trash")

4. **Add ContentView.swift to Project** (if not already added)
   - Right-click on the `ETCarouSwiftDemo` folder in the navigator
   - Select "Add Files to ETCarouSwiftDemo..."
   - Select `ContentView.swift`
   - Make sure "Copy items if needed" is unchecked
   - Make sure the target is checked
   - Click "Add"

5. **Build and Run**
   - Clean build folder (Cmd+Shift+K)
   - Build the project (Cmd+B)
   - Run the app (Cmd+R)

## Alternative: Using Xcode's File Menu

1. File → Add Package Dependencies...
2. Click "Add Local..."
3. Navigate to the `ETCarouSwift` directory (parent of ETCarouSwiftDemo)
4. Click "Add Package"
5. Select the `ETCarouSwift` library
6. Click "Add Package"

## Troubleshooting

- If you get build errors, make sure the Package.swift file is in the correct location
- Ensure the deployment target is iOS 16.0 or higher
- Clean build folder and rebuild if needed
