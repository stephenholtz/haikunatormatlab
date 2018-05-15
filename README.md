haikunatormatlab
================
Generate memorable names for instances, files, experiments etc. in MATLAB. This is modeled after the python port [haikunatorpy](https://github.com/Atrox/haikunatorpy).

## Installation
Simply add this repository to your MATLAB path using the IDE `Home>Set Path`. There is no need to include subfolders. Alternatively use the `addpath` function.

## Usage
There is only one Class `Haikunator` with one method `haikunate`. 

```
% Initalize and use current seed
h = Haikunator()

% Initalize with specified seed
h = Haikunator('seed',32)

% Standard useage
h.haikunate(); % = 'still-sun-8919'

% Use underscores as delimiter
h.haikunate('delimiter','_'); % = 'orange_morning_5786'

% Use hex token
h.haikunate('token_hex',true); % = 'lively-hill-6b04'

% Change token_chars
h.haikunate('token_chars','HAIKUNATOR'); % 'lucky-king-UHNU'
```

## Other Languages

Haikunator is also available in other languages. Check them out:

- Python: https://github.com/Atrox/haikunatorpy
- Node: https://github.com/Atrox/haikunatorjs
- .NET: https://github.com/Atrox/haikunator.net
- PHP: https://github.com/Atrox/haikunatorphp
- Java: https://github.com/Atrox/haikunatorjava
- Go: https://github.com/Atrox/haikunatorgo
- Dart: https://github.com/Atrox/haikunatordart
- Ruby: https://github.com/usmanbashir/haikunator
- Rust: https://github.com/nishanths/rust-haikunator
