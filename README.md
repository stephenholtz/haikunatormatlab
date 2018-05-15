haikunatormatlab
================
Generate memorable names for instances, files, experiments etc. in MATLAB. This is modeled after the python port [haikunatorpy](https://github.com/Atrox/haikunatorpy).

## Installation
Simply add this repository to your MATLAB path using the IDE `Home>Set Path`. There is no need to include subfolders. Alternatively use the `addpath` function.

## TODO
- Add examples

## Usage
There is only one Class `Haikunator` with one method `haikunate`. 

```
% Initalize and use current seed
h = Haikunator()

% Initalize with specified seed
h = Haikunator('seed',32)

% Standard useage
h.haikunate(); %  = 'green-frog-3716'

```
