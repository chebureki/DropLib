# DropLib
## What is it
DropLib is a simple, efficient and beautiful way to quickly build a GUI for your scripts

# Docs
## Initial
```lua
local gui = loadstring(game:HttpGet("https://gitlab.com/0x45.xyz/droplib/-/raw/master/drop-minified.lua"))()(CONFIG)
```
|CONFIG|
|--|
|(Table)[User-config](#Docs)|

## Gui Methods
```lua
gui:CleanUp()
```
Removes everything

```lua
gui:UpdateGui()
```
Updates the Interfaces based on the values in gui.Config

## Create Category / Section / SubSection
```lua
local category = gui:CreateCategory(TITLE, POSITION)
local section = category:CreateSection(TITLE)
local subsection = category:CreateSection(TITLE)
```
You can have as many nested sections as you want

|TITLE|POSITION|
|--|--|
|(String)Title|(UDim2)Initial position on screen, default: auto align|

## Category Methods
```lua
category:MoveTo(POSITION)
```
|POSITION|
|--|
|(UDim2) Screen Position|

```lua
category:EnableDraggability()
category:DisableDraggability()
```

## Category & Section Methods
```lua
catOrSec:HideCollapseButton()
catOrSec:ShowCollapseButton()

catOrSec:Collapse()
catOrSec:Expand()
```

## Elements
All of these can be used with a category, (sub-)section
### Button
```lua
local button = catOrSec:CreateButton(TITLE, CALLBACK)
```
|TITLE|CALLBACK|
|--|--|
|(String)Title|(Function)Function called on click|

### Slider
```lua
local slider = catOrSec:CreateSlider(TITLE, CALLBACK,MIN,MAX,STEP,DYNAMIC,INITIAL)
```
|TITLE|CALLBACK|MIN|MAX|STEP|DYNAMIC|INITIAL|
|--|--|-|--|--|--|--|
|(String)Title|(Function)Function called on change|(Number)Minimum|(Number)Maximum|(Number)Step, default: 0.01|(Boolean)Whether callback is called while user slides, default: false|(Number)Initial value, default: MIN|

### Switch
```lua
local switch = catOrSec:CreateSwitch(TITLE, CALLBACK,INITIAL)
```
|TITLE|CALLBACK|INITIAL|
|--|--|--|
|(String)Title|(Function)Function called on toggle|(Boolean)Initial state, default: false|

### Color Picker
```lua
local colorPicker = catOrSec:CreateColorPicker(TITLE, CALLBACK,DYNAMIC,INITIAL)
```
|TITLE|CALLBACK|DYNAMIC|INITIAL|
|--|--|--|--|
|(String)Title|(Function)Function called on toggle|(Boolean)Whether callback is called while color is being picked.|(Color3)Initial color, default: Config.AccentColor|

### Selector / Dropdown Menu
```lua
local selector = catOrSec:CreateSelector(TITLE, CALLBACK,GETCALL,INITIAL)
```
|TITLE|CALLBACK|GETCALL|INITIAL|
|--|--|--|--|
|(String)Title|(Function)Function called on toggle|(Function)Function that returns a Table from which a element is picked |(Any)Initial , default: nil / empty|

### Selector / Dropdown Menu
```lua
local selector = catOrSec:CreateSelector(TITLE,CALLBACK,GETCALL,INITIAL)
```
|TITLE|CALLBACK|GETCALL|INITIAL|
|--|--|--|--|
|(String)Title|(Function)Function called on toggle|(Function)Function that returns a Table from which a element is picked |(Any)Initial , default: nil / empty|

### Text Label
```lua
local label = catOrSec:CreateLabel(TITLE, HEIGHT)
```
|TITLE|HEIGHT|
|--|--|
|(String)Title|(INTEGER)Height in pixels, default: Config.DefaultEntryHeight|

### Key Detector
```lua
local detector = catOrSec:CreateKeyDetector(TITLE,CALLBACK,INITIAL)
```
|TITLE|CALLBACK|INITIAL|
|--|--|--|
|(String)Title|(Function)Function called on change|(KeyCode)Initial, default: Enum.KeyCode.Unknown|

### Textbox
```lua
local textbox = catOrSec:CreateTextBox(TITLE,CALLBACK,ACCEPTFORMAT,DYNAMIC,INITIAL)
```
|TITLE|CALLBACK|ACCEPTFORMAT|DYNAMIC|INITIAL|
|--|--|--|--|--|
|(String)Title|(Function)Function called on change|(Pattern)Text has to match this pattern, default: ".+"/Accepts everything|(Boolean)Whether callback is called while user is typing|(String)Initial, default: ""/Empty text|