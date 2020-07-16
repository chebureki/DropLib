# DropLib
## What is it
DropLib is a simple, efficient and beautiful way to quickly build a GUI for your scripts

## Documentation
### Initialize
It is recommended that you keep a local copy of the script, so updates don't break anything and load times are fast
```lua
local gui = loadstring(game:HttpGet("https://gitlab.com/0x45.xyz/droplib/-/raw/master/drop-minified.lua"))()(CONFIG)
```
|CONFIG|
|--|
|(Table)[User-config](#Config) which overwrites the default config, default: empty table|

### Gui Methods
```lua
gui:CleanUp()
```
Removes everything

```lua
gui:UpdateGui()
```
Updates the gui based on the values in gui.Config

### Create Category / Section / SubSection
```lua
local category = gui:CreateCategory(TITLE, POSITION)
local section = category:CreateSection(TITLE)
local subsection = category:CreateSection(TITLE)
```
You can have as many nested sections as you want

|TITLE|POSITION|
|--|--|
|(String)Title|(UDim2)Initial position on screen, default: auto align|

### Category Methods
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

### Category & Section Methods
```lua
catOrSec:HideCollapseButton()
catOrSec:ShowCollapseButton()

catOrSec:Collapse()
catOrSec:Expand()
```

### Elements
All of these can be used with a category, (sub-)section

#### Get and Set
You don't always have to specify a callback function, you can get the value with:
```lua
element.Value
```
You can also set the value with
```lua
element:SetValue(VALUE)
```

#### Button
```lua
local button = catOrSec:CreateButton(TITLE, CALLBACK)
```
|TITLE|CALLBACK|
|--|--|
|(String)Title|(Function)Function called on click|

#### Slider
```lua
local slider = catOrSec:CreateSlider(TITLE, CALLBACK,MIN,MAX,STEP,DYNAMIC,INITIAL)
```
|TITLE|CALLBACK|MIN|MAX|STEP|DYNAMIC|INITIAL|
|--|--|-|--|--|--|--|
|(String)Title|(Function)Function called on change|(Number)Minimum|(Number)Maximum|(Number)Step, default: 0.01|(Boolean)Whether callback is called while user slides, default: false|(Number)Initial value, default: MIN|

#### Switch
```lua
local switch = catOrSec:CreateSwitch(TITLE, CALLBACK,INITIAL)
```
|TITLE|CALLBACK|INITIAL|
|--|--|--|
|(String)Title|(Function)Function called on toggle|(Boolean)Initial state, default: false|

#### Color Picker
```lua
local colorPicker = catOrSec:CreateColorPicker(TITLE, CALLBACK,DYNAMIC,INITIAL)
```
|TITLE|CALLBACK|DYNAMIC|INITIAL|
|--|--|--|--|
|(String)Title|(Function)Function called on toggle|(Boolean)Whether callback is called while color is being picked.|(Color3)Initial color, default: Config.AccentColor|

#### Selector / Dropdown Menu
```lua
local selector = catOrSec:CreateSelector(TITLE, CALLBACK,GETCALL,INITIAL)
```
|TITLE|CALLBACK|GETCALL|INITIAL|
|--|--|--|--|
|(String)Title|(Function)Function called on toggle|(Function)Function that returns a Table from which a element is picked |(Any)Initial , default: nil / empty|

#### Selector / Dropdown Menu
```lua
local selector = catOrSec:CreateSelector(TITLE,CALLBACK,GETCALL,INITIAL)
```
|TITLE|CALLBACK|GETCALL|INITIAL|
|--|--|--|--|
|(String)Title|(Function)Function called on toggle|(Function)Function that returns a Table from which a element is picked |(Any)Initial , default: nil / empty|

#### Text Label
```lua
local label = catOrSec:CreateLabel(TITLE, HEIGHT)
```
|TITLE|HEIGHT|
|--|--|
|(String)Title|(INTEGER)Height in pixels, default: Config.DefaultEntryHeight|

#### Key Detector
```lua
local detector = catOrSec:CreateKeyDetector(TITLE,CALLBACK,INITIAL)
```
|TITLE|CALLBACK|INITIAL|
|--|--|--|
|(String)Title|(Function)Function called on change|(KeyCode)Initial, default: Enum.KeyCode.Unknown|

#### Textbox
```lua
local textbox = catOrSec:CreateTextBox(TITLE,CALLBACK,ACCEPTFORMAT,DYNAMIC,INITIAL)
```
|TITLE|CALLBACK|ACCEPTFORMAT|DYNAMIC|INITIAL|
|--|--|--|--|--|
|(String)Title|(Function)Function called on change|(Pattern)Text has to match this pattern, default: ".+"/Accepts everything|(Boolean)Whether callback is called while user is typing|(String)Initial, default: ""/Empty text|

## Config
Default configuration (Under Development, alot is gonna change in the near future. Expect to redo your config), change anything to your liking:
```lua
Config.PrimaryColor = Color3.fromRGB(27, 38, 59)
Config.SecondaryColor = Color3.fromRGB(13, 27, 42)
Config.AccentColor = Color3.fromRGB(41, 115, 115)
Config.TextColor =  Color3.new(1,1,1)
Config.Font = Enum.Font.Gotham
Config.TextSize = 13
Config.HeaderWidth = 300
Config.HeaderHeight = 32
Config.EntryMargin = 1
Config.AnimationDuration = 0.4
Config.AnimationEasingStyle = Enum.EasingStyle.Quint
Config.DefaultEntryHeight = 35
```
