# OpenDiMet
Dimensional metrology toolbox to support the processing of coordinate data to perform dimensional measurements. <br>
Developed and maintained by the Berez lab group from the Center for Precision Metrology at UNC Charlotte. <br>
Development partially supported by the industrial affiliates of the Center for Precision Metrology. <br>
Contact: Jaime Berez, Asst. Professor | jberez@charlotte.edu
***
Version 0.1 (released 2025-11-18)
***
**Executables** <br>
Download OpenDiMetApp.exe to install an executable that includes MATLAB Runtime, enabling users without a MATLAB license to run the software through a UI.
***
**Software requirements** <br>
| Component | Requirement |
|:-------------:|--------------:|
| MATLAB        | R2024a+ (not tested on earlier versions)     |
| Toolboxes       | Statistics and Machine Learning Toolbox    | 
| Operating System | Windows, MacOS, Linux (Primarily tested on Windows) |
***
**Quick-start guide** <br>
For users with Git installed:
```bash
git clone https://github.com/jaime-berez/OpenDiMet.git
cd DimensionalMetrology
addpath(genpath(pwd))
```

Or optionally from MATLAB:
Right Click in Files section > Source Control > Clone Git Repository > Paste URL: https://github.com/jaime-berez/OpenDiMet.git <br>

For users without Git: <br>
Simply download the entire package and set the working directory in MATLAB.

**demo_fit_geometries_simple** is a demonstration script that walks users through basic functionalities of the toolbox.
